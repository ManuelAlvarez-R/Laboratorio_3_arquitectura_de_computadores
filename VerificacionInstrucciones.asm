        .text
main:
        addi $s0, $zero, 6       # addi:  s0 = 6

        addi $t0, $zero, 4
        add  $s1, $s0, $t0       # add:   s1 = 6 + 4 = 10

        sub  $s2, $s1, $s0       # sub:   s2 = 10 - 6 = 4

        addi $t0, $zero, 0x00FF
        addi $t1, $zero, 0x0F0F
        and  $s3, $t0, $t1       # and:   s3 = 0x0000000F
        or   $s4, $t0, $t1       # or:    s4 = 0x00000FFF
        nor  $s5, $t0, $t1       # nor:   s5 = 0xFFFFF000

        slt  $s6, $s0, $s1       # slt:   6 < 10,  s6 = 1
        slt  $s7, $s1, $s0       # slt:   10 < 6,  s7 = 0

        addi $sp, $sp, -8
        sw   $s0, 0($sp)         # sw:    guarda 6
        lw   $t2, 0($sp)         # lw:    t2 = 6

        addi $t0, $zero, 0x0085
        sw   $t0, 4($sp)
        lb   $t3, 4($sp)         # lb:    t3 = 0xFFFFFF85

        beq  $t2, $s0, tomado    # beq:   6 == 6, salta
        addi $t4, $zero, 99
        j    listo_beq
tomado:
        addi $t4, $zero, 1       # t4 = 1 si el salto se tom?
listo_beq:

        beq  $s0, $s1, no_debio  # beq:   6 != 10, no salta
        addi $t5, $zero, 1       # t5 = 1 si no se tom?
        j    listo_no
no_debio:
        addi $t5, $zero, 99
listo_no:

        jal  rutina              # jal:   guarda el retorno en $ra
        addi $t7, $zero, 1       # t7 = 1 si jr regres?
        j    fin                 # j:     salta al final

rutina:
        addi $t6, $zero, 7       # t6 = 7 si jal entr? aqu?
        jr   $ra                 # jr:    PC = $ra

fin:
        j    fin