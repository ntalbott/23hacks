input = STDIN.readlines.collect{|e| e.chomp}

w = input.collect{|e| e.size}.max
input.collect!{|e| e.ljust(w, ' ')}
input.collect!{|e| e.split('')}

output = (0...w).collect{|e| ''}

output.each do |e|
  input.each do |i|
    e << i.pop
  end
end

puts output.reject{|e| e.strip == ''}.join("\n")