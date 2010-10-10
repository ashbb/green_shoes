require '../lib/green_shoes'

Shoes.app width: 300, height: 300 do
  flow do
    10.times do |i|
      flow(width: 0.5, height: 30){background (forestgreen.push 0.1*(i+1))}
      flow(width: 0.5, height: 30){background (orangered.push 1.0 - 0.1*i)}
    end
  end
end
