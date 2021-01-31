# ML model lifecycle with Poetry

This repo provides a Dockerfile to build container which contains Python and [Poetry](https://python-poetry.org/).
It is assumed that your project makes use of poetry and all the necessary dependencies are provided in the toml.
For more information about Poetry, please visit the Poetry's [docs](https://python-poetry.org/docs/).

To illustrate the use of the container I'll be using a dummy repo with a

The container execution is aimed to:
 1. Clone a git project from Github, Bitbucket or Gitlab
 2. Install dependencies.
 3. Executes the provided Poetry entrypoint

## Build

The image is built on top of [python slim-buster containers](https://hub.docker.com/_/python). It is possible to specify
the version to use with the variable `PY_VERSION`. It must match the python version number preceding those container "slim-buster"
It is also possible to use a given version for Poetry with `POE_VERSION`. It must match one of the tags found in its
[reposority](https://github.com/python-poetry/poetry/tags) in Github.
It the last available version is required, `POE_VERSION=master` or just not provide the argument will suffice.

The default case will install Python 3.8 and the latest Poetry version.
```
docker build -t batch-poetry:0.1.0 --no-cache .
```

An example providing arguments:
```
docker build \
--build-arg PY_VERSION=3.7.9 \
--build-arg POE_VERSION=1.1.3 \
-t batch-poetry:0.1.0 --no-cache .
```

## Run

The container contains an entrypoint which manages the reposority clone and code execution.
All the information must be provided through the CMD as follow:

```
docker run -it  \
--rm \
batch-poetry:0.1.0 \
<repository-address> <entrypoint> <extra-parameters>
```
Note: `<extra-parameters>` correspond to parameters provided following the interface of python libraries like: argparse or click.
If there is no extra parameters there is no need to add anything after `<entrypoint>`
Ej:  `<extra-parameters>=-n 1.2 -m 0.01`

An actual example using a repository made for this purpose is:
```
docker run -it  \
--rm \
batch-poetry:0.1.0 \
https://github.com/mgvalverde/poe_model_example.git main -n Edgar
```

### HTTPS git link

If the repository is public, it must can be provided as followed:
```
docker run -it  \
--rm \
batch-poetry:0.1.0 \
https://github.com/mgvalverde/poe_model_example.git main -n Edgar
```

### SSH git link

It is not common to work with public repository, and it is necessary to provide a set of ssh keys to access to the
repository. For those cases, it is possible to provide the keys in two ways. They can be pass as env vars at runtime as
follow:

```
SSH_LOCAL_PATH=$HOME/.ssh/id_rsa

docker run -it  \
--rm \
-e SSH_PRV="$(cat $SSH_LOCAL_PATH)" \
-e SSH_PUB="$(cat $SSH_LOCAL_PATH.pub)" \
batch-poetry:0.1.0 \
git@github.com:mgvalverde/poe_model_example.git main -n Edgar
```

They can also be mounted as volumes directly into the container. They must be mounted inside `/home/poe/.ssh/`.
This could be an interesting approach if the target is to use the container in a K8s cluster (for example) where the
SSH-keys are stored as secrets which can be injected in the containers when deployed.
```
SSH_LOCAL_PATH=$HOME/.ssh/id_rsa

docker run -it  \
--rm \
-v $SSH_LOCAL_PATH:/home/poe/.ssh/ssh-key \
-v $SSH_LOCAL_PATH.pub:/home/poe/.ssh/ssh-key.pub \
batch-poetry:0.1.0 \
git@github.com:mgvalverde/poe_model_example.git main -n Edgar
```

