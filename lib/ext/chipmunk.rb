begin
  require 'chipmunk'
rescue LoadError 
  require_relative 'chipmunk/chipmunk'
end

module ChipMunk
  def cp_space
    @space = CP::Space.new
    @space.damping = 0.8
    @space.gravity = vec2 0, 25
    @space
  end

  def cp_oval l, t, r, opts = {}
    b = CP::Body.new 1,1
    b.p = vec2 l, t
    @space.add_body b
    @space.add_shape CP::Shape::Circle.new(b, r, vec2(0, 0))
      
    opts = opts.merge({left: l-r-1, top: t-r-1, width: 2*r+2, height: 2*r+2, body: b, inflate: r-2})
    oval opts
  end
  
  def cp_line x0, y0, x1, y1, opts = {}
    opts[:strokewidth] = 5 unless opts[:strokewidth]
    sb = CP::Body.new 1.0/0.0, 1.0/0.0
    seg = CP::Shape::Segment.new sb, vec2(x0, y0), vec2(x1, y1), opts[:strokewidth]
    @space.add_shape seg
    line x0, y0, x1, y1, opts
  end
end

Shoes::ShapeBase.class_eval do
  def cp_move
    move args[:body].p.x.to_i - args[:inflate], args[:body].p.y.to_i - args[:inflate]
  end
end
