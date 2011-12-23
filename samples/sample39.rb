# An imitation of Hackety Hack opening demo.

require 'green_shoes'

Shoes.app width: 420, height: 420 do
  nostroke
  background black
  title fg(strong('Hackety Hack'), white), margin: 20

  stack do
    @m = mask{star -284, -174, 130, 500, 90}
    image File.join(DIR, "../samples/splash-hand.png") , top: 204, left: 84
  end

  animate 2 do |i|
    @m.clear{rotate i; star -284, -174, 130, 500, 90}
  end
end
