module MIPS
  # OpCode or funtc
  CMD_ID = {
    nop: 0x0,
    lw: 0x23, sw: 0x2b,
    lui: 0x0f,
    add: 0x20, addu: 0x21, sub: 0x22, subu: 0x23, and: 0x24, or: 0x25, xor: 0x26, nor: 0x27, slt: 0x2a,
    addi: 0x08, addiu: 0x09, andi: 0x0c, slti: 0x0a, sltiu: 0x0b,
    sll: 0x0, srl: 0x02, sra: 0x03,
    beq: 0x4, bne: 0x5,
    blez: 0x6, bgtz: 0x7, bgez: 0x1,
    j: 0x02, jal: 0x03,
    jr: 0x08,
    jalr: 0x09
  }

  REGS = %w(zero at v0 v1 a0 a1 a2 a3 t0 t1 t2 t3 t4 t5 t6 t7
            s0 s1 s2 s3 s4 s5 s6 s7 t8 t9 k0 k1 gp sp fp rs)

  # Represent a MIPS syntax error
  class MIPSSyntaxError < StandardError
  end

  # Assembly MIPS codes into machine codes.
  class Assembler
    attr_reader :symbol_table, :current_addr

    def initialize
      @symbol_table = {}
      @current_addr = 0x0
    end

    def assembly(line)
      fail MIPSSyntaxError, "#{line}: Syntax error." unless /^\s*((?<tag>[a-zA-Z]\w*)\s*:\s*)?((?<cmd>[a-z]+)\s*((?<arg1>\$?\w+)\s*(,\s*((?<arg2>\$?\w+)|((?<offset>\d+)\(\s*(?<arg2>\$\w+)\s*\)))\s*(,\s*(?<arg3>\$?\w+)\s*)?)?)?)?(#.*)?$/ =~ line
      read_tag tag
      parse(cmd, arg1, arg2, arg3, offset)
    end

    def self.assembly(line)
      new.assembly(line)
    end

    private

    def read_tag(tag)
      return if tag.nil?  # No tag.

      if @symbol_table.include? tag
        fail MIPSSyntaxError, "Redeclaration of tag `#{tag}`"
      else
        @symbol_table[tag] = @current_addr
      end
    end

    def parse(cmd, arg1, arg2, arg3, offset)
      return if cmd.nil?  # No command

      cmd = cmd.to_sym
      cmd_id = CMD_ID[cmd]
      case cmd
      when :nop
        fail MIPSSyntaxError, "Syntax: nop" unless arg1.nil?
        0x0
      when :lw, :sw
        unless arg1 && arg2 && offset && arg3.nil?
          fail MIPSSyntaxError, "Syntax: #{cmd} rt, offset(rs)"
        end
        type_i(cmd_id, reg(arg2), reg(arg1), offset.to_i)
      when :lui
        unless arg2 && offset.nil? && arg3.nil?
          fail MIPSSyntaxError, "Syntax: lui rt, imm"
        end
        type_i(cmd_id, 0, reg(arg1), int(arg2))
      when :add, :addu, :sub, :subu, :and, :or, :xor, :nor, :slt
        unless arg3 && offset.nil?
          fail MIPSSyntaxError, "Syntax: #{cmd} rd, rs, rt"
        end
        type_r(reg(arg2), reg(arg3), reg(arg1), 0, cmd_id)
      when :addi, :addiu, :andi, :slti, :sltiu
        unless arg3 && offset.nil?
          fail MIPSSyntaxError, "Syntax: #{cmd} rt, rs, imm"
        end
        type_i(cmd_id, reg(arg2), reg(arg1), int(arg3))
      when :sll, :srl, :sra
        unless arg3 && offset.nil?
          fail MIPSSyntaxError, "Syntax: #{cmd} rd, rt, shamt"
        end
        type_r(0, reg(arg2), reg(arg1), int(arg3), cmd_id)
      when :beq, :bne
        unless arg3 && offset.nil?
          fail MIPSSyntaxError, "Syntax: #{cmd} rs, rt, label"
        end
        type_i(cmd_id, reg(arg1), reg(arg2), relative_addr(arg3))
      when :blez, :bgtz, :bgez
        unless arg2 && offset.nil? && arg3.nil?
          fail MIPSSyntaxError, "Syntax: #{cmd} rs, label"
        end
        type_i(cmd_id, reg(arg1), (cmd == :bgez ? 1 : 0), relative_addr(arg2))
      when :j, :jal
        fail MIPSSyntaxError, "Syntax: #{cmd} target" unless arg1 && arg2.nil?
        type_j(cmd_id, absolute_addr(arg1))
      when :jr
      when :jalr
      else
        fail MIPSSyntaxError, "#{cmd}: Unknown command"
      end
    end

    def type_r(rs, rt, rd, shamt, funct)
      rs << 21 | rt << 16 | rd << 11 | shamt << 6 | funct
    end

    def type_i(opcode, rs, rt, imm)
      # Notice immi could be negative.
      opcode << 26 | rs << 21 | rt << 16 | (imm & ((1 << 16) - 1))
    end

    def type_j(opcode, target)
      opcode << 26 | (target >> 2 & ((1 << 26) - 1))
    end

    def reg(arg)
      name = arg[1..-1]
      if arg =~ /^\$([12]?[0-9])|(3[01])$/
        name.to_i
      elsif (index = REGS.index(name))
        index
      else
        fail MIPSSyntaxError, "#{arg}: Invalid register name"
      end
    end

    def int(arg)
      if /^0[xX](?<hex>\h+)$/ =~ arg
        hex.to_i(16)
      else
        arg.to_i
      end
    end

    def absolute_addr(tag)
      addr = @symbol_table[tag]
      fail MIPSSyntaxError, "#{tag}: Tag not found" if addr.nil?
      addr
    end

    def relative_addr(tag)
      addr = @symbol_table[tag]
      fail MIPSSyntaxError, "#{tag}: Tag not found" if addr.nil?
      (addr - @current_addr) / 4 - 1
    end
  end
end
