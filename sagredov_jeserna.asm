;MACROS
cargar_datos macro
                 mov ax, @data
                 mov ds, ax
                 mov es, ax
                 
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

comparar_string macro cad1, cad2, tam
                    mov cx, tam
                    lea si ,cad1
                    lea di, cad2
                    rep cmpsb
endm

leer_hex macro dst
             push bx
             call prc_leer_hex
             mov  dst, bl
             pop  bx
endm

.model small
.stack 200h
.data
    newline                  db 10,13,'$'
    contrasenia              db 'ggezpz'
    msgcontrasenia           db 'Ingrese la contraseña: ',10,13,'$'
    msgcontraseniaincorrecta db 'Las tres contraseñas ingresadas fueron incorrectas',10,13,'$'
    contraseniaingresada     db 'ci123456e','$'
    nummaxintentos           dw 3
    msgerrorcontrasenia      db 'La contraseña ingresada fue incorrecta, presione una tecla para salir',10,13,'$'
    msgmenu                  db '1. Suma y diferencia de dos numeros entre -16384 a 16383',10,13
                             db '2. Multiplicacion y division de dos numeros entre -128 a 127',10,13
                             db '3. Operaciones logicas, NOT, AND, OR, XOR de dos numeros entre 00 a FF',10,13
                             db '4. Primeros 16 numeros de la serie alternada',10,13
                             db '5. Salir',10,13,'$'
    opcionescogida           db 0,10,13,'$'
    waitvar                  db 0
    msgsalida                db 'Saliendo...',10,13,'$'
    msgprestecla             db 'Presione una tecla para continuar...',10,13,'$'
    flgnegativo              db 0
    maxdivisordecmiles       dw 10000
    maxdivisorcents          db 100


.code
main proc near
                         cargar_datos
                         mov             cx, nummaxintentos
                         call            prc_limpiar_pantalla
    ; Autentica la contraseña ingresada por teclado
    autenticacion:       
                         imprimir        msgcontrasenia
                         leer_string     contraseniaingresada, 7                   ; en realidad lee 6 caracteres y el enter
                         push            cx
                         comparar_string contrasenia, contraseniaingresada[2],6
                         je              autenticado
                         pop             cx
                         loop            autenticacion

                         imprimir        msgcontraseniaincorrecta
                         call            prc_salir

    autenticado:         
                         call            prc_limpiar_pantalla
                         call            prc_cambiar_color
                         imprimir        msgmenu
                         leer_char       opcionescogida
                         cmp             opcionescogida[0],'5'
                         je              prc_salir
                         jmp             autenticado
   
main endp
prc_imprimir proc
                         mov             ah, 09h
                         int             21h
                         ret
prc_imprimir endp
    
prc_leer_char proc
                         mov             ah, 1
                         int             21h
                         ret
prc_leer_char endp
prc_cambiar_color proc
                         mov             ax, 3
                         int             10h

                         mov             ax, 1003h
                         mov             bx, 0                                     ; desactiva los parpadeos
                         int             10h
                         
                         mov             ah, 06h
                         xor             al, al
                         xor             cx, cx
                         mov             dx, 184fh
                         mov             bh, 0c0h                                  ; color a poner
                         int             10h
                         ret
prc_cambiar_color endp
prc_limpiar_pantalla proc
                         mov             ah ,00
                         mov             al, 02
                         int             10h
                         ret
prc_limpiar_pantalla endp

prc_leer_string proc
                         mov             ah,10
                         int             21h
                         ret
prc_leer_string endp
    ; lee un numero hexadecimal en bl
prc_leer_hex proc
                         mov             cx ,2
                         mov             bl,0
                         push            ax
    ; limpiar ax
    leyendo:             
             
                         call            prc_leer_char
                         cmp             al , '0'
                         jbe             error
                         cmp             al, 'f'
                         ja              error
                         cmp             al, '9'
                         jbe             numero
                         sub             al, 57h
                         jmp             mover_4_bits
    numero:              
                         sub             al, 30h
                         jmp             mover_4_bits
    mover_4_bits:        
                         shl             bl, 4
                         or              bl, al
                         loop            leyendo
                         ret
    error:               
                         pop             ax
                         ret

prc_leer_hex endp

prc_salir proc
                         imprimir        msgsalida
                         imprimir        msgprestecla
                         leer_char       waitvar
                         mov             ah,4ch
                         int             21h
prc_salir endp
end main
