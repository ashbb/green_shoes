# The following code was quoted from http://ruby-gnome2.sourceforge.jp/hiki.cgi?tut-gtk2-treev-trees
# and edited a little bit for Green Shoes

def setup_tree_view(treeview)
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new("Buy", renderer, "text" => $buy_index)
  treeview.append_column(column)
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new("Count", renderer, "text" => $qty_index)
  treeview.append_column(column) 
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new("Product", renderer, "text" => $prod_index)
  treeview.append_column(column)
end

class GroceryItem
  attr_accessor :product_type, :buy, :quantity, :product
  def initialize(t,b,q,p)
    @product_type, @buy, @quantity, @product = t, b, q, p
  end
end
$buy_index = 0; $qty_index = 1; $prod_index = 2
$p_category = 0; $p_child = 1

list = Array.new
list[0] = GroceryItem.new($p_category, true,  0, "Cleaning Supplies")
list[1] = GroceryItem.new($p_child,    true,  1, "Paper Towels")
list[2] = GroceryItem.new($p_child,    true,  3, "Toilet Paper")
list[3] = GroceryItem.new($p_category, true,  0, "Food")
list[4] = GroceryItem.new($p_child,    true,  2, "Bread")
list[5] = GroceryItem.new($p_child,    false, 1, "Butter")
list[6] = GroceryItem.new($p_child,    true,  1, "Milk")
list[7] = GroceryItem.new($p_child,    false, 3, "Chips")
list[8] = GroceryItem.new($p_child,    true,  4, "Soda")

setup_tree_view($app.canvas)

store = Gtk::TreeStore.new(TrueClass, Integer, String)
parent = child = nil

list.each_with_index do |e, i|
  if (e.product_type == $p_category)
    j = i + 1
    while j < list.size && list[j].product_type != $p_category
      list[i].quantity += list[j].quantity if list[j].buy
      j += 1
    end
    parent = store.append(nil)
    parent[$buy_index]  = list[i].buy
    parent[$qty_index]  = list[i].quantity
    parent[$prod_index] = list[i].product
  else
    child = store.append(parent)
    child[$buy_index]  = list[i].buy
    child[$qty_index]  = list[i].quantity
    child[$prod_index] = list[i].product
  end
end

$app.canvas.model = store
