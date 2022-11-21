.model small
.stack 200h
.data
    hexleido db 0
    char1    db 0
    char2    db 0
    res      db 0
.code


main proc near
                 mov  ax, @data
                 mov  ds, ax
                 call prc_leer_hex
                 mov  ah, 4ch
                 int  21h
main endp

    ; lee un numero hexadecimal en bl
prc_leer_hex proc
                 mov  cx ,2
                 mov  bl, 0
                 mov  ax ,0           ; limpiar ax
    leyendo:     
             
                 mov  ah, 01h         ; esto se puede reusar, hay que sacarlo
                 int  21h
                 cmp  al , '0'
                 jbe  error
                 cmp  al, 'f'
                 ja   error
                 cmp  al, '9'
                 jbe  numero
                 sub  al, 57h
                 jmp  mover_4_bits
    numero:      
                 sub  al, 30h
                 jmp  mover_4_bits
    mover_4_bits:
                 shl  bl, 4
                 or   bl, al
                 loop leyendo
                 ret
    error:       
                 mov  ax, 0
                 ret

prc_leer_hex endp
end main