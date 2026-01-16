from flask import Flask, render_template, request, redirect
from db import Database
import api

app = Flask(__name__)
# session["logged_in"] = 0
dbo = Database()


@app.route("/")
def index():
    return render_template("login.html")


@app.route("/register")
def register():
    return render_template("register.html")


@app.route("/perform_registration", methods=["post"])
def perform_registration():
    name = request.form.get("user_name")
    email = request.form.get("user_email")
    password = request.form.get("user_password")

    response = dbo.insert(name, email, password)

    if response:
        return render_template(
            "login.html", message="Registration successful! Please Login to Proceed."
        )
    else:
        return render_template("register.html", message="Email already exists.")


@app.route("/perform_login", methods=["post"])
def perform_login():
    email = request.form.get("user_email")
    password = request.form.get("user_password")

    response = dbo.search(email, password)
    if response:
        # session["logged_in"] = 1
        return redirect("/profile")  # function used to redirect to another route
    else:
        return render_template("login.html", message="Incorrect email/password")


@app.route("/profile")
def profile():
    if session:
        return render_template("profile.html")
    else:
        return redirect("/")


@app.route("/ner")
def ner():
    if session:
        return render_template("ner.html")
    else:
        return redirect("/")


@app.route("/perform_ner", methods=["post"])
def perform_ner():
    if session:
        text = request.form.get("text")
        response = api.ner(text)
        return render_template("ner.html", ner_response=response)
    else:
        return redirect("/")


app.run(debug=True, port=4949)
