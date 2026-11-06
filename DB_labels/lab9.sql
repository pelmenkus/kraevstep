USE master

DROP DataBase TravelAgensy;
GO
CREATE DataBase TravelAgensy;
GO

USE TravelAgensy;
GO

-- ---------- Cleanup ----------
IF OBJECT_ID('vw_CruiseRoute', 'V') IS NOT NULL DROP VIEW vw_CruiseRoute;
GO
IF OBJECT_ID('Cruise_Route', 'U') IS NOT NULL DROP TABLE Cruise_Route;
GO
IF OBJECT_ID('Cruise', 'U') IS NOT NULL DROP TABLE Cruise;
GO
IF OBJECT_ID('Route', 'U') IS NOT NULL DROP TABLE Route;
GO
GO

-- ---------- Create base tables ----------
CREATE TABLE Route
(
    route_id INT IDENTITY(1,1) PRIMARY KEY,
    city_in NVARCHAR(100) NOT NULL,
    city_out NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE Cruise
(
    cruise_id INT IDENTITY(1,1) PRIMARY KEY,
    [length] INT NOT NULL DEFAULT 1,                -- длительность/дальность/дл. круиза
    state_in NVARCHAR(100) NOT NULL,           -- дата/время начала
    state_out NVARCHAR(100) NOT NULL,          -- дата/время окончания
    ticket_price MONEY NOT NULL CHECK (ticket_price >= 0)
);
GO

-- промежуточная таблица для жёсткой связи 1:1
CREATE TABLE Cruise_Route
(
    cruise_id INT Unique,
    route_id INT Unique,
    Primary Key (cruise_id, route_id),  -- PK + FK -> Route (1:1)
    CONSTRAINT FK_CR_Cruise FOREIGN KEY (cruise_id) REFERENCES Cruise(cruise_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_CR_Route  FOREIGN KEY (route_id)  REFERENCES Route(route_id)  ON DELETE CASCADE ON UPDATE CASCADE
);
-- Примечание: каждая запись в Cruise_Route содержит обе PK — это обеспечивает 1:1 (один cruise связан с одним route).
GO

-- ---------- Create view combining Cruise + Route ----------
CREATE VIEW vw_CruiseRoute
AS
SELECT
    c.cruise_id,
    c.[length],
    c.state_in,
    c.state_out,
    c.ticket_price,
    r.route_id,
    r.city_in,
    r.city_out
FROM Cruise c
JOIN Cruise_Route cr ON c.cruise_id = cr.cruise_id
JOIN Route r         ON r.route_id = cr.route_id;
GO

-- ---------- TRIGGERS on Cruise (table) ----------
-- Требование: создать триггеры на INSERT, UPDATE, DELETE (один должен бросать ошибку при выполнении условия).

-- 1) INSERT trigger: запрещаем вставлять круиз с нулевой или отрицательной ценой (THROW)
IF OBJECT_ID('trg_Cruise_Insert', 'TR') IS NOT NULL DROP TRIGGER trg_Cruise_Insert;
GO
CREATE TRIGGER trg_vw_CruiseRoute_Update
ON vw_CruiseRoute
INSTEAD OF UPDATE
AS
BEGIN
    -- запрещаем менять ключи
    IF UPDATE(cruise_id) OR UPDATE(route_id)
        THROW 51003, 'Cannot change keys in 1-to-1 relation', 1;

    -- Cruise
    UPDATE c
    SET ticket_price = i.ticket_price
    FROM Cruise c
    JOIN inserted i ON c.cruise_id = i.cruise_id;

    -- Route
    UPDATE r
    SET city_in = i.city_in,
        city_out = i.city_out
    FROM Route r
    JOIN inserted i ON r.route_id = i.route_id;
END;
GO


-- 2) UPDATE trigger: запрещаем менять cruise_id (PK) и запрещаем сделать ticket_price < 0
IF OBJECT_ID('trg_Cruise_Update', 'TR') IS NOT NULL DROP TRIGGER trg_Cruise_Update;
GO
CREATE TRIGGER trg_Cruise_Update
ON Cruise
AFTER UPDATE
AS
BEGIN
    -- запрещаем изменение PK (cruise_id) через UPDATE (обычно невозможно, но на всякий случай)
    IF UPDATE(cruise_id)
    BEGIN
        ;THROW 51011, 'Changing cruise_id is not allowed.', 1;
    END

    -- запрещаем устанавливать отрицательную цену
    IF EXISTS (SELECT 1 FROM inserted WHERE ticket_price < 0)
    BEGIN
        ;THROW 51012, 'ticket_price cannot be negative.', 1;
    END

    -- допустимые изменения (другие поля) — выполняются автоматически
END;
GO

-- 3) DELETE trigger: запрещаем удалять круиз (триггер, который всегда кидает ошибку)
IF OBJECT_ID('trg_Cruise_Delete', 'TR') IS NOT NULL DROP TRIGGER trg_Cruise_Delete;
GO
CREATE TRIGGER trg_Cruise_Delete
ON Cruise
INSTEAD OF DELETE
AS
BEGIN
    -- В данном варианте удаление круизов запрещено
    ;THROW 51013, 'Deleting cruises is impossible.', 1;
END;
GO


-- INSTEAD OF INSERT, UPDATE, DELETE on view — выполнять изменения в Cruise, Route и Cruise_Route.

-- INSTEAD OF INSERT on view: вставляем Route, затем Cruise, затем связь Cruise_Route.
IF OBJECT_ID('trg_vw_CruiseRoute_Insert', 'TR') IS NOT NULL DROP TRIGGER trg_vw_CruiseRoute_Insert;
GO
CREATE TRIGGER trg_vw_CruiseRoute_Insert
ON vw_CruiseRoute
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Проверки
    IF EXISTS (SELECT 1 FROM inserted WHERE ticket_price <= 0)
        THROW 51020, 'ticket_price must be > 0', 1;

    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE [length] IS NULL OR state_in IS NULL OR state_out IS NULL
    )
        THROW 51021, 'Required fields are NULL', 1;

    -- 2. Таблицы для сопоставления
    DECLARE @Routes TABLE (
        rn INT,
        route_id INT
    );

    DECLARE @Cruises TABLE (
        rn INT,
        cruise_id INT
    );

    -- 3. Нумеруем inserted
    ;WITH ins AS (
        SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) rn
        FROM inserted
    )
    
    -- 4. Вставляем Route
    INSERT INTO Route (city_in, city_out)
    OUTPUT ins.rn, inserted.route_id INTO @Routes(rn, route_id)
    SELECT city_in, city_out
    FROM ins;

    -- 5. Вставляем Cruise
    INSERT INTO Cruise ([length], state_in, state_out, ticket_price)
    OUTPUT ins.rn, inserted.cruise_id INTO @Cruises(rn, cruise_id)
    SELECT [length], state_in, state_out, ticket_price
    FROM ins;

    -- 6. Связываем
    INSERT INTO Cruise_Route (cruise_id, route_id)
    SELECT c.cruise_id, r.route_id
    FROM @Cruises c
    JOIN @Routes r ON c.rn = r.rn;

END;
GO

-- INSTEAD OF UPDATE on view: обновляем поля Cruise и Route (но запрещаем менять PKs)
IF OBJECT_ID('trg_vw_CruiseRoute_Update', 'TR') IS NOT NULL DROP TRIGGER trg_vw_CruiseRoute_Update;
GO
CREATE TRIGGER trg_vw_CruiseRoute_Update
ON vw_CruiseRoute
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- запрещаем изменение PK полей через view
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.cruise_id = d.cruise_id
        WHERE i.cruise_id <> d.cruise_id
           OR i.route_id <> d.route_id
    )
    BEGIN
        ;THROW 51021, 'Cannot change cruise_id or route_id through the view.', 1;
    END

    -- запрещаем установить некорректную цену
    IF EXISTS (SELECT 1 FROM inserted WHERE ticket_price < 0)
    BEGIN
        ;THROW 51022, 'ticket_price cannot be negative.', 1;
    END

    -- Обновляем Cruise
    UPDATE c
    SET
        c.[length] = i.[length],
        c.state_in = i.state_in,
        c.state_out = i.state_out,
        c.ticket_price = i.ticket_price
    FROM Cruise c
    JOIN inserted i ON c.cruise_id = i.cruise_id;

    -- Обновляем Route
    UPDATE r
    SET
        r.city_in = i.city_in,
        r.city_out = i.city_out
    FROM Route r
    JOIN inserted i ON r.route_id = i.route_id;
END;
GO

-- INSTEAD OF DELETE on view: удаляем связь, а затем удаляем Cruise и Route (если нужно)
IF OBJECT_ID('trg_vw_CruiseRoute_Delete', 'TR') IS NOT NULL DROP TRIGGER trg_vw_CruiseRoute_Delete;
GO
CREATE TRIGGER trg_vw_CruiseRoute_Delete
ON vw_CruiseRoute
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Для каждой удаляемой строки: удаляем связь (Cruise_Route), затем Cruise и Route.
    -- Если нужно оставить Cruise/Route — можно изменить логику; в этой реализации удаляем всё.
    DELETE FROM Cruise_Route WHERE cruise_id IN (SELECT cruise_id FROM deleted);

    DELETE FROM Cruise WHERE cruise_id IN (SELECT cruise_id FROM deleted);

    DELETE FROM Route WHERE route_id IN (SELECT route_id FROM deleted);
END;
GO

-- ---------- Testing ----------
PRINT '--- TESTS START ---';

-- 1) корректная вставка напрямую в таблицы
INSERT INTO Route (city_in, city_out) VALUES (N'Гавань A', N'Гавань B');
INSERT INTO Cruise ([length], state_in, state_out, ticket_price)
VALUES (7, GETDATE(), DATEADD(day,7,GETDATE()), 500.00);
INSERT INTO Cruise_Route (cruise_id, route_id) VALUES (1, 1);
PRINT 'Inserted base cruise & route.';
GO

-- 2) Попытка вставить через view с некорректной ценой -> должно THROW (trg_vw_CruiseRoute_Insert)
PRINT 'TEST: insert via view with ticket_price = 0 (expect THROW)';
BEGIN TRY
    INSERT INTO vw_CruiseRoute 
    (state_in, state_out, ticket_price, city_in, city_out)
    VALUES 
    (1, 2, 100, N'X', N'Y');
END TRY
BEGIN CATCH
    PRINT 'Caught error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 3) Попытка удалить cruise напрямую -> trg_Cruise_Delete должен THROW
PRINT 'TEST: delete cruise directly (expect THROW)';
BEGIN TRY
    DELETE FROM Cruise WHERE cruise_id = 1;
END TRY
BEGIN CATCH
    PRINT 'Caught error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 4) Попытка вставить корректно через view -> должно создать Route, Cruise и связь
PRINT 'TEST: insert via view correct';
BEGIN TRY
    INSERT INTO vw_CruiseRoute ([length], state_in, state_out, ticket_price, city_in, city_out)
    VALUES (5, GETDATE(), DATEADD(day,5,GETDATE()), 250.00, N'CityIn1', N'CityOut1');
    PRINT 'Insert via view succeeded.';
END TRY
BEGIN CATCH
    PRINT 'Caught error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 5) Попытка обновить через view (обновим цену) -> trg_vw_CruiseRoute_Update
PRINT 'TEST: update via view (change ticket_price)';
BEGIN TRY
    -- обнаружим только что добавленный cruise: берём max(cruise_id)
    DECLARE @cid INT = (SELECT MAX(cruise_id) FROM Cruise);
    UPDATE vw_CruiseRoute
    SET ticket_price = 300.00
    WHERE cruise_id = @cid;
    PRINT 'Update via view succeeded.';
END TRY
BEGIN CATCH
    PRINT 'Caught error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 6) Попытка обновить через view PK -> должно THROW
PRINT 'TEST: update via view change cruise_id (expect THROW)';
BEGIN TRY
    DECLARE @cid2 INT = (SELECT MAX(cruise_id) FROM Cruise);
    UPDATE vw_CruiseRoute
    SET cruise_id = @cid2 + 100
    WHERE cruise_id = @cid2;
END TRY
BEGIN CATCH
    PRINT 'Caught error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 7) Посмотрим содержимое таблиц
PRINT 'Cruise:';
SELECT * FROM Cruise;
PRINT 'Route:';
SELECT * FROM Route;
PRINT 'Cruise_Route:';
SELECT * FROM Cruise_Route;
PRINT 'vw_CruiseRoute:';
SELECT * FROM vw_CruiseRoute;
GO

PRINT 'TEST: multi insert';

INSERT INTO vw_CruiseRoute (cruise_id, ticket_price, route_id, city_in, city_out, [length], state_in, state_out)
VALUES 
(SCOPE_IDENTITY(), 100, 10, 'A', 'B', 15, 'ANAPA', 'Cochi'),
(SCOPE_IDENTITY(), 200, 20, 'C', 'D', 17, 'Havai', 'Bahamas');
GO

PRINT 'TEST: multi insert incorrect';

INSERT INTO vw_CruiseRoute (cruise_id, ticket_price, route_id, city_in, city_out)
VALUES 
(6, 100, 10, 'E', 'F'),
(3, -1, 20, 'H', 'G');
GO

PRINT '--- TESTS END ---';
GO
