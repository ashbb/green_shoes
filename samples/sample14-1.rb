require 'green_shoes'

Shoes.app width: 520, height: 520 do
  def mk_ovals degree, color, size, mx, my, n, n1, n2, n3
    ret = []
    n.times do |i|
      current_size = n1 + size
      d = (i * n2 - degree) * Math::PI / 180
      rx = Math::cos(d) * n3
      ry = Math::sin(d) * n3
      left = -current_size/2 + rx + mx
      top = -current_size/2 + ry + my
      ret << oval(left, top, current_size, current_size, fill: color).hide
    end
    ret
  end

  degree, color, size = 0, 0.1, 0
  mx = my = 520 / 2
  blue_ovals, red_ovals = [], []
  
  nostroke
  background pink
  
  150.times do |j|
    degree += 1
    color += 0.002
    size += 1
    red_ovals << mk_ovals(-degree, red.push(color), size, mx, my, 6, 100, 60, 100)
    blue_ovals << mk_ovals(degree, blue.push(color), size, mx, my, 12, 50, 30, 150)
  end

  animate 24 do |i|
    i %= 150
    red_ovals[i-1].each &:hide; red_ovals[i].each &:show
    blue_ovals[i-1].each &:hide; blue_ovals[i].each &:show
  end
end
