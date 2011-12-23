require 'green_shoes'

Shoes.app do
  stack do
    para DIR
    para Shoes::DIR
    para Shoes::App::DIR
    para self.class
    para Shoes.app{}.class
  end
end
