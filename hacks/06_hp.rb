#!/usr/bin/env ruby
# From: http://www.odetocode.com/Humor/68.aspx
# Simple HP Printer Hacker
# Written in Ruby by Erik Gregg
# 6/9/06
# Status Usage: hp-message.rb <host> status
# Message Usage: hp-message.rb <host> message "<message>"

require 'net/telnet'

begin
  if ARGV[0].nil?
    puts "Read the script.
Status Usage: hp-message.rb <host> status
Message Usage: hp-message.rb <host> message \"<message>\""
    exit
  end

  host = Net::Telnet::new("Host" => ARGV[0],
                          "Port" => 9100,
                          "Timeout" => 5,
                          "Prompt" => /\b/n)

  if ARGV[1] == "status"
    host.cmd("@PJL INFO STATUS") { |c| print c }
  elsif ARGV[1] == "message"
    host.cmd("@PJL RDYMSG DISPLAY=\""+ARGV[2]+"\"")
  else
    puts "Oh Cmon.  Look at the syntax inside me."
    exit
  end

  host.close
rescue Timeout::Error
  puts "Time to go now!"
  exit 1
end