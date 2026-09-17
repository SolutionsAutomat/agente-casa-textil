# 🤖 Agente de Contenido Automático — Casa Textil

Sistema completo para generar 2 videos semanales con IA (costo $0) y enviártelos
por Telegram para aprobación. Publicación en redes vía Buffer (gratis) o APIs directas.

## ¿Qué hay en cada archivo?

| Archivo | Qué es |
|---|---|
| `Dockerfile` | La "receta" para que Render instale n8n + Python + ffmpeg juntos |
| `workflow-casa-textil.json` | El cerebro del agente (19 nodos). Se importa dentro de n8n |
| `scripts/generar_imagenes.py` | Crea 5 imágenes por video con IA (Pollinations, gratis) |
| `scripts/generar_voz.py` | Genera la voz en off + subtítulos sincronizados (Edge-TTS, gratis) |
| `scripts/montar_video.py` | Une todo en el video final vertical con ffmpeg (Ken Burns + música) |
| `scripts/guion_ejemplo.json` | Ejemplo del formato de guion que produce Gemini |
| `PROMPT_MAESTRO.md` | La personalidad y reglas de contenido de la marca |
| `GUIA_INSTALACION.md` | ⭐ EMPIEZA AQUÍ — instalación paso a paso para no programadores |

## Flujo resumido

Lunes y jueves 9am → Gemini escribe guion → te llega por Telegram →
respondes APROBAR o CAMBIAR → Python genera imágenes + voz + video →
recibes el video final listo para publicar.

## Costo mensual: $0
- Gemini API: gratis (1,500 solicitudes/día)
- Pollinations (imágenes): gratis sin límite práctico
- Edge-TTS (voz): gratis
- Render + n8n self-hosted: gratis (con UptimeRobot para que no se duerma)
- Telegram: gratis
- Buffer: gratis (3 canales, 10 posts en cola por canal)
