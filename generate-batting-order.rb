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
        @top_count += 1
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
    MAX_TIMES = (2 ** (0.size * 8 - 2) - 1)
    BOT  = :bottom
    LOW  = :low
    MID  = :middle
    TOP  = :top

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
    guys_bottom_file = base_dir + "include/last-guys.txt"
    girls_bottom_file = base_dir + "include/last-girls.txt"

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

    both_orders = {}

    both_orders = build_order_segment(roster, Roster::LOW)
    guys_low_order = both_orders[:guy]
    girls_low_order = both_orders[:girl]

    both_orders = build_order_segment(roster, Roster::TOP)
    guys_high_order = both_orders[:guy]
    girls_high_order = both_orders[:girl]

    both_orders = build_order_segment(roster, Roster::MID)
    guys_mid_order = both_orders[:guy]
    girls_mid_order = both_orders[:girl]

    roster.guys_order = guys_high_order + guys_mid_order + guys_low_order
    roster.girls_order = girls_high_order + girls_mid_order + girls_low_order

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

def build_order_segment(roster, segment)
    # TODO
    both_orders = {}
    if segment == Roster::LOW
        return build_bottom_segment(roster)
    end

    [:guy, :girl].each do |gender|
        order_segment = []
        gender_order = []

        if gender == :guy
            gender_order = roster.guys_order
        else
            gender_order = roster.girls_order
        end

        gender_order.shuffle!

        gender_order = order_quicksort(gender_order, segment)

        if segment == Roster::TOP
            order_segment = gender_order.shift(3)
        elsif segment == Roster::MID
            order_segment = gender_order.shift(gender_order.length)
        else
            raise "Unexpected segment type: #{semgent}."
        end

        order_segment.each do |player|
            if segment == Roster::TOP
                player.inc_top_count
            else
                player.inc_middle_count
            end
        end

        #order_segment.shuffle!

        both_orders[gender] = order_segment

        if gender == :guy
            roster.guys_order = gender_order
        else
            roster.girls_order = gender_order
        end
    end

    both_orders
end

def build_bottom_segment(roster)
    both_orders = {}

    [:guy, :girl].each do |gender|
        order_segment = []
        order_last = []
        gender_order = []

        min = Roster::MAX_TIMES

        if gender == :guy
            gender_order = roster.guys_order
        else
            gender_order = roster.girls_order
        end

        gender_order.shuffle!

        gender_order.each do |player|
            if player.bottom_count < min
                order_last.clear
                order_last << player
                min = player.bottom_count
            elsif player.bottom_count == min
                order_last << player
            end
        end

        last_player = order_last.sample
        last_player.inc_bottom_count
        last_player.inc_low_count
        puts "#{last_player.name} is the last #{gender.to_s}."

        gender_order.delete_if { |player| player == last_player }

        gender_order = order_quicksort(gender_order, Roster::LOW)

        order_segment = gender_order.shift(2)

        order_segment.each do |player|
            player.inc_low_count
            gender_order.delete_if { |play| play == player }
        end

        order_segment << last_player

        if gender == :guy
            roster.guys_order = gender_order
        else
            roster.girls_order = gender_order
        end

        both_orders[gender] = order_segment
    end

    return both_orders
end

def order_quicksort(array, segment)
    return array if array.length <= 1
    pivot = array.delete_at(rand(array.size))

    left = []
    right = []


    array.each do |player|
        pivot_val = Roster::MAX_TIMES
        player_val = Roster::MAX_TIMES

        if segment == Roster::BOT
            pivot_val = pivot.bottom_count
            player_val = player.bottom_count
        elsif segment == Roster::LOW
            pivot_val = pivot.low_count.to_f / pivot.games_played.to_f
            player_val = player.low_count.to_f / player.games_played.to_f
        elsif segment == Roster::MID
            pivot_val = pivot.middle_count.to_f / pivot.games_played.to_f
            player_val = player.middle_count.to_f / player.games_played.to_f
        elsif segment == Roster::TOP
            pivot_val = pivot.top_count.to_f / pivot.games_played.to_f
            player_val = player.top_count.to_f / player.games_played.to_f
        else
            raise "Invalid segment type."
        end

        if player_val <= pivot_val
            left << player
        else
            right << player
        end
    end

    sorted_array = []
    sorted_array << order_quicksort(left, segment)
    sorted_array << pivot
    sorted_array << order_quicksort(right, segment)

    sorted_array.flatten!
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

