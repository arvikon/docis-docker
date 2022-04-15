# Create yamllint binary with PyInstaller
FROM six8/pyinstaller-alpine
ENV YAMLLINT_VER="1.26.3"
RUN \
  wget https://github.com/adrienverge/yamllint/archive/v${YAMLLINT_VER}.tar.gz \
  && tar zxf v${YAMLLINT_VER}.tar.gz \
  && cd yamllint-${YAMLLINT_VER} \
  && python setup.py install \
  && cd yamllint \
  && pyinstaller --add-data ./conf/default.yaml:yamllint/conf --add-data ./conf/relaxed.yaml:yamllint/conf --clean --name yamllint --noconfirm --onefile ./__main__.py \
  && cp -f ./dist/yamllint /srv
#
# Define base image
FROM ruby:2.7.3-alpine
#
# Define environment variables for library versions
# Based on https://hub.docker.com/r/colthreepv/docker-image_optim/dockerfile
ENV \
  # https://github.com/mozilla/mozjpeg/releases
  # MOZJPEG_VERSION="4.0.2" \
  # https://github.com/danielgtaylor/jpeg-archive/releases
  # JPEGARCHIVE_VERSION="2.2.0" \
  # https://static.jonof.id.au/dl/kenutils/
  PNGOUT_VERSION="20200115" \
  # https://github.com/errata-ai/vale/releases
  VALE_VERSION="2.15.5"
#
# Set build arguments
ARG BUILD_DATE
ARG BUILD_VER
ARG VCS_REF
#
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
# LABEL org.label-schema.vendor=
#
# Copy yamllint binary
COPY --from=0 /srv/yamllint /usr/local/bin/
#
# Copy yamllint binary (image is outdated)
# COPY --from=fleshgrinder/yamllint /usr/local/bin/yamllint /usr/local/bin/
#
# Copy Vale binary (image is behind releases)
# COPY --from=jdkato/vale /bin/vale /usr/local/bin/
#
# Set temporary working directory for image building
WORKDIR /tmp
#
# Install all external utils, leaving only the compiled/installed
# binaries behind to minimize the footprint of the image layer.
RUN apk update && apk --no-cache add \
  # runtime deps
  # ruby dev tools
  ruby-dev \
  # node
  npm \
  # utils
  gcc \
  musl-dev \
  curl \
  libc6-compat \
  make \
  util-linux \
  # image_optim deps
  gifsicle \
  jpeg \
  jpegoptim \
  optipng \
  pngcrush \
  pngquant \
  zlib \
  && apk add jhead advancecomp oxipng --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
  # build deps
  && apk add --virtual build-dependencies \
  build-base \
  # mozjpeg deps
  # pkgconf autoconf automake libtool nasm \
  # mozjpeg
  # && wget https://github.com/mozilla/mozjpeg/archive/v${MOZJPEG_VERSION}.tar.gz \
  # && tar zxf v${MOZJPEG_VERSION}.tar.gz \
  # && cd mozjpeg-${MOZJPEG_VERSION} \
  # && autoreconf -fiv && ./configure && make && make install \
  # && cd .. \
  # jpeg-recompress (from jpeg-archive)
  # && wget https://github.com/danielgtaylor/jpeg-archive/archive/v${JPEGARCHIVE_VERSION}.tar.gz \
  # && tar zxf v${JPEGARCHIVE_VERSION}.tar.gz \
  # && cd jpeg-archive-${JPEGARCHIVE_VERSION} \
  # && make && make install \
  # && cd .. \
  # pngout
  && wget https://static.jonof.id.au/dl/kenutils/pngout-${PNGOUT_VERSION}-linux-static.tar.gz \
  && tar zxf pngout-${PNGOUT_VERSION}-linux-static.tar.gz \
  && cd pngout-${PNGOUT_VERSION}-linux-static \
  && cp -f aarch64/pngout-static /usr/local/bin/pngout \
  # svgo, markdownlint
  && npm i -g svgo markdownlint-cli2 \
  # ruby gems
  && gem install bundler jekyll jekyll-liquify-alt html-proofer image_optim \
  # vale
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