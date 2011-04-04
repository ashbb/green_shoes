class Shoes
  class Widget
    def self.inherited klass, &blk
      m = klass.inspect.downcase.split('::').last
      Shoes::App.class_eval do
        define_method m do |*args, &blk|
          klass.class_variable_set :@@__app__, self
          klass.new *args, &blk
        end
      end
      klass.class_eval do
        define_method :method_missing do |*args, &blk|
          klass.class_variable_get(:@@__app__).send *args, &blk
        end
      end
    end
  end
end
