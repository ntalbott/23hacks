class Bug
  attr_accessor :type, :name, :iq, :annoyance_factor 
  @@bugs = []

  def initialize(name='unnamed',type='spider',iq=8,annoyance_factor=4)
    @type, @name, @iq, @annoyance_factor = type, name, iq, annoyance_factor
    @@bugs << self
  end

  def self.[](type)
    @@bugs.select { |bug| bug.type == type }
  end
  
  def inspect
    "I am a #{type} and my name is #{name}. I have an IQ of #{iq} and an annoyance factor of #{annoyance_factor}"
  end

  alias :to_s :inspect
end

#create some bugs!
Bug.new("ron",    "spider",       4, 2)
Bug.new("don",    "spider",       2, 3)
Bug.new("jake",   "ant",          9, 4)
Bug.new("chris",  "ladybug",      2, 4)
Bug.new("fred",   "cockchaffer",  0, 5)
Bug.new("greg",   "butterfly",    2, 0)
Bug.new("jason",  "butterfly",    0, 2)

Bug["butterfly"].each do |butterfly|
  puts butterfly
end

##################

@wordsToHighlight=["important","monkey","dancing"]
# def highlightText(input)
#   for i in 0..@wordsToHighlight.length-1 do
#     input = input.gsub(@wordsToHighlight[i],"*" + @wordsToHighlight[i] + "*")
#   end
#   return input
# end

def highlightText(input)
  input.gsub(Regexp.union(*@wordsToHighlight), '*\0*')
end

puts highlightText("I think it's important to have a dancing monkey in your bedroom.")