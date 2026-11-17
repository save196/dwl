FROM docker.io/library/ubuntu:26.04 AS build

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libwlroots-0.19-dev meson glslang-tools hwdata xwayland \
        build-essential git ca-certificates libfcft-dev \
    && rm -rf /var/lib/apt/lists/*

ARG WLROOTS_VERSION
RUN git clone --depth 1 -b "$WLROOTS_VERSION" https://gitlab.freedesktop.org/wlroots/wlroots.git /tmp/wlroots \
    && meson setup /tmp/wlroots/build /tmp/wlroots --prefix=/opt/wlroots --libdir=lib \
        --default-library=static -Dexamples=false \
    && ninja -C /tmp/wlroots/build install \
    && rm -rf /tmp/wlroots

ENV PKG_CONFIG_PATH=/opt/wlroots/lib/pkgconfig
WORKDIR /build
COPY . .
RUN make "PKG_CONFIG=pkg-config --static" clean dwl

FROM scratch
COPY --from=build /build/dwl /build/config.h /build/*-protocol.h /
