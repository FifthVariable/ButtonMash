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
	DIFFICULTY_TIME = { "no" => 40, "maybe" => 30, "kinda" => 20, "yes" => 10, "hacks" => 1 }

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
	
	def show_countdown
		sleep 1
		clear
		puts "5"
		sleep 1
		clear
		puts "4"
		sleep 1
		clear
		puts "3"
		sleep 1
		clear
		puts "2"
		sleep 1
		clear 
		puts "1"
		sleep 1
		clear
		puts "Go!"
		sleep 0.4
	end
	def show_signup
	  if @signup == "yes"
	    puts "Welcome Newbie! Please Input A Username: "
		@name = gets.strip
	  end
	  
	  if @signup == "no"
		puts "Identification Please:"
		puts "Username: "
		@name = gets.strip
	  end
	end
	def show_intro
      clear
      puts "For Years, The World Has Been Searching For A ButtonMash King...Will It Be You?"
      puts "Are you new to the Mash? yes,no"
	  @signup = gets.strip
	  show_signup
      puts "Do you even mash? no,maybe,kinda,yes"
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
		
		show_countdown
		
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
        puts "    Maybe Next Time!"
      else
        puts "    New HighScore!"
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

