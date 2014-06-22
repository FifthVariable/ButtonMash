require 'curses'
require 'yaml'
require 'gosu'

class GameSaver
    def initialize
      self.filename = filename
      self.data = YAML::load_file(filename)['highscores']
      if data.nil?
        self.data = {}
      end
    end

    def load_game
    end

    def save_game
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

class ButtonMash
  HIGHSCORE_FILENAME = 'highscore'
  DEFAULT_DIFFICULTY = "1"
  DIFFICULTY_TIME = { "no" => 40, "maybe" => 30, "kinda" => 20, "yes" => 10, "hacks" => 1}
  DIFFICULTY_BUTTONS = { "2" => 2.times.map { (65 + rand(26)).chr.downcase },
                         "3" => 3.times.map { (65 + rand(26)).chr.downcase },
                         "4" => 4.times.map { (65 + rand(26)).chr.downcase },
                         "5" => 5.times.map { (65 + rand(26)).chr.downcase },
                         "6" => 6.times.map { (65 + rand(26)).chr.downcase },
						 "10"=>10.times.map { (65 + rand(26)).chr.downcase },
						 "20"=>20.times.map { (65 + rand(26)).chr.downcase }}
  #MUSIC_CHOICE = { "country"    => "Media/cruise.mp3",
                   #"pop"        => "Media/happy.mp3",
                   #"rap"        => "Media/sway.mp3",
                   #"dubstep"     => "Media/bass.mp3",
                   #"baby metal" => "Media/baby.mp3",
                   #"chiptune"   => "Media/chiptune.mp3" }

  attr_reader :count
  attr_reader :name
  attr_reader :score_keeper


  def initialize
	@numb = 0
    @count = 0
    @score_keeper = ScoreKeeper.new(HIGHSCORE_FILENAME)
  end

  def increase_count
    @count += 1
  end

  def show_countdown
  
    puts "COUNTDOWN COMMENCING!"
    sleep 1
    clear
    puts "5.376432"
    sleep 1
    clear
    puts "4.356892"
    sleep 1
    clear
    puts "3.14159265358979323846264338327950"
    sleep 1.5
    clear
    puts "2.283475"
    sleep 1
    clear
    puts "1.9823047"
    sleep 1
    clear
	puts "GO!!!"
	sleep 1
			
	
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
      clear
    end
  end

  def show_intro
    clear
	puts "LET'S EAT (,) GRANDMA PRODUCTIONS"
	puts "PRESENTS:"
	sleep 3.5
	puts "                                                                                 
                                             
	| ------------------------------------ |				                     
	| BUTTON MASH KINGDOMS: 1N5ANE ED1T10N |                                     
	| ------------------------------------ |            
											  "
	sleep 4.3
	clear
    puts "Press,Push,Smash,Mash! Play Until You Get Carpal Tunnel!"
	puts " (please don't...)"
    puts "Are you new to the Kingdom? *yes,no*"
    @signup = gets.strip
    show_signup
    puts "Do you even mash? *no,maybe,kinda,yes*"
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
  def button_selection
    puts "How Many Fingers Can You Mash With, Bro? *2,3,4,5,6,10,20*"
    @finger = gets.strip
  end

  def button_count
    start_time = Time.now
    button_next_to_mash = button_mash_list[0]

    while (Time.now - start_time) <= get_difficulty_time(@diff)  do
      pressed_button = Curses.getch
      if button_next_to_mash == pressed_button
        increase_count
        update_count
        position = button_mash_list.index(pressed_button)
        button_next_to_mash = button_mash_list[(position + 1) % button_mash_list.length]

      end
    end
  end

  def check_correct
	clear
    puts "Name:#{@name}"
    puts "Difficulty: #{@diff}"
    puts "Music: #{@choice}"
    puts "Your Keys Are: #{button_mash_list.join(", ")}"
    puts "IS THIS GOOD? *yes,no*"
    gets.strip == "yes"
  end


  def music_taste
	clear
    puts "What Kind Of Music Do You Like?"
    puts "*country,pop,rap,dubstep,baby metal*"
    @choice = gets.strip
	clear
  end


  def button_mash_list
    DIFFICULTY_BUTTONS[@finger]
  end

  def music_choose
    MUSIC_CHOICE[@choice]
  end

  def run!
    #music_taste
    #@music = Gosu::Sample.new(Gosu::Window.new(100,100,false), MUSIC_CHOICE[@choice] )
    #@music.play
    show_intro

    #button

    @diff = gets.strip
	easter_egg

    button_selection
    run! if !check_correct

    show_countdown

    curses_start

    button_count

    if score_keeper.get_score(name) > count
      clear
      puts "    Maybe Next Time!"
    else
      puts "    New HighScore!"
      score_keeper.set_score(name, count)
    end
	clear

    score_keeper.save_scores
    show_finalscore
  end

  def update_count
    Curses.setpos(0,0)
    Curses.addstr("#{count}")
  end
  
  def easter_egg
		
	end

  def clear
    system("clear")
	system("cls")
  end
end

ButtonMash.new.run!
