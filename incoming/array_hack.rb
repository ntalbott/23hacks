class Array
  # Convert [1,3,5,6,7,9] to [1..1,3..3,5..7,9..9]
  def to_ranges
    array = self.compact.uniq.sort
    ranges = []
    if !array.empty?
      # Initialize the left and right endpoints of the range
      left, right = array.first, nil
      array.each do |obj|
        # If the right endpoint is set and obj is not equal to right's successor 
        # then we need to create a range.
        if right && obj != right.succ
          ranges << Range.new(left,right)
          left = obj
        end
        right = obj
      end
      ranges << Range.new(left,right)
    end
    ranges
  end

  ##
  # Filter values out of an Array.
  def except(*vals)
    self.reject { |item| vals.include?(item) }
  end
end
