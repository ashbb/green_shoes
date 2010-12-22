class Shoes
  class Mask
    def initialize app, &blk
      @app = app
      @parent = app.cslot
      @real = nil
      app.cslot.masked = true
      mask_block_call &blk
    end

    attr_reader :parent
    attr_accessor :contents, :real

    def clear &blk
      @real.clear
      @contents.each &:clear
      mask_block_call &blk
      Shoes.call_back_procs @app
    end

    def mask_block_call &blk
      @contents = []
      @app.cmask = self
      blk.call if blk
      @app.cmask = nil
      @contents.each &:hide
    end
  end
end