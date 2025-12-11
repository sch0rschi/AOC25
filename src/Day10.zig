const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeSequence = std.mem.tokenizeSequence;

const gurobi = @cImport({
    @cInclude("gurobi_c.h");
});

const input: []const u8 = @embedFile("day10");

pub fn main() void {
    var line_tokenss = tokenizeSequence(u8, input, "}\n");
    var part_1_sum: u64 = 0;
    var part_2_sum: u64 = 0;

    var env: ?*gurobi.GRBenv = null;
    _ = gurobi.GRBloadenv(&env, null);

    while (line_tokenss.next()) |line| {
        var line_tokens = tokenizeSequence(u8, line, "] (");
        const indicators_string = line_tokens.next().?[1..];
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();

        const indicators = allocator.alloc(bool, indicators_string.len) catch unreachable;
        defer allocator.free(indicators);
        for (indicators_string, indicators) |c, *b| {
            b.* = (c == '#');
        }

        var buttons_and_joltage = tokenizeSequence(u8, line_tokens.next().?, ") {");
        const buttons_string = buttons_and_joltage.next().?;
        var buttons: std.array_list.Managed([]bool) = std.array_list.Managed([]bool).init(allocator);
        defer buttons.deinit();

        var buttons_tokens = tokenizeSequence(u8, buttons_string, ") (");
        while (buttons_tokens.next()) |button_string| {
            var button = allocator.alloc(bool, indicators.len) catch unreachable;
            @memset(button, false);
            var wireing_tokens = tokenizeScalar(u8, button_string, ',');
            while (wireing_tokens.next()) |button_character| {
                button[@intCast(button_character[0] - '0')] = true;
            }
            _ = buttons.append(button) catch unreachable;
        }

        var current_indicator = allocator.alloc(bool, indicators.len) catch unreachable;
        part_1_sum += button_smach_brute_force(&indicators, buttons, &current_indicator);

        const joltages_string = buttons_and_joltage.next().?;
        var joltage_tokens = tokenizeScalar(u8, joltages_string, ',');
        var joltages = allocator.alloc(f64, indicators.len) catch unreachable;

        var counter: usize = 0;
        while (joltage_tokens.next()) |joltage_string| : (counter += 1) {
            joltages[counter] = std.fmt.parseFloat(f64, joltage_string) catch unreachable;
        }
        part_2_sum += ilp(env, buttons, &joltages);
    }
    print("{}\n", .{part_1_sum});
    print("{}\n", .{part_2_sum});
}

fn button_smach_brute_force(indicators: *const []bool, buttons: std.array_list.Managed([]bool), current_indicator: *[]bool) u64 {
    const power = std.math.pow(u16, 2, @intCast(buttons.items.len));
    var min_count: u64 = 10;
    for (0..power) |trial| {
        var trial_copy = trial;
        @memset(current_indicator.*, false);
        for (0..buttons.items.len) |index| {
            if (trial_copy & 1 == 1) {
                for (current_indicator.*, buttons.items[index]) |*a, b| {
                    a.* = a.* != b;
                }
            }
            trial_copy = trial_copy >> 1;
        }
        const equals = for (indicators.*, current_indicator.*) |*a, *b| {
            if (a.* != b.*) {
                break false;
            }
        } else true;
        if (equals) {
            min_count = @min(min_count, @popCount(trial));
        }
    }
    return min_count;
}

fn ilp(env: ?*gurobi.GRBenv, buttons: std.array_list.Managed([]bool), joltages: *[]f64) u64 {
    var model: ?*gurobi.GRBmodel = null;

    _ = gurobi.GRBsetintparam(env, gurobi.GRB_INT_PAR_LOGTOCONSOLE, 0);
    _ = gurobi.GRBnewmodel(env, &model, null, 0, null, null, null, null, null);

    for (0..buttons.items.len) |_| {
        _ = gurobi.GRBaddvar(model, 0, null, null, 1, 0.0, gurobi.GRB_INFINITY, gurobi.GRB_INTEGER, null);
    }

    for (joltages.*, 0..) |joltage, joltage_index| {
        var indicators: [12]c_int = undefined;
        var values: [12]f64 = undefined;
        var counter: usize = 0;
        for (buttons.items, 0..) |button, button_index| {
            if (button[joltage_index]) {
                indicators[counter] = @intCast(button_index);
                values[counter] = 1;
                counter += 1;
            }
        }
        _ = gurobi.GRBaddconstr(model, @intCast(counter), &indicators, &values, gurobi.GRB_EQUAL, joltage, null);
    }

    _ = gurobi.GRBupdatemodel(model);
    _ = gurobi.GRBoptimize(model);

    var objval: f64 = 0.0;
    _ = gurobi.GRBgetdblattr(model, gurobi.GRB_DBL_ATTR_OBJVAL, &objval);

    return @intFromFloat(objval);
}
