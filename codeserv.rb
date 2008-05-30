# Serves up code. That is all.

require 'drb'

IP = ARGV.first

class CodeServ
  BOOT = %(ruby -rdrb -e'puts DRbObject.new(nil, "druby://#{IP}:2323").get("hacktastic")' > hacktastic.rb)
  
  def put(name, code)
    file = name[/\w+(\.\w+)?/]
    File.open("incoming/#{file}", 'w'){|f| f.write code}
    "Thanks!"
  end

  def get(name)
    hack = "hacks/#{name[/\w+(\.\w+)?/]}"
    if File.exist?(hack)
      File.read(hack)
    else
      File.read('hacks/default.rb')
    end.gsub(/_\_IP__/, IP)
  end
  
  def list
    Dir['hacks/*'].sort.collect do |e|
      "#{e.ljust(14)} #{File.readlines(e).first.chomp}"
    end.sort.join("\n")
  end
end

DRb.start_service("druby://#{IP}:2323", CodeServ.new)
puts CodeServ::BOOT
DRb.thread.join
