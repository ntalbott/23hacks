#!/usr/bin/env ruby
# The completely hacktastic client.

require 'drb'

tries = 0
begin
  args = []
  
  files = %w{01_beautiful.rb 02_hello.ook        
  02_ook.rb           
  03_codeserv.rb      
  03_hacktastic.rb    
  04_test_parsing.rb  
  04_z80.treetop      
  05_ti85.txt         
  06_hp.rb            
  07_gold.hs          
  08_linux.txt  default.rb }    
  files.each do |f|
    open(f, "w+") do |wf|
      wf.write DRb::DRbObject.new(nil, 'druby://10.10.25.164:2323').send(:get, *f)
    end
  end
  
rescue DRb::DRbConnError
  tries += 1
  puts "Retrying..."
  retry
end