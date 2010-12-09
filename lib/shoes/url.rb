class Shoes
  def self.url page, m
    klass = self
    page = /^#{page}$/
    $urls[page] = proc do |s, arg|
      klass.class_eval do
        define_method :method_missing do |m, *args, &blk|
          s.send m, *args, &blk
        end
      end
      arg ? klass.new.send(m, arg) : klass.new.send(m)
    end
  end
end
