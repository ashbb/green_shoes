require '../lib/green_shoes'

Shoes.app width: 305, height: 460 do
  background lightskyblue

  flow do
    background green
    3.times do
      button 'button', margin: 5
      edit_line margin_top: 5
    end
  end

  image '../static/gshoes-icon.png', margin: 20, margin_left: 80
  tagline fg(em(strong('A sample for margin style.')), maroon), 
    margin: [30, 0, 0, 30]

  flow do
    background gold
    10.times{button 'button', margin: [10, 5, 0, 5]}
  end
end
