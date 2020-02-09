Dockerized Jekyll-centric toolkit to test, verify, and optimize static site content.

The image is based on `ruby:2.6.5-alpine`, and builds with:

- Jekyll 4.0.0
- HTMLproofer 3.15.1
- image_optim 0.26.5
- Vale 2.0.0-beta.2
- yamllint 1.17.0

**NOTE:** Although the image was created with the focus on Jekyll, you can use the tools for other content.

Below are the basic use cases with recommended commands and their explanation.

You can use either Docker commands, or Shell commands upon starting a container.

## Start container and enter Shell

- _Command_

  ```
  docker run --rm -it -v path/to/project:/srv/jekyll -p 4000:4000 arvikon/docis sh
  ```

- _Explanation_

  Starts a container, maps the project folder with the folder inside the container (`/srv/jekyll`), maps the ports needed to serve the Jekyll site and access it from outside the container, and enters Shell.

- _Example_

  ```
  docker run --rm -it -v c:/users/default/my-project:/srv/jekyll -p 4000:4000 arvikon/docis sh
  ```

Upon entering Shell, you can use the tools by running the direct commands, for example, `jekyll b`, `jekyll s`, `htmlproofer _site`, `image_optim -r images`, `vale pages`, `yamllint _config.yml`, and so on.

## Build Jekyll site

- _Command_

  ```
  docker run --rm -v path/to/project:/srv/jekyll arvikon/docis jekyll b
  ```

- _Explanation_

  Starts a container, maps the project folder with the folder inside the container (`/srv/jekyll`), and builds the Jekyll site.

  **NOTE:** By default, Jekyll operates in the `development` [environment](https://jekyllrb.com/docs/configuration/environments/). If you want to build a Jekyll site in a different environment, for example `production`, use a bit modified command:

  ```
  docker run --rm -v path/to/project:/srv/jekyll arvikon/docis sh -c "JEKYLL_ENV=production jekyll b"
  ```

- _Examples_

  ```
  docker run --rm -v c:/users/default/my-project:/srv/jekyll arvikon/docis jekyll b
  ```

  ```
  docker run --rm -v c:/users/default/my-project:/srv/jekyll arvikon/docis sh -c "JEKYLL_ENV=production jekyll b"
  ```

## Serve Jekyll site

- _Command_

  ```
  docker run --rm -it -v path/to/project:/srv/jekyll -p 4000:4000 arvikon/docis jekyll s --host 0.0.0.0
  ```

- _Explanation_

  Starts a container, maps the project folder with the folder inside the container (`/srv/jekyll`), maps the ports needed to serve the Jekyll site and access it from outside the container, and serves the Jekyll site.<br/>**IMPORTANT:** `--host 0.0.0.0` is required.

  **NOTE:** By default, Jekyll operates in the `development` [environment](https://jekyllrb.com/docs/configuration/environments/). If you want to serve a Jekyll site in a different environment, e.g. `production`, use a bit modified command:

  ```
  docker run --rm -it -v path/to/project:/srv/jekyll -p 4000:4000 arvikon/docis sh -c "JEKYLL_ENV=production jekyll s --host 0.0.0.0"
  ```

- _Examples_

  ```
  docker run --rm -it -v c:/users/default/my-project:/srv/jekyll -p 4000:4000 arvikon/docis jekyll s -I --host 0.0.0.0 --profile --force-polling
  ```

  ```
  docker run --rm -it -v c:/users/default/my-project:/srv/jekyll -p 4000:4000 arvikon/docis sh -c "JEKYLL_ENV=production jekyll s -I --host 0.0.0.0 --profile --force-polling"
  ```

## Check links using HTMLproofer

For details on using HTMLproofer, see [HTMLproofer documentation](https://github.com/gjtorikian/html-proofer/).

- _Command_

  ```
  docker run --rm -v path/to/project:/srv/jekyll arvikon/docis htmlproofer [options] [built_site_folder_name]
  ```

- _Explanation_

  Starts a container, maps the project folder with the folder inside the container (`/srv/jekyll`), and checks links in the built site folder.<br/>**NOTE:** You have to build the project beforehand.

- _Example_

  ```
  docker run --rm -v c:/users/default/my-project:/srv/jekyll arvikon/docis htmlproofer --assume-extension --allow-hash-href --empty-alt-ignore --disable-external --url-ignore "#0" _site

## Optimize image assets using image_optim

For details on using image_optim, see [image_optim documentation](https://github.com/toy/image_optim/).

- _Command_

  ```
  docker run --rm -v path/to/project:/srv/jekyll arvikon/docis image_optim -r [image_folder_name]
  ```

- _Explanation_

  Starts a container, maps the project folder with the folder inside the container (`/srv/jekyll`), and optimizes images inside the folder.

- _Example_

  ```
  docker run --rm -v c:/users/default/my-project:/srv/jekyll arvikon/docis image_optim -r images
  ```

## Lint content using Vale

For details on using Vale, see [Vale documentation](https://errata-ai.github.io/vale/).

- _Command_

  ```
  docker run --rm -v path/to/project:/srv/jekyll arvikon/docis vale [source_files_folder_name]
  ```

- _Explanation_

  Starts a container, maps the project folder with the folder inside the container (`/srv/jekyll`), and tests source files against the styles.<br/>**TIP:** It is recommended to place the Vale configuration file (`.vale.ini` or `_vale.ini`) in the project's root.

- _Example_

  ```
  docker run --rm -v c:/users/default/my-project:/srv/jekyll arvikon/docis vale --no-wrap pages
  ```

## Lint YAML files

For details on using yamllint, see [yamllint documentation](https://yamllint.readthedocs.io/).

- _Command_

  ```
  docker run --rm -v path/to/project:/srv/jekyll arvikon/docis yamllint [lint_target]
  ```

- _Explanation_

  Starts a container, maps the project folder with the folder inside the container (`/srv/jekyll`), and lints YAML files specified under `[lint_target]`.

- _Example_

  ```
  docker run --rm -v c:/users/default/my-project:/srv/jekyll arvikon/docis yamllint _config.yml
  ```