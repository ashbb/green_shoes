class Shoes
  class App
    include Mod2

    def initialize args={}
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      win_title = @owner.instance_variable_get('@title')
      class << @owner; self end.
      class_eval do
        define_method :inspect do
          win_title or 'green shoes'
        end
      end if @owner

      App.class_eval do
        attr_accessor *(args.keys - [:width, :height, :title])
      end
      
      init_app_vars
      @canvas, @win, @swin, @top_slot = nil
      @cslot = (@app ||= self)
      @width_pre, @height_pre = @width, @height
      @link_style, @linkhover_style = LINK_DEFAULT, LINKHOVER_DEFAULT
      @context_angle = @pixbuf_rotate = 0
      (Shoes.APPS << self) unless @noapp
    end

    attr_accessor :cslot, :cmask, :top_slot, :contents, :canvas, :app, :mccs, :mrcs, :mmcs, 
      :mhcs, :mlcs, :shcs, :mcs, :win, :swin, :width_pre, :height_pre, :order, :dics, :fronts, :backs, :focusables, :focus_ele
    attr_writer :mouse_button, :mouse_pos
    attr_reader :link_style, :linkhover_style, :animates, :owner, :textcursors, :textmarkers, :location, :pinning_elements

    def visit url
      if url =~ /^(http|https):\/\//
        Thread.new do
          case RUBY_PLATFORM
          when /mingw/; system "start #{url}"
          when /linux/; system("/etc/alternatives/x-www-browser #{url} &")
          else
            puts "Sorry, your platform [#{RUBY_PLATFORM}] is not supported..."
          end
        end
      else
        timer 0.001 do
          $urls.each{|k, v| clear{init_app_vars; @location = url; v.call self, $1} if k =~ url}
        end
      end
    end
    
    def stack args={}, &blk
      if args[:scroll]
        slot_with_scrollbar Stack, args, &blk
      else
        args[:app] = self
        (click_proc = args[:click]; args.delete :click) if args[:click]
        Stack.new(slot_attributes(args), &blk).tap{|s| s.click &click_proc if click_proc}
      end
    end

    def flow args={}, &blk
      if args[:scroll]
        slot_with_scrollbar Flow, args, &blk
      else
        args[:app] = self
        (click_proc = args[:click]; args.delete :click) if args[:click]
        Flow.new(slot_attributes(args), &blk).tap{|s| s.click &click_proc if click_proc}
      end
    end

    def slot_with_scrollbar slot, args={}, &blk
      args[:left] ||= 0
      args[:top] ||= 0
      args[:width] ||= 200
      args[:height] ||= 200

      app = App.new noapp: true
      app.instance_variable_set :@_w, args[:width]
      app.instance_variable_set :@_h, args[:height]
      def app.width; @_w end
      def app.height; @_h end
      app.win = win

      swin = Gtk::ScrolledWindow.new
      swin.set_size_request args[:width], args[:height]
      swin.set_policy Gtk::POLICY_NEVER, Gtk::POLICY_AUTOMATIC
      swin.vadjustment.step_increment = 10

      layout = Gtk::Layout.new
      swin.add layout
      layout.style = @canvas.style

      app.canvas = layout
      app.top_slot = slot.new app.slot_attributes(app: app, left: args[:left], top: args[:top], width: args[:width], height: args[:height], swin: swin)

      app.instance_eval &blk

      @canvas.put swin, args[:left], args[:top]
      app.top_slot
    end

    def mask &blk
      Mask.new(self, &blk).tap{|m| @mcs << m}
    end

    def clear &blk
      mcs.each &:clear
      @top_slot.clear &blk
    end

    def textblock klass, font_size, *msg
      args = msg.last.class == Hash ? msg.pop : {}
      args = eval("#{klass.to_s[7..-1].upcase}_DEFAULT").merge args
      args = basic_attributes args
      args[:markup] = msg.map(&:to_s).join
      args[:markup] = fg(args[:markup], tr_color(args[:stroke])) if args[:stroke]
      args[:markup] = bg(args[:markup], tr_color(args[:fill])) if args[:fill]
      form = {}
      args.each{|k, v| form.merge!({k => v}) if SPAN_FORM[k]}
      args[:markup] = span(args[:markup], form) unless form.empty?
      SPAN_FORM.keys.+([:stroke, :fill]).each{|k| args.delete k}
      text, attr_list = make_pango_attr args[:markup]
      args[:size] ||= font_size
      (args[:size] = font_size * FONT_SIZE[args[:size]]) if FONT_SIZE[args[:size]]
      args[:font] ||= (@font_family or 'sans')
      args[:align] ||= 'left'
      line_height =  args[:size] * 2
      
      args[:links] = make_link_index(msg) unless args[:links]

      if !(args[:left].zero? and args[:top].zero?) and (args[:width].zero? or args[:height].zero?)
        args[:nocontrol], args[:add_mlcs], args[:width], args[:height] = true, true, self.width, self.height
        layout_control = false
      else
        layout_control = true
      end
      
      if args[:create_real] or !layout_control
        args[:width] = 1 if args[:width] <= 0
        layout, context, surface = 
          make_pango_layout args[:size], args[:width], args[:height], args[:align], args[:font], args[:justify], args[:leading], args[:wrap], text, attr_list
        context.show_pango_layout layout
        context.show_page
        
        make_link_pos args[:links], layout, line_height
        
        args[:height] = layout.line_count * line_height
        img = create_tmp_png surface
        @canvas.put img, args[:left], args[:top]
        img.show_now
        @canvas.remove img if args[:hidden]
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
      args = IMAGE_DEFAULT.merge args
      args = basic_attributes args
      args[:full_width] = args[:full_height] = 0
      (click_proc = args[:click]; args.delete :click) if args[:click]
      if name =~ /^(http|https):\/\//
        tmpname = File.join(Dir.tmpdir, "__green_shoes_#{Time.now.to_f}.png")
        d = download name, save: tmpname
        img = Gtk::Image.new File.join(DIR, '../static/downloading.png')
        downloading = true
      elsif name =~ /\.(png|jpg|gif|PNG|JPG|GIF)$/
        img = Gtk::Image.new name
        downloading = false
      else
        require 'rsvg2'
        img = Gtk::Image.new RSVG::Handle.new_from_data(name).pixbuf
        downloading = false
      end

      if (!args[:width].zero? or !args[:height].zero?) and !downloading 
        args[:full_width], args[:full_height] = imagesize(name)
        args[:width] = args[:full_width] if args[:width].zero?
        args[:height] = args[:full_height] if args[:height].zero?
        img = Gtk::Image.new img.pixbuf.scale(args[:width], args[:height])
      end
      @canvas.put img, args[:left], args[:top]
      img.show_now
      @canvas.remove img if args[:hidden]
      args[:real], args[:app], args[:path] = img, self, name
      Image.new(args).tap do |s|
        @dics.push([s, d, tmpname]) if downloading
        s.click &click_proc if click_proc
      end
    end

    def imagesize name
      Gtk::Image.new(name).size_request
    end

    def button name, args={}
      args = basic_attributes args
      (click_proc = args[:click]; args.delete :click) if args[:click]
      b = Gtk::Button.new name
      b.set_size_request args[:width], args[:height] if args[:width] > 0 and args[:height] > 0
      @canvas.put b, args[:left], args[:top]
      b.show_now
      args[:real], args[:text], args[:app] = b, name, self
      Button.new(args).tap do |s|
        s.click &click_proc if click_proc
        b.signal_connect "clicked" do
          yield s
        end if block_given?
      end
    end

    def check args={}
      args = basic_attributes args
      (click_proc = args[:click]; args.delete :click) if args[:click]
      cb = Gtk::CheckButton.new
      cb.active = true if args[:checked]
      @canvas.put cb, args[:left], args[:top]
      cb.show_now
      args[:real], args[:app] = cb, self
      Check.new(args).tap do |s|
        s.click &click_proc if click_proc
        cb.signal_connect "clicked" do
          yield s
        end if block_given?
      end
    end
    
    def radio *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      group = attrs.first unless attrs.empty?
      group = args[:group] if args[:group]
      group = group ? (@radio_groups[group] ||= Gtk::RadioButton.new) : cslot.radio_group
      args = basic_attributes args
      (click_proc = args[:click]; args.delete :click) if args[:click]
      rb = Gtk::RadioButton.new group
      rb.active = true if args[:checked]
      @canvas.put rb, args[:left], args[:top]
      rb.show_now
      args[:real], args[:app] = rb, self
      Radio.new(args).tap do |s|
        s.click &click_proc if click_proc
        rb.signal_connect "clicked" do
          yield s
        end if block_given?
      end
    end

    def edit_line *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      txt = attrs.first unless attrs.empty?
      args = basic_attributes args
      args[:width] = 200 if args[:width].zero?
      args[:height] = 28 if args[:height].zero?
      (change_proc = args[:change]; args.delete :change) if args[:change]
      el = Gtk::Entry.new
      el.visibility = false if args[:secret]
      el.text = txt || args[:text].to_s
      el.set_size_request args[:width], args[:height]
      @canvas.put el, args[:left], args[:top]
      el.show_now
      args[:real], args[:app] = el, self
      EditLine.new(args).tap do |s|
        s.change &change_proc
        el.signal_connect "changed" do
          yield s
        end if block_given?
      end
    end

    def edit_box *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      txt = attrs.first unless attrs.empty?
      args = basic_attributes args
      args[:width] = 200 if args[:width].zero?
      args[:height] = 108 if args[:height].zero?
      (change_proc = args[:change]; args.delete :change) if args[:change]
      tv = Gtk::TextView.new
      tv.wrap_mode = Gtk::TextTag::WRAP_WORD
      tv.buffer.text = txt || args[:text].to_s
      tv.modify_font(Pango::FontDescription.new(args[:font])) if args[:font]
      tv.accepts_tab = args[:accepts_tab]
      args.delete :accepts_tab

      eb = Gtk::ScrolledWindow.new
      eb.set_size_request args[:width], args[:height]
      eb.set_policy Gtk::POLICY_NEVER, Gtk::POLICY_AUTOMATIC
      eb.set_shadow_type Gtk::SHADOW_IN
      eb.add tv

      @canvas.put eb, args[:left], args[:top]
      eb.show_all
      args[:real], args[:app], args[:textview] = eb, self, tv
      EditBox.new(args).tap do |s|
        s.change &change_proc
        tv.buffer.signal_connect "changed" do
          yield s
        end if block_given?
      end
    end
    
    def list_box args={}
      args = basic_attributes args
      args[:width] = 200 if args[:width].zero?
      args[:height] = 28 if args[:height].zero?
      (change_proc = args[:change]; args.delete :change) if args[:change]
      cb = args[:entry] ? Gtk::ComboBoxEntry.new : Gtk::ComboBox.new
      args[:items] ||= []
      args[:items].each{|item| cb.append_text item.to_s}
      cb.set_size_request args[:width], args[:height]
      if args[:choose]
        unless args[:entry]
          cb.active = args[:items].index(args[:choose])
        else
          cb.child.text = args[:choose].to_s
        end
      end
      @canvas.put cb, args[:left], args[:top]
      cb.show_now
      args[:real], args[:app] = cb, self
      ListBox.new(args).tap do |s|
        s.change &change_proc
        cb.signal_connect("changed") do
          yield s
        end if block_given?
      end
    end

    def animate n=10, repaint=true, &blk
      n, i = 1000 / n, 0
      a = Anim.new
      @animates << a
      GLib::Timeout.add n do
        if a.continue? 
          blk[i = a.pause? ? i : i+1]
          Shoes.repaint_all_by_order self if repaint
        end
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
      win.signal_handler_disconnect @key_press_handler if @key_press_handler
      win.set_events Gdk::Event::BUTTON_PRESS_MASK | Gdk::Event::BUTTON_RELEASE_MASK | Gdk::Event::POINTER_MOTION_MASK | Gdk::Event::KEY_PRESS_MASK
      @key_press_handler = win.signal_connect("key_press_event") do |w, e|
        k = Gdk::Keyval.to_name e.keyval
        k = case
          when Shoes::KEY_NAMES.include?(k); e.keyval.chr
          when k == 'Return'; "\n"
          when k == 'Tab'; "\t"
	  else k
        end
        blk[k]
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
      (click_proc = args[:click]; args.delete :click) if args[:click]
      args[:width].zero? ? (args[:width] = args[:radius] * 2) : (args[:radius] = args[:width]/2.0)
      args[:height] = args[:width] if args[:height].zero?
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      args[:angle1] ||= 0
      args[:angle2] ||= 2*Math::PI

      w, h, mx, my = set_rotate_angle(args)
      my *= args[:width]/args[:height].to_f
      
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, w, h
      context = Cairo::Context.new surface
      context.rotate @context_angle
      context.scale(1,  args[:height]/args[:width].to_f)
      
      if pat = (args[:fill] or fill)
        gp = gradient pat, args[:width], args[:height], args[:angle]
        context.set_source gp
        context.arc args[:radius]+mx, args[:radius]-my, args[:radius], args[:angle1], args[:angle2]
        context.fill
      end
      
      pat = (args[:stroke] or stroke)
      gp = gradient pat, args[:width], args[:height], args[:angle]
      context.set_source gp
      context.set_line_width args[:strokewidth]
      context.arc args[:radius]+mx, args[:radius]-my, args[:radius]-args[:strokewidth]/2.0, args[:angle1], args[:angle2]
      context.set_line_cap(LINECAP[args[:cap]] || cap)
      context.stroke

      img = create_tmp_png surface
      img = Gtk::Image.new img.pixbuf.rotate(ROTATE[@pixbuf_rotate])
      @canvas.put img, args[:left], args[:top]
      img.show_now
      @canvas.remove img if args[:hidden]
      args[:real], args[:app] = img, self
      Oval.new(args).tap{|s| s.click &click_proc if click_proc}
    end

    def arc l, t, w, h, a1, a2, args={}
      args.merge!({angle1: a1, angle2: a2})
      oval  l, t, w, h, args
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

      w, h, mx, my = set_rotate_angle(args)

      args = basic_attributes args
      (click_proc = args[:click]; args.delete :click) if args[:click]
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, w, h
      context = Cairo::Context.new surface

      context.rotate @context_angle
      
      if pat = (args[:fill] or fill)
        gp = gradient pat, args[:width], args[:height], args[:angle]
        context.set_source gp
        context.rounded_rectangle sw/2.0+mx, sw/2.0-my, args[:width]-sw, args[:height]-sw, args[:curve]
        context.fill
      end
      
      pat = (args[:stroke] or stroke)
      gp = gradient pat, args[:width], args[:height], args[:angle]
      context.set_source gp
      context.set_line_width sw
      context.rounded_rectangle sw/2.0+mx, sw/2.0-my, args[:width]-sw, args[:height]-sw, args[:curve]
      context.stroke
      
      img = create_tmp_png surface
      img = Gtk::Image.new img.pixbuf.rotate(ROTATE[@pixbuf_rotate])
      @canvas.put img, args[:left], args[:top]
      img.show_now
      @canvas.remove img if args[:hidden]
      args[:real], args[:app] = img, self
      Rect.new(args).tap{|s| s.click &click_proc if click_proc}
    end

    def line *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 0, 1, 2
        when 3; args[:sx], args[:sy], args[:ex] = attrs; args[:ey] = args[:ex]
        else args[:sx], args[:sy], args[:ex], args[:ey] = attrs
      end
      sx, sy, ex, ey = args[:sx], args[:sy], args[:ex], args[:ey]
      sw = args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      cw = hsw = sw*0.5
      args[:width], args[:height] = (sx - ex).abs, (sy - ey).abs
      args[:width] += cw
      args[:height] += cw
      
      args = basic_attributes args
      (click_proc = args[:click]; args.delete :click) if args[:click]
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width]+sw, args[:height]+sw
      context = Cairo::Context.new surface
      
      pat = (args[:stroke] or stroke)
      gp = gradient pat, args[:width], args[:height], args[:angle]
      context.set_source gp
      context.set_line_width args[:strokewidth]
      
      if ((sx - ex) < 0 and (sy - ey) < 0) or ((sx - ex) > 0 and (sy - ey) > 0)
        context.move_to cw+hsw, cw+hsw
        context.line_to args[:width]+hsw, args[:height]+hsw
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif ((sx - ex) < 0 and (sy - ey) > 0) or ((sx - ex) > 0 and (sy - ey) < 0)
        context.move_to cw+hsw, args[:height]+hsw
        context.line_to args[:width]+hsw, cw+hsw
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif !(sx - ex).zero? and (sy - ey).zero?
        context.move_to cw, cw+hsw
        context.line_to args[:width], cw+hsw
        args[:left] = (sx - ex) < 0 ? sx : ex
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif (sx - ex).zero? and !(sy - ey).zero?
        context.move_to cw+hsw, cw
        context.line_to cw+hsw, args[:height]
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy : ey
      else
        context.move_to 0, 0
        context.line_to 0, 0
        args[:left] = sw
        args[:top] = sy
      end
      
      context.set_line_cap(LINECAP[args[:cap]] || cap)
      context.stroke
      img = create_tmp_png surface
      @canvas.put img, (args[:left]-=cw), (args[:top]-=cw)
      img.show_now
      @canvas.remove img if args[:hidden]
      args[:real], args[:app] = img, self
      Line.new(args).tap{|s| s.click &click_proc if click_proc}
    end
    
    def shapebase klass, args
      blk = args[:block]
      args[:width] ||= 300
      args[:height] ||= 300

      w, h, mx, my = set_rotate_angle(args)

      args = basic_attributes args
      (click_proc = args[:click]; args.delete :click) if args[:click]
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, w, h
      context = Cairo::Context.new surface
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      context.set_line_width args[:strokewidth]
      context.set_line_cap(LINECAP[args[:cap]] || cap)

      context.rotate @context_angle
      
      mk_path = proc do |pat|
        gp = gradient pat, args[:width], args[:height], args[:angle]
        context.set_source gp
        context.move_to 0, 0
        klass == Shoes::Star ? context.instance_eval{blk[self, mx, -my]} : context.instance_eval(&blk)
      end

      if pat = (args[:fill] or fill)
        mk_path.call pat
        context.fill
      end
      
      mk_path.call (args[:stroke] or stroke)
      context.stroke
      
      img = create_tmp_png surface
      img = Gtk::Image.new img.pixbuf.rotate(ROTATE[@pixbuf_rotate])
      @canvas.put img, args[:left], args[:top]
      img.show_now
      @canvas.remove img if args[:hidden]
      args[:real], args[:app] = img, self
      klass.new(args).tap{|s| s.click &click_proc if click_proc}
    end

    def shape args={}, &blk
      args[:left] ||= 0
      args[:top] ||= 0
      args[:block] = blk
      shapebase Shape, args
    end
    
    def star *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 2; args[:left], args[:top] = attrs
        when 5; args[:left], args[:top], args[:points], args[:outer], args[:inner] = attrs
        else
      end
      args[:points] ||= 10; args[:outer] ||= 100.0; args[:inner] ||= 50.0
      args[:width] = args[:height] = args[:outer]*2.0
      x = y = outer = args[:outer]
      points, inner = args[:points], args[:inner]

      args[:block] = proc do |s, mx, my|
        x += mx; y += my
        s.move_to x, y + outer
        (1..points*2).each do |i|
          angle =  i * Math::PI / points
          r = (i % 2 == 0) ? outer : inner
          s.line_to x + r * Math.sin(angle), y + r * Math.cos(angle)
        end
      end
      shapebase Star, args
    end

    def arrow *attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      w = attrs[2]
      args.merge!({left: attrs[0], top: attrs[1], width: w, height: w})
      shape args do
        move_to 0, w*0.5*0.6
        line_to w*0.58, w*0.5*0.6
        line_to w*0.58, w*0.5*0.2
        line_to w, w*0.5
        line_to w*0.58, w*(1-0.5*0.2)
        line_to w*0.58, w*(1-0.5*0.6)
        line_to 0, w*(1-0.5*0.6)
        line_to 0, w*0.5*0.6
      end
    end

    def rotate angle
      @pixbuf_rotate, angle = angle.divmod(90)
      @pixbuf_rotate %= 4
      @context_angle = Math::PI * angle / 180
    end

    def rgb r, g, b, l=1.0
      (r <= 1 and g <= 1 and b <= 1) ? [r, g, b, l] : [r/255.0, g/255.0, b/255.0, l]
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
    
    def gradient *attrs
      case attrs.length
        when 1, 2
          pat1, pat2 = attrs
          pat2 = pat1 unless pat2
          return tr_color(pat1)..tr_color(pat2)
        when 3, 4
          pat, w, h, angle = attrs
          angle = 0 unless angle
        else
        return black..black
      end

      pat = tr_color pat
      color = case pat
        when Range; [tr_color(pat.first), tr_color(pat.last)]
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

    def tr_color pat
      if pat.is_a?(String) and pat[0] == '#'
        color = pat[1..-1]
        color = color.gsub(/(.)/){$1 + '0'} if color.length == 3
        rgb *color.gsub(/(..)/).map{$1.hex}
      else
        pat
      end
    end

    def background pat, args={}
      pat = eval(pat) if pat.is_a?(String) and pat[0] != '#' and !((File.extname(pat).downcase) =~ /\.[png|jpg|gif|PNG|JPG|GIF]/)
      args[:pattern] = pat
      args = basic_attributes args

      if args[:create_real] and !args[:height].zero?
        args[:width] = 1 if args[:width] <= 0
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

    def progress args={}
      args = basic_attributes args
      args[:width] = 150 if args[:width] < 150
      pb = Gtk::ProgressBar.new
      pb.text = ' ' * (args[:width] / 4 - 2)
      @canvas.put pb, args[:left], args[:top]
      pb.show_now
      args[:real], args[:app], args[:noorder], args[:nocontrol] = pb, self, true, true
      Progress.new args
    end

    def download name, args={}, &blk
      Download.new name, args, &blk
    end

    def nolayout
      @nolayout = true
    end
    
    # Resize the app window.
    def resize new_width, new_height
      win.resize new_width, new_height
    end

    def scroll_top
      @swin.vscrollbar.value
    end

    def scroll_top=(n)
      @swin.vscrollbar.value = n
    end

    def scrolled?
      @_scroll_top ||= 0
      d = scroll_top - @_scroll_top
      @_scroll_top = scroll_top
      d.zero? ? false : d
    end

    def scrolled=(n)
      @_scroll_top = n
    end

    def pinning *eles
      eles.each do |ele|
        ele.is_a?(Basic) ? (@pinning_elements << ele) : ele.contents.each{|e| (@pinning_elements << e) if e.is_a? Basic}
      end
      @pinning_elements.uniq!
    end

    def gutter
      @swin.vscrollbar.size_request.first
    end

    def clipboard
      Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD).wait_for_text
    end

    def clipboard=(str)
      Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD).text = str
    end

    def close
      win.destroy
      Shoes.APPS.delete app
    end

    def window args={}, &blk
      args.merge! owner: self
      Shoes.app args, &blk
    end

    def flush
      Shoes.call_back_procs self
    end

    [:append, :prepend, :after, :before, :click, :hover, :leave, :release].each do |m|
      define_method m do |*args, &blk|
        top_slot.send m, *args, &blk
      end
    end

    def gray *attrs
      g, a = attrs
      g ? rgb(g*255, g*255, g*255, a) : rgb(128, 128, 128)[0..2]
    end

    def cap *line_cap
      @line_cap = case line_cap.first
        when :curve, :rect, :project
          LINECAP[line_cap.first]
        else
          @line_cap ||= LINECAP[:rect]
      end
    end
  end
end
