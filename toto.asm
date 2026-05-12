; ========================================
; ADVANCED SORTING ALGORITHM VISUALIZER
; WITH FLAWLESS REAL-TIME BAR ANIMATION
; FIXED: UI Overlap, Colors, and Bar Rendering
; Build: nasm -f bin toto.asm -o toto.com
; ========================================

org 100h
bits 16

%define MAX_SIZE        200
%define ALG_COUNT       6
%define ARRAY_SIZE      60
%define VISUAL_START    6

%define CLR_HEADER      1Eh
%define CLR_BODY        1Fh
%define CLR_ACCENT      2Eh
%define CLR_SUCCESS     0Ah
%define CLR_SWAP        0Ch
%define CLR_NORMAL      07h
%define CLR_BG          1Fh

start:
    mov ax, 0003h
    int 10h
    mov word [seed], 1234h
    jmp show_menu

; ========================================
; MAIN MENU
; ========================================
show_menu:
    call clear_screen
    call draw_header
    
    mov dh, 3
    mov dl, 2
    mov si, menu_select
    call putstr
    
    mov dh, 5
    mov si, opt_1
    call putstr
    
    mov dh, 6
    mov si, opt_2
    call putstr
    
    mov dh, 7
    mov si, opt_3
    call putstr
    
    mov dh, 8
    mov si, opt_4
    call putstr
    
    mov dh, 9
    mov si, opt_5
    call putstr
    
    mov dh, 10
    mov si, opt_6
    call putstr
    
    mov dh, 11
    mov si, opt_all
    call putstr
    
    mov dh, 12
    mov si, opt_help
    call putstr
    
    mov dh, 13
    mov si, opt_exit
    call putstr
    
    mov dh, 15
    mov si, prompt
    call putstr
    
    mov ah, 00h
    int 16h
    
    cmp al, 27
    je end_prog
    
    cmp al, 'H'
    je show_help
    cmp al, 'h'
    je show_help
    
    cmp al, 'A'
    je run_all
    cmp al, 'a'
    je run_all
    
    cmp al, '1'
    jb show_menu
    cmp al, '6'
    ja show_menu
    
    sub al, '1'
    mov [algo], al
    call visualize_sort
    jmp show_menu

show_help:
    call show_help_screen
    jmp show_menu

run_all:
    xor cl, cl

run_all_loop:
    cmp cl, ALG_COUNT
    jge show_menu
    
    mov [algo], cl
    push cx
    call visualize_sort
    pop cx
    inc cl
    jmp run_all_loop

end_prog:
    mov ax, 4C00h
    int 21h

; ========================================
; HELP SCREEN
; ========================================
show_help_screen:
    call clear_screen
    call draw_header
    
    mov dh, 3
    mov dl, 2
    mov si, help_title
    call putstr
    
    mov dh, 5
    mov si, help_line1
    call putstr
    
    mov dh, 6
    mov si, help_line2
    call putstr
    
    mov dh, 7
    mov si, help_line3
    call putstr
    
    mov dh, 8
    mov si, help_line4
    call putstr
    
    mov dh, 10
    mov si, algo_title
    call putstr
    
    mov dh, 11
    mov si, algo_1
    call putstr
    
    mov dh, 12
    mov si, algo_2
    call putstr
    
    mov dh, 13
    mov si, algo_3
    call putstr
    
    mov dh, 14
    mov si, algo_4
    call putstr
    
    mov dh, 15
    mov si, algo_5
    call putstr
    
    mov dh, 16
    mov si, algo_6
    call putstr
    
    mov dh, 23
    mov si, press_any
    call putstr
    
    mov ah, 00h
    int 16h
    ret

; ========================================
; LIVE VISUALIZATION
; ========================================
visualize_sort:
    call clear_screen
    call draw_header
    
    mov dh, 2
    mov dl, 2
    call display_algo_name
    
    mov dh, 3
    mov dl, 2
    mov si, complexity_label
    call putstr
    
    mov dl, 20
    call display_complexity
    
    mov dh, 4
    mov dl, 2
    mov si, desc_label
    call putstr
    
    mov dl, 20
    call display_description
    
    call fill_random_array
    
    mov dh, VISUAL_START
    mov dl, 2
    mov si, before_label
    call putstr
    
    mov bl, CLR_NORMAL
    call draw_bars
    
    call get_time
    mov [t_start], ax
    
    mov al, [algo]
    cmp al, 0
    jne .skip_bubble
    call bubble_sort_animated
    jmp .sort_complete
.skip_bubble:
    cmp al, 1
    jne .skip_select
    call selection_sort_animated
    jmp .sort_complete
.skip_select:
    cmp al, 2
    jne .skip_insert
    call insertion_sort_animated
    jmp .sort_complete
.skip_insert:
    cmp al, 3
    jne .skip_shell
    call shell_sort_animated
    jmp .sort_complete
.skip_shell:
    cmp al, 4
    jne .skip_quick
    call quick_sort_animated
    jmp .sort_complete
.skip_quick:
    call merge_sort_animated

.sort_complete:
    call get_time
    sub ax, [t_start]
    mov [elapsed], ax
    
    mov dh, VISUAL_START
    mov dl, 2
    mov si, after_label
    call putstr
    
    mov bl, CLR_SUCCESS
    call draw_bars
    
    mov dh, VISUAL_START + 10
    mov dl, 2
    mov si, result_time
    call putstr
    
    mov dl, 25
    mov ax, [elapsed]
    call print_num
    
    mov dh, VISUAL_START + 11
    mov dl, 2
    mov si, result_swaps
    call putstr
    
    mov dl, 25
    mov ax, [swap_count]
    call print_num
    
    mov dh, VISUAL_START + 12
    mov dl, 2
    mov si, result_comps
    call putstr
    
    mov dl, 25
    mov ax, [comp_count]
    call print_num
    
    mov dh, 23
    mov dl, 2
    mov si, return_menu
    call putstr
    
    mov ah, 00h
    int 16h
    ret

display_algo_name:
    mov al, [algo]
    cmp al, 0
    jne .skip_n1
    mov si, name_1
    jmp .show_name
.skip_n1:
    cmp al, 1
    jne .skip_n2
    mov si, name_2
    jmp .show_name
.skip_n2:
    cmp al, 2
    jne .skip_n3
    mov si, name_3
    jmp .show_name
.skip_n3:
    cmp al, 3
    jne .skip_n4
    mov si, name_4
    jmp .show_name
.skip_n4:
    cmp al, 4
    jne .skip_n5
    mov si, name_5
    jmp .show_name
.skip_n5:
    mov si, name_6
.show_name:
    call putstr
    ret

display_complexity:
    mov al, [algo]
    cmp al, 0
    jne .skip_c1
    mov si, comp_bubble
    jmp .show_c
.skip_c1:
    cmp al, 1
    jne .skip_c2
    mov si, comp_select
    jmp .show_c
.skip_c2:
    cmp al, 2
    jne .skip_c3
    mov si, comp_insert
    jmp .show_c
.skip_c3:
    cmp al, 3
    jne .skip_c4
    mov si, comp_shell
    jmp .show_c
.skip_c4:
    cmp al, 4
    jne .skip_c5
    mov si, comp_quick
    jmp .show_c
.skip_c5:
    mov si, comp_merge
.show_c:
    call putstr
    ret

display_description:
    mov al, [algo]
    cmp al, 0
    jne .skip_d1
    mov si, desc_bubble
    jmp .show_d
.skip_d1:
    cmp al, 1
    jne .skip_d2
    mov si, desc_select
    jmp .show_d
.skip_d2:
    cmp al, 2
    jne .skip_d3
    mov si, desc_insert
    jmp .show_d
.skip_d3:
    cmp al, 3
    jne .skip_d4
    mov si, desc_shell
    jmp .show_d
.skip_d4:
    cmp al, 4
    jne .skip_d5
    mov si, desc_quick
    jmp .show_d
.skip_d5:
    mov si, desc_merge
.show_d:
    call putstr
    ret

; ========================================
; DRAW BARS (Memory variable based to stop register crashing)
; ========================================
draw_bars:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov byte [draw_color], bl
    mov word [col_idx], 0
    
draw_loop:
    mov si, [col_idx]
    cmp si, ARRAY_SIZE
    jge draw_done
    
    mov al, [data + si]
    shr al, 3
    mov byte [bar_height], al
    
    mov byte [row_idx], 0
    
draw_column:
    cmp byte [row_idx], 8
    jge draw_next
    
    mov dl, 2
    add dl, byte [col_idx]
    
    mov dh, VISUAL_START + 1
    add dh, byte [row_idx]
    call position_cursor
    
    mov ah, 8
    sub ah, byte [bar_height]
    cmp byte [row_idx], ah
    jge .draw_solid
    
.draw_empty:
    mov ah, 09h
    mov al, ' '
    mov bl, CLR_BG
    push cx
    mov cx, 1
    int 10h
    pop cx
    jmp .finish_char
    
.draw_solid:
    mov ah, 09h
    mov al, 219
    mov bl, [draw_color]
    push cx
    mov cx, 1
    int 10h
    pop cx
    
.finish_char:
    inc byte [row_idx]
    jmp draw_column
    
draw_next:
    inc word [col_idx]
    jmp draw_loop
    
draw_done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

position_cursor:
    push ax
    push bx
    mov ah, 02h
    mov bh, 0
    int 10h
    pop bx
    pop ax
    ret

fill_random_array:
    mov cx, ARRAY_SIZE
    xor bx, bx
fill_loop:
    call rand
    and al, 03Fh     ; Limit randoms to 0-63
    add al, 8        ; Shift to 8-71 (guarantees heights from 1 to 8 bars)
    mov [data + bx], al
    inc bx
    loop fill_loop
    
    mov word [swap_count], 0
    mov word [comp_count], 0
    ret

delay_short:
    push ax
    push cx
    push dx
    mov ah, 86h
    mov cx, 0
    mov dx, 15000
    int 15h
    pop dx
    pop cx
    pop ax
    ret

; ========================================
; BUBBLE SORT
; ========================================
bubble_sort_animated:
    push ax
    push bx
    push cx
    push dx
    
    mov cx, ARRAY_SIZE

bubble_outer:
    mov bx, 0
    mov dx, cx
    dec dx
    cmp dx, 0
    jle bubble_exit
    
bubble_inner:
    mov al, [data + bx]
    mov ah, [data + bx + 1]
    inc word [comp_count]
    
    cmp al, ah
    jbe bubble_skip
    
    mov [data + bx], ah
    mov [data + bx + 1], al
    inc word [swap_count]
    
    push bx
    mov bl, CLR_SWAP
    call draw_bars
    pop bx
    call delay_short
    
bubble_skip:
    inc bx
    dec dx
    jnz bubble_inner
    loop bubble_outer
    
bubble_exit:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ========================================
; SELECTION SORT
; ========================================
selection_sort_animated:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov cx, ARRAY_SIZE
    mov bx, 0
    
sel_outer:
    mov dx, cx
    dec dx
    cmp dx, 0
    jle sel_exit
    
    mov si, bx
    mov di, bx
    mov al, [data + bx]
    
sel_inner:
    inc si
    mov ah, [data + si]
    inc word [comp_count]
    
    cmp ah, al
    jae sel_skip
    mov al, ah
    mov di, si
    
sel_skip:
    dec dx
    jnz sel_inner
    
    mov ah, [data + bx]
    mov [data + bx], al
    mov [data + di], ah
    inc word [swap_count]
    
    push bx
    mov bl, CLR_SWAP
    call draw_bars
    pop bx
    call delay_short
    
    inc bx
    loop sel_outer
    
sel_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ========================================
; INSERTION SORT
; ========================================
insertion_sort_animated:
    push ax
    push bx
    push cx
    push si
    
    mov bx, 1
    mov cx, ARRAY_SIZE
    
ins_outer:
    cmp bx, cx
    jge ins_exit
    
    mov al, [data + bx]
    mov si, bx
    
ins_inner:
    cmp si, 0
    jle ins_place
    
    mov ah, [data + si - 1]
    inc word [comp_count]
    
    cmp ah, al
    jbe ins_place
    
    mov [data + si], ah
    inc word [swap_count]
    dec si
    jmp ins_inner
    
ins_place:
    mov [data + si], al
    
    push bx
    mov bl, CLR_SWAP
    call draw_bars
    pop bx
    call delay_short
    
    inc bx
    jmp ins_outer
    
ins_exit:
    pop si
    pop cx
    pop bx
    pop ax
    ret

; ========================================
; SHELL SORT
; ========================================
shell_sort_animated:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov cx, ARRAY_SIZE
    mov dx, cx
    shr dx, 1
    
shell_gap:
    cmp dx, 0
    jle shell_exit
    
    mov bx, dx
    
shell_outer:
    cmp bx, cx
    jge shell_next_gap
    
    mov al, [data + bx]
    mov si, bx
    
shell_inner:
    cmp si, dx
    jb shell_place
    
    mov di, si
    sub di, dx
    mov ah, [data + di]
    inc word [comp_count]
    
    cmp ah, al
    jbe shell_place
    
    mov [data + si], ah
    inc word [swap_count]
    sub si, dx
    jmp shell_inner
    
shell_place:
    mov [data + si], al
    
    push bx
    mov bl, CLR_SWAP
    call draw_bars
    pop bx
    call delay_short
    
    inc bx
    jmp shell_outer
    
shell_next_gap:
    shr dx, 1
    jmp shell_gap
    
shell_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ========================================
; QUICK SORT
; ========================================
quick_sort_animated:
    mov word [swap_count], 0
    mov word [comp_count], 0
    mov si, 0
    mov di, ARRAY_SIZE
    dec di
    call quick_sort_anim
    ret

quick_sort_anim:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    cmp si, di
    jge qs_exit
    
    mov cx, si
    mov dx, di
    mov bx, si
    add bx, di
    shr bx, 1
    mov al, [data + bx]
    
qs_part:
    mov bx, cx
    mov ah, [data + bx]
    inc word [comp_count]
    cmp ah, al
    jge qs_p2
    inc cx
    jmp qs_part
    
qs_p2:
    mov bx, dx
    mov ah, [data + bx]
    inc word [comp_count]
    cmp ah, al
    jle qs_swap
    dec dx
    jmp qs_p2
    
qs_swap:
    cmp cx, dx
    jg qs_rec
    
    mov bx, cx
    push di
    mov di, dx
    
    mov ah, [data + bx]
    push ax
    
    mov al, [data + di]
    mov [data + bx], al
    
    pop ax
    mov [data + di], ah
    
    pop di
    inc word [swap_count]
    
    push bx
    mov bl, CLR_SWAP
    call draw_bars
    pop bx
    call delay_short
    
    inc cx
    dec dx
    jmp qs_part
    
qs_rec:
    push di
    push si
    mov di, dx
    call quick_sort_anim
    pop si
    pop di
    mov si, cx
    call quick_sort_anim
    
qs_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ========================================
; MERGE SORT
; ========================================
merge_sort_animated:
    mov word [swap_count], 0
    mov word [comp_count], 0
    call merge_sort_anim
    ret

merge_sort_anim:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov cx, 1
    
ms_size:
    mov bx, 0
    
ms_outer:
    mov si, bx
    add si, cx
    cmp si, ARRAY_SIZE
    jae ms_next
    
    mov di, si
    add di, cx
    cmp di, ARRAY_SIZE
    jbe ms_do
    
    mov di, ARRAY_SIZE
    
ms_do:
    call merge_anim
    add bx, cx
    add bx, cx
    jmp ms_outer
    
ms_next:
    shl cx, 1
    cmp cx, ARRAY_SIZE
    jb ms_size
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

merge_anim:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    
    mov [p_start], bx
    mov [p_left], bx
    mov [p_mid], si
    mov [p_right], si
    mov [p_end], di
    mov [p_tmp], bx
    
ms_loop:
    mov bx, [p_left]
    cmp bx, [p_mid]
    jae ms_right_only
    
    mov si, [p_right]
    cmp si, [p_end]
    jae ms_left_only
    
    mov cl, [data + bx]
    mov ch, [data + si]
    inc word [comp_count]
    
    cmp cl, ch
    jbe ms_take_left
    
ms_take_right:
    mov bp, [p_tmp]
    mov [tmp + bp], ch
    inc word [p_right]
    inc word [swap_count]
    inc word [p_tmp]
    jmp ms_loop
    
ms_take_left:
    mov bp, [p_tmp]
    mov [tmp + bp], cl
    inc word [p_left]
    inc word [p_tmp]
    jmp ms_loop
    
ms_left_only:
    mov bx, [p_left]
    cmp bx, [p_mid]
    jae ms_copy_back
    
    mov cl, [data + bx]
    mov bp, [p_tmp]
    mov [tmp + bp], cl
    inc word [p_left]
    inc word [p_tmp]
    jmp ms_left_only
    
ms_right_only:
    mov si, [p_right]
    cmp si, [p_end]
    jae ms_copy_back
    
    mov ch, [data + si]
    mov bp, [p_tmp]
    mov [tmp + bp], ch
    inc word [p_right]
    inc word [p_tmp]
    jmp ms_right_only
    
ms_copy_back:
    mov bx, [p_start]
    mov cx, [p_tmp]
    sub cx, bx
    mov si, tmp
    add si, bx
    mov di, bx
    
ms_copy:
    cmp cx, 0
    jle ms_copy_done
    mov al, [si]
    mov [data + di], al
    inc si
    inc di
    dec cx
    jmp ms_copy
    
ms_copy_done:
    mov bx, [p_start]
    push bx
    mov bl, CLR_SWAP
    call draw_bars
    pop bx
    call delay_short
    
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ========================================
; HELPER FUNCTIONS
; ========================================
get_time:
    mov ah, 00h
    int 1Ah
    mov ax, dx
    ret

rand:
    mov ax, [seed]
    mov bx, 25173
    mul bx
    add ax, 13849
    mov [seed], ax
    mov al, ah
    ret

print_num:
    push ax
    mov [num_val], ax
    call to_str
    mov si, num_buf
    call putstr
    pop ax
    ret

to_str:
    mov ax, [num_val]
    mov di, num_buf + 9
    mov byte [di], 0
    dec di
    mov cx, 10

ts_loop:
    xor dx, dx
    div cx
    add dl, '0'
    mov [di], dl
    dec di
    test ax, ax
    jnz ts_loop
    
    inc di
    mov si, di
    mov di, num_buf

ts_copy:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    cmp al, 0
    jne ts_copy
    ret

clear_screen:
    mov ax, 0600h
    mov bh, CLR_BODY
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret

draw_header:
    mov ah, 02h
    mov bh, 0
    mov dx, 0000h
    int 10h
    
    mov ah, 09h
    mov cx, 80
    mov al, 205
    mov bl, CLR_HEADER
    int 10h
    
    mov dh, 0
    mov dl, 15
    mov si, title
    mov bl, CLR_HEADER   ; Keep header blue
    call putstr_attr
    ret

; Sets normal color before printing string
putstr:
    mov bl, CLR_NORMAL
putstr_attr:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es
    
    mov di, si
    xor cx, cx

cnt_loop:
    cmp byte [di], 0
    je cnt_done
    inc cx
    inc di
    jmp cnt_loop
    
cnt_done:
    mov ax, cs
    mov es, ax
    mov bp, si
    mov ah, 13h
    mov al, 01h
    mov bh, 0
    int 10h
    
    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ========================================
; STRINGS & DATA
; ========================================
title               db '===== SORTING ALGORITHM VISUALIZER =====', 0
menu_select         db 'SELECT ALGORITHM:', 0
opt_1               db '1 = Bubble Sort', 0
opt_2               db '2 = Selection Sort', 0
opt_3               db '3 = Insertion Sort', 0
opt_4               db '4 = Shell Sort', 0
opt_5               db '5 = Quick Sort', 0
opt_6               db '6 = Merge Sort', 0
opt_all             db 'A = Run All', 0
opt_help            db 'H = Help', 0
opt_exit            db 'ESC = Exit', 0
prompt              db 'Choice: ', 0

help_title          db 'SORTING ALGORITHM INFORMATION', 0
help_line1          db 'Watch how 60 numbers get sorted with smooth animated bars!', 0
help_line2          db 'Red bars = swapping/sorting in progress', 0
help_line3          db 'Green bars = final sorted result', 0
help_line4          db 'Compare speed and efficiency of each algorithm', 0

algo_title          db 'ALGORITHMS:', 0
algo_1              db '1. Bubble - O(n^2) - Compares neighbors', 0
algo_2              db '2. Selection - O(n^2) - Finds minimum', 0
algo_3              db '3. Insertion - O(n^2) - Builds sorted', 0
algo_4              db '4. Shell - O(n log n) - Gap insertion', 0
algo_5              db '5. Quick - O(n log n) avg - Partitions', 0
algo_6              db '6. Merge - O(n log n) - Divides/merges', 0

press_any           db 'Press any key...', 0

complexity_label    db 'Complexity: ', 0
desc_label          db 'Method:     ', 0

comp_bubble         db 'O(n^2)', 0
comp_select         db 'O(n^2)', 0
comp_insert         db 'O(n^2)', 0
comp_shell          db 'O(n log n)', 0
comp_quick          db 'O(n log n) avg', 0
comp_merge          db 'O(n log n)', 0

desc_bubble         db 'Adjacent element comparison', 0
desc_select         db 'Find and swap minimum', 0
desc_insert         db 'Insert into sorted portion', 0
desc_shell          db 'Gap-based insertion', 0
desc_quick          db 'Pivot partition divide', 0
desc_merge          db 'Divide and merge sort', 0

before_label        db 'BEFORE (Random):', 0
after_label         db 'AFTER (Sorted):', 0

result_time         db 'Time (ticks):', 0
result_swaps        db 'Swaps:', 0
result_comps        db 'Comparisons:', 0
return_menu         db 'Press ANY KEY to continue...', 0

name_1              db 'BUBBLE SORT', 0
name_2              db 'SELECTION SORT', 0
name_3              db 'INSERTION SORT', 0
name_4              db 'SHELL SORT', 0
name_5              db 'QUICK SORT', 0
name_6              db 'MERGE SORT', 0

; ========================================
; VARIABLES
; ========================================
algo                db 0
seed                dw 1234h
draw_color          db 0
col_idx             dw 0
row_idx             db 0
bar_height          db 0

t_start             dw 0
elapsed             dw 0
swap_count          dw 0
comp_count          dw 0

num_val             dw 0
num_buf             times 12 db 0

p_start             dw 0
p_left              dw 0
p_right             dw 0
p_mid               dw 0
p_end               dw 0
p_tmp               dw 0

; ========================================
; DATA ARRAYS
; ========================================
data                times MAX_SIZE db 0
tmp                 times MAX_SIZE db 0