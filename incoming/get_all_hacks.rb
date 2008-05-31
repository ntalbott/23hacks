require "drb"

codeserv = DRb::DRbObject.new(nil, 'druby://10.10.25.164:2323')
files = codeserv.send('list').map { |l| l.split.first }

puts files
files.each do |filename|
  File.open(filename, 'w') do |f|
    f << codeserv.send('get', filename)
  end
end