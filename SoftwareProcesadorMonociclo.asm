        .text
main:
        addi $sp, $sp, -40       # 10 palabras para el arreglo
        add  $a1, $sp, $zero     # a1 = base del arreglo
        addi $a0, $zero, 10      # a0 = N
        jal  serie
        add  $s3, $v0, $zero     # s3 = S(9)
fin:
        j    fin

##################
# Function: serie
# Purpose:  Calcula la serie y guarda cada termino en el arreglo
# Inputs:
# $a0: cantidad de terminos N
# $a1: direccion base del arreglo
# Outputs:
# $v0: ultimo termino, S(N-1)
# $s1: S(n-2), restaurado al salir
# $s2: S(n-1), restaurado al salir
# Variables:
# $t0: indice i
# $t3: puntero de escritura
# $ra: direccion de regreso, guardada en la pila
##################
serie:
        addi $sp, $sp, -12
        sw   $ra, 8($sp)
        sw   $s1, 4($sp)
        sw   $s2, 0($sp)

        addi $s1, $zero, 0       # S(n-2) = 0
        addi $s2, $zero, 1       # S(n-1) = 1
        addi $t0, $zero, 0       # i = 0
        add  $t3, $a1, $zero     # puntero de escritura

##################
# Function: bucle
# Purpose:  Recorre i desde 0 hasta N-1 y calcula el termino nuevo
# Inputs:
# $a0: numero maximo de iteraciones N
# $s1: S(n-2)
# $s2: S(n-1)
# $t0: indice i
# $t3: puntero de escritura
# Outputs:
# $s1: S(n-2) actualizado
# $s2: termino nuevo, S(n-1)
# Variables:
# $t1: 1 si i < N
# $t2: 2*S(n-1) + S(n-2)
##################
bucle:
        slt  $t1, $t0, $a0       # t1 = (i < N)
        beq  $t1, $zero, fbucle
        beq  $t0, $zero, caso0
        addi $t2, $zero, 1
        beq  $t0, $t2, caso1

        add  $t2, $s2, $s2       # 2*S(n-1)
        add  $t2, $t2, $s1       # 2*S(n-1) + S(n-2)
        add  $s1, $s2, $zero
        add  $s2, $t2, $zero
        sw   $t2, 0($t3)
        addi $t3, $t3, 4
        addi $t0, $t0, 1
        j    bucle

##################
# Function: caso0
# Purpose:  Escribe el primer elemento de la serie y vuelve al bucle
# Inputs:
# $t3: direccion donde se escribe S(0)
# Outputs:
# $t0: indice, queda en 1
# $t3: puntero, queda en la siguiente palabra
# Variables:
##################
caso0:
        sw   $zero, 0($t3)       # S(0) = 0
        addi $t3, $t3, 4
        addi $t0, $t0, 1
        j    bucle

##################
# Function: caso1
# Purpose:  Escribe el segundo elemento de la serie y vuelve al bucle
# Inputs:
# $t3: direccion donde se escribe S(1)
# Outputs:
# $t0: indice, queda en 2
# $t2: valor 1 que se guarda en memoria
# $t3: puntero, queda en la siguiente palabra
# Variables:
##################
caso1:
        addi $t2, $zero, 1       # S(1) = 1
        sw   $t2, 0($t3)
        addi $t3, $t3, 4
        addi $t0, $t0, 1
        j    bucle

##################
# Function: fbucle
# Purpose:  Devuelve el ultimo termino y restaura la pila
# Inputs:
# $s2: ultimo termino S(N-1)
# Outputs:
# $v0: S(N-1)
# $ra: direccion de regreso recuperada de la pila
# $s1: valor anterior recuperado de la pila
# $s2: valor anterior recuperado de la pila
# Variables:
##################
fbucle:
        add  $v0, $s2, $zero     # v0 = S(N-1)
        lw   $ra, 8($sp)
        lw   $s1, 4($sp)
        lw   $s2, 0($sp)
        addi $sp, $sp, 12
        jr   $ra
