# Jupyterhub Deployment docker-compose

**[Technical Overview](#technical-overview)** |
**[Prerequisites](#prerequisites)** |
**[Authenticator setup](#authenticator-setup)** |
**[Run JupyterHub](#run-jupyterhub)** |
**[FAQ](#faq)**

**Jupyterhub Deployment docker-compose** provides a reference
deployment of [JupyterHub](https://github.com/jupyter/jupyterhub), a
multi-user [Jupyter Notebook](http://jupyter.org/) environment, on a
**single host** using [Docker](https://docs.docker.com).  

Possible **use cases** include:

* Creating a JupyterHub demo environment that you can spin up relatively quickly.
* Providing a multi-user Jupyter Notebook environment for teams or departments.

## Disclaimer

If you are looking for a more robust solution to host JupyterHub, or
you require scaling beyond a single host, please check out the
excellent [zero-to-jupyterhub-k8s](https://github.com/jupyterhub/zero-to-jupyterhub-k8s)
project.

## Technical Overview

Key components of this reference deployment are:

* **Host**: Runs the [JupyterHub components](https://jupyterhub.readthedocs.org/en/latest/getting-started.html#overview)
  in a Docker container on the host.

* **Authenticator**: Uses [OAuthenticator](https://github.com/jupyter/oauthenticator) or other methods to
  authenticate users.

* **Spawner**:Uses [DockerSpawner](https://github.com/jupyter/dockerspawner)
  to spawn single-user Jupyter Notebook servers in separate Docker
  containers on the same host.

* **Persistence of Hub data**: Persists JupyterHub data in a Docker
  volume on the host.

* **Persistence of user notebook directories**: Persists user notebook
  directories in Docker volumes on the host.

## Prerequisites

### Docker

This deployment uses Docker, via [Docker Compose](https://docs.docker.com/compose/overview/), for all the things.
[Docker Engine](https://docs.docker.com/engine) 1.12.0 or higher is
required.

1. Use [Docker's installation instructions](https://docs.docker.com/engine/installation/)
   to set up Docker for your environment.

2. Verify Docker version and whether it is running:

   ```bash
   docker version
   docker ps
   ```

### HTTPS and SSL/TLS certificate

This deployment configures JupyterHub to use HTTPS. It is possible to provide a certificate and key file in the JupyterHub configuration. To configure:

1. Obtain domain name or DNS record, like `lab.company.com`.

1. If you do not have an existing certificate and key, you can:

   - obtain one from [Let's Encrypt](https://letsencrypt.org) using
     the [certbot](https://certbot.eff.org) client,
   - use the helper script in this repo's [letsencrypt example](examples/letsencrypt/README.md), or
   - [create a self-signed certificate](https://jupyter-notebook.readthedocs.org/en/latest/public_server.html#using-ssl-for-encrypted-communication).

1. Copy the certificate and key files to a
   directory named `secrets` in this repository's root directory.  These will be
   added to the JupyterHub Docker image at build time. For example, create a
   `secrets` directory in the root of this repo and copy the certificate and
   key files (`jupyterhub.crt` and `jupyterhub.key`) to this directory:

   ```bash
   mkdir -p secrets
   cp jupyterhub.crt jupyterhub.key secrets/
   ```


## Authenticator setup

See [Authentication Methods](https://github.com/syntho-ai/syntho-docs/blob/master/docs/deployment/docker/jupyterhub_ray.md#authentication-method).

## Run JupyterHub

Run the JupyterHub container on the host.

To run the JupyterHub container in detached mode:

```bash
docker-compose up -d
```

To bring down the JupyterHub container:

```bash
docker-compose down
```

## FAQ

### How can I view the logs for JupyterHub or users' Notebook servers?

Use `docker logs <container>`.  For example, to view the logs of the `jupyterhub` container

```bash
docker logs jupyterhub
```

### How do I specify the Notebook server image to spawn for users?

In this deployment, JupyterHub uses DockerSpawner to spawn single-user
Notebook servers. You set the desired Notebook server image in a
`DOCKER_NOTEBOOK_IMAGE` environment variable.

JupyterHub reads the Notebook image name from `jupyterhub_config.py`, which
reads the Notebook image name from the `DOCKER_NOTEBOOK_IMAGE` environment
variable:

```python
# DockerSpawner setting in jupyterhub_config.py
c.DockerSpawner.container_image = os.environ['DOCKER_NOTEBOOK_IMAGE']
```

By default, the`DOCKER_NOTEBOOK_IMAGE` environment variable is set in the
`.env` file.

```[sh]
DOCKER_NOTEBOOK_IMAGE=syntho-jupyterhub:<tag>
```

### If I change the name of the Notebook server image to spawn, do I need to restart JupyterHub?

Yes. JupyterHub reads its configuration which includes the container image
name for DockerSpawner. JupyterHub uses this configuration to determine the
Notebook server image to spawn during startup.

If you change DockerSpawner's name of the Docker image to spawn, you will
need to restart the JupyterHub container for changes to occur.

In this reference deployment, cookies are persisted to a Docker volume on the
Hub's host. Restarting JupyterHub might cause a temporary blip in user
service as the JupyterHub container restarts. Users will not have to login
again to their individual notebook servers. However, users may need to
refresh their browser to re-establish connections to the running Notebook
kernels.

### How can I backup a user's notebook directory?

There are multiple ways to [backup and restore](https://docs.docker.com/engine/userguide/containers/dockervolumes/#backup-restore-or-migrate-data-volumes) data in Docker containers.  

Suppose you have the following running containers:

```bash
    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}"

    CONTAINER ID        IMAGE                    NAMES
    bc02dd6bb91b        jupyter/minimal-notebook jupyter-jtyberg
    7b48a0b33389        jupyterhub               jupyterhub
```

In this deployment, the user's notebook directories (`/home/jovyan/work`) are backed by Docker volumes.

```bash
    docker inspect -f '{{ .Mounts }}' jupyter-jtyberg

    [{jtyberg /var/lib/docker/volumes/jtyberg/_data /home/jovyan/work local rw true rprivate}]
```

We can backup the user's notebook directory by running a separate container that mounts the user's volume and creates a tarball of the directory.  

```bash
docker run --rm \
  -u root \
  -v /tmp:/backups \
  -v jtyberg:/notebooks \
  jupyter/minimal-notebook \
  tar cvf /backups/jtyberg-backup.tar /notebooks
```

The above command creates a tarball in the `/tmp` directory on the host.
