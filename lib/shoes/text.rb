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
        rgb = color[0, 3].map{|e| (e*255.0).to_i}.map{|i| sprintf("%02X", i)[-2,2]}.join
        "<span #{tag}='##{rgb}'>#{str}</span>"
      end
    end

    def link str, arg = {}, &blk
      Link.new "#{@link_style}#{str}</span>", arg, &blk
    end

    def font name
      @font_family = name
    end

    def span str, args={}
      tmp = args.map do |k, v|
        v *= 1000 if v.is_a?(Integer) && k != :weight
        (v = v == 'single' ? 'yes' : 'no') if k == :strikethrough
        k = SPAN_FORM[k] if SPAN_FORM[k]
        if k.to_s.index('_color') and v.is_a?(Array)
          v = v.map{|x| (x * 255).to_i} if v[0].is_a?(Float)
          v = ("#%2s%2s%2s" % v.map{|x| x.to_s 16}).gsub(' ', '0')
        end
        [k, v]
      end
      form = tmp.map{|k, v| "#{k}='#{v}'"}.join(' ')
      "<span #{form}>#{str}</span>"
    end
  end

  class Text
    def initialize str
      @to_s = str
    end
    attr_reader :to_s
  end

  class Link < Text
    def initialize str, arg, &blk
      @link_proc = if blk
        blk
      elsif arg[:click].is_a? String
        proc{Shoes.APPS.first.app.visit arg[:click]}
      elsif arg[:click].nil?
        proc{}
      else
        arg[:click]
      end

      @pos, @index, @link_hover = nil, nil, false
      super str
    end
    attr_reader :link_proc
    attr_accessor :pos, :index, :link_hover
  end

  class LinkHover < Text; end
end
