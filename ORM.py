from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import hashlib, datetime, os
from run import *

class Items(db.Model):
    id = db.Column(db.Integer, unique=True, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    price = db.Column(db.Integer, nullable=False)
    inability = db.Column(db.Integer, nullable=False)
    photo_url = db.Column(db.String, nullable=False)

    def __repr__(self):
        return f'itemcheck {self.name} {self.price}'
    
    def dec_amount(self, quantity):
        self.inability -= quantity

class Users(db.Model):
    id = db.Column(db.Integer, unique=True, primary_key=True)
    user = db.Column(db.String(80), nullable=False, unique=True)
    password = db.Column(db.String(80), nullable=False)
    steamURL = db.Column(db.String(100), nullable=False, unique=True)
    Balance = db.Column(db.Integer, default=0)

    def __repr__(self):
        return f'{self.id} {self.steamlogin}'

    def validate(self, password):
        return self.password == hashlib.md5(password.encode("utf8")).hexdigest()

    def set_password(self, password):
        self.password = hashlib.md5(password.encode('utf8')).hexdigest()


class Cart(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey(Users.id), nullable=False)
    product_name = db.Column(db.Integer, db.ForeignKey(Items.id), nullable=False)
    price = db.Column(db.Integer, nullable=False)
    amount = db.Column(db.Integer, nullable=False)
    date_created = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    is_visible = db.Column(db.Boolean, default=True)

    user = db.relationship('Users', backref=db.backref('Cart', lazy=False))
    product = db.relationship('Items', backref=db.backref('Cart', lazy=False))

    def __repr__(self):
        return f'{self.id}'

    def inc_amount(self, amount):
        self.amount += amount

    def update_visibility(self):
        self.is_visible = False

class Feedback(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    text = db.Column(db.String(256))

    def __repr__(self):
        return f'{self.id} {self.text}'

def init():
    avik = Items(
        name='AWP | Азимов',
        price=3500,
        inability=100,
        photo_url='azik.jpg'
    )
    kalash = Items(
        name='st. AK-47 | Аквамариновая месть',
        price=6000,
        inability=100,
        photo_url='kalash.jpg'
    )
    knife = Items(
        name='Нож с лезвием-крюком | Гамма-волны',
        price=10000,
        inability=100,
        photo_url='knife.jpg'
    )
    basic_user = Users(
        user='admin',
        password='',
        steamURL='123',
    )
    basic_user.set_password('12345678')

    db.session.add(basic_user)
    db.session.add(avik)
    db.session.add(kalash)
    db.session.add(knife)
    db.session.commit()
    
def create_db():
    db.create_all()

def get_product_by_url(name):
    return Items.query.filter(Items.photo_url == name + '.jpg').one()

def get_product_id_by_url(name):
    return Items.query.filter(Items.photo_url == name + '.jpg').one().id

def get_products():
    return Items.query.all()

def get_reviews():  
    return Feedback.query.all()

def get_cart_for_user(user_id):
    return Cart.query.filter(Users.id == user_id)

def disable_cart_for_user(user_id):
    cart = get_cart_for_user(user_id)
    for cart_item in cart:
        cart_item.update_visibility()
        db.session.add(cart_item)
    db.session.commit()

def get_total_price_for_user(user_id):
    cart = get_cart_for_user(user_id)
    total_price = 0
    for cart_item in cart:
        if cart_item.is_visible:
            total_price += cart_item.amount * cart_item.price
    return total_price