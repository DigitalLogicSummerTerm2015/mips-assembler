    # Initialize.
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

    # Timer @ 0x40000000.
    lui     $s0, 0x4000  # TCON = 0
    sw      $zero, 8($s0)
    addi    $t0, $zero, 0x8000  # TH = 0xffff8000
    sw      $t0, 0($s0)
    addi    $t0, $zero, 0xffff  # TL = 0xffffffff
    sw      $t0, 4($s0)
    addi    $t0, $zero, 3  # TCON = 3
    sw      $t0, 8($s0)


