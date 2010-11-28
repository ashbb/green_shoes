class Shoes
  class Widget
    def self.inherited klass, &blk
      m = klass.inspect.downcase
      Shoes::App.class_eval do
        define_method m do |*args, &blk|
          klass.class_variable_set :@@app, self
          klass.new *args, &blk
        end
      end
      klass.class_eval do
        def method_missing m, *arg, &blk
         @@app.send m, *arg, &blk
        end
      end
    end
  end
end
