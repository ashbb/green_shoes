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
      @shows = true
      if block_given?
        if args[:hidden]
          @shows = false
          BASIC_ATTRIBUTES_DEFAULT.merge! hidden: true
          SLOT_ATTRIBUTES_DEFAULT.merge! hidden: true
          @hidden_flag = true unless @parent.instance_variable_get '@hidden'
        end
        yield
        if @hidden_flag
          BASIC_ATTRIBUTES_DEFAULT.delete :hidden
          SLOT_ATTRIBUTES_DEFAULT.delete :hidden
        end
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
      w = (parent.width * @initials[:width]).to_i if @initials[:width].is_a? Float
      w = (parent.width + @initials[:width]) if @initials[:width] < 0
      @width = w - (margin_left + margin_right) if w
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move3 x + parent.margin_left, max.top + parent.margin_top
        @height = Shoes.contents_alignment self
        max = self if max.height < @height
        flag = true
      else
        move3 parent.left + parent.margin_left, max.top + max.height + parent.margin_top
        @height = Shoes.contents_alignment self
        max = self
        flag = false
      end
      case @initials[:height]
      when 0
      when Float
        max.height = @height = (parent.height * @initials[:height]).to_i
      else
        max.height = @height = @initials[:height]
      end
      contents.each &:fix_size
      return max, flag
    end

    def fix_size; end
    
    def clear all = false, &blk
      all ? @contents.each(&:clear_all) : @contents.each(&:clear)
      @contents.each{|e| @app.mlcs.delete e; @app.mhcs.delete e}
      @contents = []
      if blk
        args = {}
        initials.keys.each{|k| args[k] = instance_variable_get "@#{k}"}
        args[:nocontrol] = true
        tmp = self.is_a?(Stack) ? Stack.new(@app.slot_attributes(args), &blk) : Flow.new(@app.slot_attributes(args), &blk)
        self.contents = tmp.contents
        contents.each{|e| e.parent = self if e.is_a? Basic}
        Shoes.call_back_procs @app
        Shoes.set_cursor_type @app
      end
    end

    def clear_all &blk
      @app.delete_mouse_events self
      clear true, &blk
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

    def show
      @contents.each &:show
      @shows = true
      self
    end

    def hide
      @contents.each &:hide
      @shows = false
      self
    end

    def toggle
      @shows ? hide : show
      self
    end
  end

  class Stack < Slot; end
  class Flow < Slot; end
end