.model small                ;Declaracion del modelo de memoria

.stack 200h                 ;Declaracion de tama?o de stack

.const                 ; Declaraci?n de Constantes
    VAL_LF  EQU 10     ; Constante para el Line Feed.
    VAL_RET EQU 13     ; Constante para el Return.
    CHR_FIN EQU '$'    ; Indica fin de cadena.

.data                                                                                                              ;Declaracion de variables
    msg_pass_in    db 'Ingrese contrasenia: ', CHR_FIN
    msg_pass_ok    db VAL_LF, 'Contrasenia correcta', VAL_LF, VAL_RET, CHR_FIN
    msg_pass_fail  db VAL_LF, 'Contrasenia incorrecta', VAL_LF, VAL_LF, VAL_RET, CHR_FIN
    pass           db '12345678', CHR_FIN
    array_pass     db '00000000', CHR_FIN

    menu           db VAL_LF, "----------- MENU ------------", VAL_LF, VAL_RET
    opc1           db "1.- Suma y Resta", VAL_LF, VAL_RET
    opc2           db "2.- Multiplicacion y Division", VAL_LF, VAL_RET
    opc3           db "3.- Operaciones logicas entre dos numeros (HEX)", VAL_LF, VAL_RET
    opc4           db "4.- Serie alternada", VAL_LF, VAL_RET
    opc5           db "5.- Salir", VAL_LF, VAL_RET
    msg            db "Digite una Opcion entre 1 y 5: ", CHR_FIN
    msg_num_in     db 10, 'Ingrese un numero entre -128 y 127: ', '$'
    
    
    resul_neg      db '-',CHR_FIN
    resul_suma     db VAL_LF, "Resultado de la suma: ", CHR_FIN
    resul_resta    db VAL_LF, "Resultado de la resta: ", CHR_FIN
    resul_mul      db VAL_LF, "Resultado de la multiplicacion: ", CHR_FIN
    resul_div      db VAL_LF, "Resultado de la division: ", CHR_FIN
    resul_decimal  db '00000',CHR_FIN
    
    msg_hex_in     db 10, 'Ingrese un hexadecimal entre 0 y ff: ', '$'

    hexa_array     db '0000', '$'
    hexa_array_aux db '0000', '$'
    hexa_array_not db '0000', '$'
    hexa_array_and db '0000', '$'
    hexa_array_or  db '0000', '$'
    hexa_array_xor db '0000', '$'
    number         db '0000', '$'
    binario        db '000000000', '$'

    msg_not        db 10,10,'Operacion Logica NOT', 10, 13
    msg_pnh        db 'Primer numero en Hexadecimal: ', '$'
    msg_pnb        db 10,'Primer numero en Binario: ', '$'
    msg_snh        db 10,10,'Segundo numero en Hexadecimal: ', '$'
    msg_snb        db 10,'Segundo numero en Binario: ', '$'

    msg_and        db 10,10,'Operacion Logica AND', 10, 13,'$'
    msg_or         db 10,10,'Operacion Logica OR', 10, 13,'$'
    msg_xor        db 10,10,'Operacion Logica XOR', 10, 13,'$'
    msg_reh        db 'Resultado en Hexadecimal: ', '$'
    msg_reb        db 10,'Resultado en Binario: ', '$'
    
    msg_suc        db VAL_LF, VAL_LF, 'Primeros 15 numeros de la sucecion alternada:', VAL_LF, VAL_RET, CHR_FIN
    suc_div        db 2
    suc_con        dw 1
    
    current_sign   db 0
    current_number db 0
    array_sign     db 0,0
    n2             dw 0
    array_number   db 0,0
 
    ;Declaracion para indicar inicio de codigo
.code

    ;Procesos auxiliares
    ;Proceso para imprimir un string en registro DX
printString proc
                  mov  ah, 09h             ;Funcion 09 de la interrupcion 21h para imprimir string
                  int  21h
                  RET
printString ENDP

checkPassword proc
                  mov  di,3
    loopCheckPass:
                  lea  dx,msg_pass_in
                  call printString
                  lea  si,array_pass
                  mov  cx,8
    loopGetPass:  
                  mov  ah,00h
                  int  16h
                  mov  [si],al
                  inc  si
                  loop loopGetPass
                  mov  al,array_pass
                  cmp  al,pass
                  je   passCorrecta
                  lea  dx,msg_pass_fail
                  call printString
                  dec  di
                  jnz  loopCheckPass
.EXIT
    passCorrecta:    
                     lea  dx,msg_pass_ok
                     call printString
                     RET
checkPassword ENDP

recibirDecimal proc
                     mov  current_sign, 0
                     mov  ah, 01h
                     int  21h
                     cmp  al, '-'
                     jne  datoPositivo
                     mov  current_sign, '-'
                     mov  cx, 3
                     jmp  cicloD
    datoPositivo:    
                     mov  cx, 3
                     jmp  cmpFinCiclo
    cicloD:          
                     mov  ah, 01h
                     int  21h
    cmpFinCiclo:     
                     cmp  al, 13d
                     je   finCicloD
                     mov  ah, 0
                     push ax
                     loop cicloD
    finCicloD:       
                     cmp  cx, 2
                     je   unDigito
                     cmp  cx, 1
                     je   dosDigitos
                     cmp  cx, 0
                     je   tresDigitos
    unDigito:        
                     pop  dx
                     sub  dl, 30h
                     mov  current_number, dl
                     RET
    dosDigitos:      
                     pop  dx
                     sub  dl, 30h
                     mov  current_number, dl
                     pop  dx
                     sub  dl, 30h
                     mov  al, 0ah
                     mul  dl
                     add  current_number, al
                     RET
    tresDigitos:     
                     pop  dx
                     sub  dl, 30h
                     mov  current_number, dl
                     pop  dx
                     sub  dl, 30h
                     mov  al, 0ah
                     mul  dl
                     add  current_number, al
                     pop  dx
                     sub  dl, 30h
                     mov  al, 64h
                     mul  dl
                     add  current_number, al
                     RET
recibirDecimal ENDP

recibirDecimales proc
                     lea  si,array_number
                     lea  di,array_sign
                     mov  byte ptr [di],0000b
                     mov  byte ptr [di+1],0000b
                     mov  bl,2
    loopRecNum:      
                     mov  dx, offset msg_num_in
                     call printString
                     call recibirDecimal
                     mov  al,current_number
                     mov  [si],al
                     cmp  current_sign,'-'
                     jne  recSigNum
                     mov  byte ptr [di],0001b
    recSigNum:       
                     inc  si
                     inc  di
                     dec  bl
                     cmp  bl,0
                     jne  loopRecNum
                     mov  al,current_number
                     cbw
                     mov  n2,ax
                     RET
recibirDecimales ENDP

sumarDatos proc
                     mov  cx,2
                     lea  si,array_number

                     xor  dx,dx
                     xor  bx,bx
    
    loopSuma:        
                     mov  al,[si]
                     cbw
                     test ax,ax
                     js   sumaNegativa
    sumaPositiva:    
                     add  bx,ax
                     adc  dx,0
                     jmp  sigNum
    sumaNegativa:    
                     neg  ax
                     sub  bx,ax
                     sbb  dx,0
    sigNum:          
                     inc  si
                     loop loopSuma
                     neg  dx
                     cmp  dx,0001b
                     jne  imprimirResul
                     neg  bx
                     mov  dx, offset resul_neg
                     call printString
    imprimirResul:   
                     mov  ax,bx
                     call bintodec
                     mov  dx, offset resul_decimal
                     call printString
                     RET
sumarDatos ENDP

multDatos proc
                     mov  al,array_number
                     mul  array_number+1
                     call bintodec
                     mov  al,array_sign
                     xor  al,array_sign+1
                     cmp  al,0000b
                     je   printMulRes
                     lea  dx, resul_neg
                     call printString
    printMulRes:     
                     lea  dx, resul_decimal
                     call printString
                     RET
multDatos ENDP

divDatos proc
                     mov  dx,0
                     lea  si,array_number
                     mov  al,[si]
                     cbw
                     div  n2
                     call bintodec
                     mov  al,array_sign
                     xor  al,array_sign+1
                     cmp  al,0000b
                     je   printDivRes
                     lea  dx, resul_neg
                     call printString
    printDivRes:     
                     lea  dx, resul_decimal
                     call printString
                     RET
divDatos ENDP

bintodec PROC
                     mov  bx, 10
                     xor  cx, cx
    bitsLoop:        
                     xor  dx, dx
                     div  bx
                     push dx
                     inc  cx
                     test ax, ax
                     jnz  bitsLoop
                     lea  di, resul_decimal
    decLoop:         
                     pop  ax
                     add  ax,30h
                     mov  byte ptr [di], al
                     inc  di
                     loop decLoop
                     mov  byte ptr [di], '$'
                     ret
bintodec ENDP

recibirHexa proc
                     lea  si,hexa_array
                     mov  cx,2
    loopGetHexa:     
                     lea  dx,msg_hex_in
                     call printString
                     mov  di,2
    loopGetChars:    
                     mov  ah,01h
                     int  21h
                     cmp  al, 13d
                     jne  dosDigi
                     mov  al,[si-1]
                     mov  [si],al
                     mov  al,'0'
                     mov  [si-1],al
                     inc  si
                     jmp  salirLoopC
    dosDigi:         
                     mov  [si],al
                     inc  si
                     dec  di
                     jnz  loopGetChars
    salirLoopC:      
                     loop loopGetHexa
                     RET
recibirHexa ENDP

atohex proc                                           ;entrada al:hex(ascii) - salida al:hex(valor real)
                     cmp  al,39h
                     jbe  endHAdjust
                     sub  al,27h
    endHAdjust:      
                     sub  al,30h
                     RET
atohex ENDP

hextoa proc                                           ;entrada al:hex(valor real) - salida al:hex(ascii)
                     cmp  al,09h
                     jbe  endAAdjust
                     add  al,27h
    endAAdjust:      
                     add  al,30h
                     RET
hextoa ENDP

hextobin proc                                         ;entrada al:hex(ascii) - salida number:hex(binario)
                     call atohex
                     mov  bl,al
                     shl  bl,4
                     mov  cl,4
    loopBits:        
                     shl  bl,1
                     jnc  printZero
    printOne:        
                     mov  dx,49
                     jmp  printNum
    printZero:       
                     mov  dx,48
    printNum:        
                     push dx
                     loop loopBits
                     mov  di, offset number+3
                     mov  cl,4
    loopString:      
                     pop  ax
                     mov  byte ptr [di], al
                     dec  di
                     loop loopString
                     mov  byte ptr [di+5], '$'
                     RET
hextobin endp

arraytoaux proc
                     cld
                     REP  movsb
                     mov  al,'$'
                     mov  byte ptr [di], al
                     RET
arraytoaux ENDP

hexnot proc                                           ;entrada: dos hex - salida: dos hex aplicado el complemento de 1
                     mov  cx,4
                     lea  di,hexa_array_not
                     lea  si,hexa_array
                     call arraytoaux
                     lea  si,hexa_array_not
                     mov  cx,4
    loopNot:         
                     mov  al,[si]
                     call atohex
                     not  al
                     sub  al,99h
                     cmp  al,61h
                     jae  endAdjust
                     sub  al,27h
    endAdjust:       
                     mov  [si],al
                     inc  si
                     loop loopNot
                     RET
hexnot ENDP

hexand proc                                           ;entrada: dos hex - salida: and entre los hex
                     mov  cx,4
                     lea  di,hexa_array_and
                     lea  si,hexa_array
                     call arraytoaux
                     lea  si,hexa_array_and
                     mov  cx,2
    loopAnd:         
                     mov  al,[si]
                     call atohex
                     mov  [si],al
                     mov  al,[si+2]
                     call atohex
                     and  al,[si]
                     call hextoa
                     mov  [si],al
                     inc  si
                     loop loopAnd
                     mov  al,'$'
                     mov  [si],al
                     RET
hexand ENDP

hexor proc                                            ;entrada: dos hex - salida: or entre los hex
                     mov  cx,4
                     lea  di,hexa_array_or
                     lea  si,hexa_array
                     call arraytoaux
                     lea  si,hexa_array_or
                     mov  cx,2
    loopOr:          
                     mov  al,[si]
                     call atohex
                     mov  [si],al
                     mov  al,[si+2]
                     call atohex
                     or   al,[si]
                     call hextoa
                     mov  [si],al
                     inc  si
                     loop loopOr
                     mov  al,'$'
                     mov  [si],al
                     RET
hexor ENDP

hexxor proc                                           ;entrada: dos hex - salida: xor entre los hex
                     mov  cx,4
                     lea  di,hexa_array_xor
                     lea  si,hexa_array
                     call arraytoaux
                     lea  si,hexa_array_xor
                     mov  cx,2
    loopXor:         
                     mov  al,[si]
                     call atohex
                     mov  [si],al
                     mov  al,[si+2]
                     call atohex
                     xor  al,[si]
                     call hextoa
                     mov  [si],al
                     inc  si
                     loop loopXor
                     mov  al,'$'
                     mov  [si],al
                     RET
hexxor ENDP

printBin proc                                         ;entrada:array hex - salida:imprime hex a binario
                     mov  al,hexa_array_aux
                     call hextobin
                     mov  cx,4
                     lea  di,binario
                     lea  si,number
                     call arraytoaux
                     mov  al,':'
                     mov  byte ptr [di],al
                     mov  al,hexa_array_aux+1
                     call hextobin
                     mov  cx,4
                     lea  di,binario+5
                     lea  si,number
                     call arraytoaux
                     lea  dx,binario
                     call printString
                     RET
printBin ENDP

auxOp3 proc
                     call recibirHexa
                     call hexnot
                     call hexand
                     call hexor
                     call hexxor
    
                     lea  dx,msg_not
                     call printString
                     mov  cx,2
                     lea  di,hexa_array_aux
                     lea  si,hexa_array_not
                     call arraytoaux
                     lea  dx,hexa_array_aux
                     call printString
                     lea  dx,msg_pnb
                     call printString
                     call printBin
                     lea  dx,msg_snh
                     call printString
                     mov  cx,2
                     lea  di,hexa_array_aux
                     lea  si,hexa_array_not+2
                     call arraytoaux
                     lea  dx,hexa_array_aux
                     call printString
                     lea  dx,msg_snb
                     call printString
                     call printBin
    
                     lea  dx,msg_and
                     call printString
                     lea  dx,msg_reh
                     call printString
                     lea  dx,hexa_array_and
                     call printString
                     mov  cx,2
                     lea  di,hexa_array_aux
                     lea  si,hexa_array_and
                     call arraytoaux
                     lea  dx,msg_reb
                     call printString
                     call printBin
    
                     lea  dx,msg_or
                     call printString
                     lea  dx,msg_reh
                     call printString
                     lea  dx,hexa_array_or
                     call printString
                     mov  cx,2
                     lea  di,hexa_array_aux
                     lea  si,hexa_array_or
                     call arraytoaux
                     lea  dx,msg_reb
                     call printString
                     call printBin
    
                     lea  dx,msg_xor
                     call printString
                     lea  dx,msg_reh
                     call printString
                     lea  dx,hexa_array_xor
                     call printString
                     mov  cx,2
                     lea  di,hexa_array_aux
                     lea  si,hexa_array_xor
                     call arraytoaux
                     lea  dx,msg_reb
                     call printString
                     call printBin
                     RET
auxOp3 ENDP

sucesion proc
    loopSuc:         
                     mov  ax,suc_con
                     div  suc_div
                     cmp  ah,0
                     je   sigSuc
                     mov  dl,'-'
                     mov  ah,02h
                     int  21h
    sigSuc:          
                     mov  ax,suc_con
                     call bintodec
                     lea  dx,resul_decimal
                     call printString
                     mov  ax,suc_con
                     inc  ax
                     mov  suc_con,ax
                     cmp  suc_con,16
                     je   salirSuc
                     mov  dl,','
                     mov  ah,02h
                     int  21h
                     mov  dl,' '
                     mov  ah,02h
                     int  21h
                     jmp  loopSuc
    salirSuc:        
                     RET
sucesion ENDP

    ;Proceso principal Main
main proc
                     mov  ax,@data                    ;Apuntar a la directiva de datos
                     mov  ds,ax
                     mov  es,ax
                     call checkPassword
    menuP:           
                     lea  dx, menu
                     call printString
                     mov  ah,0h
                     int  16h
                     cmp  al,'1'
                     je   opcion1
                     cmp  al,'2'
                     je   opcion2
                     cmp  al,'3'
                     je   opcion3
                     cmp  al,'4'
                     je   opcion4
                     cmp  al,'5'
                     je   salirProgram
                     jmp  menuP
    opcion1:         
                     call recibirDecimales
                     lea  si,array_number
                     lea  di,array_sign
                     mov  cx,2
    loopSignSuma:    
                     cmp  byte ptr [di],0000b
                     je   sigSumando
                     mov  al,[si]
                     neg  al
                     mov  [si],al
    sigSumando:      
                     inc  si
                     inc  di
                     loop loopSignSuma
                     lea  dx, resul_suma
                     call printString
                     call sumarDatos
                     mov  al,[array_number+1]         ;restar negando el segundo dato
                     neg  al
                     mov  array_number+1,al
                     lea  dx, resul_resta
                     call printString
                     call sumarDatos
                     jmp  menuP
    opcion2:         
                     call recibirDecimales
                     lea  dx, resul_mul
                     call printString
                     call multDatos
                     lea  dx, resul_div
                     call printString
                     call divDatos
                     jmp  menuP
    opcion3:         
                     call auxOp3
                     jmp  menuP
    opcion4:         
                     lea  dx,msg_suc
                     call printString
                     call sucesion
                     jmp  menuP
    salirProgram:    
.EXIT         ;Llamado a funcion de salida del programa
main ENDP
    
end main