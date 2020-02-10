![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/arvikon/docis) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/arvikon/docis)

# Overview

Dockerized Jekyll-centric toolkit to test, verify, and optimize your static site content.

The image builds on top of the `ruby:2.6.5-alpine` Docker image, and builds with [Jekyll](https://jekyllrb.com/) 4.0.0, [HTMLproofer](https://github.com/gjtorikian/html-proofer) 3.15.1, [image_optim](https://github.com/toy/image_optim) 0.26.5, [Vale](https://errata-ai.github.io/vale/) 2.0.0-beta.2, and [yamllint](https://github.com/adrienverge/yamllint) 1.17.0.

# Build image

```console
docker build --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION=[image_ver] -t [image_tag] .
```

where `[image_ver]` is a version of the image, and `[image_tag]` is a tag for the image.

# Use image

Although the image was created with the focus on Jekyll, you can use the tools for other content.

Below are the basic use cases with example commands and their explanation.

You can use either Docker commands, or Shell commands upon starting a container.

## Start container and enter Shell

Start a container, map the project folder with the folder inside the container (`/srv/jekyll`), map the ports needed to serve the Jekyll site and access it from outside the container, and enter Shell:

```console
docker run --rm -it -v path/to/project:/srv/jekyll -p 4000:4000 arvikon/docis sh
```

Upon entering Shell, you can use the tools by running the direct commands, for example, `jekyll b`, `jekyll s`, `htmlproofer _site`, `image_optim -r images`, `vale pages`, `yamllint _config.yml`, and so on.

## Build Jekyll site

Start a container, map the project folder with the folder inside the container (`/srv/jekyll`), and build the Jekyll site:

```console
docker run --rm -v path/to/project:/srv/jekyll arvikon/docis jekyll b
```

**Note:** By default, Jekyll operates in the `development` [environment](https://jekyllrb.com/docs/configuration/environments/). If you want to build a Jekyll site in a different environment, for example `production`, use a bit modified command:

```console
docker run --rm -v path/to/project:/srv/jekyll arvikon/docis sh -c "JEKYLL_ENV=production jekyll b"
```

## Serve Jekyll site

Start a container, map the project folder with the folder inside the container (`/srv/jekyll`), map the ports needed to serve the Jekyll site and access it from outside the container, and serve the Jekyll site:

```console
docker run --rm -it -v path/to/project:/srv/jekyll -p 4000:4000 arvikon/docis jekyll s --host 0.0.0.0
```

**Important:** `--host 0.0.0.0` is required.

**Note:** By default, Jekyll operates in the `development` [environment](https://jekyllrb.com/docs/configuration/environments/). If you want to serve a Jekyll site in a different environment, e.g. `production`, use a bit modified command:

```console
docker run --rm -it -v path/to/project:/srv/jekyll -p 4000:4000 arvikon/docis sh -c "JEKYLL_ENV=production jekyll s --host 0.0.0.0"
```

## Check links using HTMLproofer

For details on using HTMLproofer, see [HTMLproofer documentation](https://github.com/gjtorikian/html-proofer/).

Start a container, map the project folder with the folder inside the container (`/srv/jekyll`), and check links in the built site folder:

```console
docker run --rm -v path/to/project:/srv/jekyll arvikon/docis htmlproofer [options] [built_site_folder_name]
```

**Note:** You have to build the project beforehand.

**Example**

```console
docker run --rm -v c:/users/default/my-project:/srv/jekyll arvikon/docis htmlproofer --assume-extension --allow-hash-href --empty-alt-ignore --disable-external --url-ignore "#0" _site
```

## Optimize image assets using image_optim

For details on using image_optim, see [image_optim documentation](https://github.com/toy/image_optim/).

Start a container, map the project folder with the folder inside the container (`/srv/jekyll`), and optimize images in the folder:

```console
docker run --rm -v path/to/project:/srv/jekyll arvikon/docis image_optim -r [image_folder_name]
```

## Lint content using Vale

For details on using Vale, see [Vale documentation](https://errata-ai.github.io/vale/).

Start a container, map the project folder with the folder inside the container (`/srv/jekyll`), and test source files against the Vale style rules:

```console
docker run --rm -v path/to/project:/srv/jekyll arvikon/docis vale [source_files_folder_name]
```

**Tip:** It is recommended to place the Vale configuration file (`.vale.ini` or `_vale.ini`) in the project's root.

## Lint YAML files usign yamllint

For details on using yamllint, see [yamllint documentation](https://yamllint.readthedocs.io/).

Start a container, map the project folder with the folder inside the container (`/srv/jekyll`), and lint YAML files specified under `[lint_target]`:

```console
docker run --rm -v path/to/project:/srv/jekyll arvikon/docis yamllint [lint_target]
```

# License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
