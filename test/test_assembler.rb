require "test_helper"
require "mips"

# Testcase for the MIPS assembler.
class TestAssembler < Minitest::Test
  def asm(src)
    MIPS::Assembler.assembly(src)
  end

  def test_nop
    # nop
    assert_equal 0x00000000, asm("nop")
  end

  def test_memory_access
    # (lw, sw) rt, offset(rs)
    assert_equal 0x8d280004, asm("lw $t0, 4($t1)")
    assert_equal 0xad280004, asm("sw $t0, 4($t1)")
    # lui rt, immi
    assert_equal 0x3c0800ff, asm("lui $t0, 0x00ff")
  end

  def test_algebra
    # (add, addu, sub, subu, and, or, xor, nor, slt) rd, rs, rt
    assert_equal 0x012a4020, asm("add  $t0, $t1, $t2")
    assert_equal 0x012a4021, asm("addu $t0, $t1, $t2")
    assert_equal 0x012a4022, asm("sub  $t0, $t1, $t2")
    assert_equal 0x012a4023, asm("subu $t0, $t1, $t2")
    assert_equal 0x012a4024, asm("and  $t0, $t1, $t2")
    assert_equal 0x012a4025, asm("or   $t0, $t1, $t2")
    assert_equal 0x012a4026, asm("xor  $t0, $t1, $t2")
    assert_equal 0x012a4027, asm("nor  $t0, $t1, $t2")
    assert_equal 0x012a402a, asm("slt  $t0, $t1, $t2")

    # (addi, addiu, andi, slti, sltiu) rt, rs, immi
    assert_equal 0x212800ff, asm("addi  $t0, $t1, 0x00ff")
    assert_equal 0x252800ff, asm("addiu $t0, $t1, 0x00ff")
    assert_equal 0x312800ff, asm("andi  $t0, $t1, 0x00ff")
    assert_equal 0x292800ff, asm("slti  $t0, $t1, 0x00ff")
    assert_equal 0x2d2800ff, asm("sltiu $t0, $t1, 0x00ff")

    # (sll, srl, sra) rd, rt, shamt
    assert_equal 0x00094100, asm("sll $t0, $t1, 4")
    assert_equal 0x00094102, asm("srl $t0, $t1, 4")
    assert_equal 0x00094103, asm("sra $t0, $t1, 4")
  end

  def test_branch
    # (beq, bne) rs, rt, label
    # (blez, bgtz, bgez) rs, label
    # (j, jal) target
    # jr rs
    # jalr rd, rs
  end
end
