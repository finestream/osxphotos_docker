FROM python:3.12-slim

# 1. Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 2. Global uv Storage (System-wide tool)
ENV UV_TOOL_BIN_DIR=/usr/local/bin
ENV UV_TOOL_DIR=/usr/local/share/uv/tools

# 3. Setup non-root user
ENV USER=osxuser
RUN useradd -m -s /bin/bash ${USER}

# 4. Setup Global Config & Data mounts
# Point XDG variables to the root-level /config directory
ENV XDG_CONFIG_HOME=/config
ENV XDG_CACHE_HOME=/config/cache
ENV XDG_DATA_HOME=/config/share

# Create directories and grant ownership to osxuser
RUN mkdir -p /config /output && chown -R ${USER}:${USER} /config /output
RUN chmod 755 /config /output

# 5. Install osxphotos as root
RUN uv tool install osxphotos --force && \
    chmod -R o+rx /usr/local/share/uv/tools

# 6. Document the expected mount points
# /config: for themes, logs, and osxphotos settings
# /output: for the exported photos
# /library: for the source Photos library (usually mounted as :ro)
VOLUME ["/config", "/output", "/library"]

# 7. Final setup
USER ${USER}
WORKDIR /osxphotos

ENTRYPOINT ["osxphotos"]
