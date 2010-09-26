module Shoes
  class App
    def basic_attributes args={}
      default = {left: 0, top: 0, width: 0, height: 0}
      default.merge args
    end

    def create_tmp_png surface
      surface.write_to_png TMP_PNG_FILE
      Gtk::Image.new TMP_PNG_FILE
    end
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
end