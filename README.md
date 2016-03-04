# Deconst, Integrated

[`docker-compose`](https://docs.docker.com/compose/) configuration that instantiates a single "pod" of Deconst services, with all of the debug settings cranked up to full. It's useful for:

 * Integration testing of Deconst components, before you commit to master and :shipit:
 * Previewing local content or control repository changes when the [deconst client](https://github.com/deconst/client) is busted

### Prerequisites

 * Install a recent version of [Docker](https://docs.docker.com/installation/#installation) for your platform.
 * Install [docker-compose](https://docs.docker.com/compose/install/). In addition to the `curl` command they list, you can also install it from [homebrew](http://brew.sh/) or [pip](https://pypi.python.org/pypi/docker-compose/1.3.0rc1).

Make sure that docker-machine is create and running first.

```bash
docker-machine create --driver virtualbox dev
```

Run `eval $(docker-machine env default)` in each shell you'll use to interact with Docker.

### Getting Started

Clone this repository and `cd` into the directory where you cloned the repo. Then:

1. Customize your credentials and other settings. The `env`
settings require knowing your Rackspace Cloud account info
and also where you intend to clone the control repo, for example.
  ```bash
  cp env.example env
  ${EDITOR} env
  ```
2. Launch the services.
   ```bash
   script/up
   ```

`script/up` accepts any parameters that `docker-compose up` does. Notably, you can use `script/up -d` to launch services in the background.


### Manual Alternative

If you prefer, you can manually run each docker container with:

```bash
# generate an admin API key for the content service
APIKEY=$(hexdump -v -e '1/1 "%.2x"' -n 128 /dev/random)
echo "Content Service Admin API Key:" $APIKEY

# start content service dependencies
docker run -d --name elasticsearch elasticsearch:1.7
docker run -d --name mongo mongo:2.6

# build and deploy the content service
cd ${CODE_ROOT}/content-service
docker build --tag content-service:dev .
docker run -d -p 9000:8080 \
  -e NODE_ENV=development \
  -e STORAGE=memory \
  -e MONGODB_URL=mongodb://mongo:27017/content \
  -e ELASTICSEARCH_HOST=http://elasticsearch:9200/ \
  -e ADMIN_APIKEY=${APIKEY} \
  --link mongo:mongo \
  --link elasticsearch:elasticsearch \
  --name content \
  content-service:dev script/inside/dev

# build and deploy the presenter service
cd ${CODE_ROOT}/presenter
docker build --tag presenter:dev .
docker run -d -p 80:8080 \
  -e NODE_ENV=development \
  -e CONTROL_REPO_PATH=/var/control-repo \
  -e CONTROL_REPO_URL=... \
  -e CONTROL_REPO_BRANCH=... \
  -e CONTENT_SERVICE_URL=http://content:8080 \
  -e PRESENTED_URL_PROTO=http \
  -e PRESENTED_URL_DOMAIN=support.rackspace.com \
  --link content \
  --name presenter \
  presenter:dev script/dev
```

### Submitting Content

Now the site is running, but you don't have any content submitted, yet. To add some, run the appropriate `script/add-*` script with the path to your clone of a local content repository.

```bash
script/add-sphinx ~/writing/drc/docs-quickstart

script/add-jekyll ~/writing/drc/docs-developer-blog
```

#### Updating content or mappings

If you make changes to the control repo—including content mapping, template routing, redirects, or asset/template content—you will need to restart the _presenter_ so it can pick up these changes. Just run `script/refresh` to restart the presenter.
