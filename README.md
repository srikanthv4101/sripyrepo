# Python + Docker: Build, Run & Deploy

A tiny Flask web app used to teach how to containerize a Python project and
run it with Docker. It has two endpoints:

- `GET /` → returns a JSON greeting + the container's hostname
- `GET /health` → returns `{"status":"healthy"}`

## Project structure

```
python-docker-demo/
├── app.py            # the Flask application
├── requirements.txt  # pinned dependencies
├── Dockerfile        # instructions to build the image
└── .dockerignore     # files to keep OUT of the build
```

---

## Step 1 — Build the image

```bash
docker build -t python-docker-demo .
```

- `docker build` → reads the `Dockerfile` and produces an **image**.
- `-t python-docker-demo` → **t**ags (names) the image so you can refer to it later.
  You can also add a version: `-t python-docker-demo:1.0`.
- `.` → the **build context**: the folder Docker sends to the engine. The `.`
  means "the current directory". It is NOT the path to the Dockerfile.

Check it was created:

```bash
docker images
```

---

## Step 2 — Run & deploy the container (detached)

This is how you "deploy" the app so it keeps running in the background:

```bash
docker run -d -p 5000:5000 --name pyapp python-docker-demo
```

Flag by flag:

| Flag | Long form | What it does |
|------|-----------|--------------|
| `-d` | `--detach` | Run in the **background** and immediately give your terminal back. Prints the container ID. |
| `-p 5000:5000` | `--publish` | Map **host port : container port**. Left = your machine, right = inside the container. Now `http://localhost:5000` reaches the app. |
| `--name pyapp` | | Give the container a friendly **name** instead of a random one. |
| `python-docker-demo` | | The **image** to run (from Step 1). |

Test it:

```bash
curl http://localhost:5000
curl http://localhost:5000/health
```

> Why `-p` matters: the app runs on port 5000 *inside* the container. Without
> `-p`, that port is sealed off from your machine. `-p 8080:5000` would instead
> expose it on `http://localhost:8080`.

---

## Step 3 — Run interactively (`-it`)

Use `-it` when you want to **interact** with the container — type into it, see a
live terminal.

```bash
docker run -it --rm python-docker-demo
```

- `-i` (`--interactive`) → keep **STDIN open** so you can type into the container.
- `-t` (`--tty`) → allocate a **pseudo-terminal**, giving you a proper prompt,
  colors, and formatting.
- `-it` → the two combined. This is the standard combo for anything interactive.
- `--rm` → automatically **delete** the container when it stops (keeps things tidy).

Because our app is a server, running it with `-it` (no `-d`) simply shows the
live logs in your terminal, and `Ctrl+C` stops it.

### Get a shell *inside* a running container

`-it` also powers `exec`, the most common way to look inside a running container:

```bash
docker exec -it pyapp bash
```

This drops you into a Bash shell inside `pyapp`. Type `exit` to leave (the
container keeps running). Same `-i` + `-t` meaning as above.

---

## `-d` vs `-it` — the key idea

| You want to... | Use | Example |
|----------------|-----|---------|
| Deploy a server / run in background | `-d` | `docker run -d -p 5000:5000 pyapp` |
| Type into it / get a shell | `-it` | `docker exec -it pyapp bash` |
| Run once and auto-clean | `--rm` | `docker run --rm pyapp` |

You **cannot meaningfully combine `-d` and `-it`** for the same goal — `-d`
sends it to the background, `-it` keeps you attached to it. Pick based on intent.

---

## Other useful flags

| Flag | Meaning | Example |
|------|---------|---------|
| `-e KEY=value` | Set an **environment variable** | `docker run -e APP_NAME="Prod" -d -p 5000:5000 pyapp` |
| `-v host:container` | Mount a **volume** (persist data / share files) | `-v $(pwd)/data:/app/data` |
| `--restart unless-stopped` | Auto-restart on crash/reboot | good for real deployments |
| `-P` | Publish **all** EXPOSEd ports to random host ports | |

---

## Managing the container (lifecycle)

```bash
docker ps                 # list RUNNING containers
docker ps -a              # list ALL containers (incl. stopped)
docker logs pyapp         # view its output
docker logs -f pyapp      # follow logs live
docker stop pyapp         # graceful stop (SIGTERM)
docker start pyapp        # start it again
docker restart pyapp      # stop + start
docker rm pyapp           # remove it (must be stopped first)
docker rm -f pyapp        # force-remove even if running
```

## Clean up

```bash
docker rm -f pyapp
docker rmi python-docker-demo
```
