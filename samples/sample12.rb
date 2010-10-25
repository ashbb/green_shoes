require '../lib/green_shoes'

Shoes.app do
  background cadetblue
  r = rect 10, 10, 100, fill: red, strokewidth: 5, curve: 10, stroke: pink
  r.click{alert 'Yay!'}
  oval 10, 110, 100, 100, fill: green, strokewidth: 3
end
