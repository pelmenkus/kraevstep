SELECT
(SELECT SteamLogin FROM Users WHERE Id = UserId) AS user_name,
ItemID FROM ShopingKart



SELECT
(SELECT SteamLogin FROM Users WHERE Id = UserId) AS user_name,
(SELECT ItemName FROM Items WHERE Id = ItemID) AS chto_kupil,
ItemID FROM ShopingKart


SELECT
(SELECT SteamLogin FROM Users WHERE Id = UserId) AS user_name,
(SELECT ItemName FROM Items WHERE Id = ItemID) AS chto_kupil,
(SELECT SteamURL FROM Users WHERE Id = UserId) AS kuda_otpravit,
ItemID FROM ShopingKart


SELECT
(SELECT SteamLogin FROM Users WHERE SteamLogin = 'tested') AS user_name,
(SELECT ItemID FROM ShopingKart WHERE ShopingKart.UserId =  (SELECT UserId FROM Users WHERE SteamLogin = 'tested')) AS chto_kupil,
(SELECT SteamURL FROM Users WHERE  SteamLogin = 'tested') AS URL;



SELECT
(SELECT SteamLogin FROM Users WHERE SteamLogin = 'tested') AS user_name,
(SELECT ItemID FROM ShopingKart WHERE ShopingKart.UserId =  (SELECT UserId FROM Users WHERE SteamLogin = 'tested')) AS chto_kupil_id,
(SELECT SteamURL FROM Users WHERE  SteamLogin = 'tested') AS URL,
(SELECT ItemName FROM Items where Items.ItemID = (SELECT ItemID FROM ShopingKart WHERE ShopingKart.UserId =  (SELECT UserId FROM Users WHERE SteamLogin = 'tested'))) AS chto_kupil;
