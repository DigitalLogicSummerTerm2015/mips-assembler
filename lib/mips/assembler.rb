module MIPS
  class MIPSSyntaxError < StandardError
    def initialize(msg)
      @msg = msg
    end

    def to_s
      msg
    end
  end

  # Assembly MIPS codes into machine codes.
  class Assembler
    attr_reader :symbol_table, :current_addr

    def initialize
      @symbol_table = {}
      @current_addr = 0x0
    end

    def assembly(line)
      line.sub!(/#*/, "")  # Remove comments.
      line.strip!

      line = read_tag(line)
      return if line.empty?  # Tag line, @current_addr stays the same.

    end

    def self.assembly(line)
      new.assembly(line)
    end

    private

    def read_tag(line)
      return unless /^(?<tag>[a-zA-Z]\w*)\s*:\s*(?<rest>.*)/ =~ line

      if @symbol_table.include? tag
        fail MIPSSyntaxError, "Redeclaration of tag `#{tag}`"
      else
        @symbol_table[tag] = @current_addr
        rest
      end
    end
  end
end
