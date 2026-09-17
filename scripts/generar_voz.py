# -*- coding: utf-8 -*-
"""Agente Casa Textil - Paso 2: voz en off con IA gratis (Edge-TTS de Microsoft)
+ subtítulos .srt sincronizados generados desde las marcas de palabra."""
import asyncio, json, os
import edge_tts

BASE = "/opt/scripts"
GUION = os.path.join(BASE, "guion.json")
VOZ = os.path.join(BASE, "voz.mp3")
SRT = os.path.join(BASE, "voz.srt")
VOICE = os.getenv("VOZ_TTS", "es-MX-DaliaNeural")  # voz femenina en español mexicano

def a_srt(segundos):
    ms = int(round(segundos * 1000))
    h, ms = divmod(ms, 3600000)
    m, ms = divmod(ms, 60000)
    s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

async def main():
    with open(GUION, encoding="utf-8") as f:
        guion = json.load(f)
    comunicador = edge_tts.Communicate(guion["voz"], VOICE)
    palabras = []
    with open(VOZ, "wb") as audio:
        async for chunk in comunicador.stream():
            if chunk["type"] == "audio":
                audio.write(chunk["data"])
            elif chunk["type"] == "WordBoundary":
                palabras.append((chunk["offset"] / 1e7, chunk["duration"] / 1e7, chunk["text"]))
    # Agrupar palabras en líneas de subtítulo cortas
    lineas, actual, inicio = [], [], None
    for ini, dur, palabra in palabras:
        if inicio is None:
            inicio = ini
        actual.append((ini, dur, palabra))
        texto_linea = " ".join(p[2] for p in actual)
        if len(texto_linea) > 34 or (ini + dur - inicio) > 4.0:
            lineas.append((inicio, ini + dur, texto_linea))
            actual, inicio = [], None
    if actual:
        fin = actual[-1][0] + actual[-1][1]
        lineas.append((inicio, fin, " ".join(p[2] for p in actual)))
    with open(SRT, "w", encoding="utf-8") as f:
        for n, (ini, fin, t) in enumerate(lineas, 1):
            f.write(f"{n}\n{a_srt(ini)} --> {a_srt(fin)}\n{t}\n\n")
    print(f"Audio: {VOZ} | Subtítulos: {len(lineas)} líneas")

asyncio.run(main())
