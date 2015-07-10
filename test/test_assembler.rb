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
    # (addi, addiu, andi, slti, sltiu) rt, rs, immi
    # (sll, srl, sra) rd, rt, shamt
  end

  def test_branch
    # (beq, bne) rs, rt, label
    # (blez, bgtz, bgez) rs, label
    # (j, jal) target
    # jr rs
    # jalr rs, rd
  end
end
