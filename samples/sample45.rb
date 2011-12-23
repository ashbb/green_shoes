require 'green_shoes'

Shoes.app height: 200 do
  title 'Hello Green Shoes'
  font 'Coolvetica'
  title 'Hello Green Shoes'
  title 'Hello Green Shoes', font: 'Lucida console'
  nolayout
  font nil
  para 'sans (default)', left: 400, top: 30
  para 'Coolvetica', left: 400, top: 92
  para 'Lucida Console', left: 470, top: 155
end
