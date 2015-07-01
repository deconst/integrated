# Deconst, Integrated

[`docker-compose`](https://docs.docker.com/compose/) configuration that instantiates a single "pod" of Deconst services, with all of the debug settings cranked up to full. It's useful for:

 * Integration testing of Deconst components, before you commit to master and :shipit:
 * Previewing local content or control repository changes before [#9](https://github.com/deconst/deconst-docs/issues/9) is addressed

### Prerequisites

 * Install a recent version of [Docker](https://docs.docker.com/installation/#installation) for your platform.
 * Install [docker-compose](https://docs.docker.com/compose/install/). In addition to the `curl` command they list, you can also install it from [homebrew](http://brew.sh/) or [pip](https://pypi.python.org/pypi/docker-compose/1.3.0rc1).

If you're using `boot2docker` on a Mac or Windows, you'll need to make sure that it's running, first. Run `boot2docker up` and then `$(boot2docker shellinit)` in each shell you'll use to interact with Docker.

### Getting Started

Clone this repository and `cd` into its directory. Then:

1. Customize your credentials and other settings.
  ```bash
  cd env.example env
  ${EDITOR} env
  ```
2. Launch the services.
   ```bash
   script/up
   ```

`script/up` accepts any parameters that `docker-compose up` does. Notably, you can use `script/up -d` to launch services in the background.

### Submitting Content

Now the site is running, but you don't have any content submitted, yet. To add some, run the appropriate `script/add-*` script with the path to your clone of a local content repository.

```bash
script/add-sphinx ~/writing/drc/docs-quickstart

script/add-jekyll ~/writing/drc/docs-developer-blog
```

#### Updating content/mappings

If you make changes to the control repo—including content mapping, template routing, redirects, or asset/template content—you will neeed to restart the _presenter_ so it can pick up these changes. Just run `script/refresh` to restart the presenter.
