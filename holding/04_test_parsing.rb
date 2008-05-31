require 'test/unit'

require 'rubygems'
require 'treetop'
Treetop.load 'z80'

class TestParsing < Test::Unit::TestCase
  def setup
    @parser = Z80Parser.new
  end
  def test_program
    assert @parser.parse(".ord\n jmp")
  end
  def test_empty
    assert @parser.parse("")
    assert @parser.parse("\n")
    assert @parser.parse(" \n")
    assert @parser.parse(" \n ")
  end
  def test_declaration
    assert @parser.parse("#include \"file\" ")
  end
  def test_directives
    assert @parser.parse('.end')
    assert !@parser.parse(' .end')

    assert @parser.parse('.org 10')
    assert @parser.parse('.db "string",0')
  end
  def test_instructions
    assert !@parser.parse('jmp')
    assert @parser.parse(' jmp')
    assert @parser.parse(' ld a, $00')
    assert @parser.parse(' ld (a), $00')
  end
  def test_variables
    assert @parser.parse('var = 0')
    assert !@parser.parse(' var = 0')
  end
  def test_labels
    assert @parser.parse('label:')
    assert @parser.parse('label: ld')
    assert !@parser.parse(' label:')
    assert !@parser.parse('label: #include "stuff"')
  end
  def test_full
    assert @parser.parse(<<'EOP')
#include "file"

.org 10
.db "stuff",0
charpage = $80DF
 ld a, $00
label:
 ld (charpage), a
 jmp
.end
EOP
  end
end