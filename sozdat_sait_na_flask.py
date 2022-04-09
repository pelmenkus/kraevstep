import sqlalchemy
from flask import *
from ORM import *
from run import *

@app.route("/404")
def render_404():
    return render_template("404.html")

@app.route('/')
def main_page():
    return render_template("glavnaya.html")

@app.route('/katalog')
def katalog_page():
    return render_template("katalog.html")

@app.route('/login', methods=["GET", "POST"])
def render_login():
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
def render_logout():
    if session.get("login"):
        session.pop("login")
        flash("Вы вышли из аккаунта", "success")
    return redirect("/", code=302)

@app.route('/products/<item>', methods=['GET', 'POST'])
def render_coffee(item):
    if request.method == 'POST':
        if session.get('login') is not None:
            user = Users.query.filter(Users.user==session.get('login')).one()
            product = get_product_by_url(item)
            if user:
                quantity = request.form.get('quantity')
                if get_product_by_url(coffee).amount >= int(quantity):
                    cartitem = None
                    try:
                        cartitem = CartItem.query.filter(sqlalchemy.and_(Cart.product_name==product.name, Cart.is_visible==True)).one()
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