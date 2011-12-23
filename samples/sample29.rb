require 'green_shoes'

Shoes.app do
  lb = list_box items: COLORS.keys.map(&:to_s), choose: 'red' do |s|
    @o.style fill: eval(s.text)
    @p.text = s.text
  end.move(300, 0)
  @p = para
  nostroke
  @o = oval 100, 100, 100, 100
  i = 0
  button('print'){para lb.text, top: 20*(i+=1)}.move(500, 0)
end
