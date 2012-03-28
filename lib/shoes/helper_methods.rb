class Shoes
  module Mod
    def set_margin
      @margin ||= [0, 0, 0, 0]
      @margin = [@margin, @margin, @margin, @margin] if @margin.is_a? Integer
      margin_left, margin_top, margin_right, margin_bottom = @margin
      @margin_left ||= margin_left
      @margin_top ||= margin_top
      @margin_right ||= margin_right
      @margin_bottom ||= margin_bottom
    end

    def click &blk
      @click_proc = blk
      @app.mccs << self
    end
    
    def release &blk
      @release_proc = blk
      @app.mrcs << self
    end

    def hover &blk
      @hover_proc = blk
      (@app.mhcs << self) unless @app.mhcs.include? self
    end

    def leave &blk
      @leave_proc = blk
      (@app.mhcs << self) unless @app.mhcs.include? self
    end

    attr_reader :margin_left, :margin_top, :margin_right, :margin_bottom, :click_proc, :release_proc, :hover_proc, :leave_proc
    attr_accessor :hovered
  end
  
  module Mod2
    def init_app_vars
      @contents, @mccs, @mrcs, @mmcs, @mhcs, @mlcs, @shcs, @mcs, @order, @dics, @animates, @radio_groups, @textcursors, @textmarkers, @fronts, @backs, @focusables, @pinning_elements = 
        [], [], [], [], [], [], [], [], [], [], [], {}, {}, {}, [], [], [], []
      @cmask, @focus_ele, @location = nil, nil, '/'
      @mouse_button, @mouse_pos = 0, [0, 0]
      @fill, @stroke = black, black
    end

    def set_rotate_angle args
      @context_angle2 = Math::PI/2 - @context_angle
      m = args[:height] * Math.sin(@context_angle)
      w = args[:width] * Math.sin(@context_angle2) + m
      h = args[:width] * Math.sin(@context_angle) + args[:height] * Math.sin(@context_angle2)
      mx, my = m * Math.sin(@context_angle2), m * Math.sin(@context_angle)
      if @pixbuf_rotate.even?
        args[:left] += (args[:width] - w)/2.0
        args[:top] -= (h - args[:height])/2.0
      else
        args[:left] -= (h - args[:width])/2.0
        args[:top] += (args[:height] - w)/2.0
      end
      return w, h, mx, my
    end
  end

  class App
    def basic_attributes args={}
      default = BASIC_ATTRIBUTES_DEFAULT
      default.merge!({nocontrol: true}) if @nolayout
      replace_string_to_float args
      default.merge args
    end

    def slot_attributes args={}
      default = SLOT_ATTRIBUTES_DEFAULT
      replace_string_to_float args
      default.merge args
    end

    def replace_string_to_float args={}
      [:width, :height, :left, :top].each do |k|
        if args[k].is_a? String
          args[k] = args[k].include?('%') ? args[k].to_f / 100 : args[k].to_i
        end
      end
    end

    def create_tmp_png surface
      surface.write_to_png TMP_PNG_FILE
      Gtk::Image.new TMP_PNG_FILE
    end
    
    def make_link_index msg
      start, links = 0, []
      msg.each do |e|
        len = e.to_s.gsub(/<\/.*?>/, '').gsub(/<.*?>/, '').bytesize
        (links << e; e.index = [start, start + len]) if e.is_a? Link
        start += len
      end
      links
    end
    
    def make_link_pos links, layout, line_height
      links.each do |e|
        e.pos = [layout.index_to_pos(e.index[0]).x / Pango::SCALE, layout.index_to_pos(e.index[0]).y / Pango::SCALE]
        e.pos << (layout.index_to_pos(e.index[1]).x / Pango::SCALE) << (layout.index_to_pos(e.index[1]).y / Pango::SCALE)
        e.pos << line_height
      end
    end

    def make_textcursor_pos tb, n
      layout = make_textcursor_layout tb
      n = tb.text.length if n == -1
      return layout.index_to_pos(n).x / Pango::SCALE, layout.index_to_pos(n).y / Pango::SCALE
    end

    def make_textcursor_index tb, x, y
      layout = make_textcursor_layout tb
      layout.xy_to_index x * Pango::SCALE, y * Pango::SCALE
    end

    def make_textcursor_layout tb
      markup, size, width, height, align, font, justify, leading, wrap = 
        %w[@markup @size @width @height @align @font @justify @leading @wrap].map{|v| tb.instance_variable_get v}
      text, attr_list = make_pango_attr markup
      make_pango_layout(size, width, height, align, font, justify, leading, wrap, text, attr_list)[0]
    end

    def make_pango_attr markup
      attr_list, dummy_text = Pango.parse_markup markup.gsub('\u0026', '@')
      dummy_attr_list, text = Pango.parse_markup markup
      text = text.gsub('\u0026', '&')
      return text, attr_list
    end

    def make_pango_layout size, width, height, align, font, justify, leading, wrap, text, attr_list
      leading ||= 4
      wrap ||= 'word'
      wrap == 'trim' ? (wrap, ellipsize = nil, WRAP[wrap.to_sym]) : (wrap, ellipsize = WRAP[wrap.to_sym], nil)
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, width, height
      context = Cairo::Context.new surface
      layout = context.create_pango_layout
      layout.width = width * Pango::SCALE
      layout.wrap = wrap if wrap
      layout.ellipsize = ellipsize if ellipsize
      layout.spacing = leading  * Pango::SCALE
      layout.text = text
      layout.justify = justify
      layout.alignment = eval "Pango::ALIGN_#{align.upcase}"
      fd = Pango::FontDescription.new
      fd.family = font
      fd.size = size * Pango::SCALE
      layout.font_description = fd
      layout.attributes = attr_list
      return layout, context, surface
    end

    def delete_mouse_events ele
      events = [mccs, mrcs, mmcs, mhcs]
      events.pop if ele.is_a? Basic
      events.each{|m| m.delete ele}
    end
  end

  def self.contents_alignment slot
    x, y = slot.left.to_i, slot.top.to_i
    max = Struct.new(:top, :height).new
    max.top, max.height = y, 0
    slot_height, slot_top = 0, y

    slot.contents.each do |ele|
      next if ele.is_a?(Basic) && ele.cleared && !ele.is_a?(Pattern)
      if ele.is_a? ShapeBase
        ele.hide if slot.masked
        next
      end
      if slot.masked and ele.is_a? Image
        ele.hide
        next
      end
      tmp = max
      max, flag = ele.positioning x, y, max
      x, y = ele.left + ele.width, ele.top + ele.height
      unless max == tmp
        slot_height = max.top + max.height - slot_top
      end
    end
    slot_height
  end

  def self.repaint_all slot
    return if slot.masked
    slot.contents.each do |ele|
      next if ele.is_a?(Basic) && ele.cleared && !ele.is_a?(Pattern)
      next if ele.is_a? ShapeBase
      ele.is_a?(Basic) ? ele.move2(ele.left + ele.margin_left, ele.top + ele.margin_top) : repaint_all(ele)
    end
  end

  def self.repaint_all_by_order app
    tmp = app.order
    (app.fronts + app.backs).each{|e| tmp.delete e}
    (app.backs + tmp + app.fronts).each do |e|
      if e.real and !e.is_a?(Pattern) and !e.hided and !e.real.destroyed?
        app.canvas.remove e.real
        app.canvas.put e.real, e.left, e.top
      end
    end
  end

  def self.repaint_textcursors app
    app.textcursors.each do |tb, v|
      n, cursor = v
      x, y = app.make_textcursor_pos(tb, n)
      x += tb.left; y += tb.top
      cursor ? cursor.move(x, y) : app.textcursors[tb][1] = app.line(x, y, x, y+tb.size*1.7, strokewidth: 1, stroke: app.black)
    end
  end
  
  def self.call_back_procs app
    init_contents app.cslot.contents
    app.cslot.width, app.cslot.height = app.width, app.height
    scrollable_height = contents_alignment app.cslot
    repaint_all app.cslot
    mask_control app
    repaint_all_by_order app
    repaint_textcursors app
    app.canvas.set_size 0, scrollable_height unless(app.prjct or app.trvw)
    n = app.focus_ele ? app.focusables.index(app.focus_ele) : 0
    app.canvas.focus_chain = (app.focusables[n..-1] + app.focusables[0...n]).map(&:real) if n and !app.canvas.is_a?(Gtk::DrawingArea)
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
      e.click_proc[*app.mouse] if mouse_on?(e) && !$dde
    end
  end
  
  def self.mouse_release_control app
    app.mrcs.each do |e|
      e.release_proc[*app.mouse] if mouse_on? e
    end
  end

  def self.mouse_motion_control app
    app.mmcs.each do |blk|
      blk[*app.win.pointer]
    end
  end

  def self.mouse_hover_control app
    app.mhcs.each do |e|
      if mouse_on?(e) and !e.hovered
        e.hovered = true
        e.hover_proc[e] if e.hover_proc
      end
    end
  end

  def self.mouse_leave_control app
    app.mhcs.each do |e|
      if !mouse_on?(e) and e.hovered
        e.hovered = false
        e.leave_proc[e] if e.leave_proc
      end
    end
  end

  def self.mouse_link_control app
    app.mlcs.each do |tb|
      next if tb.hided
      link_proc,  = mouse_on_link(tb, app)
      link_proc.call if link_proc && !$dde
    end
  end
  
  def self.set_cursor_type app
    app.mccs.each do |e|
      next if e.is_a? Slot
      e.real.window.cursor = ARROW if e.real.window
      (e.real.window.cursor = HAND; return) if mouse_on? e and e.real.window
    end
    
    app.mlcs.each do |tb|
      next if tb.hided
      tb.text = tb.text unless tb.real
      tb.real.window.cursor = ARROW if tb.real.window
      if ret = mouse_on_link(tb, app)
        tb.real.window.cursor = HAND  if tb.real.window
        unless tb.links[ret[1]].link_hover
          markup = tb.args[:markup].gsub(app.linkhover_style, app.link_style)
          links = markup.mindex  app.link_style
          n = links[ret[1]]
          tb.text = markup[0...n] + markup[n..-1].sub(app.link_style, app.linkhover_style)
          tb.links.each{|e| e.link_hover = false}
          tb.links[ret[1]].link_hover = true
        end
        return
      end
      if tb.links.map(&:link_hover).include? true
        tb.text = tb.args[:markup].gsub(app.linkhover_style, app.link_style)
        tb.links.each{|e| e.link_hover = false}
      end
    end
  end
  
  def self.mouse_on? e
    mouse_x, mouse_y = e.app.win.pointer
    mouse_y += e.app.scroll_top
    (e.left..e.left+e.width).include?(mouse_x) and (e.top..e.top+e.height).include?(mouse_y)
  end

  def self.mouse_on_link tb, app
    mouse_x, mouse_y = app.win.pointer
    mouse_y += app.scroll_top
    mouse_x -= tb.left
    mouse_y -= tb.top
    tb.links.each_with_index do |e, n|
      return [e.link_proc, n] if ((0..tb.width).include?(mouse_x) and (e.pos[1]..(e.pos[3]+e.pos[4])).include?(mouse_y) and !((0..e.pos[0]).include?(mouse_x) and (e.pos[1]..(e.pos[1]+e.pos[4])).include?(mouse_y)) and !((e.pos[2]..tb.width).include?(mouse_x) and (e.pos[3]..(e.pos[3]+e.pos[4])).include?(mouse_y)))
    end
    return false
  end

  def self.size_allocated? app
    not (app.width_pre == app.width and app.height_pre == app.height)
  end

  def self.show_hide_control app
    flag = false
    app.shcs.each do |e|
      case
        when(!e.shows and !e.hided)
          e.remove
          e.hided = true
          flag = true
        when(e.shows and e.hided)
          e.hided = false
          e.is_a?(Pattern) ? e.move2(e.left, e.top) : app.canvas.put(e.real, e.left, e.top)
          flag = true
        else
      end
    end
    repaint_all_by_order app if flag
  end

  def self.mask_control app
    app.mcs.each do |m|
      w, h = m.parent.width, m.parent.height
      w = app.width if w.zero?
      h = app.height if h.zero?
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, w, h
      context = Cairo::Context.new surface
      context.push_group do
        m.parent.contents.each do |ele|
          x, y = ele.left - m.parent.left, ele.top - m.parent.top
          context.translate x, y
          context.set_source_pixbuf ele.real.pixbuf
          context.paint
          context.translate -x, -y
        end
      end

      sf = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, w, h
      ct = Cairo::Context.new surface
      pat = ct.push_group nil, false do
        m.contents.each do |ele|
          if ele.is_a? TextBlock
            ele.height = h
            ele.text = ele.args[:markup]
          end
          x, y = ele.left - m.parent.left, ele.top - m.parent.top
          ct.translate x, y
          ct.set_source_pixbuf ele.real.pixbuf
          ct.paint
          ct.translate -x, -y
        end
      end

      context.mask pat
      m.real = img = app.create_tmp_png(surface)
      app.canvas.put img, 0, 0
      img.show_now
    end
  end

  def self.download_images_control app
    flag = false
    app.dics.each do |e, d, tmpname|
      args = e.args
      if d.finished?
        flag = true
        app.canvas.remove e.real
        img = Gtk::Image.new tmpname
        e.full_width, e.full_height = img.size_request
        unless args[:width].zero? and args[:height].zero?
          img = Gtk::Image.new img.pixbuf.scale(args[:width], args[:height])
        end
        app.canvas.put img, e.left, e.top
        img.show_now
        e.real = img
        e.width, e.height = img.size_request
        app.dics.delete [e, d, tmpname]
        File.delete tmpname
      end
    end
    flag
  end

  def self.pinning_control app
    if d = app.scrolled?
      app.pinning_elements.each{|e| e.move e.left, e.top + d}
    end
  end
end
