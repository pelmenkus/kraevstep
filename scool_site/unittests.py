from requests import DB
import unittest

class Testdb(unittest.TestCase):

    @classmethod
    def setUpClass(cls) -> None:
        cls.db = DB()

    @classmethod
    def tearDownClass(cls) -> None:
        cls.db.DbClose()

    def setUp(self):
        self.db.newCursor()

    def tearDown(self):
        self.db.closeCursor()

    def test1(self):
        res=[(3,)]
        self.assertEqual(res,self.db.get1())

    def test2(self):
        res=[('2020',), ('2005',)]
        self.assertEqual(res,self.db.get2())

    def test3(self):
        res=[('klown',)]
        self.assertEqual(res,self.db.get3())

if __name__ == '__main__':
    unittest.main()