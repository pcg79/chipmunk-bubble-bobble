class Bubble
  attr_reader :body, :shape

  @@impulse = 50.0 # impulse x

  def initialize(space, animation)
    @body  = CP::Body.new(1.0, 1.0)
    @shape = CP::Shape::Circle.new(@body, 13.0, CP::Vec2.new(0,0))
    @animation = animation

    @shape.body.p = CP::Vec2.new(104, 403)      # position
    @shape.e = 0.5 #elasticity
    @shape.u = 0.5 #friction
    @shape.collision_type=:bubble
    @shape.body.apply_impulse(CP::Vec2.new( @@impulse, 0.0 ), CP::Vec2.new(0.1, 0))
    space.add_body(@body)
    space.add_shape(@shape)
  end

  def draw
    img = @animation[Gosu::milliseconds / 100 % @animation.size];

    img.draw_rot(@shape.body.p.x, @shape.body.p.y, ZOrder::Bubble, @shape.body.a.radians_to_gosu, 0.5, 0.5, 1, 1)
  end

  def self.impulse=(value)
    @@impulse = value
  end

  def self.impulse
    @@impulse || 0
  end
end
