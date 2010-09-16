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
    end

    def remove
      Shoes.canvas.remove real
    end
  end

  class Image < Basic; end
  class Button < Basic; end
  class Para < Basic; end
  class Shape < Basic; end
end
