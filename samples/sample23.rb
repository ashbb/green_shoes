require 'green_shoes'

Shoes.app width: 300, height: 300 do
  fname = File.join(DIR, '../static/gshoes-icon.png')
  background yellow..orange, angle: 90
  border fname, strokewidth: 20, curve: 100
  fill fname
  nostroke
  oval 100, 100, 100, 100
end
