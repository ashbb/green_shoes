module Shoes
  class Basic
    def initialize args
      Shoes.cslot.contents << self
      @parent = Shoes.cslot
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      
      Basic.class_eval do
        attr_accessor *args.keys
        attr_reader :parent
      end

      @width, @height = self.real.size_request
    end

    def move x, y
      Shoes.canvas.move real, x, y
      self.left, self.top = x, y
    end

    def remove
      Shoes.canvas.remove real
    end
  end

  class Image < Basic; end
  class Button < Basic; end
  class Shape < Basic; end

  class Para < Basic
    def text= s
      real.set_size_request 0, 0
      real.hide
      self.real = nil
      self.real = Shoes.para(s, left: left, top: top).real
    end
  end

  class EditLine < Basic
    def text
      real.text
    end
  end
end
