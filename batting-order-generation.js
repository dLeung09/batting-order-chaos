
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

    this.print = function() {
        var output = "";
        for(var player in this.full_order) {
            output += this.full_order[player].to_string();
        }

        return output;
    }
}

var print_player_array = function(array)
{
    output = "";
    for (var player in array)
    {
        output += array[player].to_string();
    }
    return output;
}

var main = function()
{
    if (typeof process !== typeof undefined)
    {
        var args = [];
        console.log("Program run with args:");
        for (var idx in process.argv)
        {
            console.log("\t" + process.argv[idx]);
            args.push(process.argv[idx]);
        }

        console.log(args);
    }

    console.log("Started!");

    //var statsTable = document.getElementById("stats");

    ////dummies.sort(function(a,b) {return b.ba - a.ba});

    //dummies.forEach(function(player)
    //{
    //    var name = document.createElement("td");
    //    name.textContent = player.name;
    //    var gp = document.createElement("td");
    //    gp.textContent = player.gp;
    //    var ab = document.createElement("td");
    //    ab.textContent = player.ab;
    //    var runs = document.createElement("td");
    //    runs.textContent = player.runs;
    //    var hits = document.createElement("td");
    //    hits.textContent = player.hits;
    //    var ba = document.createElement("td");
    //    ba.textContent = player.ba;

    //    var tr = document.createElement("tr");
    //    tr.appendChild(name);
    //    tr.appendChild(gp);
    //    tr.appendChild(ab);
    //    tr.appendChild(runs);
    //    tr.appendChild(hits);
    //    tr.appendChild(ba);

    //    statsTable.appendChild(tr);
    //});

    //document.getElementById("stats_table").style.display = "inline";

    console.log("Finished!");
}

var generate_orders = function() {
    event.preventDefault();

    ["guys_form", "girls_form"].forEach(function(form_id) {
        var order_id;
        if (form_id === "guys_form")
        {
            order_id = "guys_order";
        }
        else
        {
            order_id = "girls_order";
        }

        var new_table_body = document.createElement("tbody");
        var old_table_body = document.getElementById(order_id + "_body");
        new_table_body.id = old_table_body.id;

        var form_children = document.getElementById(form_id).childNodes;

        for (i = 1; i < form_children.length; i += 2)
        {
            var player = form_children[i].lastChild.value;

            var player_element = document.createElement("td");
            player_element.textContent = player;

            var row_element = document.createElement("tr");
            row_element.appendChild(player_element);

            new_table_body.appendChild(row_element);
        }

        old_table_body.parentNode.replaceChild(new_table_body, old_table_body);

    });

    console.log("Orders should be visible.");
}

document.forms["generate"].addEventListener("submit", generate_orders);

//////////////
// TEST:
//////////////
//var roster = new Roster();
//roster.add_to_roster("David", "guy", 3, 5, 3, 5, 2);
//roster.add_to_roster("Andrew", "guy", 3, 2, 5, 5, 2);
//
//roster.add_to_order("David", "guy");
//roster.add_to_order("Andrew", "guy");
//
//console.log("Guys order:");
//
//for (var player in roster.guys_order)
//{
//    console.log(roster.guys_order[player].to_string());
//}
//
//console.log("Girls order:");
//
//for (var player in roster.girls_order)
//{
//    console.log(roster.girls_order[player].to_string());
//}
//
//console.log("Roster print:");
//console.log(roster.print());

main();

