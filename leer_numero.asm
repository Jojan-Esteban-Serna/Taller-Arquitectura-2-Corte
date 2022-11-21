imprimir_caracter macro char
                      push ax
                      push dx
                      mov  dl, char
                      mov  ah, 02h
                      int  21h
                      pop  dx
                      pop  ax
endm
.model small
.stack 200h
.data
    num         dw 0
    flgnegativo db 0
    limpos      dw 16383
    limneg      dw 16384
    ten         dw 10
    errmsg      db 10,13,'El numero no esta dentro de los limites$'
.code
main proc near
                              mov               ax, @data
                              mov               ds, ax
                              call              prc_leer_numero
                              mov               ah, 4ch
                              int               21h
main endp
    ; lee un numero en cx
prc_leer_numero proc
                              push              dx
                              push              ax
                              push              si
        
                              mov               cx, 0
                              mov               flgnegativo, 0

    leer_digito:              


                              mov               ah, 01h                      ; esto se puede reusar, hay que sacarlo
                              int               21h

                              cmp               al, '-'
                              je                signo_negativo

                              cmp               al, 13
                              jne               verificar_borrado
                              jmp               fin_lectura
    verificar_borrado:        


                              cmp               al, 8
                              jne               verificar_numero
                              mov               dx, 0
                              mov               ax, cx
                              div               ten                          ; ax/10, quita el ultimo digito
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
                              imprimir_caracter 8                            ; mueve el cursor a la izquierda
                              imprimir_caracter ' '                          ; pone espacio
                              imprimir_caracter 8                            ; vuelve a mover el cursor
                              jmp               leer_digito
    numero_verificado:        

    ; hace espacio para el proximo digito
                              push              ax
                              mov               ax, cx
                              mul               ten                          ; dx:ax = ax*10
                              mov               cx, ax
                              pop               ax

    ; verificar si esta en el rango
                              call              prc_verificar_limites
                              ja                limitessuperados

    ;paso a ascii
                              sub               al, 30h

    ;suma lo leido a cx
                              mov               ah, 0
                              mov               dx, cx                       ; guarda en caso de overflow
                              add               cx, ax
                              call              prc_verificar_limites
                              ja                limitessuperados             ; si el numero pasa los limites quita lo ingresado

                              jmp               leer_digito

    signo_negativo:           
                              mov               flgnegativo, 1
                              jmp               leer_digito

    limitessuperados:         
                              call              prc_error_de_limites
        
        
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

prc_error_de_limites proc
                              lea               dx, errmsg
                              mov               ah,9
                              int               21h
                              mov               ah, 4ch
                              int               21h
prc_error_de_limites endp
end main