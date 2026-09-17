# =========================================================
# Casa Textil - n8n 2.35.0 + Python + FFmpeg + Edge TTS
# =========================================================

FROM n8nio/n8n:2.35.0

USER root

# ---------------------------------------------------------
# Restaurar apk (la imagen n8n v2 no lo incluye)
# ---------------------------------------------------------

COPY --from=alpine:3.22 /sbin/apk /sbin/apk
COPY --from=alpine:3.22 /lib/apk /lib/apk
COPY --from=alpine:3.22 /usr/lib/libapk* /usr/lib/

# ---------------------------------------------------------
# Instalar Python, FFmpeg y fuentes
# ---------------------------------------------------------

RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    ttf-dejavu

# ---------------------------------------------------------
# Instalar librerías Python
# ---------------------------------------------------------

RUN pip3 install --no-cache-dir \
    edge-tts \
    requests \
    --break-system-packages

# ---------------------------------------------------------
# Crear directorio de scripts
# ---------------------------------------------------------

RUN mkdir -p /opt/scripts

# ---------------------------------------------------------
# Copiar scripts de Casa Textil
# ---------------------------------------------------------

COPY scripts/ /opt/scripts/

# ---------------------------------------------------------
# Permisos
# ---------------------------------------------------------

RUN chmod -R 755 /opt/scripts && \
    chown -R node:node /opt/scripts

# ---------------------------------------------------------
# Verificaciones durante el build
# ---------------------------------------------------------

RUN python3 --version && \
    ffmpeg -version && \
    python3 -c "import requests; print('requests OK')" && \
    python3 -c "import edge_tts; print('edge-tts OK')"

# ---------------------------------------------------------
# Volver al usuario n8n
# ---------------------------------------------------------

USER node

# No colocar WORKDIR ni ENTRYPOINT personalizados.
# La imagen oficial de n8n conserva su arranque normal.
