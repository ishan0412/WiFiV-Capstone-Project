import socket
# import atexit

import qrcode
from flask import Flask, render_template, request
from qrcode import QRCode

app = Flask(__name__)

# sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
host = '192.168.224.182'
# server = '10.91.64.30'
server = '192.168.224.224'
port = 80

btnstate = True

@app.route('/', methods=('GET', 'POST'))
def index():
    global btnstate
    # sock.connect((host, port))
    # print(f"Connecting to {host} on port {port}...")
    if request.method == 'POST':
        btnstate = not btnstate
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.connect((host, port))
            sock.send(127)
    print(btnstate)
    return render_template('index.html', btnstate=btnstate)

if __name__ == '__main__':
    # atexit.register(sock.close)

    qr = QRCode(box_size=20, border=10, error_correction=qrcode.constants.ERROR_CORRECT_H)
    qr.add_data(f'http://{server}:8090')
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    # img.save("qrcode.png")

    # sock.connect((host, port))
    # print(f"Connecting to {host} on port {port}...")

    app.run(host='0.0.0.0', port=8090, debug=False)
