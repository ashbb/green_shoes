module Shoes
  class Basic
    def initialize ele
      @real = ele
    end
    attr_reader :real

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
end
