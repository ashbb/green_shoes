# Same snippet as http://shoes.heroku.com/manual/Events.html#motion{|left,top|...}

require 'green_shoes'

Shoes.app width: 200, height: 200 do
  background black
  fill white
  @circ = oval 0, 0, 100, 100
  motion do |top, left|
    @circ.move top - 50, left - 50
  end
end
