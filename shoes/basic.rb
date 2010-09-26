module Shoes
  class Basic
    def initialize args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      @app.cslot.contents << self
      @parent = @app.cslot
      
      Basic.class_eval do
        attr_accessor *args.keys
        attr_reader :parent
      end

      @width, @height = @real.size_request
    end

    def move x, y
      @app.canvas.move @real, x, y
      @left, @top = x, y
    end

    def remove
      @app.canvas.remove @real
    end
  end

  class Image < Basic; end
  class Button < Basic; end
  class Shape < Basic; end

  class Para < Basic
    def text= s
      @real.set_size_request 0, 0
      @real.hide
      @real = nil
      @real = @app.para(s, left: left, top: top).real
    end
  end

  class EditLine < Basic
    def text
      @real.text
    end
  end
end
