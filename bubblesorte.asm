.data
# Mensajes para el usuario
msg_ingreso:      .asciiz "Ingrese la cantidad de elementos (max 20): "
msg_ingreso_num:  .asciiz "Ingrese el numero "
msg_dos_puntos:   .asciiz ": "
msg_array_orig:   .asciiz "\n=== ARRAY ORIGINAL ===\n"
msg_array_ord:    .asciiz "\n=== ARRAY ORDENADO ===\n"
msg_espacio:      .asciiz " "
msg_salto:        .asciiz "\n"
msg_error:        .asciiz "Error: cantidad invalida. Debe ser entre 1 y 20.\n"
msg_intercambio:  .asciiz "Intercambiando...\n"
msg_paso:         .asciiz "\nPaso "
msg_detener:      .asciiz " - Array ya ordenado, deteniendo...\n"

# Espacio para el array (max 20 elementos)
array:            .word 0:20
array_size:       .word 0

.text
.globl main

main:
    # Configurar pila
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Solicitar cantidad de elementos
    jal solicitar_cantidad
    move $s0, $v0              # $s0 = n (cantidad de elementos)
    
    # Guardar tamaño
    la $t0, array_size
    sw $s0, 0($t0)
    
    # Solicitar elementos del array
    la $a0, array              # Dirección base del array
    move $a1, $s0              # Cantidad de elementos
    jal ingresar_elementos
    
    # Mostrar array original
    la $a0, msg_array_orig
    li $v0, 4
    syscall
    
    la $a0, array
    move $a1, $s0
    jal mostrar_array
    
    # Ordenar con Bubble Sort
    la $a0, array              # Dirección base del array
    move $a1, $s0              # Cantidad de elementos
    jal bubble_sort
    
    # Mostrar array ordenado
    la $a0, msg_array_ord
    li $v0, 4
    syscall
    
    la $a0, array
    move $a1, $s0
    jal mostrar_array
    
    # Terminar programa
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 10
    syscall

solicitar_cantidad:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    
solicitar_loop:
    # Mostrar mensaje
    li $v0, 4
    la $a0, msg_ingreso
    syscall
    
    # Leer número
    li $v0, 5
    syscall
    move $s0, $v0
    
    # Validar (1-20)
    li $t0, 1
    blt $s0, $t0, error_cantidad
    li $t0, 20
    bgt $s0, $t0, error_cantidad
    
    # Válido
    move $v0, $s0
    j fin_solicitar
    
error_cantidad:
    li $v0, 4
    la $a0, msg_error
    syscall
    j solicitar_loop
    
fin_solicitar:
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

ingresar_elementos:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    move $s0, $a0              # $s0 = dirección base
    move $s1, $a1              # $s1 = cantidad
    li $s2, 0                   # $s2 = índice
    
ingresar_loop:
    beq $s2, $s1, fin_ingresar
    
    # Mostrar mensaje "Ingrese el numero X: "
    li $v0, 4
    la $a0, msg_ingreso_num
    syscall
    
    # Mostrar índice
    addi $a0, $s2, 1           # Mostrar 1-based para usuario
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_dos_puntos
    syscall
    
    # Leer número
    li $v0, 5
    syscall
    
    # Guardar en array
    sll $t0, $s2, 2            # $t0 = índice * 4
    add $t0, $s0, $t0          # $t0 = dirección del elemento
    sw $v0, 0($t0)
    
    addi $s2, $s2, 1
    j ingresar_loop
    
fin_ingresar:
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

mostrar_array:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0              # $s0 = dirección base
    move $s1, $a1              # $s1 = cantidad
    li $t0, 0                   # $t0 = índice
    
mostrar_loop:
    beq $t0, $s1, fin_mostrar
    
    # Obtener elemento
    sll $t1, $t0, 2
    add $t1, $s0, $t1
    lw $a0, 0($t1)
    
    # Mostrar número
    li $v0, 1
    syscall
    
    # Mostrar espacio
    li $v0, 4
    la $a0, msg_espacio
    syscall
    
    addi $t0, $t0, 1
    j mostrar_loop
    
fin_mostrar:
    # Salto de línea
    li $v0, 4
    la $a0, msg_salto
    syscall
    
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

bubble_sort_basico:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0              # $s0 = dirección base
    move $s1, $a1              # $s1 = n
    
    # i = n-1 hasta 1
    addi $s2, $s1, -1          # $s2 = i (desde n-1 hasta 1)
    
bucle_externo_basico:
    blez $s2, fin_bubble_basico
    
    # j = 0 hasta i-1
    li $s3, 0                   # $s3 = j
    
bucle_interno_basico:
    bge $s3, $s2, siguiente_pasada_basico
    
    # Obtener array[j] y array[j+1]
    sll $t0, $s3, 2
    add $t0, $s0, $t0
    lw $t1, 0($t0)             # $t1 = array[j]
    
    addi $t2, $s3, 1
    sll $t2, $t2, 2
    add $t2, $s0, $t2
    lw $t3, 0($t2)             # $t3 = array[j+1]
    
    # Comparar
    ble $t1, $t3, no_intercambio_basico
    
    # Intercambiar
    sw $t3, 0($t0)
    sw $t1, 0($t2)
    
no_intercambio_basico:
    addi $s3, $s3, 1
    j bucle_interno_basico
    
siguiente_pasada_basico:
    addi $s2, $s2, -1
    j bucle_externo_basico
    
fin_bubble_basico:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

bubble_sort:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    
    move $s0, $a0              # $s0 = dirección base
    move $s1, $a1              # $s1 = n
    li $s4, 1                   # Contador de pasos para depuración
    
    # i = n-1 hasta 1
    addi $s2, $s1, -1          # $s2 = i (desde n-1 hasta 1)
    
bucle_externo:
    blez $s2, fin_bubble
    
    # Inicializar indicador de intercambio
    li $t4, 0                   # $t4 = 0 (no hubo intercambios)
    
    # Mostrar paso actual (opcional, comentar si no se desea)
    # li $v0, 4
    # la $a0, msg_paso
    # syscall
    # move $a0, $s4
    # li $v0, 1
    # syscall
    
    # j = 0 hasta i-1
    li $s3, 0                   # $s3 = j
    
bucle_interno:
    bge $s3, $s2, verificar_termino
    
    # Obtener array[j] y array[j+1]
    sll $t0, $s3, 2
    add $t0, $s0, $t0
    lw $t1, 0($t0)             # $t1 = array[j]
    
    addi $t2, $s3, 1
    sll $t2, $t2, 2
    add $t2, $s0, $t2
    lw $t3, 0($t2)             # $t3 = array[j+1]
    
    # Comparar
    ble $t1, $t3, no_intercambio
    
    # Intercambiar
    sw $t3, 0($t0)
    sw $t1, 0($t2)
    li $t4, 1                   # Hubo intercambio
    
    # Opcional: mostrar mensaje de intercambio
    # li $v0, 4
    # la $a0, msg_intercambio
    # syscall
    
no_intercambio:
    addi $s3, $s3, 1
    j bucle_interno
    
verificar_termino:
    # Si no hubo intercambios, el array ya está ordenado
    beqz $t4, detener_temprano
    
    addi $s2, $s2, -1
    addi $s4, $s4, 1           # Incrementar contador de pasos
    j bucle_externo
    
detener_temprano:
    # Mensaje opcional de detención temprana
    # li $v0, 4
    # la $a0, msg_detener
    # syscall
    
fin_bubble:
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

bubble_sort_ultimo:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    
    move $s0, $a0              # $s0 = dirección base
    move $s1, $a1              # $s1 = n
    move $s2, $s1              # $s2 = límite superior (inicia en n)
    
bucle_externo_ultimo:
    li $s4, 0                   # $s4 = último intercambio realizado
    
    # j = 0 hasta s2-1
    li $s3, 0                   # $s3 = j
    addi $t5, $s2, -1          # $t5 = s2-1
    
bucle_interno_ultimo:
    bge $s3, $t5, actualizar_limite
    
    # Obtener array[j] y array[j+1]
    sll $t0, $s3, 2
    add $t0, $s0, $t0
    lw $t1, 0($t0)
    
    addi $t2, $s3, 1
    sll $t2, $t2, 2
    add $t2, $s0, $t2
    lw $t3, 0($t2)
    
    # Comparar
    ble $t1, $t3, no_intercambio_ultimo
    
    # Intercambiar
    sw $t3, 0($t0)
    sw $t1, 0($t2)
    move $s4, $s3              # Guardar posición del último intercambio
    
no_intercambio_ultimo:
    addi $s3, $s3, 1
    j bucle_interno_ultimo
    
actualizar_limite:
    # Si no hubo intercambios, terminar
    beqz $s4, fin_bubble_ultimo
    
    # Próxima pasada solo hasta el último intercambio
    move $s2, $s4
    addi $s2, $s2, 2           # +1 por el índice, +1 por seguridad
    j bucle_externo_ultimo
    
fin_bubble_ultimo:
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

swap:
    lw $t0, 0($a0)
    lw $t1, 0($a1)
    sw $t1, 0($a0)
    sw $t0, 0($a1)
    jr $ra
