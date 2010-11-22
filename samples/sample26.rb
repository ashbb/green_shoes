require '../lib/green_shoes'

Shoes.app width: 450, height: 150 do
  strokewidth 4
  rect 0, 0, 450, 150
  20.times do |i|
    stroke rgb((0.0..0.5).rand, (0.0..1.0).rand, (0.0..0.3).rand)
    line 0, i * 5, 400, i * 8
  end
  
  mask do
    title strong("<span size='#{82*1024}'>Shoes</span>"), left: 50
  end
end
