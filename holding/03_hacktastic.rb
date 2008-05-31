# The completely hacktastic client.

require 'drb'

method = ARGV[0]
args = ARGV[1..-1]
unless STDIN.isatty
  args << STDIN.read
end

puts DRb::DRbObject.new(nil, 'druby://__IP__:2323').send(method, *args)
