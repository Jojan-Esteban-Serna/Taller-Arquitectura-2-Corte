;MACROS

cargar_datos macro
                 mov ax, @data
                 mov ds, ax
                 mov es, ax
                 
endm
imprimir_caracter macro char
                      push ax
                      push dx
                      mov  dl, char
                      mov  ah, 02h
                      int  21h
                      pop  dx
                      pop  ax
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
imprimir_bytehex2hex macro src
                         push cx
                         mov  cl, src
                         call prc_imprimir_bytehex2hex
                         pop  cx
endm
imprimir_bytehex2bin macro src
                         push cx
                         mov  cl, src
                         call prc_imprimir_bytehex2bin
                         pop  cx
endm
leer_numero macro dst, maxneg, maxpos
                mov  limneg, maxneg
                mov  limpos, maxpos
                call prc_leer_numero
                mov  dst, cx
endm

imprimir_numero macro num
                    push ax
                    mov  ax, num
                    call prc_imprimir_numero
                    pop  ax
endm
.model small
.stack 200h
.data
    ;cosas generales
    newline                  db 10,13,'$'
    waitvar                  db 0
    msgsalida                db 'Saliendo...',10,13,'$'
    msgprestecla             db 'Presione una tecla para continuar...',10,13,'$'

    ;relacionado a contraseñas
    nummaxintentos           dw 3
    contrasenia              db 'ggezpz'
    msgcontrasenia           db 'Ingrese la contraseña: ',10,13,'$'
    msgcontraseniaincorrecta db 'Las tres contraseñas ingresadas fueron incorrectas',10,13,'$'
    contraseniaingresada     db 'ci123456e','$'
    ;relacionado al menu
    msgmenu                  db '1. Suma y diferencia de dos numeros entre -16384 a 16383',10,13
                             db '2. Multiplicacion y division de dos numeros entre -128 a 127',10,13
                             db '3. Operaciones logicas, NOT, AND, OR, XOR de dos numeros entre 00 a FF',10,13
                             db '4. Primeros 16 numeros de la serie alternada',10,13
                             db '5. Salir',10,13,'$'
    opcionescogida           db 0,10,13,'$'
    ; relacionado a leer numeros decimales
    flgnegativo              db 0
    limpos                   dw 127
    limneg                   dw 128
    ten                      dw 10
    zero                     db '0'
    num1                     dw 0
    num2                     dw 0
    ; relacionado a los hexadecimales
    dictbin                  db '0000$'
                             db '0001$'
                             db '0010$'
                             db '0011$'
                             db '0100$'
                             db '0101$'
                             db '0110$'
                             db '0111$'
                             db '1001$'
                             db '1000$'
                             db '1010$'
                             db '1011$'
                             db '1100$'
                             db '1101$'
                             db '1110$'
                             db '1111$'
    dicthex                  db '0$'
                             db '1$'
                             db '2$'
                             db '3$'
                             db '4$'
                             db '5$'
                             db '6$'
                             db '7$'
                             db '8$'
                             db '9$'
                             db 'A$'
                             db 'B$'
                             db 'C$'
                             db 'D$'
                             db 'E$'
                             db 'F$'
    
    five                     db 5
    two                      db 2
.code
main proc near
                                cargar_datos
                                mov               cx, nummaxintentos
                                call              prc_limpiar_pantalla
    ; Autentica la contraseña ingresada por teclado
    autenticacion:              
                                imprimir          msgcontrasenia
                                leer_string       contraseniaingresada, 7                   ; en realidad lee 6 caracteres y el enter
                                push              cx
                                comparar_string   contrasenia, contraseniaingresada[2],6
                                je                autenticado
                                pop               cx
                                loop              autenticacion

                                imprimir          msgcontraseniaincorrecta
                                call              prc_salir

    autenticado:                
                                call              prc_limpiar_pantalla
                                call              prc_cambiar_color
                                imprimir          msgmenu
                                leer_char         opcionescogida
                                cmp               opcionescogida[0],'5'
                                je                prc_salir
                                jmp               autenticado
   
main endp
prc_salir proc
                                imprimir          msgsalida
                                imprimir          msgprestecla
                                leer_char         waitvar
                                mov               ah,4ch
                                int               21h
prc_salir endp
prc_imprimir proc
                                mov               ah, 09h
                                int               21h
                                ret
prc_imprimir endp
    
prc_leer_char proc
                                mov               ah, 1
                                int               21h
                                ret
prc_leer_char endp
prc_cambiar_color proc
                                mov               ax, 3
                                int               10h

                                mov               ax, 1003h
                                mov               bx, 0                                     ; desactiva los parpadeos
                                int               10h
                         
                                mov               ah, 06h
                                xor               al, al
                                xor               cx, cx
                                mov               dx, 184fh
                                mov               bh, 0c0h                                  ; color a poner
                                int               10h
                                ret
prc_cambiar_color endp
prc_limpiar_pantalla proc
                                mov               ah ,00
                                mov               al, 02
                                int               10h
                                ret
prc_limpiar_pantalla endp

prc_leer_string proc
                                mov               ah,10
                                int               21h
                                ret
prc_leer_string endp
    ; lee un numero hexadecimal en bl
    ; lee un numero hexadecimal en bl
prc_leer_hex proc
                                mov               cx ,2
                                mov               bl, 0
                                mov               ax ,0                                     ; limpiar ax
    leyendo:                    
             
                                call              prc_leer_char
                                cmp               al , '0'
                                jbe               no_valido
                                cmp               al, 'f'
                                ja                no_valido
                                cmp               al, '9'
                                jbe               numero
                                cmp               al, 'a'
                                jbe               no_valido
                                sub               al, 57h
                                jmp               mover_4_bits
    numero:                     
                                sub               al, 30h
                                jmp               mover_4_bits
    mover_4_bits:               
                                shl               bl, 4
                                or                bl, al
                                loop              leyendo
                                ret
    no_valido:                  
                                imprimir_caracter 8
                                imprimir_caracter ' '
                                imprimir_caracter 8
                                inc               cx
                                loop              leyendo



prc_leer_hex endp
prc_imprimir_bytehex2hex proc
                                mov               ah, 0
                                mov               al, cl
                                and               al, 0f0h
                                shr               al,4
                                mul               two
                                mov               si,ax

                                lea               dx,  dicthex[si]
                                call              prc_imprimir

 
                                mov               ah, 0
                                mov               al,cl
                                and               al,0fh
                                mul               two
                                mov               si, ax

                                lea               dx,  dicthex[si]
                                call              prc_imprimir

                                ret
prc_imprimir_bytehex2hex endp
    ; imprime el byte que este en cl a binario
prc_imprimir_bytehex2bin proc
                                mov               ah, 0
                                mov               al, cl
                                and               al, 0f0h
                                shr               al,4
                                mul               five
                                mov               si,ax

                                lea               dx,  dictbin[si]
                                call              prc_imprimir


 
                                mov               ah, 0
                                mov               al,cl
                                and               al,0fh
                                mul               five
                                mov               si, ax

                                lea               dx,  dictbin[si]
                                call              prc_imprimir
                                ret
prc_imprimir_bytehex2bin endp
    ; lee un numero en cx
prc_leer_numero proc
                                push              dx
                                push              ax
                                push              si
        
                                mov               cx, 0
                                mov               flgnegativo, 0

    leer_digito:                


                                call              prc_leer_char

                                cmp               al, '-'
                                je                signo_negativo

                                cmp               al, 13
                                jne               verificar_borrado
                                jmp               fin_lectura
    verificar_borrado:          


                                cmp               al, 8
                                jne               verificar_numero
    borrar:                     
                                mov               dx, 0
                                mov               ax, cx
                                div               ten                                       ; ax/10, quita el ultimo digito
                                mov               cx, ax
                                imprimir_caracter ' '
                                imprimir_caracter 8
                                jmp               leer_digito
    verificar_numero:           


    
                                cmp               al, '0'
                                jae               es_mayor_a_cero
                                jmp               quitar_caracter_nonum
    es_mayor_a_cero:            
                                cmp               al, '9'
                                jbe               numero_verificado
    quitar_caracter_nonum:      
                                imprimir_caracter 8                                         ; mueve el cursor a la izquierda
                                imprimir_caracter ' '                                       ; pone espacio
                                imprimir_caracter 8                                         ; vuelve a mover el cursor
                                jmp               leer_digito
    numero_verificado:          

    ; hace espacio para el proximo digito
                                push              ax
                                mov               ax, cx
                                mul               ten                                       ; dx:ax = ax*10
                                mov               cx, ax
                                pop               ax

    ; verificar si esta en el rango
                                call              prc_verificar_limites
                                ja                overflow_por_multiplicacion

    ;paso a ascii
                                sub               al, 30h

    ;suma lo leido a cx
                                push              ax
                                mov               ah, 0
                                mov               dx, cx                                    ; guarda en caso de overflow
                                add               cx, ax
                                pop               ax
                                call              prc_verificar_limites
                                ja                overflow_por_suma                         ; si el numero pasa los limites quita lo ingresado

                                jmp               leer_digito

    signo_negativo:             
                                mov               flgnegativo, 1
                                jmp               leer_digito
    overflow_por_suma:          
                                mov               ah, 0
                                sub               cx, ax
    overflow_por_multiplicacion:
                                imprimir_caracter 8
                                jmp               borrar
        
        
    fin_lectura:                
                                cmp               flgnegativo, 0
                                je                numero_positivo
                                neg               cx
    numero_positivo:            

                                pop               si
                                pop               ax
                                pop               dx
                                ret
prc_leer_numero endp
    ; verifica si cx esta dentro del rango deseado
prc_verificar_limites proc
    verificar_flag_signo:       
                                cmp               flgnegativo, 0
                                je                verificar_limite_positivo
    
    verificar_limite_negativo:  
                                cmp               cx,limneg
                                jmp               retornar
    verificar_limite_positivo:  
                                cmp               cx,limpos
                                jmp               retornar
    retornar:                   
                                ret
prc_verificar_limites endp
    ; imprime un numero en ax
prc_imprimir_signumero proc
                                push              dx
                                push              ax
                                cmp               ax, 0
                                jnz               verificar_signo
                                imprimir_caracter '0'
                                jmp               fin_impresign

    verificar_signo:            
                                cmp               ax, 0                                     ; afecta las banderas (Nos interesa la de signo)
                                jns               positivo
                                neg               ax
                                imprimir_caracter '-'
    positivo:                   
                                call              prc_imprimir_numero
    fin_impresign:              
                                pop               ax
                                pop               dx
                                ret
prc_imprimir_signumero endp
prc_imprimir_numero proc near
                                push              ax
                                push              bx
                                push              cx
                                push              dx
                                mov               cx,1                                      ; hay ceros
                                mov               bx, 10000                                 ; maximos digitos
                                cmp               ax, 0
                                jz                imprimir_cero
    impresion:                  
                                cmp               bx,0                                      ; si el divisor es cero, ya no quedan digitos
                                jz                fin_impresion
                        
                                cmp               cx, 0
                                je                extraer_digito
                                cmp               ax, bx
                                jb                reducir_divisor                           ; si el resto es mayor al divisor, reducir el divisor
    extraer_digito:             
                                mov               cx, 0                                     ; no hay ceros
                                mov               dx,0
                                div               bx                                        ; divide ax por bx y guarda en al, y guarda el resto en dx
                                add               al, 30h
                                imprimir_caracter al
                                mov               ax, dx                                    ; guarda el resto para extraer mas caracteres
    reducir_divisor:            
                                push              ax                                        ; guarda ax, porque la division lo usa
                                mov               dx, 0
                                mov               ax, bx
                                div               ten                                       ; quita un digito al divisor
                                mov               bx, ax
                                pop               ax
                                jmp               impresion


    imprimir_cero:              
                                imprimir_caracter '0'
                                ret
    fin_impresion:              
                                pop               dx
                                pop               cx
                                pop               bx
                                pop               ax
                                ret
prc_imprimir_numero endp
end main
