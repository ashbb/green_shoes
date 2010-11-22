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

      @masked = false
      @parent = @app.cslot
      @app.cslot = self
      @contents = []
      (@parent.contents << self) unless @nocontrol
      if block_given?
        yield
        @app.cslot = @parent
      else
        @left = @top = 0
      end
    end

    attr_accessor :contents, :masked
    attr_reader :parent, :initials

    def move3 x, y
      @left, @top = x, y
    end

    def positioning x, y, max
      @width = (parent.width * @initials[:width]).to_i if @initials[:width].is_a? Float
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move3 x, max.top
        @height = Shoes.contents_alignment self
        max = self if max.height < @height
      else
        move3 parent.left, max.top + max.height
        @height = Shoes.contents_alignment self
        max = self
      end
      max.height = @height = @initials[:height] unless @initials[:height].zero?
      max
    end
    
    def clear &blk
      @contents.each &:clear
      if blk
        args = {}
        initials.keys.each{|k| args[k] = instance_variable_get "@#{k}"}
	args[:nocontrol] = true
        tmp = self.is_a?(Stack) ? Stack.new(@app.slot_attributes(args), &blk) : Flow.new(@app.slot_attributes(args), &blk)
        self.contents = tmp.contents
        Shoes.call_back_procs @app
        Shoes.set_cursor_type @app
      end
    end
  end

  class Stack < Slot; end
  class Flow < Slot; end
end