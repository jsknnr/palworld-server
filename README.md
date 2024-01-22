# palworld-server
[![Static Badge](https://img.shields.io/badge/DockerHub-blue)](https://hub.docker.com/r/sknnr/palworld-dedicated-server) ![Docker Pulls](https://img.shields.io/docker/pulls/sknnr/palworld-dedicated-server) [![Static Badge](https://img.shields.io/badge/GitHub-green)](https://github.com/jsknnr/palworld-server) ![GitHub Repo stars](https://img.shields.io/github/stars/jsknnr/palworld-server)

Containerized Palworld dedicated server

**Disclaimer:** This is not an official image. No support, implied or otherwise is offered to any end user by the author or anyone else. Feel free to do what you please with the contents of this repo.

## Notice - Please Read
There is currently a bug where if you try to direct connect to your password protected server the game will not prompt you for the password and you will fail to join. If you can find your server in the server browser it will work just fine. However, another problem is that you may not be able to find your server in the server browser due to the shear amount of servers. This container image is built so that your server *should* show up in the list, but I have had some issues finding them.

A workaround for directly connecting to password protected servers has been shared here: https://steamcommunity.com/app/1623730/discussions/0/4132683013931609911/

## Usage

The processes within the container do **NOT** run as root. Everything runs as the user steam (gid:1000/uid:1000). If you exec into the container, you will drop into `/home/steam` as the steam user. Palworld will be installed to `/home/steam/palworld`. Any persistent volumes should be mounted to `/home/steam/palworld/Pal/Saved`.

### Ports

| Port | Protocol | Default |
| ---- | -------- | ------- |
| Game Port | UDP | 8211 |


### Environment Variables

| Name | Description | Default | Required |
| ---- | ----------- | ------- | -------- |
| SERVER_NAME | Name for the Server | Palworld Containerized | False |
| SERVER_PASSWORD | Password for the server | None | True |
| GAME_PORT | Port for server connections | 8211 | False |
| SERVER_SLOTS | Number of slots for connections (Max 32) | 32 | False |

### Docker

To run the container in Docker, run the following command:

```bash
docker volume create palworld-persistent-data # Only run this 1 time
docker run \
  --detach \
  --name palworld-server \
  --mount type=volume,source=palworld-persistent-data,target=/home/steam/palworld/Pal/Saved \
  --publish 8211:8211/udp \
  --env=SERVER_NAME="Palworld Containerized Server" \
  --env=SERVER_SLOTS=32 \
  --env=SERVER_PASSWORD="ChangeThisPlease" \
  --env=GAME_PORT=8211 \
  sknnr/palworld-dedicated-server:latest
```

### Docker Compose

To use Docker Compose, either clone this repo or copy the `compose.yaml` and `default.env` files out of the `container` directory to your local machine. You can leave the `compose.yaml` file uncahnged. Edit the `default.env` file to change the environment variables to the values you desire and then save the changes. Once you have made your changes, from the same directory that contains both the env file and the compose file, simply run:

```bash
docker compose up -d -f compose.yaml
```

To bring the container down:

```bash
docker compose down -f compose.yaml
```

### Podman

To run the container in Podman, run the following command:

```bash
podman volume create palworld-persistent-data # Only run this 1 time
podman run \
  --detach \
  --name palworld-server \
  --mount type=volume,source=palworld-persistent-data,target=/home/steam/palworld/Pal/Saved \
  --publish 8211:8211/udp \
  --env=SERVER_NAME="Palworld Containerized Server" \
  --env=SERVER_SLOTS=32 \
  --env=SERVER_PASSWORD="ChangeThisPlease" \
  --env=GAME_PORT=8211 \
  docker.io/sknnr/palworld-dedicated-server:latest
```

### Kubernetes

I've built a Helm chart and have included it in the `helm` directory within this repo. Modify the `values.yaml` file to your liking and install the chart into your cluster. Be sure to create and specify a namespace as I did not include a template for provisioning a namespace.
