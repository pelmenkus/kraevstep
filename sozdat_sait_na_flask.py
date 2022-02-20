from flask import *
from ORM import *
from init import *

@app.route('/')
def main_page():
    return render_template("glavnaya.html")

@app.route('/katalog')
def katalog_page():
    return render_template("katalog.html")

@app.route('/stim')
def loginsteam():
    return render_template("stim.html")

@app.route('/knife')
def item1():
    return render_template("knife.html")

@app.route('/avik')
def item2():
    return render_template("avik.html")

@app.route('/kalash')
def item3():
    return render_template("kalash.html")

@app.route('/SDOskam')
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

app.run(debug=True)