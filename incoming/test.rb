rb_obj = Object.new
Johnson.evaluate('
  rb_obj.awesome = function() { return "hello world"; };
', { 'rb_obj' => rb_obj })

puts rb_obj.awesome # => ‘hello world’
