from requests import DB
import unittest

class TestTable(unittest.TestCase):

    @classmethod
    def setupClass(cls) -> None:
        cls.db = DB("basadannih.db")

    @classmethod
    def TearDownClass(cls) -> None:
        cls.db.DbClose()

    def SetUp(self):
        self.db.newCursor()

    def tearDown(self):
        self.db.closeCursor()

    def test1(self):
        res=[('klown',)]
        self.assertEqual(res,self.db.get3())

if __name__ == '__main__':
    unittest.main()