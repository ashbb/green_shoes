class Shoes
  def self.url page, m
    klass = self
    $urls[page] = proc do |s|
      klass.class_eval do
        define_method :method_missing do |m, *args, &blk|
          s.send m, *args, &blk
        end
      end
      klass.new.send m
    end
  end
end
