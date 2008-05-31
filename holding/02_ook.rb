#!/usr/bin/env ruby

# http://web.archive.org/web/20011127073200/http://www.chadfowler.com/
# http://raa.ruby-lang.org/project/rubyook/

class Parser
	def initialize
		@commands = Hash.new
		@instructions = Array.new
	end
	def parse(instring)
		@instructions = tokenize(instring)
	end

	def next_instruction
		return @instructions.slice!(0)
	end
	
	def more_instructions?
		@instructions.size > 0
	end
	
end
class BfParser < Parser
	def initialize
		super
		@commands['>']  = Ook::Forward
		@commands['<']  = Ook::Backward
		@commands['.']  = Ook::WriteChar
		@commands[',']  = Ook::ReadChar
		@commands['+']  = Ook::Increment
		@commands['-']  = Ook::Decrement
		@commands['[']  = Ook::StartLoop
		@commands[']']  = Ook::EndLoop
	end

	def tokenize(string)
		string.gsub!(/\s+/, "")
		tokens = Array.new
		begin
			string.split(//).each do | chr |
				cmd = @commands[nil]
				tokens.push @commands[chr]
			end
		rescue Exception
			raise Ook::ParseError
		end
		tokens
	end
end

class OokParser < Parser
	def initialize
		super
		@commands['Ook.'] = { 
			"Ook?" => Ook::Forward, 
			"Ook." => Ook::Increment,
			"Ook!" => Ook::ReadChar
			}
		@commands['Ook!'] = { 
			"Ook?" => Ook::StartLoop, 
			"Ook." => Ook::WriteChar,
			"Ook!" => Ook::Decrement
			}
		@commands['Ook?'] = { 
			"Ook." => Ook::Backward, 
			"Ook!" => Ook::EndLoop
			}
	end

	def tokenize(string)
		tokens = Array.new
		ooks = string.split(/\s+/)
		begin
			0.step(ooks.size - 1, 2)  { | index |
				tokens.push @commands[ooks[index]][ooks[index+1]]
			}
		rescue Exception
			raise Ook::ParseError
		end
		tokens
	end
end

class Ook
	class ParseError < Exception
	end
	class RangeError < Exception
	end
	class StartLoop
		def StartLoop.execute(ook)
			ook.start_loop
		end
	end
	class EndLoop
		def EndLoop.execute(ook)
			ook.end_loop	
		end
	end

	class Backward
		def Backward.execute(ook)
			ook.pointer_dec
		end
	end
	class Decrement
		def Decrement.execute(ook)
			ook.cell_value_dec
		end
	end
	class Increment
		def Increment.execute(ook)
			ook.cell_value_inc
		end
	end
	class WriteChar
		def WriteChar.execute(ook)
			ook.out.putc(ook.cell_value)
		end
	end
	class ReadChar
		def ReadChar.execute(ook)
			ook.cell_value = ook.in.getc
		end
	end
	class Forward
		def Forward.execute(ook)
			ook.pointer_inc
		end
	end

	attr_reader :pointer,:in,:out
	def initialize(instream,outstream)
		@pointer = 0
		@cells = []
		@cells[@pointer] = 0
		@in = instream
		@out = outstream
		@loop_criteria_cell_pointers = []
		@loops = []
		@replay = false
	end
	def push_instruction(instr)
		if(@loops.last != nil && @replay == false) then
			@loops.last.push instr
		end
	end

	def instruction(instr)
		push_instruction(instr)
		unless (@ignore_instructions) then
			instr.execute(self)
		end
	end

	def cell_value
		@cells[@pointer]
	end

	def pointer_dec
		if(@pointer == 0) then
			raise RangeError
		end
		@pointer = @pointer - 1
		default_current_pointer
	end

	def pointer_inc
		@pointer = @pointer + 1
		default_current_pointer
	end

	def default_current_pointer
		if(@cells[@pointer] == nil) then @cells[@pointer] = 0 end
	end

	def cell_value_inc
		@cells[@pointer] += 1
	end

	def cell_value_dec
		@cells[@pointer] -= 1
	end

	def cell_value=(val)
		@cells[@pointer] = val
	end

	def start_loop
		@loops.push Array.new
		@loop_criteria_cell_pointers.push @pointer
		if(self.cell_value == 0) then
			@ignore_instructions = true
		end
	end

	def end_loop
		if(@loop_criteria_cell_pointers.last == nil) then raise ParseError end
		if(@cells[@loop_criteria_cell_pointers.last] == 0) then
			@loops.pop
		else
			replay_current_loop
		end
	end

	def replay_current_loop
		@replay = true
		@loops.last.each do | inst |
			inst.execute(self)
		end
		@replay = false
	end
	
	def process(parser)
		while(parser.more_instructions?) do
		  ins =  parser.next_instruction
		  self.instruction(ins)
		end
	end
end

if __FILE__ == $0
	ook = Ook.new(STDIN, STDOUT)
	script = IO.readlines(ARGV[0])	
	parser = script.join.include?("Ook") ? OokParser : BfParser
	p = parser.new
	p.parse(script.join)
	ook.process(p)
end
