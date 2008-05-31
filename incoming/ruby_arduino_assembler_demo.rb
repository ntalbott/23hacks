# http://rad.rubyforge.org
class AssemblerDemo < ArduinoSketch
  output_pins [2,3,4]
  serial_begin
  
  def loop
    display_digit product(3, 3)
  end
  
  assembler( :product, "int product(int a, int b);",
    <<-CODE
    product:
      mov  r18,r24; move a to another register
      ldi  r24,0; clear running sum, used to coalesce product
      ldi  r25,0; sum = 0
      
      .loop:
      tst  r18  ; is a == 0? if so, we're done
      breq .end
      
      mov  r19,r18; copy a
      andi r19,1; is a % 2 == 0
      breq .skip
      
      add  r24,r22; add b to sum
      adc  r25,r23
      
      .skip:
      lsr  r18  ; divide a by 2
      
      clc
      rol  r22  ; multiply b by 2
      rol  r23
      rjmp .loop
      
      .end:
      ret
      .size product, .-product
    CODE
  )
end
