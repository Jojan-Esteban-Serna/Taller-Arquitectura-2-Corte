imprimir_caracter macro char
                      push ax
                      push dx
                      mov  dl, char
                      mov  ah, 02h
                      int  21h
                      pop  dx
                      pop  ax
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
    lim  dw 11h
    num  db '00$'
    ten  dw 10
.code


main proc near
                           mov               ax, @data
                           mov               ds, ax
                           mov               cx, 1
    serie:                 
                           mov               ax, cx
                           and               ax, 1b
                           cmp               ax, 1b
                           jne               res_positivo
                           imprimir_caracter '-'
    res_positivo:          

                           imprimir_numero   cx
                           imprimir_caracter ','
                           imprimir_caracter ' '

                           inc               cx
                           cmp               cx, lim
                           jne               serie
                           imprimir_caracter 8
                           imprimir_caracter 8
                           imprimir_caracter ' '
                           imprimir_caracter 8
                           mov               ah, 4ch
                           int               21h
main endp
prc_imprimir_signumero proc
                           push              dx
                           push              ax
                           cmp               ax, 0
                           jnz               verificar_signo
                           imprimir_caracter '0'
                           jmp               fin_impresign

    verificar_signo:       
                           cmp               ax, 0                  ; afecta las banderas (Nos interesa la de signo)
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
                           mov               cx,1                   ; hay ceros
                           mov               bx, 10000              ; maximos digitos
                           cmp               ax, 0
                           jz                imprimir_cero
    impresion:             
                           cmp               bx,0                   ; si el divisor es cero, ya no quedan digitos
                           jz                fin_impresion
                        
                           cmp               cx, 0
                           je                extraer_digito
                           cmp               ax, bx
                           jb                reducir_divisor        ; si el resto es mayor al divisor, reducir el divisor
    extraer_digito:        
                           mov               cx, 0                  ; no hay ceros
                           mov               dx,0
                           div               bx                     ; divide ax por bx y guarda en al, y guarda el resto en dx
                           add               al, 30h
                           imprimir_caracter al
                           mov               ax, dx                 ; guarda el resto para extraer mas caracteres
    reducir_divisor:       
                           push              ax                     ; guarda ax, porque la division lo usa
                           mov               dx, 0
                           mov               ax, bx
                           div               ten                    ; quita un digito al divisor
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