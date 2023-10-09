from flask import Flask, abort
import hashlib
import os
import random
import time 

INJECT_ERROR_RATE = float(os.environ.get('INJECT_ERROR_RATE', "0.0"))
INJECT_BUSY_WAIT_SECONDS = float(os.environ.get('INJECT_BUSY_WAIT_SECONDS', "0"))



app = Flask(__name__)


def busy_wait(duration):
    end_time = time.time() + duration
    while time.time() < end_time:
        pass

@app.route('/')
def hello():
    return "hello from back!"

@app.route('/encode/<string:text>')
def encode(text):
    if random.random() < INJECT_ERROR_RATE:
        time.sleep(1)
        return abort(500, description="Internal Server Error")
    if INJECT_BUSY_WAIT_SECONDS > 0:
        busy_wait(INJECT_BUSY_WAIT_SECONDS)
    return hashlib.md5(text.encode()).hexdigest()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
