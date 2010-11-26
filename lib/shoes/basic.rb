class Shoes
  class Basic
    def initialize args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      (@app.order << self) unless @noorder
      (@app.cslot.contents << self) unless @nocontrol or @app.cmask
      (@app.cmask.contents << self) if @app.cmask
      @parent = @app.cslot
      
      Basic.class_eval do
        attr_accessor *args.keys
      end

      (@width, @height = @real.size_request) if @real and !self.is_a?(TextBlock)

      @margin ||= [0, 0, 0, 0]
      @margin = [@margin, @margin, @margin, @margin] if @margin.is_a? Integer
      margin_left, margin_top, margin_right, margin_bottom = @margin
      @margin_left ||= margin_left
      @margin_top ||= margin_top
      @margin_right ||= margin_right
      @margin_bottom ||= margin_bottom
      @width += (@margin_left + @margin_right)
      @height += (@margin_top + @margin_bottom)

      @proc = nil
      [:app, :real].each{|k| args.delete k}
      @args = args
      @hided, @shows = false, true
    end

    attr_reader :parent, :click_proc, :release_proc, :args, :shows, :margin_left, :margin_top, :margin_right, :margin_bottom
    attr_accessor :hided

    def move x, y
      @app.cslot.contents -= [self]
      @app.canvas.move @real, x, y
      move3 x, y
      self
    end

    def move2 x, y
      remove unless @hided
      @app.canvas.put @real, x, y
      move3 x, y
    end

    def move3 x, y
      @left, @top = x, y
    end

    def remove
      @app.canvas.remove @real unless @hided
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
      self
    end

    def toggle
      @app.shcs.delete self
      @app.shcs << self
      @shows = !@shows
      self
    end

    def clear
      @app.mccs.delete(self); @app.mrcs.delete(self); @app.mmcs.delete(self)
      @real.clear
    end

    def positioning x, y, max
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move3 x, max.top
        max = self if max.height < @height
      else
        move3 parent.left, max.top + max.height
        max = self
      end
      max
    end

    def click &blk
      @click_proc = blk
      @app.mccs << self
    end
    
    def release &blk
      @release_proc = blk
      @app.mrcs << self
    end
    
    def style args
      clear
      @args[:nocontrol] = @args[:noorder] = true
      @real =  eval "@app.#{self.class.to_s.downcase[7..-1]}(#{@args.merge args }).real"
    end
  end

  class Image < Basic; end
  class Button < Basic; end

  class Pattern < Basic
    def move2 x, y
      return if @hided
      clear if @real
      @left, @top, @width, @height = parent.left, parent.top, parent.width, parent.height
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

  class Shape < Basic; end
  class Rect < Shape; end
  class Oval < Shape; end
  
  class TextBlock < Basic
    def initialize args
      super
      @app.mlcs << self  unless @real
    end

    def text
      @args[:markup]
    end
    
    def text= s
      clear if @real
      @width = (@left + parent.width <= @app.width) ? parent.width : @app.width - @left
      @height = 20 if @height.zero?
      m = self.class.to_s.downcase[7..-1]
      args = [s, @args.merge({left: @left, top: @top, width: @width, height: @height, create_real: true, nocontrol: true})]
      tb = @app.send(m, *args)
      @real, @height = tb.real, tb.height
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
  end
  
  class Banner < TextBlock; end
  class Title < TextBlock; end
  class Subtitle < TextBlock; end
  class Tagline < TextBlock; end
  class Caption < TextBlock; end
  class Para < TextBlock; end
  class Inscription < TextBlock; end

  class EditLine < Basic
    def text
      @real.text
    end

    def move2 x, y
      @app.canvas.move @real, x, y
      move3 x, y
    end
  end
  
  class ListBox < Basic
    def text
      @items[@real.active]
    end
  end
end
