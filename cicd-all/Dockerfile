FROM ghcr.io/justin-yan/image/base:0.0.1

ARG BASE_PYTHON=3.11.4

ENV LANG="C.UTF-8" \
    DEBIAN_FRONTEND=noninteractive \
    UV_TOOL_BIN_DIR="/usr/local/bin" \
    PATH="/root/.local/bin:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:0.11.8 /uv /uvx /bin/

RUN uv python install "${BASE_PYTHON}"

RUN uv tool install just-bin==1.43.0 && \
    uv tool install hadolint-bin==2.14.0 && \
    uv tool install scc-bin==3.5.0 && \
    uv tool install gh-bin==2.81.0
