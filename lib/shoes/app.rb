class Shoes
  class App
    include Types

    def initialize args={}
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      App.class_eval do
        attr_accessor *(args.keys - [:width, :height, :title])
      end
      @contents, @canvas, @mccs, @mrcs, @mmcs, @mlcs, @shcs, @mcs, @win, @order = 
        [], nil, [], [], [], [], [], [], nil, []
      @cslot = (@app ||= self)
      @cmask = nil
      @top_slot = nil
      @width_pre, @height_pre = @width, @height
      @mouse_button, @mouse_pos = 0, [0, 0]
      @fill, @stroke = black, black
    end

    attr_accessor :cslot, :cmask, :top_slot, :contents, :canvas, :app, :mccs, :mrcs, :mmcs, 
      :mlcs, :shcs, :mcs, :win, :width_pre, :height_pre, :order
    attr_writer :mouse_button, :mouse_pos

    def stack args={}, &blk
      args[:app] = self
      Stack.new slot_attributes(args), &blk
    end

    def flow args={}, &blk
      args[:app] = self
      Flow.new slot_attributes(args), &blk
    end

    def mask &blk
      @mcs << Mask.new(self, &blk)
    end

    def clear &blk
      @top_slot.clear &blk
    end

    def textblock klass, font_size, *msg
      line_height =  font_size * 2
      args = msg.last.class == Hash ? msg.pop : {}
      args = basic_attributes args
      args[:markup] = msg.map(&:to_s).join
      attr_list, text = Pango.parse_markup args[:markup]
      args[:size] ||= font_size
      args[:align] ||= 'left'
      
      args[:links] = make_link_index(msg) unless args[:links]

      if !(args[:left].zero? and args[:top].zero?) and (args[:width].zero? or args[:height].zero?)
        args[:nocontrol], args[:width], args[:height] = true, self.width, self.height
        layout_control = false
      else
        layout_control = true
      end
      
      if args[:create_real] or !layout_control
        surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
        context = Cairo::Context.new surface
        layout = context.create_pango_layout
        layout.width = args[:width] * Pango::SCALE
        layout.wrap = Pango::WRAP_WORD
        layout.spacing = 5  * Pango::SCALE
        layout.text = text
        layout.alignment = eval "Pango::ALIGN_#{args[:align].upcase}"
        fd = Pango::FontDescription.new 'sans'
        fd.size = font_size * Pango::SCALE
        layout.font_description = fd
        layout.attributes = attr_list
        context.show_pango_layout layout
        context.show_page
        
        make_link_pos args[:links], layout, line_height
        
        args[:height] = layout.line_count * line_height
        img = create_tmp_png surface
        @canvas.put img, args[:left], args[:top]
        img.show_now
        args[:real], args[:noorder] = img, layout_control
      else
        args[:real] = false
      end
      
      args[:app] = self
      klass.new args
    end

    def banner *msg; textblock Banner, 48, *msg; end
    def title *msg; textblock Title, 34, *msg; end
    def subtitle *msg; textblock Subtitle, 26, *msg; end
    def tagline *msg; textblock Tagline, 18, *msg; end
    def caption *msg; textblock Caption, 14, *msg; end
    def para *msg; textblock Para, 12, *msg; end
    def inscription *msg; textblock Para, 10, *msg; end

    def image name, args={}
      args = basic_attributes args
      img = Gtk::Image.new name
      @canvas.put img, args[:left], args[:top]
      img.show_now
      args[:real], args[:app] = img, self
      Image.new args
    end

    def imagesize name
      Gtk::Image.new(name).size_request
    end

    def button name, args={}, &blk
      args = basic_attributes args
      b = Gtk::Button.new name
      b.signal_connect "clicked", &blk if blk
      @canvas.put b, args[:left], args[:top]
      b.show_now
      args[:real], args[:text], args[:app] = b, name, self
      Button.new args
    end

    def edit_line args={}
      args = basic_attributes args
      args[:width] = 200 if args[:width].zero?
      el = Gtk::Entry.new
      el.text = args[:text].to_s
      el.width_chars = args[:width] / 6
      el.signal_connect "changed" do
        yield el
        el.set_focus self
      end if block_given?
      @canvas.put el, args[:left], args[:top]
      el.show_now
      args[:real], args[:app] = el, self
      EditLine.new args
    end
    
    def list_box args={}, &blk
      args = basic_attributes args
      args[:width] = 200 if args[:width].zero?
      cb = Gtk::ComboBox.new
      args[:items] ||= []
      args[:items].each{|item| cb.append_text item.to_s}
      cb.active = args[:items].index(args[:choose]) if args[:choose]
      cb.signal_connect("changed") do
        blk.call args[:items][cb.active]
      end if blk
      @canvas.put cb, args[:left], args[:top]
      cb.show_now
      args[:real], args[:app] = cb, self
      ListBox.new args
    end

    def animate n=10, &blk
      n, i = 1000 / n, 0
      a = Anim.new
      GLib::Timeout.add n do
        blk[i = a.pause? ? i : i+1]
        Shoes.repaint_all_by_order self
        a.continue?
      end
      a
    end

    def every n=1, &blk
      animate 1.0/n, &blk
    end

    def timer n=1, &blk
      GLib::Timeout.add 1000*n do
        blk.call
        Shoes.repaint_all_by_order self
        false
      end
    end

    def motion &blk
      @mmcs << blk
    end

    def keypress &blk
      win.set_events Gdk::Event::BUTTON_PRESS_MASK | Gdk::Event::BUTTON_RELEASE_MASK | Gdk::Event::POINTER_MOTION_MASK | Gdk::Event::KEY_PRESS_MASK
      win.signal_connect("key_press_event") do |w, e|
        blk[Gdk::Keyval.to_name(e.keyval)]
      end
    end

    def mouse
      [@mouse_button, @mouse_pos[0], @mouse_pos[1]]
    end

    def oval *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 0, 1
        when 2; args[:left], args[:top] = attrs
        when 3; args[:left], args[:top], args[:radius] = attrs
        else args[:left], args[:top], args[:width], args[:height] = attrs
      end
      args = basic_attributes args
      args[:width].zero? ? (args[:width] = args[:radius] * 2) : (args[:radius] = args[:width]/2.0)
      args[:height] = args[:width] if args[:height].zero?
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
      context = Cairo::Context.new surface
      context.scale(1,  args[:height]/args[:width].to_f)
      
      if pat = (args[:fill] or fill)
        gp = gradient pat, args[:width], args[:height], args[:angle]
        context.set_source gp
        context.arc args[:radius], args[:radius], args[:radius], 0, 2*Math::PI
        context.fill
      end
      
      pat = (args[:stroke] or stroke)
      gp = gradient pat, args[:width], args[:height], args[:angle]
      context.set_source gp
      context.set_line_width args[:strokewidth]
      context.arc args[:radius], args[:radius], args[:radius]-args[:strokewidth]/2.0, 0, 2*Math::PI
      context.stroke

      img = create_tmp_png surface
      @canvas.put img, args[:left], args[:top]
      img.show_now
      args[:real], args[:app] = img, self
      Oval.new args
    end

    def rect *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 0, 1
        when 2; args[:left], args[:top] = attrs
        when 3; args[:left], args[:top], args[:width] = attrs
        else args[:left], args[:top], args[:width], args[:height] = attrs
      end
      args[:height] = args[:width] unless args[:height]
      sw = args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      
      args = basic_attributes args
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
      context = Cairo::Context.new surface
      
      if pat = (args[:fill] or fill)
        gp = gradient pat, args[:width], args[:height], args[:angle]
        context.set_source gp
        context.rounded_rectangle 0, 0, args[:width], args[:height], args[:curve]
        context.fill
      end
      
      pat = (args[:stroke] or stroke)
      gp = gradient pat, args[:width], args[:height], args[:angle]
      context.set_source gp
      context.set_line_width sw
      context.rounded_rectangle sw/2.0, sw/2.0, args[:width]-sw, args[:height]-sw, args[:curve]
      context.stroke
      
      img = create_tmp_png surface
      @canvas.put img, args[:left], args[:top]
      img.show_now
      args[:real], args[:app] = img, self
      Rect.new args
    end

    def line *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 0, 1, 2
        when 3; sx, sy, ex = attrs; ey = ex
        else sx, sy, ex, ey = attrs
      end
      sw = args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      hsw = sw*0.5
      args[:width], args[:height] = (sx - ex).abs, (sy - ey).abs
      
      args = basic_attributes args
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width]+sw, args[:height]+sw
      context = Cairo::Context.new surface
      
      pat = (args[:stroke] or stroke)
      gp = gradient pat, args[:width], args[:height], args[:angle]
      context.set_source gp
      context.set_line_width args[:strokewidth]
      
      if ((sx - ex) < 0 and (sy - ey) < 0) or ((sx - ex) > 0 and (sy - ey) > 0)
        context.move_to hsw, hsw
        context.line_to args[:width]+hsw, args[:height]+hsw
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif ((sx - ex) < 0 and (sy - ey) > 0) or ((sx - ex) > 0 and (sy - ey) < 0)
        context.move_to hsw, args[:height] + hsw
        context.line_to args[:width]+hsw, hsw
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif !(sx - ex).zero? and (sy - ey).zero?
        context.move_to 0, hsw
        context.line_to args[:width], hsw
        args[:left] = (sx - ex) < 0 ? sx : ex
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif (sx - ex).zero? and !(sy - ey).zero?
        context.move_to hsw, 0
        context.line_to hsw, args[:height]
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy : ey
      else
        context.move_to 0, 0
        context.line_to 0, 0
        args[:left] = sw
        args[:top] = sy
      end
      
      context.stroke
      img = create_tmp_png surface
      @canvas.put img, args[:left], args[:top]
      img.show_now
      args[:real], args[:app] = img, self
      Shape.new args
    end

    def rgb r, g, b, l=1.0
      (r < 1 and g < 1 and b < 1) ? [r, g, b, l] : [r/255.0, g/255.0, b/255.0, l]
    end

    %w[fill stroke strokewidth].each do |name|
      eval "def #{name} #{name}=nil; #{name} ? @#{name}=#{name} : @#{name} end"
    end

    def nostroke
      strokewidth 0
    end
    
    def nofill
      @fill = false
    end
    
    def gradient pat, w, h, angle=0
      color = case pat
        when Range; [pat.first, pat.last]
        when Array; [pat, pat]
        when String
          sp = Cairo::SurfacePattern.new Cairo::ImageSurface.from_png(pat)
          return sp.set_extend(Cairo::Extend::REPEAT)
        else
          [black, black]
      end
      dx, dy = w*angle/180.0, h*angle/180.0
      lp = Cairo::LinearPattern.new w*0.5-dx, dy, w*0.5+dx, h-dy
      lp.add_color_stop_rgba 0, *color[0]
      lp.add_color_stop_rgba 1, *color[1]
      lp
    end

    def background pat, args={}
      args[:pattern] = pat
      args = basic_attributes args

      if args[:create_real] and !args[:height].zero?
        surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
        context = Cairo::Context.new surface
        context.rounded_rectangle 0, 0, args[:width], args[:height], args[:curve]
        gp = gradient pat, args[:width], args[:height], args[:angle]
        context.set_source gp
        context.fill
        img = create_tmp_png surface
        @canvas.put img, args[:left], args[:top]
        img.show_now
        args[:real] = img
      else
        args[:real] = false
      end

      args[:app] = self
      Background.new args
    end
    
    def border pat, args={}
      args[:pattern] = pat
      args = basic_attributes args
      sw = args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )

      if args[:create_real] and !args[:height].zero?
        surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
        context = Cairo::Context.new surface
        gp = gradient pat, args[:width], args[:height], args[:angle]
        context.set_source gp
        context.set_line_width sw
        context.rounded_rectangle sw/2.0, sw/2.0, args[:width]-sw, args[:height]-sw, args[:curve]
        context.stroke
        
        img = create_tmp_png surface
        @canvas.put img, args[:left], args[:top]
        img.show_now
        args[:real] = img
      else
        args[:real] = false
      end

      args[:app] = self
      Border.new args
    end
  end
end
