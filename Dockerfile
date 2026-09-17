# Imagen de n8n + Python + ffmpeg para el agente de Casa Textil
# (n8n v2.x eliminó apk por seguridad: lo restauramos desde Alpine primero)
FROM alpine:latest AS alpine
FROM n8nio/n8n:latest

# Restaurar el gestor de paquetes apk
COPY --from=alpine /sbin/apk /sbin/apk
COPY --from=alpine /usr/lib/libapk.so* /usr/lib/

USER root

# Python, ffmpeg y fuentes para subtítulos
RUN apk add --no-cache python3 py3-pip ffmpeg ttf-dejavu

# Librerías de Python (Edge-TTS = voz IA gratis, requests = descarga de imágenes)
RUN pip3 install --no-cache-dir edge-tts requests --break-system-packages \
    || pip3 install --no-cache-dir edge-tts requests

# Copiar la carpeta scripts completa (con --chmod para no depender de comandos extra)
WORKDIR /opt/scripts
COPY --chmod=777 scripts/ /opt/scripts/

# n8n vuelve a correr con su usuario normal
USER node
