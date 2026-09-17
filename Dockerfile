# =========================================================
# CASA TEXTIL
# n8n 2.35.0 + Python + FFmpeg + Edge-TTS
# =========================================================

# ---------------------------------------------------------
# ETAPA 1
# Tomamos el n8n oficial ya construido
# ---------------------------------------------------------

FROM docker.n8n.io/n8nio/n8n:2.35.0 AS n8n


# ---------------------------------------------------------
# ETAPA 2
# Imagen final con Node + Python + FFmpeg
# ---------------------------------------------------------

FROM node:24.18.1-alpine3.24

USER root

# ---------------------------------------------------------
# Instalar herramientas del sistema
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
# Instalar librerías Python
# ---------------------------------------------------------

RUN pip3 install --no-cache-dir \
    edge-tts \
    requests \
    --break-system-packages

# ---------------------------------------------------------
# Copiar n8n 2.35.0 desde la imagen oficial
# ---------------------------------------------------------

COPY --from=n8n \
    /usr/local/lib/node_modules/n8n \
    /usr/local/lib/node_modules/n8n

# ---------------------------------------------------------
# Copiar el entrypoint oficial de n8n
# ---------------------------------------------------------

COPY --from=n8n \
    /docker-entrypoint.sh \
    /docker-entrypoint.sh

# ---------------------------------------------------------
# Crear acceso al comando n8n
# ---------------------------------------------------------

RUN mkdir -p /usr/local/bin && \
    ln -sf /usr/local/lib/node_modules/n8n/bin/n8n /usr/local/bin/n8n

# ---------------------------------------------------------
# Directorio para los scripts de Casa Textil
# ---------------------------------------------------------

RUN mkdir -p /opt/scripts

COPY scripts/ /opt/scripts/

# ---------------------------------------------------------
# Permisos
# ---------------------------------------------------------

RUN chown -R node:node /opt/scripts && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node

# ---------------------------------------------------------
# Variables necesarias para resolver módulos globales
# ---------------------------------------------------------

ENV NODE_ENV=production
ENV NODE_PATH=/usr/local/lib/node_modules
ENV SHELL=/bin/sh

# ---------------------------------------------------------
# Verificaciones durante el build
# ---------------------------------------------------------

RUN node --version && \
    python3 --version && \
    ffmpeg -version && \
    n8n --version && \
    python3 -c "import requests; print('requests OK')" && \
    python3 -c "import edge_tts; print('edge-tts OK')"

# ---------------------------------------------------------
# Puerto de n8n
# ---------------------------------------------------------

EXPOSE 5678

# ---------------------------------------------------------
# Usuario normal de n8n
# ---------------------------------------------------------

USER node

# ---------------------------------------------------------
# Entrypoint oficial
# ---------------------------------------------------------

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

CMD ["start"]
