require '../shoes'
Shoes.app do
  20.times{|i| button "hello%02d" % i}
end