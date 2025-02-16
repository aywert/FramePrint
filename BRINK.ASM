.model tiny
.code
org 100h

Begin_X    = 10
Begin_Y    = 10
Height     = 10
Len        = 28
Left_up    = 0c9h
Midle      = 0cdh
Colum      = 0bah
Right_up   = 0bbh
Left_down  = 0c8h
Right_down = 0bch

start:   
        mov ah, 02h
        mov bx, offset string
        mov dx, [bx]
        int 21h
        call DrawFrame

        mov ax, 4c00h
        int 21h
string db 'Hello, world!$'
StyleString db '+-+&!&(#)$'


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
        mov ah, 11011010b
        mov di, (Begin_Y-1)*80*2 + (Begin_X-1)*2 ; Num_Of_String * 80 * 2 + Num_Of_Position * 2
        stosw               ; mov es:[di], ax / inc di
        
        
        mov al, Midle
        call DrawStr

        mov al, Right_up
        stosw

        mov al, Colum
        mov ah, 11011010b
        call DrawCol

        mov al, Right_down
        stosw

        mov di, (Begin_Y-1)*80*2 + Begin_X*2
        mov al, Colum
        mov ah, 11011010b; no need to reclaim
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
;Destr: BX CX
;---------------------------------------------------------------
        DrawStr proc                        ; Creating a label on func (initialization of func) 
        mov cx, Len - 2;
        
        rep stosw
        ret 
        endp
;---------------------------------------------------------------
;draw a column in video memory
;Entry: AL = char to write
;       AH = color attributes
;Exit:  None
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
        mov bx, offset string
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
        mov bx, offset string
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