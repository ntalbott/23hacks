require 'rubygems'
require 'treetop'

class String
  def code_indent(num = 1)
    num *= 2
    ' ' * num + split(/\n/).join("\n#{' ' * num}")
  end

  def to_method_name
    gsub(/[^A-Za-z]/, '_').downcase
  end
end

Treetop.load 'expect'
parser = ExpectationParser.new

spec_text = <<EOF
Context Zed Shaw is full of crap
  @shaw = Dude.new(:full_of_crap)
  @shaw.flush

  Expect @people.freak_out? to be true
  Expect @internet to be in an uproar

Context Yahuda Katz won an award
  Expect @crowd.applaud?
EOF

if spec_tree = parser.parse(spec_text)
  spec_tree.elements.each do |spec|
    puts spec.to_test_unit
  end
else
  puts 'FAIL'
end
