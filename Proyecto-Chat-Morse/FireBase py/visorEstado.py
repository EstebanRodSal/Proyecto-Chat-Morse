#Este programa se encarga de que cada vez que el archivo que contiene el ultimo mensaje enviado localmente sufre cambios ejecuta 
#el programa encargado de subir el mensaje a firebase

import time
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Define la ruta al archivo que deseas monitorear
archivo_a_monitorear = r"C:\Users\esteb\OneDrive - Estudiantes ITCR\TEC\Semestre 2\Arquitectura de computadores\Proyecto-Chat-Morse\FireBase py\UltimoMensaje.txt"

# Define la ruta al programa que deseas ejecutar cuando se detecten cambios en el archivo
programa_a_ejecutar = "subirArchivo.py"

# Crea una clase personalizada que maneje los eventos del sistema de archivos
class MiManejadorDeEventos(FileSystemEventHandler):
    def on_created(self, event):
        if event.src_path == archivo_a_monitorear:
            print("El archivo ha sido creado.")

    def on_deleted(self, event):
        if event.src_path == archivo_a_monitorear:
            print("El archivo ha sido eliminado.")

    def on_modified(self, event):
        if event.src_path == archivo_a_monitorear:
            print("El archivo ha sido modificado. Ejecutando el programa...")
            subprocess.run(["python", programa_a_ejecutar])  # Ejecuta el programa deseado

# Crea un observador que utilizará el manejador de eventos personalizado
observer = Observer()
observer.schedule(MiManejadorDeEventos(), path=r"C:\Users\esteb\OneDrive - Estudiantes ITCR\TEC\Semestre 2\Arquitectura de computadores\Proyecto-Chat-Morse\FireBase py")

# Inicia la observación
observer.start()

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    observer.stop()

# Detén el observador cuando termines
observer.join()


