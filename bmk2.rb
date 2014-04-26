require 'yaml'
require 'gosu'

class TextField < Gosu::TextInput
  # Some constants that define our appearance.
  INACTIVE_COLOR  = 0xcc666666
  ACTIVE_COLOR    = 0xccff6666
  SELECTION_COLOR = 0xcc0000ff
  CARET_COLOR     = 0xffffffff
  PADDING = 5

  attr_reader :x, :y

  def initialize(window, font, x, y)
    # TextInput's constructor doesn't expect any arguments.
    super()

    @window, @font, @x, @y = window, font, x, y

    # Start with a self-explanatory text in each field.
    self.text = "Click to change text"
  end

  # Example filter method. You can truncate the text to employ a length limit (watch out
  # with Ruby 1.8 and UTF-8!), limit the text to certain characters etc.
  def filter text
    text.upcase
  end

  def draw
    # Depending on whether this is the currently selected input or not, change the
    # background's color.
    if @window.text_input == self then
      background_color = ACTIVE_COLOR
    else
      background_color = INACTIVE_COLOR
    end
    @window.draw_quad(x - PADDING,         y - PADDING,          background_color,
                      x + width + PADDING, y - PADDING,          background_color,
                      x - PADDING,         y + height + PADDING, background_color,
                      x + width + PADDING, y + height + PADDING, background_color, 0)

    # Calculate the position of the caret and the selection start.
    pos_x = x + @font.text_width(self.text[0...self.caret_pos])
    sel_x = x + @font.text_width(self.text[0...self.selection_start])

    # Draw the selection background, if any; if not, sel_x and pos_x will be
    # the same value, making this quad empty.
    @window.draw_quad(sel_x, y,          SELECTION_COLOR,
                      pos_x, y,          SELECTION_COLOR,
                      sel_x, y + height, SELECTION_COLOR,
                      pos_x, y + height, SELECTION_COLOR, 0)

    # Draw the caret; again, only if this is the currently selected field.
    if @window.text_input == self then
      @window.draw_line(pos_x, y,          CARET_COLOR,
                        pos_x, y + height, CARET_COLOR, 0)
    end

    # Finally, draw the text itself!
    @font.draw(self.text, x, y, 0)
  end

  # This text field grows with the text that's being entered.
  # (Usually one would use clip_to and scroll around on the text field.)
  def width
    @font.text_width(self.text)
  end

  def height
    @font.height
  end

  # Hit-test for selecting a text field with the mouse.
  def under_point?(mouse_x, mouse_y)
    mouse_x > x - PADDING and mouse_x < x + width + PADDING and
      mouse_y > y - PADDING and mouse_y < y + height + PADDING
  end

  # Tries to move the caret to the position specifies by mouse_x
  def move_caret(mouse_x)
    # Test character by character
    1.upto(self.text.length) do |i|
      if mouse_x < x + @font.text_width(text[0...i]) then
        self.caret_pos = self.selection_start = i - 1;
        return
      end
    end
    # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = self.text.length
  end
end


class ScoreKeeper

  attr_accessor :data
  attr_accessor :filename

  def initialize(filename)
    self.filename = filename
    self.data = YAML::load_file(filename)['highscores']
    if data.nil?
      self.data = {}
    end
  end

  def get_score(name)
    data[name] || 0
  end

  def set_score(name, score)
    data[name] = score
  end

  def save_scores
    File.open(filename, 'w') do |f|
      f.write({ 'highscores' => data }.to_yaml)
    end
  end
end


class TextInputWindow < Gosu::Window
  def initialize
    super(300, 200, false)
    self.caption = "Text Input Example"

    font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    # Set up an array of three text fields.
    @text_fields = Array.new(3) { |index| TextField.new(self, font, 50, 30 + index * 50) }

    @cursor = Gosu::Image.new(self, "media/Cursor.png", false)
  end

  def draw
    @text_fields.each { |tf| tf.draw }
    @cursor.draw(mouse_x, mouse_y, 0)
  end

  def button_down(id)
    if id == Gosu::KbTab then
      # Tab key will not be 'eaten' by text fields; use for switching through
      # text fields.
      index = @text_fields.index(self.text_input) || -1
      self.text_input = @text_fields[(index + 1) % @text_fields.size]
    elsif id == Gosu::KbEscape then
      # Escape key will not be 'eaten' by text fields; use for deselecting.
      if self.text_input then
        self.text_input = nil
      else
        close
      end
    elsif id == Gosu::MsLeft then
      # Mouse click: Select text field based on mouse position.
      self.text_input = @text_fields.find { |tf| tf.under_point?(mouse_x, mouse_y) }
      # Advanced: Move caret to clicked position
      self.text_input.move_caret(mouse_x) unless self.text_input.nil?
    end
  end
end


class ButtonMashWindow < Gosu::Window

	def initialize
		super(600,600,false)
		self.caption = "ButtonmashKing"
		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
		@cursor = Gosu::Image.new(self, "Media/cursor.png")
		@text_field = TextField.new(self, @font, 50, 30)
		@counter = 0
	end

	def update

	end

	def draw
		@text_field.draw
		@cursor.draw(mouse_x, mouse_y, 0)
	 	@font.draw(@counter, 0, 0, 1)
	end

	def button_down(id)
      if id == Gosu::KbEscape
      	if @text_input
      		@text_input = nil
      	end
      end


      if id == Gosu::MsLeft
        if @text_field.under_point?(mouse_x, mouse_y)
        	@text_input = @text_field
        end

        @text_input.move_caret(mouse_x) unless @text_input.nil?

      end
	end

	def button_down(id)
		if id == Gosu::KbLeft
			@counter += 1
		end

		if id == Gosu::KbRight
			@counter += 1
		end
	end

end

window = ButtonMashWindow.new
window.show
