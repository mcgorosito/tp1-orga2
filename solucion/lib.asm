
section .data
null: DB 'NULL', 0
formatStr: DB '%s', 0
formatChar: DB '%c', 0
formatInt: DB '%d', 0
extern malloc
extern free
extern fprintf
extern listRemove

section .text

global strLen
global strClone
global strCmp
global strConcat
global strDelete
global strPrint
global listNew
global listAddFirst
global listAddLast
global listAdd
global listClone
global listDelete
global listPrint
global sorterNew
global sorterAdd
global sorterRemove
global sorterGetSlot
global sorterGetConcatSlot
global sorterCleanSlot
global sorterDelete
global sorterPrint
global fs_sizeModFive
global fs_firstChar
global fs_bitSplit

;*** String ***
strClone:
	push rbp
	mov rbp, rsp
	push rbx           ; preservar registros reservados
	push r12

	%define str_original rbx
	%define str_nueva rax
	%define str_len r12

	mov str_original, rdi
	call strLen        ; resultado en eax

	inc rax
	mov str_len, rax   ; usar el resultado extendido a 64 bits para comparar con pos de memoria
	mov rdi, str_len   
	call malloc		   ; solicitar strLen + 1 bits de memoria: ptr a str nueva en rax
	xor rcx, rcx	   ; inicializar contador en 0

.ciclo:
	cmp rcx, str_len
	je .fin
	mov r8b, [str_original+rcx]
	mov [str_nueva+rcx], r8b
	inc rcx
	jmp .ciclo

.fin:
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
strLen:
	push rbp
	mov rbp, rsp

	%define string rdi

	xor rcx, rcx     ; inicializar el contador en 0

.ciclo:
	mov sil, [string+rcx]
	cmp sil, 0
	je .fin
	inc rcx
	jmp .ciclo

.fin:
    mov eax, ecx
	pop rbp
	ret
;----------------------------------------------------------------
strCmp:
	push rbp
	mov rbp, rsp

	%define str_a rdi
	%define str_b rsi
	%define char_a dl
	%define char_b cl

.ciclo:
	mov char_a, [str_a]
	mov char_b, [str_b]

    cmp byte char_a, 0   ; si a es cero (ver si b también es cero)
    je .verSiBTambienEsCero

    cmp byte char_b, 0   ; si b es cero y a no
    je .mayor
    jmp .comparar        ; si ninguno es cero

.verSiBTambienEsCero:
	cmp byte char_b, 0   ; si b también es cero, las str son iguales
	je .igual
	jmp .menor           ; si no a es menor

.comparar:
	cmp char_a, char_b
	jg .mayor
	jl .menor

	inc str_a
    inc str_b
    jmp .ciclo

.menor:
	mov eax, 1
	jmp .fin

.mayor:
    mov eax, -1
    jmp .fin

.igual:
    mov eax, 0

.fin:
	pop rbp
	ret
;----------------------------------------------------------------
strConcat:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	%define str_a rbx
	%define str_b r12
	%define str_nueva rax
	%define len_a r13
	%define len_b r14

	mov str_a, rdi
	mov str_b, rsi
		
	call strLen       ; calcular longitud de a, resultado en eax
	mov len_a, rax    ; extender resultado a 64 bits para operar con memoria

	mov rdi, str_b    ; calcular longitud de b, resultado en rax
	call strLen
	mov len_b, rax

	mov rdi, len_a    ; sumar longitudes de a y b
	inc len_b
	add rdi, len_b
	call malloc
	
	xor rcx, rcx      ; inicializar rcx en cero (contador para recorrer str nueva)
	xor r8, r8        ; inicializar r8 en cero (contador para recorrer str a copiar)

.copiara:
	cmp r8, len_a
	je .reiniciar
	mov dl, [str_a+r8]
	mov [str_nueva+rcx], dl
	inc r8
	inc rcx
	jmp .copiara

.reiniciar: xor r8, r8  ; reiniciar contador a str a copiar

.copiarb:
	cmp r8, len_b
	je .borrar
	mov dl, [str_b+r8]
	mov [str_nueva+rcx], dl
	inc r8
	inc rcx
	jmp .copiarb

.borrar:
    mov r14, str_nueva
    cmp str_b, str_a
    je .iguales
    mov rdi, str_a
	call free
	
.iguales:
	mov rdi, str_b
	call free
	mov rax, r14

.fin:
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
strDelete:
	push rbp
	mov rbp, rsp

	call free

	pop rbp
	ret
;----------------------------------------------------------------
strPrint:
	push rbp
	mov rbp, rsp

	mov rdx, rdi        ; parámetros para fprintf: rdx <- ptr a str
	mov rdi, rsi        ; rdi <- ptr a file
	mov rsi, formatStr  ; rsi <- formato

    mov cl, [rdx]       ; chequear si str es vacía
	cmp cl, 0
	jne .print
	mov rdx, null       ; si es vacía, reemplazar "" por "NULL"
	
.print:
	call fprintf

	pop rbp
	ret
;----------------------------------------------------------------
;*** List ***

%define SIZE_STRUCT_LIST 16
%define SIZE_STRUCT_ELEM 24
%define OFFSET_FIRST 0
%define OFFSET_LAST 8
%define OFFSET_DATA 0
%define OFFSET_NEXT 8
%define OFFSET_PREV 16
%define NULL 0

listNew:
	push rbp
	mov rbp, rsp

	mov rdi, SIZE_STRUCT_LIST             ; reservar 16 bytes para los dos ptr de struct list_t
	call malloc
	mov qword [rax+OFFSET_FIRST], NULL    ; inicializar ptrs en null
	mov qword [rax+OFFSET_LAST], NULL

	pop rbp
	ret
;----------------------------------------------------------------
listAddFirst:
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	%define list rbx
	%define data r12
	%define new_elem rax
	%define next_elem rdi
	
	mov list, rdi
	mov data, rsi
	
	mov rdi, SIZE_STRUCT_ELEM      		      ; pedir 24 bytes para los 3 ptr del struct list_elem
	call malloc
	mov [new_elem], data          		      ; asignar data a la primera posición de list_elem
	mov qword [new_elem+OFFSET_NEXT], NULL    ; inicializar los ptrs en cero
	mov qword [new_elem+OFFSET_PREV], NULL

	cmp qword [list+OFFSET_FIRST], NULL
	je .vacia
    mov next_elem, [list+OFFSET_FIRST]        ; conectar el nuevo elem a su next (el 1ro de la lista) 
    mov [new_elem+OFFSET_NEXT], next_elem
    mov [next_elem+OFFSET_PREV], new_elem     ; conectar el nuevo elem al prev del siguiente
    jmp .fin
 
 .vacia:
    mov [list+OFFSET_LAST], new_elem          ; conectar last al nuevo elem

.fin:
    mov [list+OFFSET_FIRST], new_elem         ; conecta first al nuevo elem

	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
listAddLast:
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	%define list rbx
	%define data r12
	%define new_elem rax
	%define prev_elem rdi
	
	mov list, rdi
	mov data, rsi
	
	mov rdi, SIZE_STRUCT_ELEM
	call malloc
	mov [new_elem], data                    ; poner data en nuevo elem
	mov qword [new_elem+OFFSET_NEXT], NULL  ; inicializar los ptrs en cero
	mov qword [new_elem+OFFSET_PREV], NULL

	cmp qword [list], NULL
	je .vacia
    mov prev_elem, [list+OFFSET_LAST]       ; conectar el nuevo elem a su anterior (el último de la lista) 
    mov [prev_elem+OFFSET_NEXT], new_elem
    mov [new_elem+OFFSET_PREV], prev_elem   ; conectar prev del nuevo elem al anterior
    jmp .fin

.vacia:
    mov [list+OFFSET_FIRST], new_elem       ; conectar first al nuevo elem

.fin:
   	mov [list+OFFSET_LAST], new_elem        ; conectar last al nuevo elem

	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
listAdd:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	%define list rbx
	%define data r12
	%define func_cmp r13

    mov list, rdi
    mov data, rsi
    mov func_cmp, rdx

    mov rdi, SIZE_STRUCT_ELEM              ; crear el nuevo nodo
    call malloc
	mov [rax], data                        ; poner data en el nuevo nodo
	mov qword [rax+OFFSET_NEXT], NULL      ; inicializar los ptrs en 0
	mov qword [rax+OFFSET_PREV], NULL
	mov r12, rax                           ; ptr a nuevo nodo en r12
	mov rcx, [list+OFFSET_FIRST]      
	cmp qword [list+OFFSET_FIRST], NULL    ; chequear si la lista está vacía
	je .insertarvacia

	%define new_elem r12
	%define double_ptr r14
	%define actual r15

    mov double_ptr, list

.comparar:
    mov actual, [double_ptr]               ; comparar data nodo nuevo con data nodo actual
    mov rsi, [actual+OFFSET_DATA]
    mov rdi, [new_elem+OFFSET_DATA]
    call func_cmp
    cmp rax, 1
    je .insertar

    lea double_ptr, [actual+OFFSET_NEXT]   ; avanzar doble puntero
    cmp qword [double_ptr], NULL      	   ; ver si hay siguiente, si es null insertar el elemento al final
    je .insertarfinal
    jmp .comparar

.insertar:
	mov [new_elem+OFFSET_NEXT], actual     ; conectar el nuevo nodo a su siguiente (el actual)
	mov rcx, [actual+OFFSET_PREV]   
	cmp rcx, NULL                          ; si actual no tiene prev, es el 1ro (y nuevo se inserta al principio)
	jne .seguir
	mov [list+OFFSET_FIRST], new_elem      ; poner al nuevo nodo como first en struct lista
.seguir:
	mov [new_elem+OFFSET_PREV], rcx        ; conectar el nuevo nodo al anterior
	mov [actual+OFFSET_PREV], new_elem     ; poner el ptr al nuevo nodo en el prev del siguiente
	mov rdx, [new_elem+OFFSET_PREV]        ; cargar el ptr al anterior en rdx
	cmp rdx, NULL
	je .fin
	mov [rdx+OFFSET_NEXT], new_elem        ; cargar el nuevo nodo en siguiente del anterior
	jmp .fin

.insertarfinal:
    mov [new_elem+OFFSET_PREV], actual     ; conectar el nuevo nodo con su anterior
    mov [actual+OFFSET_NEXT], new_elem     ; conectar el nodo anterior con su siguiente
    mov [list+OFFSET_LAST], new_elem       ; poner al nuevo nodo como last en struct lista
    jmp .fin

.insertarvacia:
   mov [list+OFFSET_FIRST], new_elem
   mov [list+OFFSET_LAST], new_elem

.fin:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
listClone:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	%define list rbx
	%define func_dup r12
	%define new_list r13
	%define actual r14
	%define new_data rax

	mov list, rdi
    mov func_dup, rsi

    call listNew     				       ; crear nueva lista
	mov new_list, rax
	cmp qword [list+OFFSET_FIRST], NULL	   ; si la lista está vacía, termina (ptr a nueva ya está en rax)
    je .fin

    %define double_ptr rbx

.clone:
	mov actual, [double_ptr]    		   ; ptr a nodo actual (lista original)
	mov rdi, [actual+OFFSET_DATA]          ; carga ptr a data en rdi
	call func_dup           
	mov rdi, new_list
	mov rsi, new_data
	call listAddLast

	mov actual, [double_ptr]
	cmp qword [actual+OFFSET_NEXT], NULL   ; ver si next es null, y si lo es, terminar
	je .fin
	lea double_ptr, [actual+OFFSET_NEXT]   ; avanzar puntero
	jmp .clone

.fin:
	mov rax, new_list
    pop r14
    pop r13
    pop r12
    pop rbx
	pop rbp
    ret
;----------------------------------------------------------------
listDelete:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	%define list rbx
	%define func_delete r12

	mov list, rdi
	mov func_delete, rsi

	cmp qword [list+OFFSET_FIRST], NULL   ; si la lista está vacía, terminar
	je .fin

	%define actual r13
	%define actual_next r14

	mov actual, [list+OFFSET_FIRST]       ; borrar el primer nodo
	mov actual_next, [actual+OFFSET_NEXT]
	mov rdi, [actual+OFFSET_DATA]
	cmp func_delete, NULL
	je .seguir
	call func_delete

.seguir:
	mov rdi, actual
	call free
    cmp actual_next, NULL                 ; si el siguiente es null, terminar
    je .fin

.ciclo:
	mov actual, actual_next               ; pasar al siguiente nodo
	mov actual_next, [actual+OFFSET_NEXT]
	mov rdi, [actual+OFFSET_DATA]    
	cmp func_delete, NULL
	je .seguirCiclo
	call func_delete

.seguirCiclo:
	mov rdi, actual
	call free                
	cmp actual_next, NULL                 ; si el siguiente es null, terminar
    jne .ciclo

.fin:
    mov rdi, list                         ; borrar ptr a lista
    call free

	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
listPrint:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	%define BRACKET_INICIAL 91
	%define BRACKET_FINAL 93
	%define COMA 44
	%define list rbx
	%define file r12
	%define func_print r13
	%define double_ptr r14
	%define actual r15

	mov list, rdi
	mov file, rsi
	mov func_print, rdx

	mov rdi, file                            ; imprimir bracket inicial
	mov rsi, formatChar
	mov dl, BRACKET_INICIAL
	call fprintf

	cmp qword [list+OFFSET_FIRST], NULL
	je .fin

	mov double_ptr, rbx

.printElem:
    mov actual, [double_ptr]
    mov rdi, [actual+OFFSET_DATA]
    mov rsi, file
    call func_print

    cmp qword [actual+OFFSET_NEXT], NULL    ; ver si hay siguiente, si es null salta a fin
    je .fin
    lea double_ptr, [actual+OFFSET_NEXT]    ; avanzar doble puntero

	mov rdi, file                           ; imprimir coma
	mov rsi, formatChar
	mov dl, COMA
	call fprintf

    jmp .printElem

.fin:
	mov rdi, file                           ; imprimir bracket final
	mov rsi, formatChar
	mov dl, BRACKET_FINAL
	call fprintf

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
;*** Sorter ***
%define OFFSET_SIZE 0
%define OFFSET_SORTER_FUNC 8
%define OFFSET_CMP_FUNC 16
%define OFFSET_SLOTS 24
%define SIZE_SORTER_STRUCT 32
%define SIZE_SLOT 8

sorterNew:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	%define size bx
	%define funcSorter r12
	%define funcCmp r13
	%define sorter r14

	mov size, di
	mov funcSorter, rsi
	mov funcCmp, rdx

	mov rdi, SIZE_SORTER_STRUCT              ; crear sorter_t
	call malloc
	mov sorter, rax							 ; asignar size y funciones
	mov word [sorter+OFFSET_SIZE], size
	mov qword [sorter+OFFSET_SORTER_FUNC], funcSorter
	mov qword [sorter+OFFSET_CMP_FUNC], funcCmp
	
	mov di, size                            ; crear arreglo de punteros
	shl di, 3								; reservar memoria 8*size
	call malloc
	mov qword [r14+OFFSET_SLOTS], rax       ; poner en slots un ptr al primer elemento del arreglo
	
	mov r12, rax

	%define ptr_lista r12
	%define contador bx

.ciclo:
    cmp contador, 0
    je .fin
	call listNew                            ; crear nueva lista y guardar dir
	mov [ptr_lista], rax
	add ptr_lista, 8                        ; avanzar posición en el arreglo
	dec contador                            ; decrementar contador
	jmp .ciclo

.fin:
	mov rax, sorter                         ; devolver ptr a sorter
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

;----------------------------------------------------------------
sorterAdd:
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	%define sorter rbx
	%define data r12

	mov sorter, rdi                   ; sorter en r12 
	mov data, rsi                     ; guardar *data en r13 

	mov rdi, data                     ; determinar slot donde va el elemento, resultado en ax
	call [sorter+OFFSET_SORTER_FUNC]

	movzx rcx, ax                     ; calcular offset de lista donde insertar elem
	shl rcx, 3
	mov rdx, [sorter+OFFSET_SLOTS]    ; obtener primer elem de slots
	mov rdi, [rdx+rcx]                ; sumar dir primero + offset: rdi <- ptr a lista
	mov rsi, data                     ; cargar los otros parametros: rsi <- data, rdx <- funcCmp
	mov rdx, [sorter+OFFSET_CMP_FUNC]
	call listAdd

.fin:
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
sorterRemove:
	push rbp
	mov rbp, rsp
    push rbx
	push r12
	push r13
	push r14

	%define sorter rbx
	%define data r12
	%define funcDelete r13
	%define slots r14

	mov sorter, rdi
	mov data, rsi
	mov funcDelete, rdx

	mov rdi, data	                  ; llamar a la función sorter para encontrar slot
	call [sorter+OFFSET_SORTER_FUNC]  ; ax <- num de slot

	mov slots, [sorter+OFFSET_SLOTS]
	movzx rax, ax                     ; extender num de slot a 64 bits
	shl rax, 3	                      ; calcular offset: slot*8
	mov rdi, [slots+rax]	          ; cargar parámetros para listRemove: rbx <- *lista
	mov rsi, data                     ; rsi <- *data
	mov rdx, [sorter+OFFSET_CMP_FUNC] ; rdx <- *funcion_cmp
	mov rcx, funcDelete	              ; rcx <- *fd
	call listRemove

.fin:
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
sorterGetSlot:
	push rbp
	mov rbp, rsp

	%define sorter rdi
	%define num_slot si
	%define funcDup rdx

	movzx rcx, num_slot   	         ; extender num de slot a 64 bits
	shl rcx, 3                       ; calcular offset slot: slot*size_elem_arreglo (8)
	mov r8, [sorter+OFFSET_SLOTS]    ; sumar inicio arreglo y offset slot
	add r8, rcx
	mov rdi, [r8]				     ; poner ptr a lista en rdi
	mov rsi, funcDup
	call listClone                   ; resultado en rax

	pop rbp
	ret
;----------------------------------------------------------------
sorterGetConcatSlot:
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	%define sorter rdi
	%define num_slot si

	movzx rcx, num_slot                   ; ir al slot correspondiente
	shl rcx, 3
	mov r8, [rdi+OFFSET_SLOTS]
	add r8, rcx
	mov rcx, [r8]                         ; rcx <- lista correspondiente al slot
	mov r12, [rcx+OFFSET_FIRST]	          ; r12 <- nodo actual

	%define actual r12

	cmp actual, NULL                      ; caso lista vacía
	je .vacia

	cmp actual, [rcx+OFFSET_LAST]         ; caso un único elemento
	je .unElemento  

	mov rdi, [actual+OFFSET_DATA]         ; obtener copia de str a (primer elem)
	call strClone

	%define str_a rbx

.ciclo:
	mov str_a, rax                        ; guardar ptr a str a
	mov actual, [actual+OFFSET_NEXT]      ; avanzar el puntero al segundo elem
	mov rdi, [actual+OFFSET_DATA]         ; obtener copia de str b (en rax)
	call strClone

	mov rdi, str_a                        ; poner str a en rdi
	mov rsi, rax                          ; poner str_b en rsi
	call strConcat      				  ; resultado en rax

	cmp qword [actual+OFFSET_NEXT], NULL  ; si no hay siguiente, terminar
	je .fin
	jmp .ciclo

.vacia:
	mov rdi, 1
	call malloc
	mov byte [rax], 0                     ; devolver string vacía ("\0")
	jmp .fin

.unElemento:
	mov rdi, [actual+OFFSET_DATA]         ; clonar str del único elem
	call strClone                         ; resultado en rax
	jmp .fin

.fin:
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
sorterCleanSlot:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	%define sorter rdi
	%define num_slot si
	%define funcDelete rdx

	movzx rcx, num_slot            ; ir al slot correspondiente
	shl rcx, 3
	mov rbx, [sorter+OFFSET_SLOTS]
	add rbx, rcx                   ; rbx <- ptr a lista del slot correspondiente

	%define ptr_lista rbx

	mov rdi, [ptr_lista]           ; rdi <- lista correspondiente al slot
	mov rsi, funcDelete            ; funcDelete a rsi
	call listDelete                ; borrar lista
	call listNew                   ; crear lista nueva vacía y ponerla en el slot
	mov [ptr_lista], rax

	add rsp, 8
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
sorterDelete:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	%define sorter rbx
	%define funcDelete r12
	%define contador r13w
	%define actual r14

	mov sorter, rdi
	mov funcDelete, rsi
	mov contador, [sorter+OFFSET_SIZE]
	mov actual, [sorter+OFFSET_SLOTS]

.borrarListas:                       ; recorrer los slots y borrar las listas
	cmp contador, 0
	je .borrarSlots
	mov rdi, [actual]                ; poner lista en rdi
	mov rsi, funcDelete              ; poner funcDelete en rsi
	call listDelete
	add actual, SIZE_SLOT            ; avanzar en el arreglo
	dec contador
	jmp .borrarListas

.borrarSlots:
	mov rdi, [sorter+OFFSET_SLOTS]   ; borrar arreglo de slots
	call free

	mov rdi, sorter                  ; borrar sorter struct
	call free

	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
sorterPrint:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	%define EQUAL_SIGN 61
	%define LINE_BREAK 10
	%define SPACE 32
	%define sorter rbx
	%define file r12
	%define funcPrint r13

	mov sorter, rdi
	mov file, rsi
	mov funcPrint, rdx

	mov r15w, [sorter+OFFSET_SIZE]   ; guardar sorter size
    cmp r15w, 0					     ; si el sorter está vacío, terminar
    je .fin

	xor r14, r14                      ; inicializar contador en 0 (para número de lista)
	mov rbx, [sorter+OFFSET_SLOTS]

    %define sorter_size r15w
    %define ptr_lista rbx
    %define num_lista r14w

.ciclo:
	cmp num_lista, sorter_size
	je .fin
    mov rdi, file                     ; imprimir número de lista
	mov rsi, formatInt
	movzx edx, num_lista
	call fprintf

	mov rdi, file
	call imprimirEspacio

	mov rdi, file                     ; imprimir signo igual
	mov rsi, formatChar
	mov dl, EQUAL_SIGN
	call fprintf

	mov rdi, file
	call imprimirEspacio

	mov rdi, [ptr_lista]              ; recorrer listas e imprimirlas
	mov rsi, file
	mov rdx, funcPrint
	call listPrint

	mov rdi, file                     ; imprimir salto de línea
	mov rsi, formatChar
	mov dl, LINE_BREAK
	call fprintf

	add ptr_lista, SIZE_SLOT          ; ir a próxima lista
	inc num_lista
	jmp .ciclo

.fin:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;----------------------------------------------------------------
;*** aux Functions ***
fs_sizeModFive:
	push rbp
	mov rbp, rsp

	call strLen    ; calcular longitud de string (ya está en rdi)
				   ; longitud en eax
	xor rdx, rdx   ; inicializar rdx en cero
	cmp eax, 0     ; si strLen es cero, devuelve cero
	je .fin
	mov ecx, 5	   ; obtener el modulo
	div ecx        ; cociente en eax, modulo en edx

.fin:
	mov ax, dx     ; devolver el modulo en 16 bits
	pop rbp
	ret
;----------------------------------------------------------------
fs_firstChar:
	push rbp
	mov rbp, rsp

	movzx ax, [rdi]  ; extender el char a 16 bits

	pop rbp
	ret
;----------------------------------------------------------------
fs_bitSplit:
	push rbp
	mov rbp, rsp

	%define first_char cl
	%define potencia_dos dl
	%define contador sil

	mov first_char, [rdi]
	cmp first_char, 0
	je .cero
	mov potencia_dos, 1
	mov contador, 0

.ciclo:
	cmp first_char, potencia_dos
	je .esPotencia
	shl potencia_dos, 1
	inc contador
	cmp potencia_dos, 0        ; si llegó a cero, terminar (ya recorrió todas las potencias de dos
	je .noEsPotencia           ; y no es igual a ninguna)
	jmp .ciclo

.cero:
	mov ax, 8
	jmp .fin

.noEsPotencia:
	mov ax, 9
	jmp .fin

.esPotencia:
	movzx ax, contador

.fin:
	pop rbp
	ret
;----------------------------------------------------------------
; void imprimirEspacio(*pFile f);
imprimirEspacio:
	push rbp
	mov rbp, rsp

	mov rsi, formatChar
	mov dl, SPACE
	call fprintf

	pop rbp
	ret
