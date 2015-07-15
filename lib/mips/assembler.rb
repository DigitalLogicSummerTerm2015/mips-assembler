module MIPS
  # OpCode or funtc
  CMD_ID = {
    nop: 0x0,
    lw: 0x23, sw: 0x2b,
    lui: 0x0f,
    add: 0x20, addu: 0x21, sub: 0x22, subu: 0x23, and: 0x24, or: 0x25, xor: 0x26, nor: 0x27, slt: 0x2a,
    addi: 0x08, addiu: 0x09, andi: 0x0c, slti: 0x0a, sltiu: 0x0b,
    sll: 0x0, srl: 0x02, sra: 0x03,
    j: 0x02, jal: 0x03,
    jr: 0x08,
    jalr: 0x09
  }

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

      cmd_id = CMD_ID[cmd.to_sym]
      case cmd.to_sym
      when :nop
        fail MIPSSyntaxError, "Syntax: nop" unless arg1.nil?
        0x0
      when :lw, :sw
      when :lui
      when :add, :addu, :sub, :subu, :and, :or, :xor, :nor, :slt
      when :addi, :addiu, :andi, :slti, :sltiu
      when :sll, :srl, :sra
      when :beq, :bne
      when :blez, :bgtz, :bgez
      when :j, :jal
      when :jr
      when :jalr
      else
        fail MIPSSyntaxError, "#{cmd}: Unknown command"
      end
    end

    def reg
    end

    def tag
    end
  end
end
