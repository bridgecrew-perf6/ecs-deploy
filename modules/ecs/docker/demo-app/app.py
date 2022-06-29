from flask import Flask, render_template
from healthcheck import HealthCheck
import random
import urllib.request
import socket

app = Flask(__name__)
health = HealthCheck(app, "/status")
hostname = (socket.gethostname())

# list of cat images:
images = [
    "https://media.giphy.com/media/mlvseq9yvZhba/giphy.gif",
    "https://media.giphy.com/media/VbnUQpnihPSIgIXuZv/giphy.gif",
    "https://media.giphy.com/media/3nbxypT20Ulmo/giphy.gif",
    "https://media.giphy.com/media/CjmvTCZf2U3p09Cn0h/giphy.gif",
    "https://media.giphy.com/media/l6Td5sKDNmDGU/giphy.gif",
    "https://media.giphy.com/media/CqVNwrLt9KEDK/giphy.gif",
    "https://media.giphy.com/media/fjxMEdpMT9qDyBVLL4/giphy.gif",
    "https://media.giphy.com/media/8JIRQqil8mvEA/giphy.gif",
    "https://media.giphy.com/media/26n6xF5M2Ht4eKdO0/giphy.gif",
    "https://media.giphy.com/media/xH7Yh3DSNvn4k/giphy.gif",
    "https://media.giphy.com/media/GeimqsH0TLDt4tScGw/giphy.gif",
    "https://media.giphy.com/media/Nm8ZPAGOwZUQM/giphy.gif"
]

def demo_available():
	code = urllib.request.urlopen("http://127.0.0.1:8082").getcode()
	print(code)
	if code == 200:
		return True, "OK"
	else:
		return False, "ERROR"

health.add_check(demo_available)

@app.route('/')
def index():
    url = random.choice(images)
    return render_template(
        'index.html',
        url=url,
        hostname=hostname,
        )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8082)