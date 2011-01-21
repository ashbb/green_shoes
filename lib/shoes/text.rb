class Shoes
  class App
    [[:code, :tt], [:del, :s], [:em, :i], [:ins, :u], [:strong, :b], [:sub, :sub], [:sup, :sup]].each do |m, tag|
      define_method m do |*str|
        "<#{tag}>#{str.join}</#{tag}>"
      end
    end

    [[:bg, :background], [:fg, :foreground]].each do |m, tag|
      define_method m do |*str|
        color = str.pop
        str = str.join
        rgb = color[0, 3].map{|e| (e*255.0).to_i}.map{|i| sprintf("%#02X", i)[-2,2]}.join
        "<span #{tag}='##{rgb}'>#{str}</span>"
      end
    end

    def link str, &blk
      Link.new "#{LINK_DEFAULT}#{str}</span>", &blk
    end

    def font name
      @font_family = name
    end
  end

  class Text
    def initialize str
      @to_s = str
    end
    attr_reader :to_s
  end

  class Link < Text
    def initialize str, &blk
      @link_proc, @pos, @index, @link_hover = blk, nil, nil, false
      super str
    end
    attr_reader :link_proc
    attr_accessor :pos, :index, :link_hover
  end

  class LinkHover < Text; end
end
