# The completely hacktastic client.

require 'drb'

method = ARGV[0]
args = ARGV[1..-1]
unless STDIN.isatty
  args << STDIN.read
end

args << File.open(args.last, "r"){|f| f.read} if File.exist?(args.last)
puts DRb::DRbObject.new(nil, 'druby://10.10.25.164:2323').send(method, *args)
