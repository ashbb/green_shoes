class Shoes
  class App
    def style klass, args={}
      if klass == Shoes::Link
        @link_style = LINK_DEFAULT.dup
        @link_style.sub!('single', 'none') if args[:underline] == false
        @link_style.sub!("foreground='#06E'", "foreground='#{args[:stroke]}'") if args[:stroke]
        @link_style.sub!('>', " background='#{args[:fill]}'>") if args[:fill]
        @link_style.sub!('normal', "#{args[:weight]}") if args[:weight]
      elsif klass == Shoes::LinkHover
        @linkhover_style = LINKHOVER_DEFAULT.dup
        @linkhover_style.sub!('single', 'none') if args[:underline] == false
        @linkhover_style.sub!("foreground='#039'", "foreground='#{args[:stroke]}'") if args[:stroke]
        @linkhover_style.sub!('>', " background='#{args[:fill]}'>") if args[:fill]
        @linkhover_style.sub!('normal', "#{args[:weight]}") if args[:weight]
      elsif klass.superclass == Shoes::TextBlock or klass == Shoes::Image
        eval("#{klass.to_s[7..-1].upcase}_DEFAULT").clear.merge! args
      end
    end
  end

  class ShapeBase
    def style args
      args.each{|k, v| send("#{k}=", v) if self.class.method_defined? "#{k}="}
      real.clear
      @args[:nocontrol] = @args[:noorder] = true
      m = self.class.to_s.downcase[7..-1]
      args = @args.merge args
      @real = @app.send(m, args, &args[:block]).real
    end
  end

  class Pattern
    def style args
      real.clear if real
      args[:pattern] ||= @pattern
      m = self.class.to_s.downcase[7..-1]
      args = @args.merge args
      obj = @app.send m, args[:pattern], args, &args[:block]
      obj.instance_variables.each{|iv| eval "#{iv} = obj.instance_variable_get('#{iv}')"}
    end
  end

  class TextBlock
    def style args
      args[:markup] ||= @args[:markup]
      args[:size] ||= @args[:size]
      args[:font] ||= @args[:font]
      args[:align] ||= @args[:align]
      
      clear false if @real
      @width = (@left + parent.width <= @app.width) ? parent.width : @app.width - @left
      @width = initials[:width] unless initials[:width].zero?
      @height = 20 if @height.zero?
      m = self.class.to_s.downcase[7..-1]
      args = [args[:markup], @args.merge({left: @left, top: @top, width: @width, height: @height, 
        create_real: true, nocontrol: true, size: args[:size], font: args[:font], align: args[:align]})]
      tb = @app.send(m, *args)
      @real, @height = tb.real, tb.height
      @args[:markup], @args[:size], @args[:font], @args[:align] = tb.markup, tb.size, tb.font, tb.align
      @markup, @size, @font, @align = @args[:markup], @args[:size], @args[:font], @args[:align]
    end
  end

  class Slot
    def style args = nil
      args ? [:width, :height].each{|s| @initials[s] = args[s] if args[s]} :
        {width: @width, height: @height}
    end
  end

  class Basic
    def style args = nil
      return {width: @width, height: @height} unless args
      args[:width] ||= @width
      args[:height] ||= @height
      case self
        when Button, EditBox, EditLine, ListBox
          real.set_size_request args[:width], args[:height]
          @height = args[:height]
        when Progress
          real.text = ' ' * (args[:width] / 4 - 2)
        else
      end
      @width = args[:width]
    end
  end
end
