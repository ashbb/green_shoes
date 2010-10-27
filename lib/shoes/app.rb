class Shoes
  class App
    include Types

    def initialize args={}
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      App.class_eval do
        attr_accessor *(args.keys - [:width, :height])
      end
      @contents, @canvas, @mccs, @mmcs, @win, @order = [], nil, [], [], nil, []
      @cslot = (@app ||= self)
      @width_pre, @height_pre = @width, @height
    end

    attr_accessor :cslot, :contents, :canvas, :app, :mccs, :mmcs, :win, :width_pre, :height_pre, :order

    def stack args={}, &blk
      args[:app] = self
      Stack.new slot_attributes(args), &blk
    end

    def flow args={}, &blk
      args[:app] = self
      Flow.new slot_attributes(args), &blk
    end

    def para *msg
      args = msg.last.class == Hash ? msg.pop : {}
      args = basic_attributes args
      msg = msg.join + ' ' * 5
      args[:width] = 10*msg.length if args[:width].zero?
      args[:height] = 18 if args[:height].zero?

      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
      context = Cairo::Context.new surface
      layout = context.create_pango_layout
      layout.text = msg
      context.show_pango_layout layout
      context.show_page

      img = create_tmp_png surface
      @canvas.put img, args[:left], args[:top]
      img.show_now
      args[:real], args[:app] = img, self
      args[:nocontrol] = true unless (args[:left].zero? and args[:top].zero?)
      Para.new args
    end

    def image name, args={}
      args = basic_attributes args
      img = Gtk::Image.new name
      @canvas.put img, args[:left], args[:top]
      img.show_now
      args[:real], args[:app] = img, self
      Image.new args
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
      el = Gtk::Entry.new
      el.text = args[:text].to_s
      el.signal_connect "changed" do
        yield el
      end if block_given?
      @canvas.put el, args[:left], args[:top]
      el.show_now
      args[:real], args[:app] = el, self
      EditLine.new args
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

    def motion &blk
      @win.set_events Gdk::Event::POINTER_MOTION_MASK
      @mmcs << blk
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
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
      context = Cairo::Context.new surface
      context.scale(1,  args[:height]/args[:width].to_f)
      context.arc args[:radius], args[:radius], args[:radius], 0, 2*Math::PI
      context.set_source_rgba *(args[:fill] or fill or black)
      context.fill

      context.set_source_rgba *(args[:stroke] or stroke or black)
      context.set_line_width args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
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
      args[:curve] ||= 0
      args[:height] = args[:width] unless args[:height]
      args = basic_attributes args
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
      context = Cairo::Context.new surface
      
      context.rounded_rectangle 0, 0, args[:width], args[:height], args[:curve]
      context.set_source_rgba *(args[:stroke] or stroke or black)
      context.fill
      
      sw = args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      context.rounded_rectangle sw, sw, args[:width]-sw*2, args[:height]-sw*2, args[:curve]
      context.set_source_rgba *(args[:fill] or fill or black)
      context.fill
      
      img = create_tmp_png surface
      @canvas.put img, args[:left], args[:top]
      img.show_now
      args[:real], args[:app] = img, self
      Rect.new args
    end

    def rgb r, g, b, l=1.0
      (r < 1 and g < 1 and b < 1) ? [r, g, b, l] : [r/255.0, g/255.0, b/255.0, l]
    end

    %w[fill stroke strokewidth].each do |name|
      eval "def #{name} #{name}=nil; #{name} ? @#{name}=#{name} : @#{name} end"
    end

    def background pat, args={}
      args[:pattern] = pat
      args[:width] ||= 0
      args[:height] ||= 0
      args[:curve] ||= 0
      args = basic_attributes args

      if args[:create_real] and !args[:height].zero?
        surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
        context = Cairo::Context.new surface
        context.rounded_rectangle 0, 0, args[:width], args[:height], args[:curve]
        context.set_source_rgba *(pat)
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
  end
end
