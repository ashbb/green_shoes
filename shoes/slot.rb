class Shoes
  class Slot
    def initialize args={}
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      
      Slot.class_eval do
        attr_accessor *args.keys
        attr_accessor :parent, :contents, :left_end, :top_end
      end

      @left_end, @top_end = @left, @top
      @parent = @app.cslot
      @app.cslot = self
      @contents = []
      @parent.contents << self
      if block_given?
        yield
        @app.cslot = @parent
      end
    end

    def append ele
      ele.left, ele.top = left_end, top_end
      ele.move ele.left, ele.top
    end
  end

  class Stack < Slot
    def append ele
      super if ele.is_a? Basic
      self.top_end += ele.height
    end
  end

  class Flow < Slot
    def append ele
      super if ele.is_a? Basic
      self.left_end += ele.width
    end
  end
end