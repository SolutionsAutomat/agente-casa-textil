# Imagen de n8n + Python + ffmpeg para el agente de Casa Textil
FROM n8nio/n8n:latest

USER root

# Python, ffmpeg y fuentes para subtítulos (Alpine usa apk)
RUN apk add --no-cache python3 py3-pip ffmpeg ttf-dejavu

# Librerías de Python (Edge-TTS = voz IA gratis, requests = descarga de imágenes)
RUN pip3 install --no-cache-dir edge-tts requests --break-system-packages \
    || pip3 install --no-cache-dir edge-tts requests

# Copiar la carpeta scripts completa (con assets incluido)
WORKDIR /opt/scripts
COPY scripts/ /opt/scripts/
RUN chmod -R 777 /opt/scripts

# n8n vuelve a correr con su usuario normal
USER node
