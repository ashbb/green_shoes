require 'green_shoes'

# The same as sample60.rb on Shoes Tutorial Note
Shoes.app :width => 300, :height => 300 do
  i = 45
  button 'new'do
    i += 5
    box = rand(2) == 0 ? rect(i, i, 20) : oval(i, i, 10)
    box.style :fill => send(COLORS.keys[rand(COLORS.keys.size)])

    @flag = false
    box.click{@flag = true; @box = box}
    box.release{@flag = false}
    motion{|left, top| @box.move(left-10, top-10) if @flag}
  end

end
