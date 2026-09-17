# =========================================================
# CASA TEXTIL
# n8n 2.35.0 + Python + FFmpeg + Edge-TTS
# =========================================================

FROM n8nio/n8n:2.35.0 AS n8n

FROM node:24.18.1-alpine3.24

USER root

# ---------------------------------------------------------
# Sistema
# ---------------------------------------------------------

RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    ttf-dejavu \
    tini \
    ca-certificates \
    tzdata

# ---------------------------------------------------------
# Python
# ---------------------------------------------------------

RUN pip3 install --no-cache-dir \
    edge-tts \
    requests \
    --break-system-packages

# ---------------------------------------------------------
# n8n
# ---------------------------------------------------------

COPY --from=n8n \
    /usr/local/lib/node_modules/n8n \
    /usr/local/lib/node_modules/n8n

# Crear comando n8n
RUN mkdir -p /usr/local/bin && \
    ln -s /usr/local/lib/node_modules/n8n/bin/n8n /usr/local/bin/n8n

# ---------------------------------------------------------
# Scripts Casa Textil
# ---------------------------------------------------------

RUN mkdir -p /opt/scripts

COPY scripts/ /opt/scripts/

# ---------------------------------------------------------
# Directorios y permisos
# ---------------------------------------------------------

RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node && \
    chown -R node:node /opt/scripts && \
    chmod -R 755 /opt/scripts

# ---------------------------------------------------------
# Configuración n8n
# ---------------------------------------------------------

ENV NODE_ENV=production
ENV NODE_PATH=/usr/local/lib/node_modules
ENV N8N_RELEASE_TYPE=stable
ENV N8N_PORT=10000
ENV N8N_LISTEN_ADDRESS=0.0.0.0
ENV PORT=10000
ENV SHELL=/bin/sh

# ---------------------------------------------------------
# Directorio de trabajo oficial de n8n
# ---------------------------------------------------------

WORKDIR /home/node

# ---------------------------------------------------------
# Verificaciones
# ---------------------------------------------------------

RUN node --version && \
    python3 --version && \
    ffmpeg -version && \
    n8n --version && \
    python3 -c "import requests; print('requests OK')" && \
    python3 -c "import edge_tts; print('edge-tts OK')"

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

ENTRYPOINT ["tini", "--", "n8n"]

CMD ["start"]
