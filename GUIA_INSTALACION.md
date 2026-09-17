# 🚀 GUÍA DE INSTALACIÓN PASO A PASO (para no programadores)

## PARTE 1 — Conseguir las 3 claves gratis (30 minutos)

### 1. Bot de Telegram (tu control remoto del agente)
1. Abre Telegram y busca **@BotFather**
2. Escribe `/newbot` y dale un nombre (ej: "Agente Casa Textil")
3. Te da un **TOKEN** (largo, como `7123...:AAF...`). GUÁRDALO — es tu TELEGRAM_BOT_TOKEN
4. Escribele a tu bot cualquier mensaje (ej: "hola")
5. Abre en tu navegador: `https://api.telegram.org/bot<TU_TOKEN>/getUpdates`
6. Busca el número `"chat":{"id":123456789` — ese número es tu TELEGRAM_CHAT_ID

### 2. Clave de Google Gemini (el cerebro que escribe guiones)
1. Entra a **aistudio.google.com** con tu cuenta de Google
2. Menú "Get API key" → "Create API key"
3. Copia la clave — es tu GEMINI_API_KEY (gratis: ~1,500 usos al día)

### 3. Cuenta de GitHub (para subir los archivos)
1. Entra a **github.com** y crea cuenta gratis
2. Crea un repositorio nuevo llamado `agente-casa-textil` (público o privado)
3. Sube TODOS los archivos de esta carpeta (botón "uploading an existing file",
   arrastra: Dockerfile, la carpeta scripts completa). NO subas workflow-casa-textil.json
   todavía, ese se importa dentro de n8n.

## PARTE 2 — Desplegar en Render

**IMPORTANTE:** tu n8n actual en Render probablemente fue creado con la imagen estándar.
Necesitas reconstruirlo con este Dockerfile (que añade Python + ffmpeg). No pierdes nada:
exporta tus workflows actuales primero (en n8n: Workflows → Descargar).

1. En Render: **New → Web Service → conecta tu repositorio** `agente-casa-textil`
2. Render detecta el Dockerfile solo. Región: la más cercana a México (Oregon).
3. En **Environment Variables** agrega:
   - `GEMINI_API_KEY` = tu clave de Google
   - `TELEGRAM_CHAT_ID` = tu chat id de Telegram
   - `WEBHOOK_URL` = https://TU-SERVICIO.onrender.com/  (la URL que te dará Render)
   - `N8N_ENCRYPTION_KEY` = inventa una contraseña larga y guárdala
   - `N8N_HOST` = TU-SERVICIO.onrender.com
   - `N8N_PROTOCOL` = https
4. Crea el servicio. Espera 5-10 minutos a que termine de construir.
5. Entra a `https://TU-SERVICIO.onrender.com` y crea tu usuario de n8n.

## PARTE 3 — Configurar el workflow

1. En n8n: **Workflows → Import from File** → sube `workflow-casa-textil.json`
2. Crea la credencial de Telegram: Credentials → New → Telegram API → pega tu TELEGRAM_BOT_TOKEN
3. Abre el workflow y en los 4 nodos de Telegram selecciona esa credencial
4. Activa el workflow (toggle arriba a la derecha)

## PARTE 4 — Evitar que Render "se duerma" (GRATIS)

El plan gratis de Render apaga el servicio tras 15 min sin uso.
1. Crea cuenta en **uptimerobot.com** (gratis)
2. Add Monitor → HTTP(s) → URL: `https://TU-SERVICIO.onrender.com/` → intervalo 5 min
3. Listo: el agente siempre estará despierto

## PARTE 5 — Tu primera prueba

1. En el workflow, clic derecho al nodo "Cuándo - Lunes y Jueves 9am" → **Execute step**
2. En 1-2 minutos recibirás el guion en Telegram
3. Responde **APROBAR** → en ~5-10 min recibes el video (1080x1920, con voz y subtítulos)
4. Si respondes **CAMBIAR: que sea más corto y mencione precios**, el agente reescribe el guion

## PARTE 6 — Música de fondo (opcional)

1. Descarga una pista libre de derechos en **pixabay.com/music** (suave, tipo lo-fi)
2. Guárdala como `musica.mp3` dentro de `scripts/assets/`
3. Súbela a tu repo de GitHub y redeploya en Render (Manual Deploy → Deploy latest commit)

## ⚠️ Advertencias honestas

- **Disco efímero de Render**: si Render reinicia tu servicio, los archivos temporales
  (guion.json, videos) se pierden. No pasa nada: el workflow vuelve a generar todo.
  Exporta tus workflows de n8n cada cierto tiempo como respaldo.
- **Primera generación de imágenes**: Pollinations (gratis) a veces tarda 1-3 min por imagen.
- **Presupuesto de ejecución**: los nodos de Python pueden tardar 5-15 min en total;
  si n8n corta la ejecución, revisa los logs (Render → Logs).
