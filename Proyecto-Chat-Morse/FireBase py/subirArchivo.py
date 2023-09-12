#Este programa se encarga de subir el ultimo mensaje enviado por el usuario local a firebase

import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage

# Ruta al archivo de credenciales de Firebase
cred = credentials.Certificate(r'C:\Users\esteb\OneDrive - Estudiantes ITCR\TEC\Semestre 2\Arquitectura de computadores\Proyecto-Chat-Morse\FireBase py\KEY.json')

# Inicializar la aplicación de Firebase
firebase_admin.initialize_app(cred, {
    'storageBucket': 'chat-morse.appspot.com'
})

def upload_file(file_path, destination_path):
    try:
        # Obtener una referencia al bucket de Firebase Storage
        bucket = storage.bucket()

        # Verificar si el archivo ya existe en el bucket
        blob = bucket.blob(destination_path)
        if blob.exists():
            blob.delete()  # Eliminar el archivo existente

        # Subir el archivo
        blob.upload_from_filename(file_path)

        print(f"Archivo '{file_path}' subido exitosamente a '{destination_path}'")

    except Exception as e:
        print(f"Error al subir el archivo: {str(e)}")

if __name__ == "__main__":
    file_to_upload = r'C:\Users\esteb\OneDrive - Estudiantes ITCR\TEC\Semestre 2\Arquitectura de computadores\Proyecto-Chat-Morse\FireBase py\UltimoMensaje.txt'  # Ruta del archivo local que deseas subir
    destination_blob = 'UltimoMensaje.txt'  # Ruta de destino en Firebase Storage
    

    upload_file(file_to_upload, destination_blob)
