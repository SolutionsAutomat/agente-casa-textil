# -*- coding: utf-8 -*-
"""Agente Casa Textil - Paso 3: monta el video vertical con ffmpeg (gratis).
Ken Burns (zoom suave) + voz en off + subtítulos quemados + música opcional."""
import glob, os, subprocess, sys

BASE = "/opt/scripts"
ESCENAS = sorted(glob.glob(os.path.join(BASE, "escenas", "*.jpg")))
VOZ = os.path.join(BASE, "voz.mp3")
SRT = os.path.join(BASE, "voz.srt")
MUSICA = os.path.join(BASE, "assets", "musica.mp3")
FINAL = os.path.join(BASE, "video_final.mp4")
TMP = os.path.join(BASE, "tmp_segmentos")
FPS = 30

def duracion(archivo):
    out = subprocess.run(["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
                          "-of", "csv=p=0", archivo], capture_output=True, text=True)
    return float(out.stdout.strip())

def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError("ffmpeg falló:\n" + r.stderr[-900:])

def main():
    if not ESCENAS:
        sys.exit("No hay imágenes en escenas/. Ejecuta primero generar_imagenes.py")
    os.makedirs(TMP, exist_ok=True)
    total = duracion(VOZ)
    n = len(ESCENAS)
    dur = total / n
    frames = max(1, int(dur * FPS))

    segmentos = []
    for i, img in enumerate(ESCENAS):
        seg = os.path.join(TMP, f"seg_{i:02d}.mp4")
        if i % 2 == 0:  # zoom in / zoom out alternado
            z = f"z='min(1+0.0009*on,1.18)':d={frames}"
        else:
            z = f"z='max(1.18-0.0009*on,1.0)':d={frames}"
        vf = ("scale=2400:4266:force_original_aspect_ratio=increase,crop=2400:4266,"
              + "zoompan=" + z + ":x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps="
              + str(FPS) + ",format=yuv420p")
        run(["ffmpeg", "-y", "-loop", "1", "-i", img, "-vf", vf, "-t", f"{dur:.3f}",
             "-an", "-c:v", "libx264", "-preset", "veryfast", "-crf", "20", seg])
        segmentos.append(seg)
        print(f"Segmento {i+1}/{n} listo")

    lista = os.path.join(TMP, "lista.txt")
    with open(lista, "w") as f:
        for s in segmentos:
            f.write(f"file '{s}'\n")

    cmd = ["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", lista, "-i", VOZ]
    if os.path.exists(MUSICA):
        cmd += ["-stream_loop", "-1", "-i", MUSICA]
        fc = ("[0:v]subtitles='" + SRT + "':charenc=UTF-8[v];"
              + f"[1:a]volume=1.2[voz];[2:a]atrim=0:{total},volume=0.14[mus];"
              + "[voz][mus]amix=inputs=2:duration=first:normalize=0[a]")
    else:
        fc = "[0:v]subtitles='" + SRT + "':charenc=UTF-8[v];[1:a]volume=1.2[a]"
    cmd += ["-filter_complex", fc, "-map", "[v]", "-map", "[a]",
            "-c:v", "libx264", "-preset", "medium", "-crf", "20", "-pix_fmt", "yuv420p",
            "-c:a", "aac", "-b:a", "128k", "-shortest", FINAL]
    run(cmd)
    print(f"VIDEO FINAL: {FINAL} ({duracion(FINAL):.1f} segundos)")

if __name__ == "__main__":
    main()
