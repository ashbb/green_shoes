class Shoes
  class App
    [[:code, :tt], [:del, :s], [:em, :i], [:ins, :u], [:strong, :b], [:sub, :sub], [:sup, :sup]].each do |m, tag|
      define_method m do |str|
        "<#{tag}>#{str}</#{tag}>"
      end
    end

    [[:bg, :background], [:fg, :foreground]].each do |m, tag|
      define_method m do |str, color|
        rgb = color[0, 3].map{|e| (e*255.0).to_i}.map{|i| sprintf("%#02X", i)[-2,2]}.join
        "<span #{tag}='##{rgb}'>#{str}</span>"
      end
    end
  end
end
