require 'green_shoes'

Shoes.app do
  flow width: 0.3, height: 0.5 do
    background lawngreen
    edit_line width: 0.5, margin: 10, text: 'edit_line'
  end
  flow width: 0.4, height: 0.5 do
    background goldenrod
    edit_box width: 1.0, height: 1.0, margin: 20, text: "edit_box\n" * 3
  end
  flow width: 0.3, height: 0.5 do
    background salmon
    button 'Shoes', width: 1.0, height: 1.0, margin: 50
  end
  flow width: 1.0, height: 0.5 do
    background plum
    list_box items: %w[edit_box edit_line list_box button], width: 0.5 , margin: 20, choose: 'list_box'
  end
end
