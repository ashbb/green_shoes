class Shoes
  class Mask
    def initialize app, &blk
      @parent = app.cslot
      @contents = []
      app.cslot.masked = true
      app.cmask = self
      blk.call if blk
      app.cmask = nil
      @contents.each &:hide
    end
    attr_reader :parent
    attr_accessor :contents
  end
end