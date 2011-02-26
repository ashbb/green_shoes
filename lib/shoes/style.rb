class Shoes
  class App
    def style klass, args={}
      if klass == Shoes::Link
          @link_style = LINK_DEFAULT
          @link_style.sub!('single', 'none') if args[:underline] == false
          @link_style.sub!("foreground='#06E'", "foreground='#{args[:stroke]}'") if args[:stroke]
          @link_style.sub!('>', " background='#{args[:fill]}'>") if args[:fill]
          @link_style.sub!('normal', "#{args[:weight]}") if args[:weight]
      elsif klass == Shoes::LinkHover
          @linkhover_style = LINKHOVER_DEFAULT
          @linkhover_style.sub!('single', 'none') if args[:underline] == false
          @linkhover_style.sub!("foreground='#039'", "foreground='#{args[:stroke]}'") if args[:stroke]
          @linkhover_style.sub!('>', " background='#{args[:fill]}'>") if args[:fill]
          @linkhover_style.sub!('normal', "#{args[:weight]}") if args[:weight]
      end
    end
  end

  class ShapeBase
    def style args
      real.clear
      m = self.class.to_s.downcase[7..-1]
      args = @args.merge args
      obj = @app.send m, args, &args[:block]
      obj.instance_variables.each{|iv| eval "#{iv} = obj.instance_variable_get('#{iv}')"}
    end
  end

  class TextBlock
    def style args
      args[:markup] ||= @args[:markup]
      args[:size] ||= @args[:size]
      args[:font] ||= @args[:font]
      args[:align] ||= @args[:align]
      
      clear if @real
      @width = (@left + parent.width <= @app.width) ? parent.width : @app.width - @left
      @width = initials[:width] unless initials[:width].zero?
      @height = 20 if @height.zero?
      m = self.class.to_s.downcase[7..-1]
      args = [args[:markup], @args.merge({left: @left, top: @top, width: @width, height: @height, 
        create_real: true, nocontrol: true, size: args[:size], font: args[:font], align: args[:align]})]
      tb = @app.send(m, *args)
      @real, @height = tb.real, tb.height
      @args[:markup], @args[:size], @args[:font], @args[:align] = tb.markup, tb.size, tb.font, tb.align
    end
  end

  class Slot
    def style args = nil
      args ? [:width, :height].each{|s| @initials[s] = args[s] if args[s]} :
        {width: @width, height: @height}
    end
  end
end
