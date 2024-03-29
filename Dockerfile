# Define base image
FROM ruby:alpine3.18
# Define environment variables for library versions
# Based on https://hub.docker.com/r/colthreepv/docker-image_optim/dockerfile
ENV \
  # https://static.jonof.id.au/dl/kenutils/
  PNGOUT_VERSION="20200115" \
  # https://github.com/errata-ai/vale/releases
  VALE_VERSION="2.28.0"
# Set build arguments
ARG BUILD_DATE
ARG BUILD_VER
ARG VCS_REF
# Add image metadata
# See http://label-schema.org/rc1/
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="arvikon/docis"
LABEL org.label-schema.description="Jekyll-centric toolkit to proof, optimize, and verify your static site content"
LABEL org.label-schema.version=${BUILD_VER}
LABEL org.label-schema.build-date=${BUILD_DATE}
LABEL org.label-schema.url="https://hub.docker.com/r/arvikon/docis"
LABEL org.label-schema.usage="https://hub.docker.com/r/arvikon/docis"
LABEL org.label-schema.docker.cmd="docker run --rm -it -v path/to/project:/srv/jekyll -p 4000:4000 arvikon/docis"
LABEL maintainer="arvikon@outlook.com"
LABEL org.label-schema.vcs-url="https://github.com/arvikon/docis-docker"
LABEL org.label-schema.vcs-ref=${VCS_REF}
# Set temporary working directory for image building
WORKDIR /tmp
# Install all external utils, leaving only the compiled/installed
# binaries behind to minimize the footprint of the image layer.
RUN apk update \
  && apk --no-cache add \
    # runtime deps
    # ruby dev tools
    ruby-dev \
    # node
    npm \
    # utils
    gcc \
    musl-dev \
    curl \
    jq \
    libc6-compat \
    libxml2-utils \
    make \
    util-linux \
    # image_optim deps
    advancecomp \
    gifsicle \
    jpeg \
    jpegoptim \
    optipng \
    pngcrush \
    pngquant \
    zlib \
  && apk add jhead oxipng editorconfig-checker yamllint --update-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
  # build deps
  && apk add --virtual build-dependencies build-base \
  # pngout
  && wget https://www.jonof.id.au/files/kenutils/pngout-${PNGOUT_VERSION}-linux-static.tar.gz \
  && tar zxf pngout-${PNGOUT_VERSION}-linux-static.tar.gz \
  && cd pngout-${PNGOUT_VERSION}-linux-static \
  && cp -f aarch64/pngout-static /usr/local/bin/pngout \
  # svgo, markdownlint
  && npm i -g svgo markdownlint-cli2 \
  # ruby gems
  && gem install \
    bundler \
    jekyll \
    html-proofer \
    image_optim \
    image_optim_pack \
  # vale
  && wget https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz \
  && tar zxf vale_${VALE_VERSION}_Linux_64-bit.tar.gz \
  && cp -f vale /usr/local/bin \
  # cleanup
  && rm -rf /usr/share/ri \
  && rm -rf /tmp/* \
  && apk del build-dependencies \
  && rm -rf /var/lib/apt/lists/*
# Set image working directory
WORKDIR /srv/jekyll
# Set image volume to mount
VOLUME /srv/jekyll
# Expose ports for Jekyll
EXPOSE 35729
EXPOSE 4000
CMD [ "sh" ]