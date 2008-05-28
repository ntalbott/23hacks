require 'zlib'

STDOUT.sync = true

data = "eJzVlVEOAyEIRP/3FCRz/zs21nVABLZdtx81qbVCeKIDFXEDbfhNa0PlFOwf
q8+YEghDpacoEBq8ymMHYW1/i8BPEVjCMtIjCLRAXkZdV8OynQUyBC37CAyl
er+gjm6+RYTI/O8ggNEV1KY5LHlAh4/I1sJQbY04C64us2gxVI/9Q8T5K3sL
HrlEmIZGDb4RYoxdUb73Deiahkdg5ozLEbN1vHNN6uJatC4VMW2ep0ur+9xz
9xQpakXMHg8hsGbBVdJp0z64KAo1oj/3BsLU1ISwjG2EhBcFu95CIEY4+af/
et8hxCEswyOuu1yJgFYjH2RBzGVTIyRHoELo/AmCtzL3KLOvijLyC7qfc5Lp
m5nDzjQdL2oHU74="

z = Zlib::Inflate.new
z << data.unpack('m').first
z.inflate(nil).split('').each do |e|
  print e
  sleep 0.003
end #Pad