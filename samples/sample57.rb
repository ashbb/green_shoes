require 'green_shoes'

Shoes.app do
  background deeppink
  title fg " Happy coding!", white
  code = IO.read File.join DIR, '../samples/sample28.rb'
  cb = code_box text: code, width: 500, height: 400, margin_left: 50
  button('  run  '){eval cb.text}.move 500, 30
end
