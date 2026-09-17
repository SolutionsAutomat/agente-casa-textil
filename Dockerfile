# =========================================================
# CASA TEXTIL
# n8n 2.35.0 + Python + FFmpeg + Edge-TTS
# =========================================================

FROM node:24.18.1-bookworm-slim

USER root

# ---------------------------------------------------------
# Variables
# ---------------------------------------------------------

ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=stable
ENV N8N_PORT=10000
ENV N8N_LISTEN_ADDRESS=0.0.0.0
ENV PORT=10000
ENV NODE_PATH=/usr/local/lib/node_modules
ENV SHELL=/bin/sh

# ---------------------------------------------------------
# Sistema
# ---------------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        ffmpeg \
        fonts-dejavu \
        tini \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# n8n 2.35.0
#
# Permitimos los scripts de instalación necesarios para
# módulos nativos usados por n8n.
# ---------------------------------------------------------

RUN npm install -g n8n@2.35.0 \
    --allow-scripts=@parcel/watcher,isolated-vm,sqlite3,agent-browser,oracledb,protobufjs,msgpackr-extract,ssh2,@sentry/node-native-stacktrace,@sentry/node-cpu-profiler,@confluentinc/kafka-javascript

# ---------------------------------------------------------
# Entorno virtual Python
# ---------------------------------------------------------

RUN python3 -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# ---------------------------------------------------------
# Python packages
# ---------------------------------------------------------

RUN pip install --no-cache-dir \
    edge-tts \
    requests

# ---------------------------------------------------------
# Scripts Casa Textil
# ---------------------------------------------------------

RUN mkdir -p /opt/scripts

COPY scripts/ /opt/scripts/

RUN chmod -R 755 /opt/scripts

# ---------------------------------------------------------
# Directorios n8n
# ---------------------------------------------------------

RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node && \
    chown -R node:node /opt/scripts

# ---------------------------------------------------------
# Verificación
# ---------------------------------------------------------

RUN node --version && \
    npm --version && \
    python3 --version && \
    python --version && \
    ffmpeg -version && \
    n8n --version && \
    python -c "import requests; print('requests OK')" && \
    python -c "import edge_tts; print('edge-tts OK')"

# ---------------------------------------------------------
# Puerto
# ---------------------------------------------------------

EXPOSE 10000

# ---------------------------------------------------------
# Usuario n8n
# ---------------------------------------------------------

USER node

# ---------------------------------------------------------
# Arranque
# ---------------------------------------------------------

ENTRYPOINT ["tini", "--"]

CMD ["n8n", "start"]
