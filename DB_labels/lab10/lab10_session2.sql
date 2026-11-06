USE TravelAgensy;
GO

/* =======================================================
   1. READ UNCOMMITTED (Dirty Read)
   ======================================================= */

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT *
FROM Ticket
WHERE TicketNumber = 1;
GO


/* =======================================================
   2. READ COMMITTED (ожидание)
   ======================================================= */

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM Ticket
WHERE TicketNumber = 1;
GO


/* =======================================================
   3. Попытка изменения при REPEATABLE READ
   ======================================================= */

UPDATE Ticket
SET CruiseID = 55
WHERE TicketNumber = 1;
GO


/* =======================================================
   4. Попытка INSERT при SERIALIZABLE
   ======================================================= */

INSERT INTO Ticket (CruiseID, PassportNum)
VALUES (3, 2000);
GO


/* =======================================================
   Просмотр блокировок
   ======================================================= */

SELECT 
    request_session_id AS SessionID,
    resource_type AS ResourceType,
    request_mode AS LockMode,
    request_status AS LockStatus
FROM sys.dm_tran_locks;
GO
