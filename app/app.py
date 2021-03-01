from flask import Flask, request
from . import maze

app = Flask(__name__)


@app.route("/maze")
def home():
    width = int(request.args.get("width", 20))
    height = int(request.args.get("height", 10))
    return f"""
<html>
<head>
<style>
pre {{
    font-family: "Lucida Console", Monaco, monospace;
}}
</style>
</head>
<body>
<pre>
{maze.Maze.generate(width, height)}</pre>
</body>
</html>
    """


@app.route("/healthcheck")
def healthcheck():
    return "Healthy"


if __name__ == "__main__":
    app.run()
