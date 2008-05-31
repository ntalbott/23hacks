(1..13).each do |i|
  s = `banner -w 45 #{i} | ruby rotate.rb`
  10.times{puts}
  puts s.split("\n").collect{|e| (" "*40) + e}.join("\n")
  Dir[File.expand_path(File.dirname(__FILE__) + '/../holding') + "/#{'%02i' % i}_*"].each do |f|
    `cp #{f} ../hacks/`
  end
  gets
end