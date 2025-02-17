.model tiny
.code
org 100h


;Left_up    db 0c9h
;Midle      db 0cdh
;Colum      db 0bah
;Right_up   db 0bbh
;Left_down  db 0c8h
;Right_down db 0bch
AdCmd = 82h

start:   
        mov si, AdCmd
        call GetDigit
        mov Height, ax
        call GetDigit
        mov Len, ax

        ;mov ax, ds:[AdCmd] 
        mov si, offset StyleStr
        mov bx, 0b800h
        mov es, bx
        call CntStartPosition
        mov ah, Color_style
        
        call DrawFrame

        mov ax, 4c00h
        int 21h



;---------------------------------------------------------------
;DrawFrame - draws a frame in video memory and print given string in the center
;Entry: SI - address of StyleString
;       ES - address og the video memory
;       DI - position of the beggining of the frame
;       AH - color attributes
;Exit:  None
;Destr: CX SI DI AX BX
;---------------------------------------------------------------
DrawFrame proc 
        call DrawStr
        mov bp, offset Height
        mov bx, 0
        mov bx, [bp]
        sub bx, 2
        mov cx, bx
        Cycle:
                call DrawStr
                sub si, 3
        loop Cycle
        add si, 3
        call DrawStr

        call CntStringPosition
                                                ;mov di, (Begin_Y + Height/2 - 1)*80*2 + 2*(Begin_X + Len/2 - 1)
        call CntLenString 

        push ax
        shr ax, 1
        shl ax, 1
        sub di, ax 
        
        pop ax
         
        call DrawRdmString

        ret 
        endp
        

;---------------------------------------------------------------
;DrawStr - draws a string according to a StyleString
;Entry: DS:[SI] - address of the begining of the style 
;       DI - relative address where to print first symbol
;       AH - color attributes
;Exit:  None
;Destr: DI AL SI
;---------------------------------------------------------------
        DrawStr proc
        push cx   
        lodsb                           ;mov al, ds:[si]
                                        ;inc si
        stosw                           ;печатаю первый символ 3 байтовой последовательности 
        
        mov al, ds:[si]
        mov bp, offset Len
        mov bx, 0
        mov bx, [bp] 
        sub bx, 2 
        
        mov cx, bx ; mov cx, Len-2                
        rep stosw                       ;печатаю последовательность из второго символа len-2 раза
        
        inc si
        lodsb                           ;mov al, ds:[si]
                                        ;inc si
        stosw                           ;печатаю последний символ 3 байтовой последовательности
        
        pop cx
        mov bp, offset Len
        mov bx, 0
        mov bx, [bp]
        shl bx, 1
        mov dx, 160
        sub dx, bx
        add di, dx ;add di, 160 - 2*Len
        ret 
        endp

;---------------------------------------------------------------
;DrawRdmString - draws a given string in video memory
;Entry: AX - length of the string
;Exit:  None
;Destr: BX AX CX 
;---------------------------------------------------------------
        DrawRdmString proc  
        mov bx, offset String
        mov cx, ax
    metkaRS:
        mov ax, [bx]
        mov ah, color_style
        stosw
        inc bx
        loop metkaRS
        ret 
        endp

;---------------------------------------------------------------
;CntLenString - counts(without $) number of symbols in the given string 
;Entry: AH = color attributes
;Exit:  None
;Destr: AX BX CX
;---------------------------------------------------------------
        CntLenString proc  
        mov bx, offset String
        mov cx, 0
        mov ax, -1
    metkaCLS:
        mov cx, [bx]
        sub cl, 35
        mov ch, 0
        inc bx
        inc ax
        loop metkaCLS
        ret 
        endp

;---------------------------------------------------------------
;CntStartPosition - counts the position where to start frame
;Enter: 
;Exit: DI - result of operation
;Destr: AX BX DI
;---------------------------------------------------------------
        CntStartPosition proc
;(Begin_Y-1)*80*2 + (Begin_X-1)*2
        mov bp, offset Begin_Y
        mov ax, 0
        mov ax, [bp]    ;mov ax, [offset Begin_Y]
        dec ax
        mov bx, 160
        mul bx
        mov bp, offset Begin_X
        mov bx, 0
        mov bx, [bp]    ;mov bx, [offset Begin_X]
        dec bx
        shl bx, 1
        add ax, bx
        mov di, ax
        ret
        endp

;---------------------------------------------------------------
;CntStartPosition - counts the position where to start frame
;Enter: 
;Exit: DI - result of operation
;Destr: AX BX
;---------------------------------------------------------------
        CntStringPosition proc ;(Begin_Y + Height/2 - 1)*80*2 + 2*(Begin_X + Len/2 - 1)
        ;(
        mov bp, offset Begin_Y
        mov ax, 0
        mov ax, [bp] 
        dec ax
        mov bp, offset Height
        mov bx, 0
        mov bx, [bp]
        shr bx, 1
        add ax, bx
        mov bx, 160
        mul bx
        mov di, ax
        ;)
        ;+
        ;(
        mov bp, offset Begin_X
        mov ax, 0
        mov ax, [bp]
        dec ax
        mov bp, offset Len
        mov bx, 0
        mov bx, [bp]
        shr bx, 1
        add ax, bx
        shl ax, 1
        add di, ax
        ;)
        ret
        endp

;-----------------------------------------------------------------------
;GetDigit - gets a number from command string
;Enter: SI - relative address from where to find the number
;Exit:  AX - number
;Destr: AX BX CX DX
;-----------------------------------------------------------------------
        GetDigit proc
        ;mov si, AdrCmd
        ;mov ax, 0
        mov cx, 2
        metkaGD:
                mov bl, ds:[si]
                cmp bl, 20h
                je ENDNUM
                cmp bl, 39h
                ja ENDNUM
                cmp bl, 30h
                jb ENDNUM
                
                sub bl, 30h
                mov dx, 10
                mul dx
                add al, bl
                inc si
                inc cx
                loop metkaGD
        ENDNUM:

        ret
        endp
        
                

String db 'Hello, World@$'
StyleStr db '+-+&!&(#)$'
Color_style db 01011010b
Begin_X    dw 16
Begin_Y    dw 5
Height     dw 7
Len        dw 26

end start
