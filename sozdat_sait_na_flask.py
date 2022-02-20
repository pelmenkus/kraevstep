from flask import *

app = Flask(__name__)

@app.route('/')
def main_page():
    return render_template("glavnaya.html")

@app.route('/katalog')
def katalog_page():
    return render_template("katalog.html")

@app.route('/stim')
def loginsteam():
    return render_template("stim.html")

@app.route('/otzovik')
def usless_page():
    return render_template("otzovik.html")

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

app.run(debug=True)