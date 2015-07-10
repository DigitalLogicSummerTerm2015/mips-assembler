module MIPS
  # Assembly MIPS codes into machine codes.
  class Assembler
    attr_reader :symbol_table, :current_addr

    def initialize
      @symbol_table = {}
      @current_addr = 0x0
    end

    def assembly(line)
      0x0
    end

    def self.assembly(line)
      new.assembly(line)
    end
  end
end
