#!usr/bin/env ruby

# Default constants
version = "1.2.4"
delay = 0.05        # default delay
mcolour = "\e[92m"  # default colour (bright green)

# Colour constants
GREEN = "\e[32m"
RED = "\e[31m"
YELLOW = "\e[33m"
BLUE = "\e[34m"
MAGENTA = "\e[35m"
CYAN = "\e[36m"
BLACK = "\e[30m"
WHITE = "\e[37m"
BRIGHT_GREEN = "\e[92m"
BRIGHT_RED = "\e[91m"
BRIGHT_YELLOW = "\e[93m"
BRIGHT_BLUE = "\e[94m"
BRIGHT_MAGENTA = "\e[95m"
BRIGHT_CYAN = "\e[96m"
BRIGHT_BLACK = "\e[90m"
BRIGHT_WHITE = "\e[97m"

if ARGV.include?("-c")
  CHAR_SET =
    ('A'..'Z').to_a +
    ('a'..'z').to_a +
    ('0'..'9').to_a +
    [
      'ｦ','ｧ','ｨ','ｩ','ｪ','ｫ','ｬ','ｭ','ｮ','ｯ','ｰ','ｱ','ｲ',
      'ｳ','ｴ','ｵ','ｶ','ｷ','ｸ','ｹ','ｺ','ｻ','ｼ','ｽ','ｾ','ｿ',
      'ﾀ','ﾁ','ﾂ','ﾃ','ﾄ','ﾅ','ﾆ','ﾇ','ﾈ','ﾉ','ﾊ','ﾋ','ﾌ',
      'ﾍ','ﾎ','ﾏ','ﾐ','ﾑ','ﾒ','ﾓ','ﾔ','ﾕ','ﾖ','ﾗ','ﾘ','ﾙ',
      'ﾚ','ﾛ','ﾜ','ﾝ'
    ] +
    [
      '!','@','#','$','%','^','&','*','(',')','-','+','='
    ]
else
    CHAR_SET =
    ('A'..'Z').to_a +
    ('a'..'z').to_a +
    ('0'..'9').to_a +
    [
      '!','@','#','$','%','^','&','*','(',')','-','+','='
    ]
end

if ARGV.include?("-C")
  index = ARGV.index("-C")
  color_set = ARGV[index + 1].downcase
  # Using || operator breaks arguments below, so I made them all seperate elsif statements.
  if color_set == "green"
    mcolour = GREEN
  elsif color_set == "red"
    mcolour = RED
  elsif color_set == "yellow"
    mcolour = YELLOW
  elsif color_set == "blue"
    mcolour = BLUE
  elsif color_set == "magenta"
    mcolour = MAGENTA
  elsif color_set == "cyan"
    mcolour = CYAN
  elsif color_set == "black"
    mcolour = BLACK
  elsif color_set == "white"
    mcolour = WHITE
  elsif color_set == "bright-green"
    mcolour = BRIGHT_GREEN
  elsif color_set == "bright-red"
    mcolour = BRIGHT_RED
  elsif color_set == "bright-yellow"
    mcolour = BRIGHT_YELLOW
  elsif color_set == "bright-blue"
    mcolour = BRIGHT_BLUE
  elsif color_set == "bright-magenta"
    mcolour = BRIGHT_MAGENTA
  elsif color_set == "bright-cyan"
    mcolour = BRIGHT_CYAN
  elsif color_set == "bright-black"
    mcolour = BRIGHT_BLACK
  elsif color_set == "bright-white"
    mcolour = BRIGHT_WHITE
  else
    puts "No colour has been correctly specified, defaulting to green."
    sleep 1
    print "."
    sleep 1
    print "."
    sleep 1
    print "."
    sleep 1
  end
end

# Detect delay argument for different speed
if ARGV.include?("-d")
  index = ARGV.index("-d")
  delay = ARGV[index + 1].to_f
end

if ARGV.include?("-h")
  index = ARGV.index("-h")
  print "\e[2J"
  print "\e[H"
  print "RubyMatrix version #{version}\n\n"
  print "Usage: ruby matrix.rb -[argument]\n\n"
  print "-c: Includes half-width kana inside the rainfall's set of characters."
  print "-C [colour]: Sets a user specified colour for rainfall. Default is green.\n"
  print "-d [number]: Sets the delay for speed. Default is 0.05 seconds\n"
  print "-h: Print usage and exit.\n"
  print "-v: Show version number.\n"
  print "\n"
  print "Shortcuts:\n"
  print "Ctrl + S: Pauses/unpauses the rainfall\n"
  print "Ctrl + C: Closes the program\n"
  print "\n"
  exit
end

if ARGV.include?("-v")
  index = ARGV.index("-v")
  print "RubyMatrix version #{version}\n"
  exit
end

def winsize
 #Ruby 1.9.3 added 'io/console' to the standard library.
 require 'io/console'
 IO.console.winsize # Reads window size.
 rescue LoadError
 # This works with older Ruby, but only with systems
 # that have a tput(1) command, such as Unix clones.
[Integer(`tput li`), Integer(`tput co`)]
end

Char = Struct.new(:row, :col, :char)

# Letter instances of Char
# row and col are fields of Struct.

# Initializing these fields before using them.
foreground = []
dispense   = []

print "\e[2J"     # Clear whole screen once

COLOR = mcolour   # Sets colour 
RESET = "\e[0m"   # Reset colour

# Prevents scrolling by technically switching to a different screen.
print "\e[?1049h"               # Switch to alternate screen buffer
at_exit { print "\e[?1049l" }   # Switch back when program exits

loop do
  rows, cols = winsize
  heads = {}

  # Spawn new rain sources
  new_streams = [1, cols / 20].max  # At least 1, otherwise cols/20
  new_streams.times { dispense << rand(cols) }

  # Create falling letters
  dispense.each do |col|
    foreground << Char.new(0, col, CHAR_SET.sample)
  end

  # Randomly stop streams
  dispense.reject! do |_col|
    rand([5].min) == 0 # set probability
  end

  # Move letters downward
  foreground.each do |letter|
    # Check for leading letter in trail
    if heads[letter.col].nil? || letter.row > heads[letter.col].row
      heads[letter.col] = letter
    end

    letter.row += 1
  end

  # Remove letters that hit the bottom, and when resized smaller
  foreground.reject! { |l| l.row >= rows || l.col >= cols }

  print "\e[H"   # Move cursor to top-left

  screen = Array.new(rows) { Array.new(cols, ' ') }

  # Draw falling letters
  foreground.each do |letter|

    # Randomly change a character
    if rand(15) == 0
      letter.char = CHAR_SET.sample
    end

    # Randomise head letter every frame
    # and set colour accordingly
    if heads[letter.col] == letter
      letter.char = CHAR_SET.sample
      color = BRIGHT_WHITE
    else
      color = COLOR
    end

    # Apply befitting colour to letters and output chars
    screen[letter.row][letter.col] = "#{color}#{letter.char}#{RESET}"
  end

  # Print frame
  screen.each do |row|
    print row.join
    # Must use print instead of puts, 
    # or else flickering will occur in the animation.
  end

  sleep delay
end