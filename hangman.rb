require "yaml"

class Game
  def initialize
    @secret_word = get_word()
    @guessing_word = @secret_word.gsub(/./, "_")
    @bad_guesses = []
    play()
  end

  def play
    while (!game_over?)
      display()
      print "\nEnter a letter. Type 'save' to save your game. Type 'exit' to exit: "
      input = gets.chomp
      while !input_valid?(input)
        input = gets.chomp
      end
      if input == "save"
        save_game()
      elsif input == "exit"
        break
      else 
        get_guess(input)
      end
    end
  end

  def display
    puts "\n#{@guessing_word}"
    puts "Your guesses so far: #{@bad_guesses}"
    puts "You have #{6-@bad_guesses.length} guesses left"
  end

  def get_guess(guess)
    if @secret_word.include?(guess)
      update_guessing_word(guess)
    else
      @bad_guesses.push(guess)
    end
  end

  def get_word
    dictionary = load_dictionary()
    @secret_word = dictionary.sample
  end

  def self.load_game
    if Dir.empty?("./Saved games")
      puts "There are no saved games"
      return
    end
    loaded = false
    while !loaded
      puts "Select game to load"
      saved_games = Dir.entries("./Saved games").select {|f| File.file? File.join("./Saved games", f)}
      for i in 0...saved_games.length
        puts "(#{i+1}) #{saved_games[i]}"
      end
      load = gets.chomp
      while load.to_i.to_s != load
        puts "Wrong input"
        load = gets.chomp
      end
      load = load.to_i
      begin
        game = YAML::load(File.read("./Saved games/#{saved_games[load-1]}"))
        game.play()
        break
      rescue
        puts "No such file"
      end
    end
  end

  def save_game
    print "Choose a name for the save file: "
    filename = gets.chomp
    Dir.mkdir("Saved games") unless Dir.exists? "Saved games"
    File.open("./Saved games/#{filename}.yml", 'w') do |file|
      file.puts YAML::dump(self)
    end
  end

  def load_dictionary
    dictionary = File.read("5desk.txt")
    dictionary = dictionary.split("\r\n")
    dictionary.filter! {|word| (word.length >= 5 && word.length <= 12)}
    dictionary.collect! {|word| word.downcase}
  end

  def input_valid?(input)
    if input.length > 1
      if input.downcase == "save" || input.downcase == "exit"
        return true
      else 
        return false 
      end
    elsif !input.downcase.match(/[[:lower:]]/)
      return false
    elsif @bad_guesses.include?(input)
      return false
    elsif @guessing_word.include?(input)
      return false
    else
      return true
    end
  end

  def game_over?
    if cracked?
      puts @guessing_word
      puts "Congratulations you guessed the word!"
      return true
    elsif out_of_guesses?
      puts "Oh thats too bad you got hanged."
      puts "The word was #{@secret_word}"
      return true
    else
      return false
    end
  end

  def cracked?
    if @guessing_word == @secret_word
      return true
    else
      return false
    end
  end

  def out_of_guesses?
    if @bad_guesses.length > 5
      return true
    else
      return false
    end
  end

  def update_guessing_word(guess)
    found = true
    index = -1
    while found
      if @secret_word.index("#{guess}",index+1)
        index = @secret_word.index("#{guess}",index+1)
        @guessing_word[index] = guess
      else
        found = false
      end
    end
  end

end

puts "---Hangman---"
puts "You have to guess a secret word selected randomly from a dictionary"
puts "You are allowed up to 5 mistakes"
puts "(1) New game"
puts "(2) Load Game"
new_load = ""
while(new_load != "1" && new_load != "2")
  new_load = gets.chomp
end
if new_load == "1"
  Game.new
else
  Game.load_game
end
