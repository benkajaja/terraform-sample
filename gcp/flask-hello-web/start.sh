sudo apt-get update
sudo apt-get install -yq build-essential python-pip rsync
pip install flask
echo -e "from flask import Flask\napp = Flask(__name__)\n@app.route('/')\ndef hello_cloud():\n   return 'Hello World' \napp.run(host='0.0.0.0')" > /tmp/app.py