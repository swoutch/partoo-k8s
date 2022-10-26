import os

import flask


app = flask.Flask(__name__)

@app.route('/')
def index():
    if "MSG" in os.environ:
        return os.environ["MSG"]
    return "Coucou"
