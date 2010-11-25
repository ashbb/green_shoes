require '../lib/green_shoes'

Shoes.app do
  button 'go' do
    p = para 0, top: 30
    a = every do |i|
      j = i*20
      p.text = i.to_s
      para i.to_s, left: j*2, top: 30
      oval 100+j, 100+j, 10, 10
      a.stop if i > 8
    end

    timer 10 do
      p.text = 'hello'
      para 'green shoes', top: 200
    end
  end
end
