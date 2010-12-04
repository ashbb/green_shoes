require '../lib/green_shoes'

Shoes.app title: 'Green Shoes New Logo Icon!', width: 300, height: 420 do
  stack do
    image '../static/gshoes-icon.png'
    flow do
      image '../static/gshoes-icon.png'
      image '../static/gshoes-icon.png'
    end
    image '../static/gshoes-icon.png'
    para ' ' * 30, 'Created by Zak'
  end
end
