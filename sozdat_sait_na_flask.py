import sqlalchemy
from flask import *
from ORM import *
from run import *

@app.route("/404")
def r404():
    return render_template("404.html")

@app.route('/')
def main_page():
    return render_template("glavnaya.html")

@app.route('/katalog')
def katalog_page():
    return render_template("katalog.html", items=get_products())

@app.route('/login', methods=["GET", "POST"])
def login():
    if request.method == "POST":
        login = request.form.get("login")
        password = request.form.get("password")
        print(login, password)
        try:
            if Users.query.filter(Users.user == login).one().validate(password):
                session["login"] = login
                return redirect('/', code=301)
            flash("Неправильный пароль", "warning")
        except sqlalchemy.exc.NoResultFound:
            flash("Неправильный логин", "warning")
    return render_template("stim.html")

@app.route("/logout")
def logout():
    if session.get("login"):
        session.pop("login")
        flash("Вы вышли из аккаунта", "success")
    return redirect("/", code=302)

@app.route('/products/<item>', methods=['GET', 'POST'])
def items(item):
    if request.method == 'POST':
        if session.get('login') is not None:
            user = Users.query.filter(Users.user==session.get('login')).one()
            product = get_product_by_url(item)
            print(product)
            if user:
                quantity = request.form.get('quantity')
                if get_product_by_url(item).inability >= int(quantity):
                    cartitem = None
                    try:
                        cartitem = Cart.query.filter(sqlalchemy.and_(Cart.product_name==product.name, Cart.is_visible==True)).one()
                        cartitem.inc_amount(int(quantity))
                    except sqlalchemy.exc.NoResultFound:
                        cartitem = Cart(
                            user_id=user.id,
                            product_name=product.name,
                            price=product.price,
                            amount=quantity
                        )

                    product.dec_amount(int(quantity))
                    db.session.add(cartitem)
                    db.session.commit()

                    flash('Товар добавлен в корзину', 'success')
                else:
                    flash('Недостаточно товара на складe', 'warning')
                    
            return render_template("item.html", item=get_product_by_url(item))

        flash('Пожалуйста, войдите в свой аккаунт, чтобы продолжить', 'warning')
    return render_template("item.html", item=get_product_by_url(item))

@app.route('/<login>', methods=['GET', 'POST'])
def profile(login):
    if session.get('login') == login:
        print('here')
        user = Users.query.filter(Users.user == login).one()
        if request.method == 'POST':
            old_password = request.form.get('old_password')
            new_password = request.form.get('new_password')

            if old_password:
                if user.validate(old_password):
                    user.set_password(new_password)
                    flash('Пароль изменен', 'success')
                    db.session.add(user)
                    db.session.commit()
                elif new_password == None:
                    flash('Новый пароль пуст', 'warning')
                else:
                    flash('Старый пароль неверен', 'warning')
        return render_template('profile.html', user=user, cart=get_cart_for_user(user.id), total_price=get_total_price_for_user(user.id))
        
    flash('Пожалуйста, войдите в свой аккаунт, чтобы продолжить', 'warning')
    return redirect('/login', code=301)

@app.route('/buy/<login>', methods=['POST', 'GET'])
def buy(login):
    if session.get('login') == login:
        print('here')
        user = Users.query.filter(Users.user == session.get('login')).one()
        
        disable_cart_for_user(user.id)
    
        flash('Спасибо за покупку!', 'success')   

    return redirect('/katalog')

@app.route('/SDOskam.html')
def sdo():
    return render_template("SDOskam.html")

@app.route('/otzovik', methods=['GET', 'POST'])
def about():
    feedback = Feedback.query.all()
    if request.method == 'POST':
        login = request.form.get('login')
        text = request.form.get('text')
        if login != '' and text != '':
            f = Feedback(name=login, text=text)
            db.session.add(f)
            db.session.commit()
            feedback.append(f)
    print(feedback)
    return render_template('otzovik.html', feedback=feedback)