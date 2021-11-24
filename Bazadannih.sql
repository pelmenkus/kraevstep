
CREATE TABLE "Users" (
	"UserId"	INTEGER NOT NULL UNIQUE,
	"SteamLogin"	TEXT NOT NULL,
	"SteamPass"	INTEGER NOT NULL,
	"SteamURL"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("UserId" AUTOINCREMENT)
);




CREATE TABLE "ShopingKart" (
	"ID"	INTEGER NOT NULL UNIQUE,
	"UserID"	INTEGER NOT NULL,
	"ItemID"	INTEGER NOT NULL,
	PRIMARY KEY("ID" AUTOINCREMENT)
);



CREATE TABLE "Items" (
	"ItemID"	INTEGER NOT NULL UNIQUE,
	"Price"	INTEGER NOT NULL,
	"ItemName"	INTEGER NOT NULL,
	"inAbility"	INTEGER NOT NULL,
	PRIMARY KEY("ItemID" AUTOINCREMENT)
);



INSERT INTO Users (UserId, SteamLogin, SteamPass) VALUES (1, 'klown', 123456);
INSERT INTO Users (UserId, SteamLogin, SteamPass) VALUES (2, 'test', 123456);
INSERT INTO Users (UserId, SteamLogin, SteamPass) VALUES (3, 'tested', 123456);


INSERT INTO Items (ItemID, Price, ItemName, inAbility) VALUES (1, 3500, 'AWP', 1);
INSERT INTO Items (ItemID, ItemName, Price, inAbility) VALUES (2, 'GUT Knife', 9000, 1);
INSERT INTO Items (ItemID, ItemName, Price, inAbility) VALUES (3, 'AK-47', 6000, 1);


INSERT INTO ShopingKart (ID, UserId, ItemID) VALUES (1, 1,3);
INSERT INTO ShopingKart (ID, UserId, ItemID) VALUES (2, 3,2);
INSERT INTO ShopingKart (ID, UserId, ItemID) VALUES (3, 2,3);