UPDATE Users
SET RegistrationDate = substr(RegistrationDate, 7, 4) || '-' || substr(RegistrationDate, 4, 2) || '-' || substr(RegistrationDate, 1, 2);

SELECT SteamLogin FROM Users
WHERE RegistrationDate = (SELECT MAX(RegistrationDate) FROM Users);


SELECT DISTINCT(substr(RegistrationDate, 1, 4)) FROM USERS;

SELECT count(*) AS total_items  FROM Items;

SELECT AVG(date('now') - RegistrationDate) FROM Users
WHERE date('now', '-2 months') >= RegistrationDate;