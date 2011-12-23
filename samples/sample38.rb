require 'green_shoes'

Shoes.app width: 250, height: 250 do
  nofill
  animate do |i|
    clear do
      rotate 10*i
      rect 50, 50, 50, 20, stroke: green
      oval 150, 100, 50, 20, stroke: red
      star 50, 150, 5, 30, 10, stroke: blue
    end
  end
end
