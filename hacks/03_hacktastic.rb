# The completely hacktastic client.

require 'drb'

method = ARGV[0]
args = ARGV[1..-1]
args << STDIN.read unless STDIN.eof?

puts DRb::DRbObject.new(nil, 'druby://__IP__:2323').send(method, *args)
