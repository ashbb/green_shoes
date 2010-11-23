require '../lib/green_shoes'

Shoes.app width: 450, height: 150 do
  background black
  strokewidth 4

  paint_lines = proc do
    20.times do |i|
      stroke rgb((0.0..0.5).rand, (0.0..1.0).rand, (0.0..0.3).rand)
      line 0, i * 5, 400, i * 8
    end
  end

  s = stack do
    mask do
      title strong("<span size='#{82*1024}'>Shoes</span>"), left: 50
    end
  end

  animate(5){s.clear{paint_lines.call}}
end
