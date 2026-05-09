# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS builder

ARG EMBOSS_TAG=EMBOSS-6.6.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        build-essential \
        autoconf \
        automake \
        libtool \
        pkg-config \
        libexpat1-dev \
        zlib1g-dev \
        libx11-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${EMBOSS_TAG}" https://github.com/kimrutherford/EMBOSS.git emboss
WORKDIR /src/emboss
RUN ./configure --prefix=/opt/emboss \
    && make -j"$(nproc)" \
    && make install

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        emboss-data \
        libexpat1 \
        libx11-6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/emboss /opt/emboss
ENV PATH="/opt/emboss/bin:${PATH}"

RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -eu' \
    'if [ "${1:-}" = "emboss" ]; then' \
    '  shift' \
    'fi' \
    'if [ "${1:-}" = "" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then' \
    '  echo "EMBOSS container entrypoint"' \
    '  echo "Usage: emboss <program> [args]"' \
    '  echo "Example: emboss seqret -help"' \
    '  exec wossname -auto' \
    'fi' \
    'if command -v "$1" >/dev/null 2>&1; then' \
    '  cmd="$1"' \
    '  shift' \
    '  exec "$cmd" "$@"' \
    'fi' \
    'echo "Unknown EMBOSS program: $1" >&2' \
    'exit 2' \
    > /usr/local/bin/emboss \
    && chmod +x /usr/local/bin/emboss

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/emboss"]
CMD ["--help"]
