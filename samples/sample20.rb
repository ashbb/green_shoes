# This is a tiny flip book (aka Para-Para Manga in Japanese)
# original is http://www.paraman.net/play/preview/1258
# 
require '../lib/green_shoes'

Shoes.app title: 'potacho', width: 175, height: 160 do
  background tan
  
  @imgs = []
  1.upto 60 do |i|
    @imgs << image("./potato_chopping/1258_s#{"%03d" % i}.gif").hide.move(10, 10)
  end

  @imgs.first.show
  
  def potacho
    @imgs[59].hide
    a = animate 12 do |i|
      @imgs[i].show
      @imgs[i-1].hide if i > 0
      a.stop if i > 58
    end
  end
  
  button('  start  '){potacho}.move 10, 130
end
