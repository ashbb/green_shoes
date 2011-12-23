# For Christmas
require 'green_shoes'

Shoes.app width: 330, height: 300 do
  nostroke
  background black
  data = []
  5.times{data << [30+rand(10), 20+rand(200), 20+rand(200)]}

  a = animate do |i|
    rotate i*5
    clear do
      background black
      5.times{|j| star data[j][1], data[j][2], 5, data[j][0], data[j][0]/2.0, fill: gold..white, angle: 45}
      para fg(strong('Merry Christmas'), white), size: 48 if i > 30
    end
    a.stop if i > 50
  end
end
