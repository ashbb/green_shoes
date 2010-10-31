class Shoes
  class Basic
    def initialize args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      (@app.order << self) unless @noorder
      (@app.cslot.contents << self) unless @nocontrol
      @parent = @app.cslot
      
      Basic.class_eval do
        attr_accessor *args.keys
      end

      (@width, @height = @real.size_request) if @real
      @proc = nil
      [:app, :real].each{|k| args.delete k}
      @args = args
    end

    attr_reader :parent, :click_proc, :release_proc, :args

    def move x, y
      @app.cslot.contents -= [self]
      @app.canvas.move @real, x, y
      move3 x, y
    end

    def move2 x, y
      remove
      @app.canvas.put @real, x, y
      move3 x, y
    end

    def move3 x, y
      @left, @top = x, y
    end

    def remove
      @app.canvas.remove @real
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

  class Background < Basic
    def move2 x, y
      remove if @real
      @left, @top, @width, @height = parent.left, parent.top, parent.width, parent.height
      bg = @app.background(@pattern, left: @left, top: @top, width: @width, height: @height, curve: @curve, create_real: true, nocontrol: true)
      @real = bg.real
      @width, @height = 0, 0
    end
  end

  class Shape < Basic; end
  class Rect < Shape; end
  class Oval < Shape; end
  
  class Para < Basic
    def text= s
      clear
      @real = @app.para(s, left: left, top: top, nocontrol: true).real
    end
  end

  class EditLine < Basic
    def text
      @real.text
    end

    def move2 x, y
      @app.canvas.move @real, x, y
      move3 x, y
    end
  end
end
