require 'green_shoes'

titles = ['True or False', 'Count', 'bla bla bla']
tables = [[[true, 4, 'Cleaning Supplies'], [true, 1, 'Paper Towels'], [true, 3, 'Toilet Paper']],
          [[true, 7, 'Food'], [true, 2, 'Bread'], 
           [[false, 1, 'Butter'], [[true, 2, 'Color'], [false, 1, 'red'], [true, 1, 'blue']], [false, 1, 'Shop'], [true, 1, 'City']], 
           [true, 1, 'Milk'], [false, 3, 'Chips'], [true, 4, 'Soda']],
          [[true, 40, 'Cleaning Supplies'], [true, 10, 'Paper Towels'], [true, 30, 'Toilet Paper']]]

Shoes.app do
  button 'Open TreeView Window' do
    window width: 300, height: 400, treeview: true do
      tree_view titles, tables do |tv|
        owner.append do
          owner.para [tv.true_or_false, tv.count, tv.bla_bla_bla]
        end
      end
    end
  end
end
