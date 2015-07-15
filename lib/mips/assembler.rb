module MIPS
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

      case cmd
      when "nop"
        fail MIPSSyntaxError, "#{cmd}, Expect 0 argument" unless arg1.nil?
        0x0
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
