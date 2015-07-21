    # Entries.
    j       Reset
    j       Break
    j       Exception

Reset:
    # Digit tube decoding.
    addi    $t0, $zero, 0x0040  # 0
    sw      $t0, 0($zero)
    addi    $t0, $zero, 0x0079  # 1
    sw      $t0, 4($zero)
    addi    $t0, $zero, 0x0024  # 2
    sw      $t0, 8($zero)
    addi    $t0, $zero, 0x0030  # 3
    sw      $t0, 12($zero)
    addi    $t0, $zero, 0x0019  # 4
    sw      $t0, 16($zero)
    addi    $t0, $zero, 0x0012  # 5
    sw      $t0, 20($zero)
    addi    $t0, $zero, 0x0002  # 6
    sw      $t0, 24($zero)
    addi    $t0, $zero, 0x0078  # 7
    sw      $t0, 28($zero)
    addi    $t0, $zero, 0x0000  # 8
    sw      $t0, 32($zero)
    addi    $t0, $zero, 0x0010  # 9
    sw      $t0, 36($zero)
    addi    $t0, $zero, 0x0008  # A
    sw      $t0, 40($zero)
    addi    $t0, $zero, 0x0003  # b
    sw      $t0, 44($zero)
    addi    $t0, $zero, 0x0046  # C
    sw      $t0, 48($zero)
    addi    $t0, $zero, 0x0021  # d
    sw      $t0, 52($zero)
    addi    $t0, $zero, 0x0006  # E
    sw      $t0, 56($zero)
    addi    $t0, $zero, 0x000e  # F
    sw      $t0, 60($zero)

    # Initialize timer @ 0x40000000.
    lui     $s7, 0x4000
    sw      $zero, 8($s7)       # TCON = 0
    addi    $t0, $zero, 0x8000  # TH = 0xffff8000
    sw      $t0, 0($s7)
    addi    $t0, $zero, 0xffff  # TL = 0xffffffff
    sw      $t0, 4($s7)
    addi    $t0, $zero, 3       # TCON = 3
    sw      $t0, 8($s7)

Break:
    # Disable break & clear status.
    lui     $s7, 0x4000
    lw      $t0, 8($s7)         # TCON
    addi    $t1, $zero, 0xfff9  # $t1 = 0xfffffff9
    and     $t0, $t0, $t1
    sw      $t0, 8($s7)         # TCON &= 0xfffffff9

    # Calculate GCD.
    addi    $v0, $zero, $zero   # Initialize result to 0
    # Assume a@$s0, b@$s1
    beq     $s0, $zero, Done
    beq     $s1, $zero, Done

Loop:
    blt     $s0, $s1, Swap
    sub     $s0, $s0, $s1
    b       Loop
Swap:
    add     $t0, $s0, $zero
    add     $s0, $s1, $zero
    add     $s1, $t0, $zero

    bne     $s1, $zero, Loop
    add     $v0, $s0, $zero

Done:  # Now v0 = result
    sw      $v0, 12($s7)        # Display result on the LED.

    # Enable break.
    lw      $t0, 8($s7)
    ori     $t0, $t0, 0x0002    # TCON |= 0x00000002

Return:
    jr      $k0                 # Jump back

Exception:
