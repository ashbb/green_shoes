class Shoes
  class Slot
    include Mod
    def initialize args={}
      @initials = args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      
      Slot.class_eval do
        attr_accessor *(args.keys - [:app])
      end

      set_margin

      @radio_group = Gtk::RadioButton.new
      @masked = @hovered = false
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
    attr_reader :parent, :initials, :radio_group
    attr_writer :app

    def app &blk
      blk ? @app.instance_eval(&blk) : @app
    end

    def move3 x, y
      @left, @top = x, y
    end

    def positioning x, y, max
      @width = (parent.width * @initials[:width]).to_i if @initials[:width].is_a? Float
      @width = (parent.width + @initials[:width]) if @initials[:width] < 0
      @width -= (margin_left + margin_right)
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move3 x + parent.margin_left, max.top + parent.margin_top
        @height = Shoes.contents_alignment self
        max = self if max.height < @height
      else
        move3 parent.left + parent.margin_left, max.top + max.height + parent.margin_top
        @height = Shoes.contents_alignment self
        max = self
      end
      case @initials[:height]
      when 0
      when Float
        max.height = @height = (parent.height * @initials[:height]).to_i
      else
        max.height = @height = @initials[:height]
      end
      contents.each &:fix_size
      max
    end

    def fix_size; end
    
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

    def append &blk
      prepend contents.length, &blk
    end
    
    def prepend n = 0
      self.contents, tmp = contents[0...n], contents[n..-1]
      cslot, @app.cslot = @app.cslot, self
      yield
      self.contents += tmp
      @app.cslot = cslot
      Shoes.call_back_procs @app
    end
    
    def before e, &blk
      prepend contents.index(e).to_i, &blk
    end
    
    def after e, &blk
      n = contents.index e
      n = n ? n+1 : contents.length
      prepend n, &blk
    end
  end

  class Stack < Slot; end
  class Flow < Slot; end
end