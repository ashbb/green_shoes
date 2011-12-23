require 'green_shoes'

Shoes.app width: 500, height: 100, title: 'Bloopsaphone Play Lists'do
  background mediumspringgreen..hotpink, angle: 90
  nostroke
  
  plists = Dir.glob File.join(DIR, "ext/bloops/songs/*_by_*.rb")

  i = 0
  plists.each do |list|
    y = 10 + 24 * i
    song, auther = list.split('_by_').collect{|e| File.basename(e, '.rb').gsub('_', ' ')}
    
    rect width: 480, height: 20, left: 10, top: y, fill: rgb(75, 0, 130, 0.2), curve: 5
    pos = i.zero? ? {margin_left: 20, margin_top: 10} : {margin_left: 20}
    para link(song){load list}, '   ', fg(strong(auther), white), pos
    i += 1
  end
end
