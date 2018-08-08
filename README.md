# Deconst, Integrated

Deconst Integrated is a
[`docker-compose`](https://docs.docker.com/compose/) configuration
that instantiates a single collection of Deconst services, with all of
the debug settings cranked up to full. It's useful for:

 * Integration testing of Deconst components, before you commit to
   master and :shipit:
 * Previewing local content or control repository changes

## Prerequisites
### OSX

 * Install a recent version of
   [Docker](https://docs.docker.com/installation/#installation)


### Windows or Linux

 1. Install [docker-compose](https://docs.docker.com/compose/install/)
 1. Create a `docker-machine dev` instance:
    ```bash
    docker-machine create --driver virtualbox dev
    ```
 1. Run `eval $(docker-machine env default)` in each shell that you'll
    use to interact with Docker.


## Edit the env file

Clone this Deconst Integrated repository and change to the directory
where you cloned the repo. Customize your credentials and other
settings in the `env` file. Setting the variables correctly require
knowing your Rackspace Cloud account info and also where you intend to
clone the control repo.

   1. Copy the example file to `env`:
      ```bash
      cp env.example env
      ```
   1. Edit the `env` file in a text editor and change it as
      appropriate for your environment.
   1. Since this a local test environment, any API key is fine. To
      create a random API key, type:
      ```bash
      hexdump -v -e '1/1 "%.2x"' -n 40 /dev/random
      50d1606d4bd6bd1a5f2adefdcae603deff9b012a164cb8bf0b68caf3638d8e868
      ```

   1. Paste the key between the quotes on this line in the
      `env` file:
      ```bash
      # The content service's administrative API Key. Used for write actions.
      # Set this to something arbitrary and "random". While you're running locally it doesn't need to
      # be anything particularly difficult.
      export ADMIN_APIKEY="50d1606d4bd6bd1a5f2adefdcae603deff9b012a164cb8bf0b68caf3638d8e868""
      ```

   1. Set the domain name of the published documentation site:
      ```bash
      # Set this to the domain name of the site you're interested in.
      export PRESENTED_URL_DOMAIN=deconst.horse
      ```

   1. Set the location of your control repository. For
      example, for `deconst.horse`:
      ```bash
      # Set this to a path to a control repository on your local
      # machine to preview local changes to a control repository.
      unset CONTROL_REPO_HOST_PATH
      export CONTROL_REPO_HOST_PATH="/Users/writer1/deconst-docs-control"
      ```

## Start integrated services

Launch the services:
```bash
script/up
```

The `script/up` command accepts any parameters that `docker-compose
up` does. Notably, you can use `script/up -d` to launch services in
the background.


### Option: Run the Docker containers manually

As an alternative to the `up` script, you can manually run each Docker
container, as follows:

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

### Submitting content

Now the site is running, but you don't have any content submitted,
yet. To add some, run the appropriate `script/add-*` script with the
path to your clone of a local content repository.

```bash
# add the control repository:
script/add-assets ~/writing/drc/deconst-docs-control

# add a Sphinx site:
script/add-sphinx ~/writing/drc/docs-quickstart

# add a Jekyll site:
script/add-jekyll ~/writing/drc/docs-developer-blog
```

#### Updating content or mappings

If you make changes to the control repo — including content mapping,
template routing, redirects, or asset/template content — you must
restart the _presenter_ so it can pick up these changes. Run
`script/refresh` to restart the presenter.

## Cleaning up

To shut down all containers, type:
```bash
docker stop $(docker ps -a -q)
```
