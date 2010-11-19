require '../lib/green_shoes'

Shoes.app width: 400, height: 400 do
  background yellow
  rect 0, 0, 100, 100
  rect 100, 100, 100, 100
  rect 200, 200, 100, 100
  rect 0, 200, 100, 100
  rect 200, 0, 100, 100
  stroke '../static/gshoes-icon.png'
  strokewidth 10
  line 355, 180, 5, 111, strokewidth: 20
  stroke red
  line 0, 0, 100, 0
  line 0, 100, 0, 0
  line 300, 200, 200, 200
  line 100, 200, 200, 100
  stroke white
  line 200, 200, 200, 300
  line 300, 200, 200, 100
end
