require '../lib/green_shoes'

Shoes.app do
  10.times do |i|
    button "hello#{i}"
    image '../static/gshoes-icon.png'
    edit_line
  end
end
