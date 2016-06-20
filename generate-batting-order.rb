#### TODO ####
# - Add flag for resetting included files
# - Update ./include/last-girls.txt with GP
# - Update ./include/last-guys.txt with GP
# - Format console output strings
# - Add debug flag

class Player
    @@roster_size = 0
    @@next_batting_position = 1

    attr_reader   :name
    attr_accessor :bottom_count
    attr_reader   :games_played

    def initialize(name, bottom_count, games_played)
        @@roster_size += 1
        @name = name.to_sym          # String
        @bottom_count = bottom_count.to_i
        @games_played = games_played.to_i
        self
    end

    def inc_bottom_count
        @bottom_count += 1
        self
    end

    def inc_games_played
        @games_played += 1
        self
    end

    def to_string
        output = "#{@name.to_s}\t#{@bottom_count}\t#{@games_played}\n"
    end
end

class Roster
    attr_reader   :playing_roster_size      # Integer
    attr_accessor :guys_order               # Array
    attr_accessor :girls_order              # Array
    attr_accessor :full_roster              # Hash

    def initialize
        @playing_roster_size = 0
        @guys_order = []
        @girls_order = []
        @full_roster = {}
    end

    def add_to_roster(name, bottom_count, games_played)
        @full_roster[name] = Player.new(name, bottom_count, games_played)
    end

    def add_to_order(name, gender)
        if @full_roster.key?(name)
            player = @full_roster.fetch(name)
            if gender == :boy
                @guys_order << player.inc_games_played
            else
                @girls_order << player.inc_games_played
            end
            @playing_roster_size += 1
        else
            puts "#{name} not a member of the roster"
        end
    end

    def print
        output = ""
        @full_roster.each_value do |player|
            output += player.to_string
        end
        output
    end

end

def print_player_array(array)
    output = ""
    array.each do |player|
        output += player.to_string
    end
    output
end

def main
    # Check for flags
    args = Hash[ ARGV.flat_map { |s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) } ]
    puts args

    base_dir = ""
    if (args.key?('t') or args.key?('test'))
        base_dir = "test/"
    end

    guys_bottom_file = base_dir + "include/last-guys.txt"
    girls_bottom_file = base_dir + "include/last-girls.txt"

    # Make new roster instance
    roster = Roster.new

    # Add all players to roster with bottom count and games played
    File.open(guys_bottom_file).readlines.each do |line|
        temp_array = line.chop!.split

        name = temp_array[0].to_sym
        bottom_count = temp_array[1]
        games_played = temp_array[2]

        roster.add_to_roster(name, bottom_count, games_played)
    end
    File.open(girls_bottom_file).readlines.each do |line|
        temp_array = line.chop!.split

        name = temp_array[0].to_sym
        bottom_count = temp_array[1]
        games_played = temp_array[2]

        roster.add_to_roster(name, bottom_count, games_played)
    end

    puts roster.full_roster

    guys_input_file = base_dir + "input/guys.txt"
    girls_input_file = base_dir + "input/girls.txt"

    # Generate alphabetic list of players for game
    File.open(guys_input_file).readlines.each do |line|
        name = line.chop!.to_sym
        if roster.full_roster.key?(name)
            roster.add_to_order(name, :boy)
            puts "Added #{name} to guys order."
        else
            puts "Cannot find #{name} in roster."
        end
    end
    puts "NAME:\tBOTTOM COUNT:"
    puts print_player_array(roster.guys_order)
    File.open(girls_input_file).readlines.each do |line|
        name = line.chop!.to_sym
        if roster.full_roster.key?(name)
            roster.add_to_order(name, :girl)
            puts "Added #{name} to girls order."
        else
            puts "Cannot find #{name} in roster."
        end
    end
    puts "NAME:\tBOTTOM COUNT\tGAMES_PLAYED:"
    puts print_player_array(roster.girls_order)

    # Determine all players of each gender that have been bottom least
    #   number of times
    guys_min = (2**(0.size * 8 - 2) - 1)
    guys_last = []
    roster.guys_order.each do |player|
        if player.bottom_count < guys_min
            guys_last.clear
            guys_last << player
            guys_min = player.bottom_count
        elsif player.bottom_count == guys_min
            guys_last << player
        end
        puts "#{player.name} has been bottom #{player.bottom_count} times."
    end
    puts print_player_array(guys_last)
    girls_min = (2 ** (0.size * 8 - 2) - 1)
    girls_last = []
    roster.girls_order.each do |player|
        if player.bottom_count < girls_min
            girls_last.clear
            girls_last << player
            girls_min = player.bottom_count
        elsif player.bottom_count == girls_min
            girls_last << player
        end
        puts "#{player.name} has been bottom #{player.bottom_count} times."
    end
    puts print_player_array(girls_last)

    # Randomly select one player from each list of min bottom counts
    last_guy = guys_last.sample
    last_guy.inc_bottom_count
    puts "#{last_guy.name} is last guy."
    last_girl = girls_last.sample
    last_girl.inc_bottom_count
    puts "#{last_girl.name} is last girl."

    # Randomize each order
    roster.guys_order.shuffle!
    roster.girls_order.shuffle!

    # Move last of each gender to end of list
    roster.guys_order.delete_if { |player| player == last_guy }
    roster.guys_order << last_guy
    roster.girls_order.delete_if { |player| player == last_girl }
    roster.girls_order << last_girl

    puts print_player_array(roster.guys_order)
    puts print_player_array(roster.girls_order)

    # Save each order to output file
    guys_order_file = base_dir + "output/guys-order.txt"
    girls_order_file = base_dir + "output/girls-order.txt"
    File.open(guys_order_file, 'w') do |file|
        output = ""
        roster.guys_order.each do |player|
            output += "#{player.name}\n"
        end
        file.write(output)
    end
    File.open(girls_order_file, 'w') do |file|
        output = ""
        roster.girls_order.each do |player|
            output += "#{player.name}\n"
        end
        file.write(output)
    end

    # Update "last-guys.txt" and "last-girls.txt".
    # TODO: Uncomment when a flag is added to reset include files
    #File.open(guys_bottom_file, 'w') do |file|
        #file.write(roster.print)
    #end

    # Print "Done!" to console
    puts "Done!"
end

main

