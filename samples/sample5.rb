require '../shoes'

Shoes.app width: 295, height: 28 do
  5.times do |i|
    i+=1
    button("sample#{i}"){load "./sample#{i}.rb"}
  end
end
