# Imagen de n8n + Python + ffmpeg para el agente de Casa Textil
FROM alpine:latest AS alpine
FROM n8nio/n8n:latest

# Restaurar apk (n8n v2.x lo eliminó por seguridad)
COPY --from=alpine /sbin/apk /sbin/apk
COPY --from=alpine /usr/lib/libapk.so* /usr/lib/

USER root

# Python, ffmpeg y fuentes para subtítulos
RUN apk add --no-cache python3 py3-pip ffmpeg ttf-dejavu

# Librerías de Python (Edge-TTS = voz IA gratis, requests = descarga de imágenes)
RUN pip3 install --no-cache-dir edge-tts requests --break-system-packages \
    || pip3 install --no-cache-dir edge-tts requests

# Copiar scripts a ruta absoluta (sin cambiar el WORKDIR original de n8n)
COPY --chmod=777 scripts/ /opt/scripts/

USER node
