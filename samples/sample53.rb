require '../lib/green_shoes'

Shoes.app do
  button 'Open TreeView Window' do
    Shoes.app width: 275, height: 300, treeview: true do
      $app = app
      load './treeview.rb'
    end
  end
end
