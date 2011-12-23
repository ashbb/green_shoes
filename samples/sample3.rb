require 'green_shoes'

Shoes.app width: 300, height: 400 do
  fill rgb(0, 0.6, 0.9, 0.1)
  stroke rgb(0, 0.6, 0.9)
  strokewidth 0.25
  100.times do
    oval left: (-30..self.width).rand, top: (-30..self.height).rand, radius: (25..50).rand
  end
end
