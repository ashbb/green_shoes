require '../lib/green_shoes'

class Hello < Shoes::Widget
  def initialize word= 'hi', &blk
    oval 100, 100, 100
    para word
    blk.call self if blk
  end

  def go where
    para where
  end
end

Shoes.app do
  hello ('hello'){|s| s.go 'go to Japan'}
end
