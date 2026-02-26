.data
# Mensajes para el usuario
msg_ingreso:     .asciiz "Ingrese la cantidad de elementos (max 20): "
msg_ingreso_num: .asciiz "Ingrese el numero "
msg_dos_puntos:  .asciiz ": "
msg_array_orig:  .asciiz "\nArray original:\n"
msg_array_ord:   .asciiz "\nArray ordenado:\n"
msg_espacio:     .asciiz " "
msg_salto:       .asciiz "\n"
msg_error:       .asciiz "Error: cantidad invalida. Debe ser entre 1 y 20.\n"

# Espacio para el array (max 20 elementos)
array:           .word 0:20
array_size:      .word 0

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
    
    # Ordenar con Quicksort
    la $a0, array              # Dirección base del array
    li $a1, 0                   # Índice izquierdo (low)
    addi $a2, $s0, -1          # Índice derecho (high)
    jal quicksort
    
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
    
    move $a0, $s2
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

quicksort:
    # Guardar registros en pila
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0              # $s0 = dirección base
    move $s1, $a1              # $s1 = low
    move $s2, $a2              # $s2 = high
    
    # Verificar si low < high
    bge $s1, $s2, fin_quicksort
    
    # Realizar partición
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal partition
    move $s3, $v0              # $s3 = índice del pivote
    
    # Ordenar elementos izquierdos (low a pivote-1)
    move $a0, $s0
    move $a1, $s1
    addi $a2, $s3, -1
    jal quicksort
    
    # Ordenar elementos derechos (pivote+1 a high)
    move $a0, $s0
    addi $a1, $s3, 1
    move $a2, $s2
    jal quicksort
    
fin_quicksort:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

partition:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    
    move $s0, $a0              # $s0 = dirección base
    move $s1, $a1              # $s1 = low
    move $s2, $a2              # $s2 = high
    
    # Elegir pivote (elemento del medio para mejor rendimiento)
    add $t0, $s1, $s2
    srl $t0, $t0, 1            # $t0 = (low + high) / 2
    
    # Obtener valor del pivote
    sll $t1, $t0, 2
    add $t1, $s0, $t1
    lw $s3, 0($t1)             # $s3 = valor del pivote
    
    # Mover pivote al inicio temporalmente (swap con low)
    sll $t1, $s1, 2
    add $t1, $s0, $t1
    lw $t2, 0($t1)             # $t2 = array[low]
    sw $s3, 0($t1)             # array[low] = pivote
    
    sll $t1, $t0, 2
    add $t1, $s0, $t1
    sw $t2, 0($t1)             # array[mid] = array[low]
    
    # Inicializar índices
    addi $s4, $s1, 1           # $s4 = i (low + 1)
    move $t3, $s2              # $t3 = j (high)
    
partition_loop:
    # Buscar elemento mayor que pivote desde la izquierda
buscar_izquierda:
    bgt $s4, $t3, partition_done
    
    sll $t0, $s4, 2
    add $t0, $s0, $t0
    lw $t1, 0($t0)             # $t1 = array[i]
    
    bgt $t1, $s3, encontrado_izq
    addi $s4, $s4, 1
    j buscar_izquierda
    
encontrado_izq:
    # Buscar elemento menor o igual que pivote desde la derecha
buscar_derecha:
    bgt $s4, $t3, partition_done
    
    sll $t0, $t3, 2
    add $t0, $s0, $t0
    lw $t2, 0($t0)             # $t2 = array[j]
    
    ble $t2, $s3, encontrado_der
    addi $t3, $t3, -1
    j buscar_derecha
    
encontrado_der:
    # Intercambiar array[i] y array[j]
    sll $t0, $s4, 2
    add $t0, $s0, $t0
    lw $t4, 0($t0)             # $t4 = array[i]
    
    sll $t1, $t3, 2
    add $t1, $s0, $t1
    lw $t5, 0($t1)             # $t5 = array[j]
    
    sw $t5, 0($t0)             # array[i] = array[j]
    sw $t4, 0($t1)             # array[j] = array[i]
    
    addi $s4, $s4, 1
    addi $t3, $t3, -1
    j partition_loop
    
partition_done:
    # Colocar pivote en posición final
    sll $t0, $s1, 2
    add $t0, $s0, $t0
    lw $t1, 0($t0)             # $t1 = pivote
    
    sll $t2, $t3, 2
    add $t2, $s0, $t2
    lw $t4, 0($t2)             # $t4 = array[j]
    
    sw $t4, 0($t0)             # array[low] = array[j]
    sw $t1, 0($t2)             # array[j] = pivote
    
    move $v0, $t3              # Retornar posición del pivote
    
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
