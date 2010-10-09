class Shoes
  class Basic
    def initialize args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      (@app.cslot.contents << self) unless @nocontrol
      @parent = @app.cslot
      
      Basic.class_eval do
        attr_accessor *args.keys
      end

      @width, @height = @real.size_request
    end

    attr_reader :parent

    def move x, y
      @app.cslot.contents -= [self]
      move2 x, y
    end

    def move2 x, y
      @app.canvas.move @real, x, y
      @left, @top = x, y
    end

    def remove
      @app.canvas.remove @real
    end

    def positioning x, y, max
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move2 x, max.top
        max = self if max.height < @height
      else
        move2 parent.left, max.top + max.height
        max = self
      end
      max
    end
  end

  class Image < Basic; end
  class Button < Basic; end
  class Background < Basic; end
  class Shape < Basic
    def initialize args
      super
    @app.cslot.contents -= [self]
    end
  end

  class Para < Basic
    def text= s
      @real.set_size_request 0, 0
      @real.hide
      @real = nil
      @real = @app.para(s, left: left, top: top, nocontrol: true).real
    end
  end

  class EditLine < Basic
    def text
      @real.text
    end
  end
end
