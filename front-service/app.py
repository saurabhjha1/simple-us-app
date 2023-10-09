from flask import Flask
import hashlib
import requests
import os

SINGLE_US = os.environ.get('SINGLE_US', "false").lower() == "true"

app = Flask(__name__)

@app.route('/')
def hello():
    return "hello"

@app.route('/encode/<string:text>')
def encode(text):
    if SINGLE_US:
        return hashlib.md5(text.encode()).hexdigest()
    else:
        response = requests.get(f'http://back-service:80/encode/{text}')
        return response.text

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

