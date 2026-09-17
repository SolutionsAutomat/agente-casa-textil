# Imagen de n8n + Python + ffmpeg para el agente de Casa Textil
FROM n8nio/n8n:latest

USER root

# Python, ffmpeg y fuentes para subtítulos (Alpine usa apk, no apt-get)
RUN apk add --no-cache python3 py3-pip ffmpeg ttf-dejavu

# Librerías de Python (Edge-TTS = voz IA gratis, requests = descarga de imágenes)
RUN pip3 install --no-cache-dir edge-tts requests --break-system-packages \
    || pip3 install --no-cache-dir edge-tts requests

# Copiar los scripts del agente (están en la raíz del repositorio)
WORKDIR /opt/scripts
COPY generar_imagenes.py generar_voz.py montar_video.py guion_ejemplo.json /opt/scripts/
COPY LEEME-musica.txt /opt/scripts/assets/LEEME-musica.txt
RUN chmod -R 777 /opt/scripts

# n8n vuelve a correr con su usuario normal
USER node
