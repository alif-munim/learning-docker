# Docker
Learning all about docker, images, and containerization.

<br/><br/>

# 📦 Getting Started
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

<br/><br/>

# 📧 Pushing to Registry
Docker images are shared through a Docker registry, usually Docker Hub. Docker Hub is like GitHub, but for Docker images instead of project repositories. Below are the steps to share an image on Docker Hub.
1. Login to Docker Hub
2. Create a new repository
3. Run: `docker push <username>/<image-name`
   > Note: if you haven't tagged your image as `<username>/<image-name>`, do so using the following command: `docker tag <image-name> <username>/<image-name>`

<br/><br/>

# 🛢 Volumes: Persisting Data

### Names Volumes
Although multiple containers can be created from a single image, changes in individual containers' filesystems won't be reflected in others. This means that when a container is removed, all of its file changes since the initial filesystem image will be removed along with it.

Docker addresses the issue of persisting data by using `volumes`. You can think of these as buckets of data that are **mounted** from specific container filesystem paths back to the host machine.

Creating a named volume:
`docker volume create todo-db`

Starting a container with a volume mount:
`docker run -dp 3000:3000 -v todo-db:/etc/todos getting-started`

### 📷 Bind Mounts
`Bind mounts` can be used to monitor code changes so that the container does not need to be rebuilt following each individual code change. Apart from `named volumes`, they are one of two main volume types in Docker. The main differences from `named volumes` are the following:
* You control the host location
* You must explicitly state the volume path on host machine when using the `-v` flag
  * `-v /path/to/data:/usr/local/data`
* Bind mounts do not populate new volumes with container contents
* Bind mounts do not support volume drivers

To start a dev-mode container:
* Mount the source code into the container
* Install all dependencies
* Start nodemon to monitor code changes

```bash
docker run -dp 3000:3000 \
    -w /app -v ${PWD}:/app \
    node:12-alpine \
    sh -c "yarn install && yarn run dev"
```

Breaking down the code:
* `-dp 3000:3000` start the container in detached mode and map port 3000 of the container to port 3000 of the host
* `-w /app` set /app to be the working directory
* `-v ${PWD}:/app` mount the volume to the /app host directory 
* `node:12-alpine` specifying image and tag to use
* `sh -c "yarn install && yarn run dev"` start shell using sh, run yarn install to install all dependencies, run yarn run dev to start nodemon
> Note: For Windows, use `%CD%` instead of `${PWD}`

<br/><br/>

# 🌩 Multi-Container Apps
Often, apps are composed of multiple containers which communicate with each other. This is possible through a network, as each container has its own dedicated IP address. You can either assign a container to a network on start, or create a network and attach the container later on.

### Creating Network and Connecting MYSQL
To create a network:
`docker network create todo-app`

To start a mysql container and attach it to the network:
```bash
docker run -d \
   --network todo-app --network-alias mysql \
   -v todo-mysql-data:/var/lib/mysql \ 
   -e MYSQL_ROOT_PASSWORD=secret \
   e MYSQL_DATABASE=todos \
   mysql:5.7
```
Breaking down the command:
* `--network todo-app` attach to the todo-app network
* `--network-alias mysql` so that Docker can resolve the name mysql to its network IP
* `-v todo-mysql-data:/var/lib/mysql` mount the named volume todo-mysql-data to the specified filepath
* `-e MYSQL_ROOT_PASSWORD=secret` set environment variable 
* `-e MYSQL_DATABASE` set environment variable 
* `mysql:5.7` image to use

Confirm connection and show databases:
`docker exec -it <mysql-container-id> mysql -p`

> Note: `docker exec -it` opens the container in interactive tty mode (-it) and executes the specified command

`mysql> SHOW DATABASES;`

```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| todos              |
+--------------------+
5 rows in set (0.00 sec)
```

### Connecting Containers
The following command:
* Starts the app container in detached mode on port 3000
* Connects the container to the `todo-app` network
* Sets the `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, and `MYSQL_DB` environment variables
* Specifies the image to use, `node:12-alpine`
* Starts a shell and runs the `yarn install` and `yarn run dev` commands

```bash
docker run -dp 3000:3000 \
  -w /app -v ${PWD}:/app \
  --network todo-app \
  -e MYSQL_HOST=mysql \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=secret \
  -e MYSQL_DB=todos \
  node:12-alpine \
  sh -c "yarn install && yarn run dev"
```

Verify items are being written to database:
`docker exec -it <mysql-container-id> mysql -p todos`
`mysql> select * from todos_items;`

```
+--------------------------------------+--------------------+-----------+
| id                                   | name               | completed |
+--------------------------------------+--------------------+-----------+
| c906ff08-60e6-44e6-8f49-ed56a0853e85 | Do amazing things! |         0 |
| 2912a79e-8486-4bc3-a4c5-460793a575ab | Be awesome!        |         0 |
+--------------------------------------+--------------------+-----------+
```