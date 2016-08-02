

function Player (name, gender, low, mid, top_c, bot, gp) {
    var name = name;
    var gender = gender;
    var low_count = low;
    var middle_count = mid;
    var top_count = top_c;
    var bottom_count = bot;
    var games_played = gp;

    this.get_name = function() { return name };
    this.get_gender = function() { return gender };
    this.get_low_count = function() { return low_count };
    this.get_middle_count = function() { return middle_count };
    this.get_top_count = function() { return top_count };
    this.get_bottom_count = function() { return bottom_count };
    this.get_games_played = function() { return games_played };

    this.inc_low_count = function() { low_count += 1 };
    this.inc_middle_count = function() { middle_count += 1 };
    this.inc_top_count = function() { top_count += 1 };
    this.inc_bottom_count = function() { bottom_count += 1 };
    this.inc_games_played = function() { games_played += 1 };

    this.to_string = function() {
        return "" + name + "\t" + low_count + "\t" + middle_count + "\t" + top_count + "\t" + bottom_count + "\t" + games_played + "\n";
    }
}

function Roster () {
    this.guys_order = [ ];
    this.girls_order = [ ];
    this.full_order = new Object();

    this.add_to_roster = function(name, gender, low, mid, top_c, bot, gp) {
        var player = new Player(name, gender, low, mid, top_c, bot, gp);
        this.full_order[name] = player;
    }

    this.add_to_order = function(name, gender) {
        if (this.full_order.hasOwnProperty(name)) {
            var player = this.full_order[name];
            player.inc_games_played();
            if (gender === "guy") {
                this.guys_order.push(player);
            }
            else {
                this.girls_order.push(player);
            }

            this.full_order[name] = player;
        }
        else {
            console.log(name + " is not a member of the roster");
        }
    }

    this.print = new function() {
        var output = "";
        for(var player in this.full_order) {
            output += player.to_string();
        }

        return output;
    }
}


var roster = new Roster();
roster.add_to_roster("David", "guy", 3, 5, 3, 5, 2);
roster.add_to_roster("Andrew", "guy", 3, 2, 5, 5, 2);

roster.add_to_order("David", "guy");
roster.add_to_order("Andrew", "guy");

for (var player in roster.full_order)
{
    console.log(roster.full_order[player].to_string());
}

