.model small

;------------------------------------; DAtA section ;------------------------------------;

.data

max_size equ 10 ;   equ is used to define a constant var
queue db max_size dup(0)
count dw ?
pointer dw ?
queue_front dw ?
queue_back dw ?

flag_empty db ?
flag_full db ?

element db ?
c db ?  ;col
r db ?  ;row



    ; main menu                                                     
heading db 09,09,'Welcome',0dh,0ah,'$'  ;09 for tap - 0dh,0ah for endl
choose_msg db 'choose a number',0dh,0ah,'$'
menu db 'menu:',0dh,0ah,'$'
ch1 db '1. Push an element',0dh,0ah,'$'
ch2 db '2. Pop an element',0dh,0ah,'$'
ch3 db '3. Print the whole queue',0dh,0ah,'$'
ch4 db '4. Print the front',0dh,0ah,'$' 
ch5 db '5. Print the back',0dh,0ah,'$'
ch6 db '6. Exit',0dh,0ah,'$'
enter_msg db 'Enter your choice: ','$'

    ; before printing
print_msg db 'The queue elements are: ','$'
num_of_elements db ' elements.','$'
front_msg db 'The front of the queue is: ','$'
back_msg db 'The back of the queue is: ','$'

    ; helper
add_msg db 'Enter a number: ','$'
full_msg db 'There is no enough space in the queue','$'
empty_msg db 09,'The queue is already empty','$'
error_msg db 'Enter valid number!','$'
newline db 0dh,0ah,'$'
space db ' ','$'


;------------------------------------; CODE section ;------------------------------------;
;------------------------------------; Main function ;------------------------------------;

.code
main proc far
   .startup
   
   call graphics
   call intialize_queue
   
   menu_loop:
       call display_menu  ; Display the menu options
       call read_char    ; Read user's choice
       call endl
       call endl

       cmp al, '1'
   je push_choice
       cmp al, '2'
   je pop_choice
       cmp al, '3'
   je print_choice
       cmp al, '4'
   je front_choice
       cmp al, '5'
   je back_choice
       cmp al, '6'
   je exit_program
   ; wrong choice
       lea dx,error_msg
       call display_string
       call endl
   jmp menu_loop

   push_choice:
       call push_back
   jmp menu_loop

   pop_choice:
       call pop_front
   jmp menu_loop

    print_choice:
        call display_queue
   jmp menu_loop

   front_choice:
       call front
   jmp menu_loop

   back_choice:
       call back
   jmp menu_loop

   exit_program:
       .exit

       
   .exit
main endp




;------------------------------------; Display menu functions ;------------------------------------;


    
display_menu proc near

   call sleep   ;to prevent the screen from being cleared too quickly
   call clear
   
   ; moving the cursor to the top left of the screen
   ; notice that in graphics mode we use cx,dx to deal with pixels - graphics mode has no cursor
   ; but here in text mode we use dh,dl and we deal with coordinates not pixels
   mov dh,0h  ;row
   mov dl,0h  ;col
   mov ah,02h
   int 10h
   
   lea dx,heading
   call display_string
   lea dx, choose_msg
   call display_string
   lea dx, menu
   call display_string
   lea dx, ch1
   call display_string
   lea dx, ch2
   call display_string
   lea dx, ch3
   call display_string
   lea dx, ch4
   call display_string
   lea dx, ch5
   call display_string
   lea dx, ch6
   call display_string
   lea dx, enter_msg
   call display_string
   
   ret
display_menu endp


;------------------------------------;


; clear screen - the function is hard coded and the pixels cleared are chosed manually 
; it will only work well with video mode 12h and may not work well in some screens

clear proc near

    ; clear by coloring the pixels with black
    ; color pixel interrupt 
    ; cleared the whole line horizontally starting from some chosen line (DX) vertically
    
    mov ah, 0ch      ; function code to color a pixel
    mov al, 00h      ; color to fill with (00h for black)
    mov cx, 00h      ; the beginning of the line
    mov dx, 48h      ; from where to start clearing vertically - know by trial
    
    ;nested loop to clear around whole 3 or 4 sentences written in 20h lines
    mov bp,30h       ; number of lines to clear completely vertically - the number was chosen to not affect the diagram
    clr:
        mov bx,300   ; to clear the whole line horizontally
        right1:
            int 10h  ;color
            inc cx   ;move rigth - starting from 0   
            dec bx
        jnz right1
        inc dx       ;move down
        mov cx,00h   ;return to the start of the line
        dec bp
    jne clr
    
    
    ; here I only clear 10h horizontally to not affect the diagram and also clear after print function
    ; in print function up to 10 numbers can be displayed vetically
    ; note that the line is not the same as the line in coordinates, it's around 5 or 6 times taller
    
    mov dx,68h  ;48h+30h
    mov cx,00h
    
    mov bp,80h  ;number of vertical lines to clear
    clr2:
        mov bx,10h      ; number of horizontal lines
        right2:
            int 10h
            inc cx      ; to go right
            dec bx
        jnz right2
        inc dx          ; to go down
        mov cx,00h      ; start at the beginning of the line
        dec bp
    jne clr2
    
    ret
clear endp


;------------------------------------;


; sleep function
; The LOOP instruction is specifically designed to manage loops and automatically decrement the CX register.
; However, it has a side effect that also affects DX in certain cases:
; When CX reaches zero, LOOP implicitly decrements DX by 1.
; This behavior allows for creating longer delays or iterating through larger data sets using nested loops

sleep proc near
    
    ;2000000 = 2sec, use of nested loop due to max-size dx can handle with 16bits.
    mov bp,100
    sleep2:
        mov dx, 20000   
        delay_loop:
        loop delay_loop 
        
        dec bp
    jne sleep2

    ret
sleep endp



;------------------------------------;  Graphics function ;------------------------------------;


; graphics
graphics proc near
    
    ; the interrupt for showing the graphics screen
    mov ah,0h
    mov al,13h  ;setting the video mode (12h or 13h)
    int 10h
    
    ; coordinates of the entry point - known by trial
    ; cx,dx have the pixels coordinates, the first pixel at the top left is cx:0 dx:0
    mov cx,200   ;right
    mov dx,350   ;down
    
    ; the int for coloring a pixel
    mov al,09h  ;pixel color
    mov ah,0ch 
    int 10h
    
    ; drawing the top horizontal line
    mov bx,210  ; # of pixels to color - the length of the line
    left:
        int 10h ;color the pixel interrupt
        dec cx  ;to go left
        dec bx
    jnz left
    
    ; drawing the farest left vertical line
    mov bx,20   ; # of pixels to color 
    down:
        int 10h
        inc dx  ;to go down
        dec bx
    jnz down
    
    ; drawing the bottom horizontal line
    mov bx,210
    right:
        int 10h
        inc cx  ;to ho right
        dec bx
    jnz right
    
    ; adjusting the coordinates to start drawing the vertical lines - known by trial
    mov cx,10
    mov dx,350
    
    ; nested loop to draw other vertical lines
    mov bl,9    ;# of lines
    draw:
        mov bh,20   ;#of pixels - the length of the line
        border:
            int 10h
            inc dx  ;to go down
            dec bh
        jnz border
        
        add cx,20   ;to go right for placing other lines
        sub dx,20   ;to go up by the line length to start to draw it
        dec bl
    jne draw
    
   
    ret
graphics endp



;------------------------------------; displaying queue elements on the diagram ;------------------------------------;



; function to place the cursor on the corresponding cell in the diagram with push and pop
; the function depends on the value of queue_front & queue_back to detemine the cell
cursor proc near

    ; Get cursor position interrupt
    mov ah, 03h  
    int 10h
    
    ; save the cursor attributes
    mov c,dl    ;col
    mov r,dh    ;row
    
    ; the intial col value in the first cell - known by trial
    mov dl,8 
    
    ; bx has queue_back value when push and queue_front value when pop
    cmp bx,0h   
    je c0
    cmp bx,1h
    je c1
    cmp bx,2h
    je c2
    cmp bx,3h
    je c3
    cmp bx,4h
    je c4
    cmp bx,5h
    je c5
    cmp bx,6h
    je c6
    cmp bx,7h
    je c7
    cmp bx,8h
    je c8
    cmp bx,9h
    je c9
    
    
    ;all values known by trial
    
c0:
    add dl,0
    jmp stopc
c1:
    add dl,2
    jmp stopc
c2:
    add dl,5
    jmp stopc
c3:
    add dl,7
    jmp stopc
c4:
    add dl,10
    jmp stopc
c5:
    add dl,12
    jmp stopc
c6:
    add dl,15
    jmp stopc
c7:
    add dl,17
    jmp stopc
c8:
    add dl,20
    jmp stopc
c9:
    add dl,23
    jmp stopc
   
stopc:
    
    mov dh,19  ;row
    mov bl,5h  ;color attribute
    
    ; set cursor interrupt
    mov ah,02h  
    int 10h
    
    ret
cursor endp


;------------------------------------;


; display the element in the stack
emplace_element proc near

    ; to use queue_back in cursor call
    mov bx,queue_back   
    call cursor
    
    ; the value pushed is presaved in element var in push fun
    mov al, element     
    call display_char
    
    ; returning the cursor to where it was (to the text section instead of diagram one)
    ; values of the cursor were presaved in cursor fun
    mov dl,c
    mov dh,r
    
    ; Set cursor position interrupt
    mov ah, 02h  
    int 10h
    ret
    
emplace_element endp


;------------------------------------;


delete_element proc near

    ; to use queue_front in cursor call
    mov bx,queue_front
    call cursor
    
    ; to undisplay the value poped, just put a space at the same coordinates
    lea dx,space
    call display_string
    
    ; returning the cursor to where it was (to the text section instead of diagram one)
    ; values of the cursor were presaved in cursor fun
    mov dl,c
    mov dh,r
    
    ; Set cursor position interrupt
    mov ah, 02h  
    int 10h
    ret
    
delete_element endp



;------------------------------------; Helper Fuctions ;------------------------------------;



; for the inc and % formula, requires dealing with bx
next proc near
    cmp bx,max_size
    je equal
    
    jmp next_stop
    
    equal:
        mov bx,0h
    next_stop:
    ret
next endp

;------------------------------------;

; char is read into al
read_char proc near
    mov ah,01h
    int 21h
    ret
read_char endp

;------------------------------------;

; display what's in al
display_char proc near
    mov dh,bl  ;save bl value 
    mov bl,0Eh  ;color attribute
    mov ah,0Eh
    int 10h
    mov bl,dh  ; return the bl value as it is (cuz it affected the print fun)
    ret
display_char endp

;------------------------------------;

; display msg fun
display_string proc near
    mov ah,09h
    int 21h
    ret
display_string endp

;------------------------------------;

; to endl
endl proc near
    lea dx,newline
    call display_string
    ret
endl endp



;------------------------------------; Queue Implementation functions ;------------------------------------;


   ;intialize queue
intialize_queue proc near
   lea si, queue
   mov pointer,si
   mov queue_front,0h
   mov queue_back,max_size-1 ;so that the first element added to cell 0
   ret
intialize_queue endp


;------------------------------------;


    ;print
display_queue proc near
    call is_empty
    cmp flag_empty,1h
    je empty_display
    
    mov bx,queue_front
    lea dx, print_msg
    call display_string

    mov ax,count
    add al,30h
    call display_char   ;it will sadly not be able to display 10 cuz it's 2 digits
    lea dx, num_of_elements
    call display_string
    call endl
    
    
    queue_print:
        mov bp,pointer
        add bp,bx
        mov al,[bp]
        call display_char
        lea dx,space
        call display_string
        cmp bx,queue_back 
        je display_stop
        inc bx
        call next
    jmp queue_print
    
    
    empty_display:
        lea dx,empty_msg
        call display_string
        call endl
    
    display_stop:
    ret
display_queue endp


;------------------------------------;


   ;push
push_back proc near
   
   Call is_full
   cmp flag_full,1h
   je full_to_push
   
   
   not_full_to_push:
       inc count
       inc queue_back
       mov bx, queue_back
       call next
       mov queue_back,bx
       
       
       lea dx,add_msg
       call display_string
       call read_char
       mov element,al
       call endl
       call emplace_element
       
       mov bx, pointer
       add bx,queue_back
       mov [bx],al
   jmp push_stop
   
   
   full_to_push:
       lea dx,full_msg
       call display_string
       call endl
   
   push_stop:
   ret
push_back endp


;------------------------------------;


    ;pop
pop_front proc near
   Call is_empty
   cmp flag_empty,1h
   je empty_to_pop
   
   not_empty_to_pop:
       dec count
       call delete_element   ;call it first before changing queue_front value
       inc queue_front
       mov bx, queue_front
       call next
       mov queue_front,bx
   jmp pop_stop
   
   empty_to_pop:
       lea dx,empty_msg
       call display_string
       call endl
   
   pop_stop:
   ret
pop_front endp  


;------------------------------------;


    ;front
front proc near
   call is_empty
   cmp flag_empty,1h
   je empty
   
   mov bx,pointer
   add bx,queue_front
   mov ax,[bx]
   lea dx, front_msg
   call display_string
   call display_char
   call endl
   jmp empty_stop
   
   empty:
       lea dx,empty_msg
       call display_string
       call endl
   
   empty_stop:
   ret
front endp


;------------------------------------;


    ;back
back proc near
   call is_empty
   cmp flag_empty,1h
   je back_empty
   
   mov bx,pointer
   add bx,queue_back
   mov ax,[bx]
   lea dx, back_msg
   call display_string
   call display_char
   call endl
   jmp back_stop
   
   back_empty:
       lea dx,empty_msg
       call display_string
       call endl
   
   back_stop:
   ret
back endp


;------------------------------------;


   ;isfull
is_full proc near
   mov dx,count
   cmp dx,max_size
   je full
   
   
   not_full:
       mov dh,0h
       mov flag_full,dh
   jmp stop
   
   full:
       mov dh,1h
       mov flag_full,dh
   
   stop:
   ret
is_full endp


;------------------------------------;


   
   ;is empty
is_empty proc near
   mov dx,0h
   cmp dx,count
   je front_empty
   
   not_empty:
       mov dh,0h
       mov flag_empty,dh
   jmp is_empty_stop
   
   front_empty:
       mov dh,1h
       mov flag_empty,dh
   
   is_empty_stop:
   ret
is_empty endp


   
end main    


