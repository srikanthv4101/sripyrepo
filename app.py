from flask import Flask
import os
import socket

app = Flask(__name__)


@app.route("/")
def home():
    # APP_NAME comes from an environment variable (set in the Dockerfile
    # or overridden at run time with -e). Falls back to a default.
    name = os.environ.get("APP_NAME", "Docker Demo")
    return {
        "message": f"Hello from {name}!",
        "served_by_container": socket.gethostname(),
        "status": "running",
    }


@app.route("/health")
def health():
    # A simple health endpoint (handy for HEALTHCHECK / Kubernetes probes)
    return {"status": "healthy"}, 200


if __name__ == "__main__":
    # host="0.0.0.0" is REQUIRED inside a container.
    # 127.0.0.1 would only be reachable from inside the container itself,
    # so port mapping (-p) would appear to "not work".
    app.run(host="0.0.0.0", port=5000)
