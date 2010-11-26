require '../lib/green_shoes'

Shoes.app do
  lb = list_box items: COLORS.keys.map(&:to_s), choose: 'red' do |item|
    @o.style fill: eval(item)
    @p.text = item
  end.move(300, 0)
  @p = para
  nostroke
  @o = oval 100, 100, 100, 100
  i = 0
  button('print'){para lb.text, top: 20*(i+=1)}.move(500, 0)
end
