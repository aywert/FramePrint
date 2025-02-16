.model tiny
.code
org 100h

Begin_X    = 10
Begin_Y    = 10
Height     = 10
Len        = 3
Left_up    = 0c9h
Midle      = 0cdh
Colum      = 0bah
Right_up   = 0bbh
Left_down  = 0c8h
Right_down = 0bch
Color_style = 11011010b

start:   
        mov si, offset StyleStr
        mov bx, 0b800h
        mov es, bx
        mov di, 0
        mov ah, Color_style
        ;call DrawFrame
        call DrawStr

        mov ax, 4c00h
        int 21h
String db 'Hello, world!$'
StyleStr db '+-+&!&(#)$'


;---------------------------------------------------------------
;draw a char in video memory
;Entry: None
;Exit:  None
;Destr: AX BX ES DX CX DI
;---------------------------------------------------------------
        DrawFrame proc 
        mov bx, 0b800h
        mov es, bx          ; put adress of video mem in register es

        mov al, Left_up
        mov ah, Color_style
        mov di, (Begin_Y-1)*80*2 + (Begin_X-1)*2 ; Num_Of_String * 80 * 2 + Num_Of_Position * 2
        stosw               ; mov es:[di], ax / inc di
        
        
        mov al, Midle
        call DrawStr

        mov al, Right_up
        stosw

        mov al, Colum
        mov ah, Color_style
        call DrawCol

        mov al, Right_down
        stosw

        mov di, (Begin_Y-1)*80*2 + Begin_X*2
        mov al, Colum
        mov ah, Color_style; no need to reclaim
        call DrawCol

        mov al, Left_down
        stosw

        mov al, Midle
        call DrawStr
        
        mov di, (Begin_Y + Height/2 - 1)*80*2 + 2*(Begin_X + Len/2 - 2)
        call CntLenString 
        ;mov ah, 0
        shr ax, 1
        sub di, ax 
        sub di, ax 
        ;sub di, ax 
        call DrawRdmString

        ret 
        endp
        

;---------------------------------------------------------------
;draw a string that consist of only one given degit in video memory
;Entry: AL = char to write
;       AH = color attributes
;Exit:  None
;Destr: CX DI AX
;---------------------------------------------------------------
        DrawStr proc             
        mov al, ds:[si]
        stosw                           ;печатаю первый символ 3 байтовой последовательности 
        inc si
        mov al, ds:[si]
        mov cx, Len - 2                 
        rep stosw                       ;печатаю последовательность из второго символа len-2 раза
        mov al, ds:[si]
        inc si
        mov al, ds:[si]
        stosw
        inc si
        ret 
        endp
;---------------------------------------------------------------
;draw a column in video memory
;Entry: AL = char to write
;       AH = color attributes
;Exit:  None0
;Destr: DI CX
;---------------------------------------------------------------
        DrawCol proc  
        mov cx, Height - 2;
    metkaHgt:
        add di, 158 
        stosw
        loop metkaHgt
        add di, 158 
        ret 
        endp

;---------------------------------------------------------------
;draw a given string in video memory
;Entry: AL = char to write
;       AH = color attributes
;Exit:  None
;Destr: AX BX CX DI
;---------------------------------------------------------------
        DrawRdmString proc  
        mov bx, offset String
        mov cx, 0
    metkaRS:
        mov ax, [bx]
        mov ah, 00001010b
        stosw
        mov cx, [bx]
        sub cl, 35
        mov ch, 0
        inc bx
        loop metkaRS
        mov ax, 0
        dec di
        stosw
        ret 
        endp

;---------------------------------------------------------------
;draw a column in video memory
;Entry: AL = char to write
;       AH = color attributes
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
end start