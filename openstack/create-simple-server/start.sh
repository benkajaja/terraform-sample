#!/bin/bash
sudo apt update
sudo apt install -yq build-essential python-pip rsync
pip install flask
echo -e "from flask import Flask\napp = Flask(__name__)\n@app.route('/')\ndef hello_cloud():\n   return 'Hello World\n' \napp.run(host='0.0.0.0')" > /tmp/app.py