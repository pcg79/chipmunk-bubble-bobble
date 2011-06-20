require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'ZOrder'
require 'bubble'

# DTIME is basically how long each substep is.
# Lower values will increates the accuracy while higher help performance.
SUBSTEPS, DTIME = 3, (1.0 / 30.0)

class GameWindow < Gosu::Window
  def initialize
    super 512, 448, false
    self.caption = "¡Chip Munk demo!"

    @background_image = Gosu::Image.new(self, "media/bubble-bobble.png", true)
    @bubble_anim = Gosu::Image::load_tiles(self, "media/bubble.png", 36, 36, true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @blup = Gosu::Sample.new(self, "media/bubble1.ogg")
    @song = Gosu::Song.new(self, "media/bubble_bobble.mp3")
    @song.play(true)

    @bubbles = Array.new

    # Create our Space with a bit of resistance and inverted gravity.
    @space = CP::Space.new
    @space.damping = 0.6  # viscosity => i.e. a 0.9 value decrement a 10% v per second
    @space.gravity = CP::Vec2.new(0.0, -10.0)
    @space.elastic_iterations=3

    @static_body = CP::Body.new((1.0 / 0.0), (1.0 / 0.0)); # mass and inertia infinite == static body

    shapify_walls
  end

  def update
    # Perform the physics steps first
    SUBSTEPS.times do
      @space.step(DTIME)
    end

    # Destroy hidden bubbles
    @bubbles.reject!{ |bubble| bubble.body.p.y < 0 }
  end

  def draw
    @background_image.draw(0,0,ZOrder::Background)
    @font.draw("Gravity: #{@space.gravity.y}  Impulse: #{Bubble.impulse}", 180, 15, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @bubbles.each { |bubble| bubble.draw }
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape
      close
    elsif id == Gosu::Button::KbSpace
      @blup.play
      add_bubble
    elsif id == Gosu::Button::KbUp
      @space.gravity.y += 5
    elsif id == Gosu::Button::KbDown
      @space.gravity.y -= 5
    elsif id == Gosu::Button::KbRight
      Bubble.impulse += 10
    elsif id == Gosu::Button::KbLeft
      Bubble.impulse -= 10
    end

    @song.volume=@song.volume - 0.1 if id == Gosu::Button::KbPageDown && @song.volume > 0
    @song.volume=@song.volume + 0.1 if id == Gosu::Button::KbPageUp && @song.volume < 1

  end

  def add_bubble
    bubble = Bubble.new(@space, @bubble_anim)
    @bubbles <<  bubble
  end

  # Array with coordenates should be passed in clockwise order
  def draw_poly_structure(coord, group)
    verts = array_to_vec(coord)
    sp = CP::Shape::Poly.new(@static_body, verts, CP::Vec2.new(0,0) )
    sp.e = 0.9 #elasticity
    sp.u = 0.1 #friction
    sp.collision_type = group
    @space.add_shape sp
  end

  def array_to_vec(array)
    array.map do |a|
      CP::Vec2.new(a[0], a[1])
    end
  end

  #NOTE: I've added some pixels or one vector more to force the bubble to go up
  def shapify_walls
    ## horizontal first walls from left to right
    draw_poly_structure( [ [32,356], [ 111,351 ], [ 111,336 ], [ 31,336 ] ], :wall )
    draw_poly_structure( [ [144, 351], [167, 354], [191, 351], [191,336], [144,336] ], :wall )
    draw_poly_structure( [ [320, 351], [343, 354], [367, 351], [367,336], [320,336] ], :wall )
    draw_poly_structure( [ [400, 351], [480, 356], [480, 336], [400,336] ], :wall )

    ## border vertical walls
    draw_poly_structure( [ [0, 431],[31, 431], [31, 32], [0, 32] ], :wall ) # left
    draw_poly_structure( [ [480, 431],[510, 431], [510, 32], [480, 32] ], :wall ) # right
    ## border top walls
    draw_poly_structure( [ [0, 55], [143, 47], [143, 32], [0, 32] ], :wall )
    draw_poly_structure( [ [208, 47], [255, 52], [303, 47], [303, 32], [208, 32] ], :wall )
    draw_poly_structure( [ [368, 47], [511, 55], [511, 32], [368, 32] ], :wall )

    ## left middle wall(down to up)
    draw_poly_structure( [ [96, 271], [167, 276], [239, 271], [239, 256], [96, 256], ], :wall ) # horizontal 1
    draw_poly_structure( [ [96,191], [223, 191], [223, 176], [ 96, 176] ], :wall )  # horizontal 2
    draw_poly_structure( [ [96,127], [207, 127], [207, 112], [ 96, 112] ], :wall )  # horizontal 3
    draw_poly_structure( [ [80, 271], [95, 271], [95, 112], [80, 112], ], :wall )   # vertical

    ## right middle wall (down to up)
    draw_poly_structure( [ [272, 271], [351, 276], [431, 271], [431, 256], [272, 256], ], :wall )  # horizontal 1
    draw_poly_structure( [ [288,191], [416, 191], [416, 176], [288, 176], ], :wall )   # horizontal 2
    draw_poly_structure( [ [304, 127], [416, 127], [416, 112,], [304, 112], ], :wall ) # horizontal 3
    draw_poly_structure( [ [416, 271], [431, 271], [431, 112], [416, 112], ], :wall )  # vertical

  end

end


window = GameWindow.new
window.show
