require 'green_shoes'

Shoes.app title: 'Green Shoes New Logo Icon!', width: 300, height: 420 do
  stack do
    path = File.join(DIR, '../static/gshoes-icon.png')
    image path
    flow do
      image path
      image path
    end
    image path
    para ' ' * 30, 'Created by Zak'
  end
end
