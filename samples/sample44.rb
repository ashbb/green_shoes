#
# Shoes Clock by Thomas Bell
# posted to the Shoes mailing list on 04 Dec 2007
# Original code for Red Shoes is: https://github.com/shoes/shoes/blob/master/samples/good-clock.rb
# The following is a little bit modified snippet for Green Shoes, using show and hide instead of clear.
#
require 'green_shoes'

Shoes.app height: 260, width: 250 do
  def draw_background
    background rgb(230, 240, 200)

    fill white
    stroke black
    strokewidth 4
    oval @centerx - 102, @centery - 102, 204, 204

    fill black
    nostroke
    oval @centerx - 5, @centery - 5, 10, 10

    stroke black
    strokewidth 1
    line(@centerx, @centery - 102, @centerx, @centery - 95)
    line(@centerx - 102, @centery, @centerx - 95, @centery)
    line(@centerx + 95, @centery, @centerx + 102, @centery)
    line(@centerx, @centery + 95, @centerx, @centery + 102)
  end
  
  def clock_hand(time, sw, unit=30, color=black)
    radius_local = unit == 30 ? @radius : @radius - 15
    _x = radius_local * Math.sin( time * Math::PI / unit )
    _y = radius_local * Math.cos( time * Math::PI / unit )
    stroke color
    strokewidth sw
    line @centerx, @centery, @centerx + _x, @centery - _y, hidden: true
  end
  
  @radius, @centerx, @centery = 90, 126, 140
  draw_background
  stack do
    background black
    @msg = para '', margin: 4, align: 'center'
  end
  hour, min, sec = [], [], []
  12.times{|i| 5.times{|j| hour << clock_hand(i+(j/5.0), 8, 6)}}
  60.times{|i| 4.times{|j| min << clock_hand(i+(j/4.0), 5)}}
  60.times{|i| 8.times{|j| sec << clock_hand(i+(j/8.0), 2, 30, red)}}

  animate 8 do |i|
    t = Time.new
    h, m, s, u = t.hour, t.min, t.sec, t.usec
    if i % 8 == 0
      @msg.text = fg(t.strftime("%a"), tr_color("#666")) +
        fg(t.strftime(" %b %d, %Y "), tr_color("#ccc")) +
        strong(fg(t.strftime("%I:%M"), white)) +
        fg(t.strftime(".%S"), tr_color("#666"))
    end
    t = h*5+m/12; hour[(t-1)%60].hide; hour[t%60].show
    t = m*4+s/15; min[(t-1)%240].hide; min[t%240].show 
    t = s*8+u/125000; sec.each(&:hide); sec[t%480].show  
  end
end
