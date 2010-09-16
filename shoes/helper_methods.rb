module Shoes
  def self.basic_attributes args={}, default={}
    default = {left: 0, top: 0, width: 0, height: 0}.merge default
    default.merge args
  end
  
  def self.contents_alignment contents
    contents.each do |ele|
      if ele.is_a? Slot
        ele.left = ele.left_end = ele.parent.left_end + ele.left
        ele.top = ele.top_end = ele.parent.top_end + ele.top
        contents_alignment ele.contents
        set_slot_width_and_height ele
      end
      ele.parent.append ele if ele.is_a?(Slot) or (ele.left.zero? and ele.top.zero?)
    end
  end
  
  def self.set_slot_width_and_height ele
    if ele.is_a? Stack
      ele.height = ele.contents.collect(&:height).inject(&:+)
      ele.width = ele.contents.collect(&:width).max
    else
      ele.height = ele.contents.collect(&:height).max
      ele.width = ele.contents.collect(&:width).inject(&:+)
    end
  end

  # The followings are dummy methods for module Shoes.
  def self.append ele; end
  def self.left_end; 0 end
  def self.top_end; 0 end
end
