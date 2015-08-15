## MIPS 汇编器

### 常量/类型定义

我们先定义了一些常量。其中 `CMD_ID` 保存了 I 型和 R 型指令的 OpCode 或 R 型指令的功能码，`REGS` 则保存了各个寄存器的名字：

```ruby
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
          s0 s1 s2 s3 s4 s5 s6 s7 t8 t9 k0 k1 gp sp fp ra)
```

然后，我们定义了 `MIPSSyntaxError`，用来充当解析错误时抛出的异常：

```ruby
# Represent a MIPS syntax error
class MIPSSyntaxError < StandardError
end
```

然后我们便可以定义 `Assembler` 类了。在我们的设计中，`Assembler` 类需要保存以下几个状态：

* `symbol_table`: 符号表，用来保存源代码中出现的标签，以及他们所对应的地址。
* `current_addr`: 当前地址，用来记录当前解析的语句所处的地址。

```ruby
def initialize
  @symbol_table = {}
  @current_addr = 0x0
end
```

### 汇编器实现

而汇编的思路也很简单。首先，我们扫描一遍 MIPS 源代码，在解析语法的同时保存出现的标签和其所在的地址。然后，我们再依次对解析过的各个语句进行汇编。其中，我们采用正则表达式来匹配标签和汇编指令。对于不符合语法的语句，我们直接抛出 `MIPSSyntaxError` 异常。

```ruby
def assembly(src)
  cmds = []
  # Read tags.
  src.each_line do |line|
    fail MIPSSyntaxError, "#{line}: Syntax error." unless /^\s*((?<tag>[a-zA-Z]\w*)\s*:\s*)?((?<cmd>[a-z]+)\s*((?<arg1>\$?\w+)\s*(,\s*((?<arg2>\$?\w+)|((?<offset>\d+)\(\s*(?<arg2>\$\w+)\s*\)))\s*(,\s*(?<arg3>\$?\w+)\s*)?)?)?)?(#.*)?$/ =~ line
    read_tag tag
    if cmd
      cmds << [cmd, arg1, arg2, arg3, offset]
      @current_addr += 4
    end
  end
  # Parse commands.
  @current_addr = 0
  result = []
  cmds.each do |cmd|
    line_result = parse(*cmd)
    result << line_result if line_result
    @current_addr += 4
  end
  result
end

def self.assembly(src)
  new.assembly(src)
end
```

然后我们开始具体实现解析。首先是对标签的解析。我们先在符号表中查找，如果发现相同标签就抛出异常。若没有，我们则将当前标签和当前地址加入到符号表中。

```ruby
def read_tag(tag)
  return if tag.nil?  # No tag.
  if @symbol_table.include? tag
    fail MIPSSyntaxError, "Redeclaration of tag `#{tag}`"
  else
    @symbol_table[tag] = @current_addr
  end
end
```

紧接着，我们来对指令进行解析。注意到尽管 R 型，I 型和 J 型指令内部的结构不同，每种指令内部格式确是一样的，我们首先定义 `type_r`, `type_i` 和 `type_j` 函数，用来构建三种指令：

```ruby
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
```

同时，我们构造一些辅助函数，来解析指令中的各个部分，包括：寄存器，整数，绝对地址，相对地址：

```ruby
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
```

最后，我们根据指令的类型，将指令的不同部分解析为不同类型，并用指令所属类型对应的函数构建指令：

```ruby
def parse(cmd, arg1, arg2, arg3, offset)
  return if cmd.nil?  # No command
  cmd = cmd.to_sym
  cmd_id = CMD_ID[cmd]
  begin
    case cmd
    when :nop
      0x0
    when :lw, :sw
      type_i(cmd_id, reg(arg2), reg(arg1), offset.to_i)
    when :lui
      type_i(cmd_id, 0, reg(arg1), int(arg2))
    when :add, :addu, :sub, :subu, :and, :or, :xor, :nor, :slt
      type_r(reg(arg2), reg(arg3), reg(arg1), 0, cmd_id)
    when :addi, :addiu, :andi, :slti, :sltiu
      type_i(cmd_id, reg(arg2), reg(arg1), int(arg3))
    when :sll, :srl, :sra
      type_r(0, reg(arg2), reg(arg1), int(arg3), cmd_id)
    when :beq, :bne
      type_i(cmd_id, reg(arg1), reg(arg2), relative_addr(arg3))
    when :blez, :bgtz, :bgez
      type_i(cmd_id, reg(arg1), (cmd == :bgez ? 1 : 0), relative_addr(arg2))
    when :j, :jal
      type_j(cmd_id, absolute_addr(arg1))
    when :jr
      type_r(reg(arg1), 0, 0, 0, cmd_id)
    when :jalr
      type_r(reg(arg2), 0, reg(arg1), 0, cmd_id)
    else
      fail MIPSSyntaxError, "#{cmd}: Unknown command"
    end
  rescue  # Got error while parsing.
    raise MIPSSyntaxError, "#{cmd}: Syntax error"
  end
end
```

这样，我们就实现了一个基础的 MIPS 汇编器。

### 自动代码生成

为了简化我们的工作，我们希望实现这样的效果：我们每次修改 MIPS 代码之后，只需要运行 `rake` 指令，便能生成更新后的 `rom.v` 文件。为了达到这个目标，我们首先实现一个命令行程序，用来从 `.asm` 文件生成 `.v` 文件：

```ruby
require "mips"

code_head = <<EOS
`timescale 1ns/1ps

module ROM(addr, data);
input [31  :0] addr;
output [31:0] data;

localparam ROM_SIZE = 32;

reg [31:0] dat _DATA[ROM_SIZE-1:0];

always@(*)
    case(addr[9:2])  // Address Must Be Word Aligned.
EOS 
code_tail = <<EOS
        default: data <= 32'h0800_0000;
    endcase
endmodule
EOS


exit if ARGV.size != 2

fin = ARGV.first
result = MIPS::Assembler.assembly(File.read(fin))
fout = File.open(ARGV.last, "w")

fout.puts code_head
result.each_with_index do |line, index|
    fout.puts "        #{index}: data <= 32'h#{line.to_s(16).rjust(8, '0')};"
end
fout.puts code_tail
```

然后，我们在 `Rakefile` 中添加如下条目，在测试之后进行代码生成：

```ruby
task :gen_code => :test do
    system "ruby", "-Ilib", "bin/assembly.rb", "test/gcd.asm", "test/rom.v"
end
```

这样，我们就完成了自动代码生成的工作。
