from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from init import *
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
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

class Feedback(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    text = db.Column(db.String(256))

    def __repr__(self):
        return f'{self.id} {self.text}'

class Cart(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey(User.id), nullable=False)
    product_name = db.Column(db.Integer, db.ForeignKey(Product.id), nullable=False)
    price = db.Column(db.Integer, nullable=False)
    amount = db.Column(db.Integer, nullable=False)
    date_created = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    is_visible = db.Column(db.Boolean, default=True)

    user = db.relationship('User', backref=db.backref('Cart', lazy=False))
    product = db.relationship('Product', backref=db.backref('Cart', lazy=False))

    def __repr__(self):
        return f'{self.id}'

    def inc_amount(self, amount):
        self.amount += amount

    def update_visibility(self):
        self.is_visible = False




