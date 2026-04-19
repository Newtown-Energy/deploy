import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def show_env():
    return jsonify({
        "SMTP_HOST": os.environ.get("SMTP_HOST"),
        "SMTP_USER": os.environ.get("SMTP_USER"),
        "SMTP_FROM_ADDRESS": os.environ.get("SMTP_FROM_ADDRESS"),
        "HOME": os.environ.get("HOME"),
    })
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
