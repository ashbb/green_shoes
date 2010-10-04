class Shoes
  class Slot
    def initialize args={}
      @initials = args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      
      Slot.class_eval do
        attr_accessor *args.keys
      end

      @parent = @app.cslot
      @app.cslot = self
      @contents = []
      @parent.contents << self
      if block_given?
        yield
        @app.cslot = @parent
      end
    end

    attr_accessor :contents
    attr_reader :parent, :initials

    def move2 x, y
      @left, @top = x, y
    end

    def positioning x, y, max
      @width = (parent.width * @initials[:width]).to_i if @initials[:width].is_a? Float
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move2 x, max.top
        @height = Shoes.contents_alignment self
        max = self if max.height < @height
      else
        move2 parent.left, max.top + max.height
        @height = Shoes.contents_alignment self
        max = self
      end
      max
    end
  end

  class Stack < Slot; end
  class Flow < Slot; end
end