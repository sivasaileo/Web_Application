from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, This is Siva sai. Welcome!"

@app.route('/about')
def about():
    return "About Page: This is a Flask Application"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
