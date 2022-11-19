;MACROS
imprimir macro str
             mov  dx, offset str
             call prc_imprimir
endm

leer macro destino
         call prc_leer
         mov  destino, al
endm
.model small
.stack 200h
.data
    msgcontraseniaa     db 'Ingrese la contraseña: ',10,13,'$'
    nummaxintentos      db 3
    msgerrorcontrasenia db 'La contraseña ingresada fue incorrecta, presione una tecla para salir',10,13,'$'
    msgmenu             db '1. Suma y diferencia de dos numeros entre -16384 a 16383',10,13
                        db '2. Multiplicacion y division de dos numeros entre -128 a 127',10,13
                        db '3. Operaciones logicas, NOT, AND, OR, XOR de dos numeros entre 00 a FF',10,13
                        db '4. Primeros 16 numeros de la serie alternada',10,13,'$'
    flgnegativo         db 0
    maxdivisordecmiles  dw 10000
    maxdivisorcents     db 100

.code
main proc near
                 mov  ax, @data
                 mov  ds, ax
                 mov  ah, 09
                 mov  dx, offset msgmenu
                 int  21h                   ;
                 call salir
                 
main endp
prc_imprimir PROC
                 mov  ah, 09h
                 int  21h
                 ret
prc_imprimir ENDP
    
prc_leer PROC
                 mov  ah, 1
                 int  21h
                 ret
prc_leer ENDP

salir PROC
                 mov  ah,4ch
                 int  21h
salir ENDP
end main
