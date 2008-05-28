require 'zlib'

zipper = Zlib::Deflate.new
zipper << STDIN.read
STDOUT.write([zipper.deflate(nil, Zlib::FINISH)].pack('m'))