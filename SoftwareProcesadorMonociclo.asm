        .text
main:
        addi $sp, $sp, -40       # 10 palabras para 
        add  $a1, $sp, $zero     # a1 = base del arreglo
        addi $a0, $zero, 10      # a0 = N
        jal  serie
        add  $s3, $v0, $zero     # s3 = S(9)
fin:
        j    fin

# serie(N, base) -> v0 = S(N-1)
# guarda s1, s2 y ra
serie:
        addi $sp, $sp, -12
        sw   $ra, 8($sp)
        sw   $s1, 4($sp)
        sw   $s2, 0($sp)

        addi $s1, $zero, 0       # S(n-2) = 0
        addi $s2, $zero, 1       # S(n-1) = 1
        addi $t0, $zero, 0       # i = 0
        add  $t3, $a1, $zero     # puntero de escritura

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

caso0:
        sw   $zero, 0($t3)       # S(0) = 0
        addi $t3, $t3, 4
        addi $t0, $t0, 1
        j    bucle

caso1:
        addi $t2, $zero, 1       # S(1) = 1
        sw   $t2, 0($t3)
        addi $t3, $t3, 4
        addi $t0, $t0, 1
        j    bucle

fbucle:
        add  $v0, $s2, $zero     # v0 = S(9)
        lw   $ra, 8($sp)
        lw   $s1, 4($sp)
        lw   $s2, 0($sp)
        addi $sp, $sp, 12
        jr   $ra