import os

from flask import Flask


app = Flask(__name__)

@app.route('/')
def index():
    if "MSG" in os.environ:
        return os.environ["MSG"]
    return "Coucou"
