# Build a named and tagged image        : docker build --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION=1.1 -t arvikon/docis .
# Name and tag the image (if built w/o) : docker tag IMAGE_ID name:tag
# Upload the image to hub               : docker push arvikon/docis:$BUILD_VERSION
#
# Define base image
FROM ruby:2.6.5-alpine
#
# Define environment variables for library versions
# Based on https://hub.docker.com/r/colthreepv/docker-image_optim/dockerfile
ENV \
  # https://github.com/mozilla/mozjpeg/releases
  MOZJPEG_VERSION="3.3.1" \
  # https://github.com/danielgtaylor/jpeg-archive/releases
  JPEGARCHIVE_VERSION="2.2.0" \
  # https://static.jonof.id.au/dl/kenutils/
  PNGOUT_VERSION="20200115" \
  # https://github.com/errata-ai/vale/releases
  VALE_VERSION="2.1.0"
#
# Set build arguments
ARG BUILD_DATE
ARG BUILD_VERSION
#
# Add image metadata
# See http://label-schema.org/rc1/
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="arvikon/docis"
LABEL org.label-schema.description="Jekyll-centric toolkit to proof, optimize, and verify your static site content"
LABEL org.label-schema.version=${BUILD_VERSION}
LABEL org.label-schema.build-date=${BUILD_DATE}
LABEL org.label-schema.url="https://hub.docker.com/r/arvikon/docis"
LABEL org.label-schema.usage="https://hub.docker.com/r/arvikon/docis"
LABEL org.label-schema.docker.cmd="docker run --rm -it -v path/to/project:/srv/jekyll -p 4000:4000 arvikon/docis"
LABEL maintainer="arvikon@outlook.com"
LABEL org.label-schema.vcs-url="https://github.com/arvikon/docis-docker"
# LABEL org.label-schema.vcs-ref=
# LABEL org.label-schema.vendor=
#
# Copy yamllint binary
COPY --from=flintci/yamllint /usr/local/bin/yamllint /usr/local/bin/
#
# Copy Vale binary
# COPY --from=jdkato/vale /bin/vale /usr/local/bin/
#
# Set temporary working directory for image building
WORKDIR /tmp
#
# Install all external utilities, leaving only the compiled/installed
# binaries behind to minimize the footprint of the image layer.
RUN apk update && apk --no-cache add \
  # runtime dependencies
  # ruby dev tools
  ruby-dev \
  # svgo deps
  npm \
  # utils
  curl \
  make \
  # image_optim deps
  gifsicle \
  jpegoptim \
  optipng \
  pngcrush \
  pngquant \
  jpeg \
  && apk add jhead advancecomp --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
  # build dependencies
  && apk add --virtual build-dependencies \
  build-base \
  # mozjpeg
  pkgconfig autoconf automake libtool nasm \
  # jpeg-recompress (from jpeg-archive along with mozjpeg dependency)
  && curl -L -O https://github.com/mozilla/mozjpeg/archive/v${MOZJPEG_VERSION}.tar.gz \
  && tar zxf v${MOZJPEG_VERSION}.tar.gz \
  && cd mozjpeg-${MOZJPEG_VERSION} \
  && autoreconf -fiv && ./configure && make && make install \
  && cd .. \
  && curl -L -O https://github.com/danielgtaylor/jpeg-archive/archive/v${JPEGARCHIVE_VERSION}.tar.gz \
  && tar zxf v${JPEGARCHIVE_VERSION}.tar.gz \
  && cd jpeg-archive-${JPEGARCHIVE_VERSION} \
  && make && make install \
  && cd .. \
  # pngout (binary distrib)
  && curl -L -O https://static.jonof.id.au/dl/kenutils/pngout-${PNGOUT_VERSION}-linux-static.tar.gz \
  && tar zxf pngout-${PNGOUT_VERSION}-linux-static.tar.gz \
  && cd pngout-${PNGOUT_VERSION}-linux-static \
  && cp -f aarch64/pngout-static /usr/local/bin/pngout \
  # svgo
  && npm install -g svgo \
  # ruby gems
  && gem install jekyll bundler html-proofer image_optim \
  # Get vale from github
  && wget https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz \
  && tar zxf vale_${VALE_VERSION}_Linux_64-bit.tar.gz \
  && cp -f vale /usr/local/bin \
  # cleanup
  && rm -rf /usr/share/ri \
  && rm -rf /tmp/* \
  && apk del build-dependencies \
  && rm -rf /var/lib/apt/lists/*
#
# Set image working directory
WORKDIR /srv/jekyll
#
# Set image volume to mount
VOLUME /srv/jekyll
#
# Expose ports for Jekyll
EXPOSE 35729
EXPOSE 4000