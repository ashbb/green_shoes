class Shoes
  class Download
    def initialize name, args, &blk
      require 'open-uri'
      Thread.new do
        open name,
          content_length_proc: lambda{|len| @content_length, @started = len, true},
          progress_proc: lambda{|size| @progress = size} do |sio|
          open(args[:save], 'wb'){|fw| fw.print sio.read} if args[:save]
          blk[sio] if blk
          @finished = true
        end
      end
    end
    
    attr_reader :progress, :content_length
    
    def started?
      @started
    end
    
    def finished?
      @finished
    end
  end
end
