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

    jal     Next                # Get next address.
Next:
    lui     $t0, 0x8000
    nor     $t0, $t0, $zero     # Now $t0 = 0x7fffffff
    and     $ra, $t0, $ra       # Clear MSB.
    addi    $ra, $ra, 6         # Get ready for a dead loop.
    addi    $t0, $zero, 3       # TCON = 3
    sw      $t0, 8($s7)
    jr      $ra


Break:
    # Disable break & clear status.
    lui     $s7, 0x4000
    lw      $t0, 8($s7)         # TCON
    addi    $t1, $zero, 0xfff9  # $t1 = 0xfffffff9
    and     $t0, $t0, $t1
    sw      $t0, 8($s7)         # TCON &= 0xfffffff9

    # Calculate GCD.
    lw      $t0, 32($s7)        # $t0 = ready
    beq     $t0, $zero, Done    # Just Display previous $v0 if not ready.

    lw      $a0, 24($s7)        # $a0 = a
    lw      $a1, 28($s7)        # $a1 = b
    beq     $a0, $zero, Zero
    beq     $a1, $zero, Zero
    # Copy to $s0, $s1.
    add     $s0, $a0, $zero
    add     $s1, $a1, $zero

Loop:
    slt     $t0, $s0, $s1
    bne     $t0, $zero, Swap
    sub     $s0, $s0, $s1
    j       Loop
Swap:
    add     $t0, $s0, $zero
    add     $s0, $s1, $zero
    add     $s1, $t0, $zero

    bne     $s1, $zero, Loop
    add     $v0, $s0, $zero

    # Now v0 = result, send it.
    sw      $v0, 36($s7)
    addi    $t0, $zero, 1
    sw      $t0, 40($s7)        # tx_en = 1
    sw      $zero, 40($s7)      # tx_en = 0
    j Done

Zero:
    add     $v0, $zero, $zero   # $v0 = 0 if a/b = 0.
Done:
    sw      $v0, 12($s7)        # Display result on the LED.

    lw      $t4, 20($s7)        # Digit tube
    # Show next digit.
    srl     $t4, $t4, 8
    addi    $t4, $t4, 0x000f    # $t4 = AN[3:0]
    srl     $t4, $t4, 1         # Scan from left to right.
    bne     $t4, $zero, Choose
    addi    $t4, $zero, 0x0008  # Init left-most digit.
Choose:
    addi    $t0, $zero, 0x0001
    addi    $t1, $zero, 0x0002
    addi    $t2, $zero, 0x0004
    addi    $t3, $zero, 0x0008
    beq     $t4, $t0, Digit0
    beq     $t4, $t1, Digit1
    beq     $t4, $t2, Digit2
    beq     $t4, $t3, Digit3
    addi    $t4, $zero, 0x0008  # Else init to digit0.

Digit0:
    srl     $t5, $a0, 4
    j       Display
Digit1:
    add     $t5, $a0, $zero
    j       Display
Digit2:
    srl     $t5, $a1, 4
    j       Display
Digit3:
    add     $t5, $a1, $zero
    j       Display

Display:
    andi    $t5, $t5, 0x000f    # $t5 = index
    sll     $t5, $t5, 2
    lw      $t5, 0($t5)
    sll     $t4, $t4, 8
    add     $t0, $t4, $t5
    sw      $t0, 20($s7)

    # Enable break.
    lw      $t0, 8($s7)
    addi    $t1, $zero, 0x0002
    or      $t0, $t0, $t1       # TCON |= 0x00000002
    sw      $t0, 8($s7)


Return:
    jr      $k0                 # Jump back

Exception:
    jr      $k0                 # Jump back
