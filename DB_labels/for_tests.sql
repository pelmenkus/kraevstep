/* testim */

USE TravelAgensy;
GO

-- Удаляем таблицу, если она есть
IF OBJECT_ID('Ticket', 'U') IS NOT NULL
    DROP TABLE Ticket;
GO

-- Создаём таблицу с IDENTITY
CREATE TABLE Ticket
(
    TicketNumber BIGINT IDENTITY(1,1) PRIMARY KEY,
    CruiseID INT NOT NULL
);
GO


-- Включаем возможность вставки вручную
SET IDENTITY_INSERT Ticket ON;

INSERT INTO Ticket (TicketNumber, CruiseID)
VALUES (100, 3);  -- вставляем своё значение в IDENTITY

SET IDENTITY_INSERT Ticket OFF;
select * from Ticket;
go


