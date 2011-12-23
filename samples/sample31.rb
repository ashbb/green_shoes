require 'green_shoes'

Shoes.app do
  strokewidth 3
  eles = []
  eles << oval(0, 0, 300, angle: 90)
  eles << rect(50, 50, 350, 350, curve: 10)
  eles << star(100, 100, 30, 200, 180)
  eles << shape(left: 200, top: 200){
    move_to 200, 150
    line_to 200, 100
    curve_to 100, 100, 20, 200, 100, 50
    line_to 20, 100
  }
  eles << line(100, 100, 480, 480)

  button 'change colors' do
    eles.each do |ele|
      colors = []
      4.times{colors << send(COLORS.keys[rand(COLORS.keys.size)])}
      ele.style fill: colors[0]..colors[1], stroke: colors[2]..colors[3]
    end
  end
end
