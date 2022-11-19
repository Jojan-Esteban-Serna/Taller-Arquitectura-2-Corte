;MACROS
cargar_datos macro
                 mov ax, @data
                 mov ds, ax
endm

imprimir macro str
             mov  dx, offset str
             call prc_imprimir
endm

leer_char macro destino
              call     prc_leer_char
              mov      destino, al
              imprimir newline
endm

leer_string macro destino,maximos_digitos
                lea  dx, destino
                mov  destino, maximos_digitos
                call prc_leer_string
endm

.model small
.stack 200h
.data
    contrasenia          db 'ggezpz'
    newline              db 10,13,'$'
    msgcontrasenia       db 'Ingrese la contraseña: ',10,13,'$'
    contraseniaingresada db 'ci123456e','$'                                                                      ;(c)cantidad de elementos permitidos,(i) elementos ingresados,(e)enter al ingresar
    nummaxintentos       db 3
    msgerrorcontrasenia  db 'La contraseña ingresada fue incorrecta, presione una tecla para salir',10,13,'$'
    msgmenu              db '1. Suma y diferencia de dos numeros entre -16384 a 16383',10,13
                         db '2. Multiplicacion y division de dos numeros entre -128 a 127',10,13
                         db '3. Operaciones logicas, NOT, AND, OR, XOR de dos numeros entre 00 a FF',10,13
                         db '4. Primeros 16 numeros de la serie alternada',10,13
                         db '5. Salir',10,13,'$'
    opcionescogida       db 0,10,13,'$'
    waitvar              db 0
    msgsalida            db 'Saliendo...',10,13,'$'
    msgprestecla         db 'Presione una tecla para continuar...',10,13,'$'
    flgnegativo          db 0
    maxdivisordecmiles   dw 10000
    maxdivisorcents      db 100


.code
main proc near
                         cargar_datos
                         
    autenticado:         
                         call         prc_limpiar_pantalla
                         imprimir     msgmenu
                         leer_char    opcionescogida
                         cmp          opcionescogida[0],'5'
                         je           prc_salir
                         jmp          autenticado
   
main endp
prc_imprimir proc
                         mov          ah, 09h
                         int          21h
                         ret
prc_imprimir endp
    
prc_leer_char proc
                         mov          ah, 1
                         int          21h
                         ret
prc_leer_char endp
    
prc_limpiar_pantalla proc
                         mov          ah ,00
                         mov          al, 02
                         int          10h
                         ret
prc_limpiar_pantalla endp

prc_leer_string proc
                         mov          ah,10
                         int          21h
                         ret
prc_leer_string endp

prc_salir proc
                         imprimir     msgsalida
                         imprimir     msgprestecla
                         leer_char    waitvar
                         mov          ah,4ch
                         int          21h
prc_salir endp
end main
