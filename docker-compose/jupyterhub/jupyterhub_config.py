# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Configuration file for JupyterHub
import os
from jupyterhub.utils import random_port
from tornado import gen
from oauthenticator.azuread import AzureAdOAuthenticator
from dockerspawner import DockerSpawner

c = get_config()

class custom_spawner(DockerSpawner):
    @gen.coroutine
    def get_ip_and_port(self):
        return self.container_ip, self.container_port

    @gen.coroutine
    def start(self, *args, **kwargs):
        self.container_port = random_port()
        spawn_cmd = "start-singleuser.sh --port={}".format(self.container_port)
        self.extra_create_kwargs.update({"command": spawn_cmd})

        # start the container
        ret = yield DockerSpawner.start(self, *args, **kwargs)
        return ret

# We rely on environment variables to configure JupyterHub so that we
# avoid having to rebuild the JupyterHub container every time we change a
# configuration parameter.

# Spawn single-user servers as Docker containers
c.JupyterHub.spawner_class = custom_spawner
# Spawn containers from this image
c.DockerSpawner.image = os.environ['DOCKER_NOTEBOOK_IMAGE']
c.DockerSpawner.start_timeout = 600
# JupyterHub requires a single-user instance of the Notebook server, so we
# default to using the `start-singleuser.sh` script included in the
# jupyter/docker-stacks *-notebook images as the Docker run command when
# spawning containers.  Optionally, you can override the Docker run command
# using the DOCKER_SPAWN_CMD environment variable.
spawn_cmd = os.environ.get('DOCKER_SPAWN_CMD', "start-singleuser.sh")
#c.DockerSpawner.extra_create_kwargs.update({ 'command': spawn_cmd })
# Connect containers to this Docker network
network_name = os.environ['DOCKER_NETWORK_NAME']
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name
# Pass the network name as argument to spawned containers
c.DockerSpawner.extra_host_config = { 'network_mode': 'host' }
# Explicitly set notebook directory because we'll be mounting a host volume to
# it.  Most jupyter/docker-stacks *-notebook images run the Notebook server as
# user `jovyan`, and set the notebook directory to `/home/jovyan/work`.
# We follow the same convention.
notebook_dir = os.environ.get('DOCKER_NOTEBOOK_DIR') or '/home/jovyan/work'
c.DockerSpawner.notebook_dir = notebook_dir
# Mount the real user's Docker volume on the host to the notebook user's
# notebook directory in the container
c.DockerSpawner.volumes = { 'jupyterhub-user-{username}': notebook_dir }
# volume_driver is no longer a keyword argument to create_container()
# c.DockerSpawner.extra_create_kwargs.update({ 'volume_driver': 'local' })
# Remove containers once they are stopped
c.DockerSpawner.remove = True
# For debugging arguments passed to spawned containers
c.DockerSpawner.debug = True

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = 'localhost'
c.JupyterHub.hub_port = 8080

# Environment variables
c.Spawner.environment = {
    "LICENSE_KEY_SIGNED": os.environ.get('LICENSE_KEY', "key/license")
}

# TLS config
c.JupyterHub.port = 443
#c.JupyterHub.ssl_key = os.environ['SSL_KEY']
#c.JupyterHub.ssl_cert = os.environ['SSL_CERT']

# Authenticate users
# Currently set for DummyAuthenticator (ONLY FOR TESTING)
c.JupyterHub.authenticator_class = 'jupyterhub.auth.DummyAuthenticator'

#c.JupyterHub.authenticator_class = AzureAdOAuthenticator
#c.Application.log_level = 'DEBUG'
#c.AzureAdOAuthenticator.tenant_id = os.environ.get('AAD_TENANT_ID')
#c.AzureAdOAuthenticator.oauth_callback_url = 'http://{your-domain}/hub/oauth_callback'
#c.AzureAdOAuthenticator.client_id = '{AAD-APP-CLIENT-ID}'
#c.AzureAdOAuthenticator.client_secret = '{AAD-APP-CLIENT-SECRET}'

# Persist hub data on volume mounted inside container
data_dir = os.environ.get('DATA_VOLUME_CONTAINER', '/data')

c.JupyterHub.cookie_secret_file = os.path.join(data_dir,
    'jupyterhub_cookie_secret')

c.JupyterHub.db_url = 'postgresql://postgres:{password}@{host}/{db}'.format(
    host=os.environ['POSTGRES_HOST'],
    password=os.environ['POSTGRES_PASSWORD'],
    db=os.environ['POSTGRES_DB'],
)

# Whitlelist users and admins
c.Authenticator.whitelist = whitelist = set()
c.Authenticator.admin_users = admin = set()
c.JupyterHub.admin_access = True
pwd = os.path.dirname(__file__)
with open(os.path.join(pwd, 'userlist')) as f:
    for line in f:
        if not line:
            continue
        parts = line.split()
        # in case of newline at the end of userlist file
        if len(parts) >= 1:
            name = parts[0]
            whitelist.add(name)
            if len(parts) > 1 and parts[1] == 'admin':
                admin.add(name)
