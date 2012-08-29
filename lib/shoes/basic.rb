class Shoes
  class Basic
    include Mod
    def initialize args
      @initials = args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      (@app.order << self) unless @noorder or self.is_a?(EditBox) or self.is_a?(EditLine)
      (@app.cslot.contents << self) unless @nocontrol or @app.cmask
      (@app.cmask.contents << self) if @app.cmask
      if self.is_a? Native
        @app.focusables << self
        self.state = args[:state] if args[:state]
        args.delete :state
      end
      @parent = @app.cslot
      
      Basic.class_eval do
        attr_accessor *args.keys
      end

      (@width, @height = @real.size_request) if @real and !self.is_a?(TextBlock)

      set_margin
      @width += (@margin_left + @margin_right)
      @height += (@margin_top + @margin_bottom)

      @proc = nil
      [:app, :real].each{|k| args.delete k}
      @args = args
      @hovered = false
      @cleared = false
      @hidden ? (@hided, @shows = true, false) : (@hided, @shows = false, true)
      @app.fronts.push self if @front
      @app.backs.push self if @back
    end

    attr_reader :args, :shows, :initials, :cleared
    attr_accessor :parent, :hided

    def move x, y
      @app.cslot.contents -= [self]
      @app.canvas.move @real, x, y unless @hided
      move3 x, y
      self
    end

    def move2 x, y
      unless @hided
        remove
        @app.canvas.put @real, x, y
      end
      move3 x, y
    end

    def move3 x, y
      @left, @top = x, y
    end

    def remove
      @app.canvas.remove @real unless @hided
      @hided = true if self.is_a?(ShapeBase)
    end

    def hide
      @app.shcs.delete self
      @app.shcs << self
      @shows = false
      self
    end

    def show
      @app.shcs.delete self
      @app.shcs << self
      @shows = true
      @args.delete :hidden
      self
    end

    def toggle
      @app.shcs.delete self
      @app.shcs << self
      @shows = !@shows
      self
    end

    def clear flag = true
      @app.delete_mouse_events self
      @cleared = true if flag
      case self
        when Button, EditLine, EditBox, ListBox
          @app.cslot.contents.delete self
          @app.focusables.delete self
          remove
          @real = nil
        else
          @real.clear if @real
      end
    end

    alias :clear_all :clear

    def positioning x, y, max
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move3 x + parent.margin_left, max.top + parent.margin_top
        max = self if max.height < @height
      else
        move3 parent.left + parent.margin_left, max.top + max.height + parent.margin_top
        max = self
      end
      max
    end

    def fix_size
      flag = false
      set_margin
      case self
      when EditBox, Button
        if 0 < @initials[:width] and @initials[:width] <= 1.0
          @width = @parent.width * @initials[:width] - @margin_left - @margin_right
          flag = true
        end
        if 0 < @initials[:height] and @initials[:height] <= 1.0
          @height = @parent.height * @initials[:height] - @margin_top - @margin_bottom
          flag = true
        end
      when EditLine, ListBox
        if 0 < @initials[:width] and @initials[:width] <= 1.0
          @width = @parent.width * @initials[:width] - @margin_left - @margin_right
          @height = 26
          flag = true
        end
      else
      end
      if flag
        @real.set_size_request @width, @height
        move @left, @top
      end
    end
  end

  class Image < Basic
    def initialize args
      @path = args[:path]
      args.delete :path
      super args      
    end
    
    attr_reader :path
    
    def path=(name)
      @path = name
      @real.clear
      args = {width: @width, height: @height, noorder: true}
      args.merge!({hidden: true}) if @hided
      @real = @app.image(name, args).move(@left, @top).real.tap{@app.flush}
    end

    def rotate angle
      (@real_orig, @first_time = @real, true) unless @real_orig
      len = Math.sqrt @width**2 + @height**2
      surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, len, len
      context = Cairo::Context.new surface
      hlen, dleft, dtop = len/2.0, (len-width)/2.0, (len-height)/2.0
      context.save do
        pixbuf = @real_orig.pixbuf
        context.translate hlen, hlen
        context.rotate angle * Math::PI / 180
        context.translate -hlen, -hlen
        context.set_source_pixbuf pixbuf, dleft, dtop
        context.paint
      end
      remove
      @real = app.create_tmp_png surface
      app.canvas.put @real, 0, 0
      @real.show_now
      (@left -= dleft; @top -= dtop; @first_time = false) if @first_time
      move @left, @top
    end
  end

  class Pattern < Basic
    def move2 x, y
      return if @hided
      clear if @real
      @left, @top, @width, @height = parent.left, parent.top, parent.width, parent.height
      @width = @args[:width] unless @args[:width].zero?
      @height = @args[:height] unless @args[:height].zero?
      m = self.class.to_s.downcase[7..-1]
      args = eval "{#{@args.keys.map{|k| "#{k}: @#{k}"}.join(', ')}}"
      args = [@pattern, args.merge({create_real: true, nocontrol: true})]
      pt = @app.send(m, *args)
      @real = pt.real
      @width, @height = 0, 0
    end
  end
  class Background < Pattern; end
  class Border < Pattern; end

  class ShapeBase < Basic; end
  class Shape < ShapeBase; end
  class Rect < ShapeBase; end
  class Oval < ShapeBase; end
  class Line < ShapeBase; end
  class Star < ShapeBase; end
  
  class TextBlock < Basic
    def initialize args
      super
      @app.mlcs << self  if !@real or @add_mlcs
      @add_mlcs = false
    end

    def text
      @args[:markup].gsub(/\<.*?>/, '').gsub('&amp;', '&').gsub('&lt;', '<')
    end
    
    def text= s
      @args[:add_mlcs] = false
      style markup: s  if !@hided or @args[:hidden]
    end

    alias :replace :text=

    def positioning x, y, max
      self.text = @args[:markup]
      super
    end
    
    def move2 x, y
      self.text = @args[:markup]
      super
    end

    def remove
      flag = @args[:hidden] ? @shows : @hided
      @app.canvas.remove @real unless flag
    end

    def cursor=(n)
      if !n
        @app.textcursors[self][1].clear if @app.textcursors[self][1]
        @app.textcursors.delete self
      else
        @app.textcursors[self] ? (@app.textcursors[self][0] = n) : (@app.textcursors[self] = [n, nil])
      end
    end

    def cursor
      @app.textcursors[self] ? @app.textcursors[self][0] : nil
    end

    def hit x, y
      a, b, c = @app.make_textcursor_index(self, x - left, y - top + @app.scroll_top)
      a ? b : nil
    end

    def marker=(n)
      if cursor
        cindex = cursor == -1 ? text.length : cursor
        len = cindex - n
        self.text = text[0...n] + @app.bg(text[n, len], @app.yellow) + text[n+len..-1] if len > 1
      end
      @app.textmarkers[self] = n
    end
    
    def marker
      @app.textmarkers[self]
    end
    
    def highlight
      unless cursor
        return nil, 0
      else
        cindex = cursor == -1 ? text.length : cursor
        mindex = marker ? marker : cindex
        return marker, cindex - mindex
      end
    end
  end
  
  class Banner < TextBlock; end
  class Title < TextBlock; end
  class Subtitle < TextBlock; end
  class Tagline < TextBlock; end
  class Caption < TextBlock; end
  class Para < TextBlock; end
  class Inscription < TextBlock; end

  class Native < Basic
    def change obj, &blk
      obj.signal_connect "changed", &proc{parent.append{blk[self]}} if blk
    end

    def focus
      real.grab_focus
      @app.focus_ele = self
    end
    
    attr_reader :state
    
    def state=(ctl)
      real = self.is_a?(EditBox) ? @textview : @real
      case ctl
        when "disabled"
          real.sensitive = false
        when 'readonly'
          case self
            when EditLine, EditBox
              real.sensitive, real.editable = true, false
              real.modify_base Gtk::STATE_NORMAL, Gdk::Color.new(56540, 56540, 54227)
            else
          end
        when nil
          real.sensitive = true
          case self
            when EditLine, EditBox
              real.editable = true
              real.modify_base Gtk::STATE_NORMAL, Gdk::Color.new(65535, 65535, 65535)
            else
          end
        else
      end
      @state = ctl
    end
  end
  class Button < Native
    def click &blk
      real.signal_connect "clicked", &proc{parent.append{blk[self]}} if blk
    end
  end
  class ToggleButton < Button
    def checked?
      real.active?
    end
    
    def checked=(tof)
      real.active = tof
    end
  end
  class Check < ToggleButton; end
  class Radio < ToggleButton
    def focus
      self.checked = true
      super
    end
  end

  class EditLine < Native
    def text
      @real.text
    end
    
    def text=(s)
      @real.text = s
    end

    def move2 x, y
      @app.canvas.move @real, x, y
      move3 x, y
    end

    def change &blk
      super @real, &blk
    end
  end

  class EditBox < Native
    def text
      @textview.buffer.text
    end
    
    def text=(s)
      @textview.buffer.text = s.to_s
    end

    def move2 x, y
      @app.canvas.move @real, x, y
      move3 x, y
    end

    def change &blk
      super @textview.buffer, &blk
    end

    def focus
      textview.grab_focus
      @app.focus_ele = self
    end

    def accepts_tab=(t)
      textview.accepts_tab = t
    end
  end
  
  class ListBox < Native
    def text
      @entry ? @real.active_text : @items[@real.active]
    end

    def choose item
      unless @entry
        @real.active = @items.index item
      else
        @real.child.text = item.to_s
      end
    end

    def change &blk
      super @real, &blk
    end

    def items= items
      @items.length.times{real.remove_text 0}
      @items = items
      items.each{|item| real.append_text item.to_s}
    end
  end

  class Progress < Native
    def fraction
      real.fraction
    end

    def fraction= n
      real.fraction = n
    end

    undef_method :focus, :state, :state=
  end
end
