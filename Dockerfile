# 1. Start FROM an official, slim Python base image.
#    "slim" = small size, fewer packages, smaller attack surface.
FROM python:3.12-slim

# 2. Set the working directory INSIDE the container.
#    Every command after this runs from /app.
WORKDIR /app

# 3. Copy ONLY the requirements file first.
#    Reason: Docker caches each layer. As long as requirements.txt
#    doesn't change, the slow "pip install" step is reused from cache
#    even when you edit app.py. This makes rebuilds much faster.
COPY requirements.txt .

# 4. Install the Python dependencies.
#    --no-cache-dir keeps the image smaller.
RUN pip install --no-cache-dir -r requirements.txt

# 5. Now copy the rest of the application code.
COPY . .

# 6. Document the port the app listens on (informational).
#    Note: EXPOSE does NOT publish the port. You still need -p at run time.
EXPOSE 5000

# 7. A default environment variable (can be overridden with -e at run time).
ENV APP_NAME="Kodelize Docker Demo"

# 8. The command that runs when the container STARTS.
CMD ["python", "app.py"]
