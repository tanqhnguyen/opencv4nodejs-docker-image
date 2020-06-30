FROM node:14.4-alpine3.10

LABEL maintainer="Tan Nguyen <tan.qh.nguyen@gmail.com>"

ARG OPENCV4NODEJS_AUTOBUILD_OPENCV_VERSION=4.3.0
ENV OPENCV4NODEJS_AUTOBUILD_OPENCV_VERSION=$OPENCV4NODEJS_AUTOBUILD_OPENCV_VERSION

RUN apk add --update --no-cache \
  # Build dependencies
  build-base clang clang-dev cmake pkgconf wget openblas openblas-dev \
  linux-headers git \
  # Image IO packages
  libjpeg-turbo libjpeg-turbo-dev \
  libpng libpng-dev \
  libwebp libwebp-dev \
  tiff tiff-dev \
  jasper-libs jasper-dev \
  openexr openexr-dev \
  # Video depepndencies
  ffmpeg-libs ffmpeg-dev \
  libavc1394 libavc1394-dev \
  gstreamer gstreamer-dev \
  gst-plugins-base gst-plugins-base-dev \
  libgphoto2 libgphoto2-dev && \
  apk add --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  --update --no-cache libtbb libtbb-dev && \
  # Update also musl to avoid an Alpine bug
  apk upgrade --repository http://dl-cdn.alpinelinux.org/alpine/edge/main musl && \
  # Fix libpng path
  ln -vfs /usr/include/libpng16 /usr/include/libpng && \
  ln -vfs /usr/include/locale.h /usr/include/xlocale.h

# https://github.com/npm/npm/issues/3849
RUN npm install -g opencv4nodejs --unsafe-perm

# Clean up
RUN cd / && apk del --purge build-base clang clang-dev cmake pkgconf wget openblas-dev \
  openexr-dev gstreamer-dev gst-plugins-base-dev libgphoto2-dev \
  libtbb-dev libjpeg-turbo-dev libpng-dev tiff-dev jasper-dev \
  ffmpeg-dev libavc1394-dev && \
  rm -vrf /var/cache/apk/*

ENV NODE_PATH=/usr/local/lib/node_modules

# make sure we have everything
RUN node -e "require('opencv4nodejs')"