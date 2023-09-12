include irvine32.inc


BUFFER_SIZE = 501
.data
;//Variables
hStdIn          dd 0
nRead           dd 0
spacePressed    db 0

_INPUT_RECORD STRUCT
EventType               WORD ?
WORD ? ; For alignment
UNION
KeyEvent              KEY_EVENT_RECORD          <>
MouseEvent            MOUSE_EVENT_RECORD        <>
WindowBufferSizeEvent WINDOW_BUFFER_SIZE_RECORD <>
MenuEvent             MENU_EVENT_RECORD         <>
FocusEvent            FOCUS_EVENT_RECORD        <>
ENDS
_INPUT_RECORD ENDS

InputRecord _INPUT_RECORD <>
ConsoleMode     dd 0

;//Variables de texto
msgClick        db ".", 0 ;//ClickIzquierdo
msgClickRight   db "-", 0 ;//ClickDerecho
msgClickScroll  db " ", 0 ;//ClickBtnScroll
msgSpace        db " / ", 0 ;//Espacio
msgExit         db "Mensaje enviado", 0

;//Variable que contiene el último mensaje mandado por el usuario
mensaje DWORD ?

;//Nuevas variables para el mensaje actual (Encargadas de regular los espacios entre palabras)
mensajeActual db 256 DUP(0); Ajusta el tamaño máximo del mensaje
longitudMensaje dd 0
.code


;//Variables para guardar la variable mensaje en un archivo txt

filename BYTE "C:\Users\esteb\OneDrive - Estudiantes ITCR\TEC\Semestre 2\Arquitectura de computadores\Proyecto-Chat-Morse\FireBase py\UltimoMensaje.txt", 0





main PROC

;//Ciclo principal
again : 

invoke GetStdHandle, STD_INPUT_HANDLE
mov   hStdIn, eax

invoke GetConsoleMode, hStdIn, ADDR ConsoleMode
mov eax, 0090h; ENABLE_MOUSE_INPUT | DISABLE_QUICK_EDIT_MODE | ENABLE_EXTENDED_FLAGS
invoke SetConsoleMode, hStdIn, eax



;//Ciclo de inserción de mensajes
.WHILE InputRecord.KeyEvent.wVirtualKeyCode != VK_RETURN
	invoke ReadConsoleInput, hStdIn, ADDR InputRecord, 1, ADDR nRead

	movzx  eax, InputRecord.EventType
	cmp eax, MOUSE_EVENT
	jne no_mouse_click

	mov[spacePressed], 0

	; Validar el botón del ratón
	test InputRecord.MouseEvent.dwButtonState, 1; Validar el clic izquierdo
	jz left

	RightClick :
		lea edx, msgClickRight; Validar el clic derecho
		Call WriteString
			

		;//Se agrega el caracter a la variable mensaje
		mov al, '-'; Carácter para clic izquierdo
		mov edi, OFFSET mensajeActual
		add edi, [longitudMensaje]
		mov[edi], al
		inc[longitudMensaje]
		jmp done

	left :
		test InputRecord.MouseEvent.dwButtonState, 2
		jz scrollBtn

	LeftClick :
		lea edx, msgClick
		Call WriteString
			

		;//Se agrega el caracter a la variable mensaje
		mov al, '.'; Carácter para clic izquierdo
		mov edi, OFFSET mensajeActual
		add edi, [longitudMensaje]
		mov[edi], al
		inc[longitudMensaje]
		jmp done

	scrollBtn :
		test InputRecord.MouseEvent.dwButtonState, 4; Validar el clic de la rueda de desplazamiento
		jz no_mouse_click

	ScrollClick :
		lea edx, msgClickScroll
		Call WriteString
			

		;//Se agrega el caracter a la variable mensaje
		mov al, ' '; Carácter para clic de rueda de desplazamiento
		mov edi, OFFSET mensajeActual
		add edi, [longitudMensaje]
		mov[edi], al
		inc[longitudMensaje]
		jmp done

	no_mouse_click :

		;//Verificar si se presionó la tecla de espacio(VK_SPACE = 20h)
		cmp InputRecord.KeyEvent.wVirtualKeyCode, VK_SPACE
		jne skip_space

		;//Si se presionó la tecla de espacio y no se había presionado antes, escribir '/' en pantalla
		mov al, [spacePressed]
		cmp al, 0
		jne skip_space
		mov[spacePressed], 1

		mov edx, OFFSET msgSpace
		Call WriteString
			

			;//Se agrega el caracter a la variable mensaje
		mov al, ' '; Carácter para clic de rueda de desplazamiento
			mov edi, OFFSET mensajeActual
			add edi, [longitudMensaje]
			mov[edi], al
			inc[longitudMensaje]
			

		;//Se agrega la barra inclinada
		mov al, '/' 
		mov edi, OFFSET mensajeActual
		add edi, [longitudMensaje]
		mov[edi], al
		inc[longitudMensaje]


			;//Se agrega el caracter a la variable mensaje
		mov al, ' '; Carácter para clic de rueda de desplazamiento
			mov edi, OFFSET mensajeActual
			add edi, [longitudMensaje]
			mov[edi], al
			inc[longitudMensaje]
			jmp done
		

	skip_space:

.ENDW



EnvioMensaje:
	;//Copia el mensaje actual a "mensaje" y reiniciar la longitud del mensaje actual(Para controlar la no repeticion de espacios)
	mov edi, OFFSET mensaje
	mov esi, OFFSET mensajeActual
	mov ecx, [longitudMensaje]
	rep movsb
	

		;// Se abre un cuadro de dialogo y muestra el mensaje digitado
		mov edx, OFFSET mensaje
		call MsgBox


			GuardarMensajeEnArchivo :
		; Abrir el archivo en modo de escritura(creará el archivo si no existe)
			invoke CreateFile, ADDR filename, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
			mov esi, eax; Guarda el descriptor de archivo en esi

			; Verificar si se abrió el archivo correctamente
			cmp esi, INVALID_HANDLE_VALUE
			je archivo_no_abierto

			; Escribir el mensaje en el archivo
			mov edx, OFFSET mensaje
			mov ecx, [longitudMensaje];//AGREGAR UN CONTADOR POR CADA INPUT DE TECLADO
			invoke WriteFile, esi, edx, ecx, ADDR nRead, 0

			; Verificar si la escritura fue exitosa
			cmp eax, 0
			jne escritura_exitosa

			archivo_no_abierto :
		; En caso de error al abrir o escribir en el archivo
			; Puedes manejar el error aquí, por ejemplo, mostrando un mensaje de error.

			escritura_exitosa:
		; Cerrar el archivo
			invoke CloseHandle, esi
			jmp exit_p





;//Se vuelve a ajusatar el ciclo y se repite
done :
mov eax, ConsoleMode
invoke SetConsoleMode, hStdIn, eax
jmp again


exit_p :
exit

main ENDP

end main