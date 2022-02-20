from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__) # объект приложения Flask
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db' # привязываем базу данных
db = SQLAlchemy(app)

class Items(db.Model):
    id = db.Column(db.Integer, unique=True, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    price = db.Column(db.Integer, nullable=False)
    inability = db.Column(db.Integer, nullable=False)

    def __repr__(self):
        return f'itemcheck {self.name} {self.price}'

class ShopingCard(db.Model):
    id = db.Column(db.Integer, unique=True, primary_key=True)
    item = db.Column(db.Integer, db.ForeignKey(Items.id), nullable=False)
    item_id = db.relationship('Items', backref=db.backref('ShopingCard', lazy=False))

    def __repr__(self):
        return f'user-card {self.id} {self.item}'

class Users(db.Model):
    id = db.Column(db.Integer, unique=True, primary_key=True)
    user = db.Column(db.Integer, db.ForeignKey(ShopingCard.id), nullable=False, unique=True)
    user_id = db.relationship('ShopingCard', backref=db.backref('Users', lazy=False))
    steamlogin = db.Column(db.String(80), nullable=False)
    steamURL = db.Column(db.String(100), nullable=False, unique=True)
    Balance = db.Column(db.Integer)

    def __repr__(self):
        return f'{self.id} {self.steamlogin}'

db.create_all()

user = Users(user= 1, steamlogin="klown", steamURL='fgdjfkhsaf', Balance=100)
user2 = Users(user= 2, steamlogin="maksim_durak", steamURL='fgdjfkhsasffgafqfqfqfaf', Balance=500)
it1 = Items(name='AWP | POW', price=5400, inability=1)
it2 = Items(name='KNIFE | LORE', price=10000, inability=1)
pokupka= ShopingCard(id=1, item=1)
pokupka2= ShopingCard(id=2, item=2)



db.session.add(user)
db.session.add(user2)
db.session.add(it1)
db.session.add(it2)
db.session.add(pokupka)
db.session.add(pokupka2)

db.session.commit()

print(Users.query.all())
print(Items.query.all())



