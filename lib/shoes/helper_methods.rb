class Shoes
  class App
    def basic_attributes args={}
      default = {left: 0, top: 0, width: 0, height: 0}
      default.merge args
    end

    def slot_attributes args={}
      default = {left: nil, top: nil, width: 1.0, height: 0}
      default.merge args
    end

    def create_tmp_png surface
      surface.write_to_png TMP_PNG_FILE
      Gtk::Image.new TMP_PNG_FILE
    end
  end

  def self.contents_alignment slot
    x, y = slot.left.to_i, slot.top.to_i
    max = Struct.new(:top, :height).new
    max.top, max.height = y, 0
    slot_height = 0

    slot.contents.each do |ele|
      next if ele.is_a? Shape
      tmp = max
      max = ele.positioning x, y, max
      x, y = ele.left + ele.width, ele.top + ele.height
      slot_height += max.height unless max == tmp
    end
    slot_height
  end

  def self.repaint_all slot
    slot.contents.each do |ele|
      next if ele.is_a? Shape
      ele.is_a?(Basic) ? ele.move2(ele.left, ele.top) : repaint_all(ele)
    end
  end

  def self.repaint_all_by_order app
    app.order.each do |e|
      if e.real and !e.is_a?(Background)
        app.canvas.remove e.real
        app.canvas.put e.real, e.left, e.top
      end
    end
  end
  
  def self.call_back_procs app
    init_contents app.cslot.contents
    app.cslot.width, app.cslot.height = app.width, app.height
    contents_alignment app.cslot
    repaint_all app.cslot
    repaint_all_by_order app
    true
  end

  def self.init_contents contents
    contents.each do |ele|
      next unless ele.is_a? Slot
      ele.initials.each do |k, v|
        ele.send "#{k}=", v
      end
    end
  end

  def self.mouse_click_control app
    app.mccs.each do |e|
      mouse_x, mouse_y = e.real.pointer
      e.click_proc.call if ((0..e.width).include?(mouse_x) and (0..e.height).include?(mouse_y))
    end
  end
  
  def self.mouse_release_control app
    app.mrcs.each do |e|
      mouse_x, mouse_y = e.real.pointer
      e.release_proc.call if ((0..e.width).include?(mouse_x) and (0..e.height).include?(mouse_y))
    end
  end

  def self.mouse_motion_control app
    app.mmcs.each do |blk|
      blk[*app.win.pointer]
    end
  end
  
  def self.set_cursor_type app
    app.mccs.each do |e|
      e.real.window.cursor = ARROW if e.real.window
      (e.real.window.cursor = HAND; break) if mouse_on? e
    end
  end
  
  def self.mouse_on? e
    mouse_x, mouse_y = e.real.pointer
    (0..e.width).include?(mouse_x) and (0..e.height).include?(mouse_y)
  end

  def self.size_allocated? app
    not (app.width_pre == app.width and app.height_pre == app.height)
  end
end
