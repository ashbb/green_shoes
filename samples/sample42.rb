require 'green_shoes'

Shoes.app height: 200 do
  stack margin_left: 10 do
    title 'Progress Example'
    @p = para '0%'
  end

  pg = progress left: 10, top: 100, width: width - 20
  animate do |i|
    j = i % 100 + 1
    pg.fraction = j / 100.0
    @p.text = "%2d%" % (pg.fraction * 100)
  end
end
