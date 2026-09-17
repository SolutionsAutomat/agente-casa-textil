# -*- coding: utf-8 -*-
"""Agente Casa Textil - Paso 1: genera las imágenes de cada escena con IA gratis (Pollinations).
Lee guion.json (creado por n8n) y descarga una imagen vertical 9:16 por escena."""
import json, os, sys, time, urllib.parse, requests

BASE = "/opt/scripts"
GUION = os.path.join(BASE, "guion.json")
SALIDA = os.path.join(BASE, "escenas")
os.makedirs(SALIDA, exist_ok=True)

def descargar_imagen(prompt, destino, intentos=3):
    seed = abs(hash(os.path.basename(destino))) % 99999
    url = ("https://image.pollinations.ai/prompt/" + urllib.parse.quote(prompt)
           + f"?width=1080&height=1920&nologo=true&enhance=true&seed={seed}")
    for i in range(intentos):
        try:
            r = requests.get(url, timeout=180)
            if r.status_code == 200 and len(r.content) > 10000:
                with open(destino, "wb") as f:
                    f.write(r.content)
                print(f"OK: {destino}")
                return True
        except Exception as e:
            print(f"Intento {i+1} falló ({e}). Reintentando...")
        time.sleep(5)
    return False

def main():
    with open(GUION, encoding="utf-8") as f:
        guion = json.load(f)
    todo_ok = True
    for i, escena in enumerate(guion["escenas"]):
        destino = os.path.join(SALIDA, f"escena_{i:02d}.jpg")
        if os.path.exists(destino):
            print(f"Ya existe, se omite: {destino}")
            continue
        prompt_img = ("Fotografía profesional de interiorismo y telas, "
                      + escena["prompt"]
                      + ", iluminación cálida natural, estética editorial de revista de decoración, "
                        "texturas de tela muy visibles, alta calidad, formato vertical 9:16")
        print(f"Generando escena {i+1}/{len(guion['escenas'])}...")
        if not descargar_imagen(prompt_img, destino):
            print(f"ERROR: no se pudo generar la escena {i}")
            todo_ok = False
    sys.exit(0 if todo_ok else 1)

if __name__ == "__main__":
    main()
