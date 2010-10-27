require '../lib/green_shoes'

Shoes.app width: 300, height: 300 do
  background cadetblue
  r = rect 100, 10, 100, fill: red, strokewidth: 5, curve: 10, stroke: pink
  r.click{alert 'Yay!'}
  o = oval 100, 110, 100, 100, fill: green, strokewidth: 3, stroke: white
  para 'Green Shoes!!', left: 100, top: 70

  colors = [pink, green, crimson, orangered]
  j = 0
  a = animate 1 do |i|
    unless j == i
      r.style fill: colors[rand 4]
      o.style stroke: colors[rand 4]
      j = i
    end
  end

  button('pause'){a.pause}
end
