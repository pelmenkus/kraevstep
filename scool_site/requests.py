import sqlite3

class DB:
    def __init__(self):
        self.connection = sqlite3.connect("basadannih.db")

    def newCursor(self):
        self.cursor = self.connection.cursor()

    def closeCursor(self):
        self.cursor.close()

    def test_connection(self):
        query = ('''
        SELECT SteamLogin FROM Users
        ''')
        self.cursor.execute(query)
        result = self.cursor.fetchall()
        for res in result:
            print(res)

    def DbClose(self):
        self.connection.close()

    def get1(self):
        zap1 = ('''SELECT count(*) AS total_items  FROM Items''')
        self.cursor.execute(zap1)
        return self.cursor.fetchall()

    def get2(self):
        zap2 = ('''SELECT DISTINCT(substr(RegistrationDate, 1, 4)) FROM USERS''')
        self.cursor.execute(zap2)
        return self.cursor.fetchall()

    def get3(self):
        zap3 = ('''SELECT SteamLogin FROM Users
        WHERE RegistrationDate = (SELECT MAX(RegistrationDate) FROM Users)''')
        self.cursor.execute(zap3)
        return self.cursor.fetchall()

