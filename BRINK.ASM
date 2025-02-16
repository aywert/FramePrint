.model tiny
.code
org 100h

Begin_X    = 10
Begin_Y    = 10
Height     = 5
Len        = 36
Left_up    = 0c9h
Midle      = 0cdh
Colum      = 0bah
Right_up   = 0bbh
Left_down  = 0c8h
Right_down = 0bch
Color_style = 01011010b

start:   
        mov si, offset StyleStr
        mov bx, 0b800h
        mov es, bx
        mov di, (Begin_Y-1)*80*2 + (Begin_X-1)*2 
        mov ah, Color_style
        
        call DrawFrame

        mov ax, 4c00h
        int 21h
String db 'Hello, World]$'
StyleStr db '+-+&!&(#)$'


;---------------------------------------------------------------
;DrawFrame - draws a frame in video memory and print given string in the center
;Entry: SI - address of StyleString
;       ES - address og the video memory
;       DI - position of the beggining of the frame
;       AH - color attributes
;Exit:  None
;Destr: CX SI DI AX 
;---------------------------------------------------------------
DrawFrame proc 
        call DrawStr
        mov cx, Height-2
        Cycle:
                call DrawStr
                sub si, 3
        loop Cycle
        add si, 3
        call DrawStr
        
        mov di, (Begin_Y + Height/2 - 1)*80*2 + 2*(Begin_X + Len/2 - 1)
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
        mov cx, Len - 2                 
        rep stosw                       ;печатаю последовательность из второго символа len-2 раза
        
        inc si
        lodsb                           ;mov al, ds:[si]
                                        ;inc si
        stosw                           ;печатаю последний символ 3 байтовой последовательности
        
        pop cx
        add di, 160 - 2*Len
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
end start
