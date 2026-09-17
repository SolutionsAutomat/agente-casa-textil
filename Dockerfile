# Imagen de n8n + Python + ffmpeg para el agente de Casa Textil
FROM n8nio/n8n:latest

USER root

# Python, ffmpeg y fuentes para los subtítulos
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip ffmpeg fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

# Librerías de Python (Edge-TTS = voz IA gratis, requests = descarga de imágenes)
RUN pip3 install --no-cache-dir edge-tts requests --break-system-packages \
    || pip3 install --no-cache-dir edge-tts requests

# Copiar los scripts del agente
WORKDIR /opt/scripts
COPY scripts/ /opt/scripts/
RUN chmod -R 777 /opt/scripts

# n8n vuelve a correr con su usuario normal
USER node
