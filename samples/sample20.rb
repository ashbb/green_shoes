# This is a tiny flip book (aka Para-Para Manga in Japanese)
# original is http://www.paraman.net/play/preview/1258
# 
require 'green_shoes'

Shoes.app title: 'potacho', width: 175, height: 160 do
  background tan
  
  @imgs = []
  1.upto 59 do |i|
    @imgs << image(File.join(DIR, "../samples/potato_chopping/1258_s#{"%03d" % i}.gif")).hide.move(10, 10)
  end

  @imgs.first.show
  
  def potacho
    @imgs[58].hide
    a = animate 12 do |i|
      @imgs[i].show
      @imgs[i-1].hide if i > 0
      a.stop if i > 57
    end
  end
  
  button('  start  '){potacho}.move 10, 130
end
