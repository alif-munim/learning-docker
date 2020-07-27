# Docker
Learning all about docker, images, and containerization.

### Getting Started
To start the tutorial, start up [Docker]() and run the following command.
`docker run -d -p 80:80 docker/getting-started`
Breaking down the command:
* `docker run` is the standard command for starting up a container
* `-d` is a flag which tells docker to run the container in detached mode (in the background, or outside of it's terminal environment)
* `-p 80:80` maps port 80 of the host to port 80 of the container
* `docker/getting-started` is the image used to create the container. Containers are instances of their image.

### Docker Dashboard
The dashboard gives an overview of the containers that are currently running and allows you to interact with them.

### Containers
A container is a process with an environment that is completely isolated from all of the other processes on your machine.
It is an instance of a given container image which has its own file system which leverages linux features such as kernel namespaces and cgroups.
Having all of your project files and dependencies encapsulated inside of its own container allows it to run predictably regardless of what kind of machine it is on.
This was traditionally achieved using virtual machines, but containers do not require the overhead of loading up an entire OS and are therefore much more lightweight.

### Building an App
To build a container image, a `Dockerfile` is required. The `Dockerfile` contains important information such as the starting image, working directory, and commands to run when building and running the container. Here is one such example:

```Dockerfile
FROM node:12-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "/app/src/index.js"]
```

Once a `Dockerfile` has been created, you can use the following command to build a container image:
`docker build -t getting-started .`

Breaking down the command:
* `-t getting-started` tags the image with the name "getting-started"
* `.` the directory of the `Dockerfile` (?)

### Starting an App
Much like starting up the `docker/getting-started` tutorial, run the following command which starts a container in detached mode on port 3000 using the `getting-started` image:
`docker run -dp 3000:3000 getting-started`
The app should now be accessible on **http://localhost:3000**, and the container will show up on the Docker dashboard.

### Updating an App
Once you've made updates to an app, you'll likely have to rebuild and restart the container. Before doing so however, you must remove the old container as it is using the same port. Here are some commands that may come in handy:
* `docker ps` lists all running containers.
* `docker ps -a` lists all containers, running or stopped.
* `docker stop <container-id>` will stop a running container. Usually, the first 4 or 5 characters will suffice for the container-id.
* `docker rm <container-id>` will remove a container.

### Pushing to Registry
Docker images are shared through a Docker registry, usually Docker Hub. Docker Hub is like GitHub, but for Docker images instead of project repositories. Below are the steps to share an image on Docker Hub.
1. Login to Docker Hub
2. Create a new repository
3. Run: `docker push <username>/<image-name`
   > Note: if you haven't tagged your image as <username>/<image-name>, do so using the following command: `docker tag <image-name> <username>/<image-name>`