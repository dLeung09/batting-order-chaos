#### TODO ####
# - Format console output strings
# - Add debug flag

class Player
    attr_reader     :name
    attr_reader     :gender
    attr_accessor   :low_count
    attr_accessor   :middle_count
    attr_accessor   :top_count
    attr_reader     :bottom_count
    attr_reader     :games_played

    def initialize(name, gender, low_count, middle_count, top_count, bottom_count, games_played)
        @name = name.to_sym
        @gender = gender.to_sym
        @low_count = low_count.to_i
        @middle_count = middle_count.to_i
        @top_count = top_count.to_i
        @bottom_count = bottom_count.to_i
        @games_played = games_played.to_i
        self
    end

    def inc_low_count
        @low_count += 1
        self
    end

    def inc_middle_count
        @middle_count += 1
        self
    end

    def inc_top_count
        @high_count += 1
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
        output = "#{@name.to_s}\t#{@low_count}\t#{@middle_count}\t#{@top_count}\t#{@bottom_count}\t#{@games_played}\n"
    end
end

class Roster
    attr_accessor :guys_order               # Array
    attr_accessor :girls_order              # Array
    attr_accessor :full_roster              # Hash

    def initialize
        @guys_order = []
        @girls_order = []
        @full_roster = {}
    end

    def add_to_roster(name, gender, low_count, middle_count, top_count, bottom_count, games_played)
        @full_roster[name] = Player.new(name, gender, low_count, middle_count, top_count, bottom_count, games_played)
    end

    def add_to_order(name, gender)
        if @full_roster.key?(name)
            player = @full_roster.fetch(name)
            if gender == :guy
                @guys_order << player.inc_games_played
                @full_roster[name] = player
            else
                @girls_order << player.inc_games_played
                @full_roster[name] = player
            end
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

def reset_files(base_dir, roster)
    output = ""

    roster.full_roster.each_pair do |name, player|
        output += "#{name.to_s}\t0\t0\t0\t0\t0\n" if player.gender == :guy
    end

    File.open(guys_bottom_file, 'w') do |file|
        file.write(output)
    end

    puts "\nGUYS BOTTOM FILE:"
    puts output

    output = ""

    roster.full_roster.each_pair do |name, player|
        output += "#{name.to_s}\t0\t0\t0\t0\t0\n" if player.gender == :girl
    end

    puts "\nGIRLS BOTTOM FILE:"
    puts output

    File.open(girls_bottom_file, 'w') do |file|
        file.write(output)
    end
end

def initialize_roster(base_dir)
    guys_bottom_file = base_dir + "include/last-guys.txt"
    girls_bottom_file = base_dir + "include/last-girls.txt"

    roster = Roster.new

    # Add all players to roster with bottom count and games played
    File.open(guys_bottom_file).readlines.each do |line|
        temp_array = line.chop!.split

        name = temp_array[0].to_sym
        low_count = temp_array[1]
        middle_count = temp_array[2]
        top_count = temp_array[3]
        bottom_count = temp_array[4]
        games_played = temp_array[5]

        roster.add_to_roster(name, "guy", low_count, middle_count, top_count, bottom_count, games_played)
    end
    File.open(girls_bottom_file).readlines.each do |line|
        temp_array = line.chop!.split

        name = temp_array[0].to_sym
        low_count = temp_array[1]
        middle_count = temp_array[2]
        top_count = temp_array[3]
        bottom_count = temp_array[4]
        games_played = temp_array[5]

        roster.add_to_roster(name, "girl", low_count, middle_count, top_count, bottom_count, games_played)
    end

    puts "NAME:\tLOW COUNT:\tMIDDLE COUNT\tTOP COUNT\tBOTTOM COUNT:\tGAMES PLAYED"
    roster.full_roster.each_value do |player|
        puts player.to_string if (player.gender == :guy)
    end

    puts "NAME:\tLOW COUNT:\tMIDDLE COUNT\tTOP COUNT\tBOTTOM COUNT:\tGAMES PLAYED"
    roster.full_roster.each_value do |player|
        puts player.to_string if (player.gender == :girl)
    end

    roster
end

def build_order(base_dir, roster)
    guys_input_file = base_dir + "input/guys.txt"
    girls_input_file = base_dir + "input/girls.txt"

    # Generate alphabetic list of players for game
    File.open(guys_input_file).readlines.each do |line|
        name = line.chop!.to_sym
        if roster.full_roster.key?(name)
            roster.add_to_order(name, :guy)
            puts "Added #{name} to guys order."
        else
            puts "Cannot find #{name} in roster."
        end
    end

    #puts "NAME:\tLOW COUNT\tMIDDLE COUNT\tTOP COUNT\tBOTTOM COUNT:\tGAMES PLAYED"
    #puts print_player_array(roster.guys_order)

    File.open(girls_input_file).readlines.each do |line|
        name = line.chop!.to_sym
        if roster.full_roster.key?(name)
            roster.add_to_order(name, :girl)
            puts "Added #{name} to girls order."
        else
            puts "Cannot find #{name} in roster."
        end
    end

    #puts "NAME:\tLOW COUNT\tMIDDLE COUNT\tTOP COUNT\tBOTTOM COUNT\tGAMES_PLAYED:"
    #puts print_player_array(roster.girls_order)

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
        #puts "#{player.name} has been bottom #{player.bottom_count} times."
    end

    #puts print_player_array(guys_last)

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
        #puts "#{player.name} has been bottom #{player.bottom_count} times."
    end
    #puts print_player_array(girls_last)

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

    puts ""
    puts print_player_array(roster.guys_order)
    puts ""
    puts print_player_array(roster.girls_order)
    puts ""

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

    roster
end

def update_bottom_file(base_dir, roster)
    guys_bottom_file = base_dir + "include/last-guys.txt"
    girls_bottom_file = base_dir + "include/last-girls.txt"

    output = ""
    roster.full_roster.each_value do |player|
       output += player.to_string if (player.gender == :guy)
    end

    File.open(guys_bottom_file, 'w') do |file|
       file.write(output)
    end

    puts "\nGUYS BOTTOM FILE:"
    puts output
    output = ""

    roster.full_roster.each_value do |player|
        output += player.to_string if (player.gender == :girl)
    end

    File.open(girls_bottom_file, 'w') do |file|
        file.write(output)
    end

    puts "\nGIRLS BOTTOM FILE:"
    puts output
    output = ""
end

def main
    # Check for flags.
    args = Hash[ ARGV.flat_map { |s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) } ]
    puts args

    # Use test directory files, if flag set.
    base_dir = ""
    if (args.key?('t') or args.key?('test'))
        base_dir = "test/"
    end

    # Make new roster instance
    roster = initialize_roster(base_dir)

    # Reset include files to default, if flag set.
    #   Requires roster to be initialized.
    if (args.key?('r') or args.key?('reset'))
        reset_files(base_dir, roster)
        return
    end

    # Build the order and save to output file.
    roster = build_order(base_dir, roster)

    # Update "last-guys.txt" and "last-girls.txt".
    update_bottom_file(base_dir, roster)

    # Print "Done!" to console
    puts "\nDone!"
end

main

