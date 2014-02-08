require 'curses'
require 'yaml'


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

class ButtonMash
  HIGHSCORE_FILENAME = 'highscore'
	DEFAULT_DIFFICULTY = "1"
	DIFFICULTY_TIME = { "1" => 40, "2" => 30, "3" => 20, "4" => 10, "5" => 1 }

	attr_reader :count
  attr_reader :name
  attr_reader :score_keeper
	def initialize
      @count = 0
      @score_keeper = ScoreKeeper.new(HIGHSCORE_FILENAME)
	end

	def increase_count
		@count += 1
	end

	def show_intro
      clear
      puts "Welcome Young Button Masher...Are You Ready To Mash?"
      puts "What Is Your Name?"
      @name = gets.strip
      puts "How Extreme Are You? 1,2,3,4"
    end

    def show_finalscore
    	clear
		puts "You Got: #{count}"
    puts "Your Highschore was: #{score_keeper.get_score(name)}"
		sleep 5
	end
    def get_difficulty_time(difficulty)
    	DIFFICULTY_TIME[difficulty] || DIFFICULTY_TIME[DEFAULT_DIFFICULTY]
    end
    def curses_start
    	Curses.noecho # do not show typed keys
		Curses.init_screen
	    Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
	end

	def run!
		show_intro

        diff = gets.strip
        curses_start
        start_time = Time.now

        while (Time.now - start_time) <= get_difficulty_time(diff)  do
        	case Curses.getch
  			when Curses::Key::RIGHT
    			increase_count
    			Curses.setpos(0,0)
    			Curses.addstr("#{count}")
  			when Curses::Key::LEFT
   				increase_count
    			Curses.setpos(0,0)
    			Curses.addstr("#{count}")
  			end
  		end

      if score_keeper.get_score(name) > count
        clear
        puts "Maybe Next Time!"
      else
        puts "Setting score"
      score_keeper.set_score(name, count)
    end

      score_keeper.save_scores
      show_finalscore
	end

  def clear
	system("clear")
  end
end

ButtonMash.new.run!

