require 'green_shoes'

Shoes.app width: 400, height: 300 do
  el = edit_line text: 'hello'do |s|
    @msg.text = s.text
  end
  button('move at random'){@msg.move rand(200), 50 + rand(200)}
  @msg = para el.text
end
