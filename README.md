# docis

Dockerized Jekyll-centric toolkit to test,
verify, and optimize your static site content.

The image builds on top of `ruby:alpine3.16` with
[Jekyll](https://jekyllrb.com/) 4.3.2,
[HTMLproofer](https://github.com/gjtorikian/html-proofer) 5.0.7,
[xmllint](http://xmlsoft.org/xmllint.html) 20914,
[editorconfig-checker](https://editorconfig-checker.github.io/) 2.7.0,
[yamllint](https://github.com/adrienverge/yamllint) 1.28.0,
[markdownlint](https://github.com/DavidAnson/markdownlint) 0.28.1 with
[markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) 0.7.0,
[Vale](https://github.com/errata-ai/vale) 2.24.4, and
[image_optim](https://github.com/toy/image_optim) 0.31.3 with
[image_optim_pack](https://github.com/toy/image_optim_pack) 0.9.1.

## Build image locally

```console
docker build --build-arg VCS_REF=[vcs_ref] --build-arg \
  BUILD_DATE=[build_date] --build-arg BUILD_VER=[build_ver] -t [name]:[tag] .
```

## Use image

Although the image was created with the focus on Jekyll, you can
use its tools with other content and static site generators.

Below are the basic use cases with example commands and their explanation.

You can use either Docker commands from your operating system,
or Shell commands upon starting a container.

### Start container and enter Shell

Start a container, map the project folder with the folder inside the
container (`/srv/jekyll`), map the ports needed to serve the Jekyll
site and access it from outside the container, and enter Shell:

```console
docker run --rm -it -v path/to/project:/srv/jekyll \
  -p 4000:4000 arvikon/docis
```

**Note:** `-p 4000:4000` is necessary to access
the served project from outside the container.

Upon entering Shell, you can use the tools by running the direct commands,
for example, `jekyll build`, `jekyll serve`, `htmlproofer _site`,
`image_optim -r images`, `vale pages`, `yamllint _config.yml`, and so on.

### Build Jekyll site

Start a container, map the project folder with the folder inside
the container (`/srv/jekyll`), and build the Jekyll site:

```console
docker run --rm -v path/to/project:/srv/jekyll arvikon/docis jekyll build
```

By default, Jekyll operates in the `development`
[environment](https://jekyllrb.com/docs/configuration/environments/).
If you want to build a Jekyll site in a different environment,
for example `production`, use a bit modified command:

```console
docker run --rm -v path/to/project:/srv/jekyll \
  arvikon/docis JEKYLL_ENV=production jekyll build
```

### Serve Jekyll site

Start a container, map the project folder with the folder inside the
container (`/srv/jekyll`), map the ports needed to serve the Jekyll site
and access it from outside the container, and serve the Jekyll site:

```console
docker run --rm -v path/to/project:/srv/jekyll -p 4000:4000 \
  arvikon/docis jekyll serve -I --host 0.0.0.0
```

**Important:** `--host 0.0.0.0` is required.

**Note:** `-p 4000:4000` is necessary to access
the served project from outside the container.

By default, Jekyll operates in the `development`
[environment](https://jekyllrb.com/docs/configuration/environments/).
If you want to serve a Jekyll site in a different environment,
for example `production`, use a bit modified command:

```console
docker run --rm -v path/to/project:/srv/jekyll -p 4000:4000 \
  arvikon/docis JEKYLL_ENV=production jekyll serve --host 0.0.0.0
```

If you use Docker on Windows, and your site uses _relative_ URL addresses,
to properly serve the site from the container based on this image,
you must explicitly set `JEKYLL_ENV` to any other value than `development`.
(For details, see [Jekyll, Docker, Windows, and 0.0.0.0](https://tonyho.net/jekyll-docker-windows-and-0-0-0-0/).)
For example:

```console
docker run --rm -v path/to/project:/srv/jekyll -p 4000:4000 \
  arvikon/docis JEKYLL_ENV=docker jekyll serve --host 0.0.0.0
```

### Check links using HTMLproofer

For details on using HTMLproofer, see
[HTMLproofer documentation](https://github.com/gjtorikian/html-proofer/).

Start a container, map the project folder with the folder inside the
container (`/srv/jekyll`), and check links in the built project folder:

```console
docker run --rm -v path/to/project:/srv/jekyll \
  arvikon/docis htmlproofer [options] [built_project_folder]
```

**Note:** You have to build the project beforehand.

### Validate XML files using xmllint

For details on using xmllint, see
[xmllint documentation](http://xmlsoft.org/xmllint.html).

Start a container, map the project folder with the folder
inside the container (`/srv/jekyll`), and validate the
specified XML files in the build project folder:

```console
docker run --rm -v path/to/project:/srv/jekyll \
  arvikon/docis xmllint [options] [xml_files]
```

**Note:** You have to build the project beforehand.

### Check coding styles using editorconfig-checker

For details on using editorconfig-checker, see
[editorconfig-checker documentation](https://editorconfig-checker.github.io/).

Start a container, map the project folder with the folder inside the container
(`/srv/jekyll`), and check the coding styles in the specified targets:

```console
docker run --rm -v path/to/project:/srv/jekyll \
  arvikon/docis ec [options] [targets]
```

### Lint YAML files using yamllint

For details on using yamllint, see
[yamllint documentation](https://yamllint.readthedocs.io/).

Start a container, map the project folder with the folder inside
the container (`/srv/jekyll`), and lint the specified targets:

```console
docker run --rm -v path/to/project:/srv/jekyll \
  arvikon/docis yamllint [options] [targets]
```

### Check Markdown syntax using markdownlint

For details on using markdownlint, see
[markdownlint](https://github.com/DavidAnson/markdownlint) and
[markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
documentation.

Start a container, map the project folder with a folder inside the
container (`/srv/jekyll`), and check syntax in the target Markdown files:

```console
docker run --rm -v path/to/project:/srv/jekyll \
  arvikon/docis markdownlint-cli2 [options] [targets]
```

### Lint content using Vale

For details on using Vale, see
[Vale documentation](https://vale.sh/docs/vale-cli/installation/).

Start a container, map the project folder with the folder inside the
container (`/srv/jekyll`), and lint the content of the targets:

```console
docker run --rm -v path/to/project:/srv/jekyll \
  arvikon/docis vale [options] [targets]
```

**Tip:** It is recommended to place the Vale configuration
file (`.vale.ini` or `_vale.ini`) in the project's root.

### Optimize image assets using image_optim

For details on using image_optim, see
[image_optim documentation](https://github.com/toy/image_optim/).

Start a container, map the project folder with the folder inside the
container (`/srv/jekyll`), and optimize images in the target:

```console
docker run --rm -v path/to/project:/srv/jekyll \
  arvikon/docis image_optim [options] [target]
```

## License

This project is licensed under the MIT License.
See [LICENSE](https://github.com/arvikon/docis-docker/blob/master/LICENSE)
for details.
