.model small

.stack 200h 
.data
     hexnum  db 0ffh
     dictbin db '0000$'
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
     dicthex db '0$'
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
    
     five    db 5
     two     db 2
.code
main proc
          mov ax, @data
          mov ds, ax

          mov ah, 0
          mov al, hexnum
          and al, 0f0h
          shr al,4
     ;mul five
          mul two
          mov si,ax

     ;lea dx,  dictbin[si]
          lea dx,  dicthex[si]
          mov ah, 9
          int 21h

 
          mov ah, 0
          mov al,hexnum
          and al,0fh
     ;mul five
          mul two
          mov si, ax

     ;lea dx,  dictbin[si]
          lea dx,  dicthex[si]
          mov ah, 9
          int 21h
        

main endp

end main
