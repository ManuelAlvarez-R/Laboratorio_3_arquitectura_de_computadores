# ============================================================================
#  Arquitectura de Computadores y Laboratorio - 2026-2
#  Laboratorio 03 : Procesador monociclo MIPS32
#  Equipo 7 : Ivan Rene Acosta Lallemand - Manuel Felipe Alvarez Rua
#
#  Instrucciones adicionales asignadas : LB (load byte) y ADDI (add immediate)
#  Problema : calcular los primeros diez elementos de la serie
#                   S(n) = 2*S(n-1) + S(n-2),   S(0) = 0,  S(1) = 1
#
#  Resultados visibles en:
#       memoria de datos 0x100 .. 0x124  -> S(0) .. S(9)   (palabras)
#       memoria de datos 0x300           -> S(9)
#       memoria de datos 0x304           -> suma de los bytes bajos (LB)
#       memoria de datos 0x308           -> cantidad de terminos procesados
#
#  Convencion de registros MIPS respetada:
#       $a0-$a2 argumentos, $v0-$v1 valores de retorno,
#       $t0-$t3 temporales, $s1-$s2 salvados, $ra retorno, $sp pila
# ============================================================================

        .text

# ----------------------------------------------------------------------------
#  main : programa principal
# ----------------------------------------------------------------------------
main:
        addi $t0, $zero, 0x200      # t0 = direccion de la tabla de configuracion
        addi $t1, $zero, 0x20A      # byte 0 = 10 (N) ; byte 1 = 0 (relleno)
        sw   $t1, 0($t0)            # la configuracion se escribe desde el programa
        lb   $a0, 0($t0)            # a0 = N = 10  (leido con LB, extension de signo)
        addi $a1, $zero, 0x100      # a1 = base del arreglo de resultados
        jal  serie                  # v0 = S(N-1) y escribe S(0..N-1) en memoria
        addi $a2, $zero, 0x300      # a2 = base de los resultados escalares
        sw   $v0, 0($a2)            # memoria[0x300] = S(9) = 985
        addi $a1, $zero, 0x100      # a1 = base del arreglo (para el checksum)
        jal  checksum               # v0 = suma de bytes bajos, v1 = cantidad
        sw   $v0, 4($a2)            # memoria[0x304] = checksum
        sw   $v1, 8($a2)            # memoria[0x308] = cantidad de terminos
        lw   $s3, 0($a2)            # s3 = S(9)     leido de memoria
        lw   $s4, 4($a2)            # s4 = checksum leido de memoria
        lw   $s5, 8($a2)            # s5 = cantidad leida de memoria
        addi $t0, $zero, 0x120
        lw   $s6, 4($t0)            # s6 = S(9) leido del arreglo (0x124)
fin:
        j    fin                    # el procesador queda detenido aqui

# ----------------------------------------------------------------------------
#  serie : calcula S(0) .. S(N-1) y los almacena como palabras
#      entrada : $a0 = N (>= 2) , $a1 = direccion base del arreglo
#      salida  : $v0 = S(N-1)
#      usa     : $s1 = S(n-2) , $s2 = S(n-1) , $t0..$t3
# ----------------------------------------------------------------------------
serie:
        addi $sp, $sp, -12          # aparta espacio en la pila
        sw   $ra, 8($sp)             # salva el retorno
        sw   $s1, 4($sp)             # salva s1 (registro salvado)
        sw   $s2, 0($sp)             # salva s2 (registro salvado)
        addi $s1, $zero, 0           # s1 = S(0)  = 0
        addi $s2, $zero, 1           # s2 = S(1)  = 1
        addi $t0, $zero, 0           # i = 0
        add  $t3, $a1, $zero         # t3 = puntero de escritura
bucle:
        slt  $t1, $t0, $a0           # t1 = (i < N)
        beq  $t1, $zero, fbucle      # si i >= N termina
        beq  $t0, $zero, caso0       # caso particular i == 0
        addi $t2, $zero, 1
        beq  $t0, $t2, caso1         # caso particular i == 1
        add  $t2, $s2, $s2           # t2 = 2*S(n-1)
        add  $t2, $t2, $s1           # t2 = 2*S(n-1) + S(n-2)
        add  $s1, $s2, $zero         # S(n-2) <- S(n-1)
        add  $s2, $t2, $zero         # S(n-1) <- S(n)
        sw   $t2, 0($t3)             # almacena S(n)
        addi $t3, $t3, 4             # siguiente palabra
        addi $t0, $t0, 1             # i = i + 1
        j    bucle
caso0:
        sw   $zero, 0($t3)           # S(0) = 0
        addi $t3, $t3, 4
        addi $t0, $t0, 1
        j    bucle
caso1:
        addi $t2, $zero, 1           # S(1) = 1
        sw   $t2, 0($t3)
        addi $t3, $t3, 4
        addi $t0, $t0, 1
        j    bucle
fbucle:
        add  $v0, $s2, $zero         # v0 = S(N-1)
        lw   $ra, 8($sp)             # restaura el retorno
        lw   $s1, 4($sp)             # restaura s1
        lw   $s2, 0($sp)             # restaura s2
        addi $sp, $sp, 12            # libera la pila
        jr   $ra                     # retorna al llamador

# ----------------------------------------------------------------------------
#  checksum : recorre el arreglo de palabras y suma el byte bajo de cada una
#      entrada : $a0 = N , $a1 = direccion base
#      salida  : $v0 = suma con extension de signo (LB) , $v1 = cantidad
#      usa     : $t0 (i) , $t1 , $t2 (byte) , $t3 (puntero)
# ----------------------------------------------------------------------------
checksum:
        addi $sp, $sp, -4            # aparta espacio para $ra
        sw   $ra, 0($sp)
        addi $v0, $zero, 0           # acumulador = 0
        addi $v1, $zero, 0           # contador   = 0
        addi $t0, $zero, 0           # i = 0
        add  $t3, $a1, $zero         # t3 = puntero de lectura
cbucle:
        slt  $t1, $t0, $a0           # t1 = (i < N)
        beq  $t1, $zero, fcbucle
        lb   $t2, 0($t3)             # t2 = byte bajo de la palabra (con signo)
        add  $v0, $v0, $t2           # acumula
        addi $v1, $v1, 1             # contador++
        addi $t3, $t3, 4             # siguiente palabra
        addi $t0, $t0, 1             # i = i + 1
        j    cbucle
fcbucle:
        lw   $ra, 0($sp)             # restaura el retorno
        addi $sp, $sp, 4             # libera la pila
        jr   $ra                     # retorna al llamador
