from flask import Flask
from flask import jsonify
import requests

app = Flask(__name__)

@app.route('/')
def get_ip():
	r = requests.get("http://ipinfo.io/json").json()
	return jsonify(node_ip=str(r['ip']),
			node_location=str(r['city'] + ", " + r['region']))

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')

