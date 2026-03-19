def winsize
 #Ruby 1.9.3 added 'io/console' to the standard library.
 require 'io/console'
 IO.console.winsize # Reads window size.
 rescue LoadError
 # This works with older Ruby, but only with systems
 # that have a tput(1) command, such as Unix clones.
[Integer(`tput li`), Integer(`tput co`)]
end

CHAR_SET =
  ('A'..'Z').to_a +
  ('a'..'z').to_a +
  ('0'..'9').to_a +
  ['!',"@","#","$","%","^","&","*","(",")","-","+","="]

Char = Struct.new(:row, :col)

=begin
  
Letter instances of Char
row and col are fields of Struct.

=end


# Initializing these fields before using them.
foreground = []
dispense   = []

print "\e[2J"   # Clear whole screen once

GREEN = "\e[32m" # Sets green 
RESET = "\e[0m"  # Reset colour

# Prevents scrolling by technically switching to a different screen.
print "\e[?1049h"  # Switch to alternate screen buffer
at_exit { print "\e[?1049l" }  # Switch back when program exits

loop do
  rows, cols = winsize

  background = Array.new(rows) do
    Array.new(cols) { CHAR_SET.sample }
  end

  # Spawn new rain sources
  new_streams = [1, cols / 20].max  # At least 1, otherwise cols/20
  new_streams.times { dispense << rand(cols) }

  # Create falling letters
  dispense.each do |col|
    foreground << Char.new(0, col)
  end

  # Randomly stop streams, probability scales with width
  dispense.reject! do |_col|
    rand([20, cols / 5].min) == 0 # [MAX, cols / MIN] maximum vs. minimum probability
  end

  # move letters downward
  foreground.each do |letter|
    letter.row += 1
  end

  # Remove letters that hit the bottom, and when resized smaller
  foreground.reject! { |l| l.row >= rows || l.col >= cols }

  print "\e[H"   # Move cursor to top-left

  screen = Array.new(rows) { Array.new(cols, ' ') }

  # Draw falling letters
  foreground.each do |letter|
    screen[letter.row][letter.col] = CHAR_SET.sample
  end

  # Print frame
  screen.each do |row|
    puts GREEN + row.join + RESET # RESET Makes sure only the characters are green
  end

  sleep 0.03
end