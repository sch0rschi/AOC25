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
    _ = gurobi.GRBsetintparam(env, gurobi.GRB_INT_PAR_LOGTOCONSOLE, 0);
    var model: ?*gurobi.GRBmodel = null;
    _ = gurobi.GRBnewmodel(env, &model, null, 0, null, null, null, null, null);


    var indicators: [10]bool = undefined;
    var current_indicator: [10]bool = undefined;
    var buttons: [15][10]bool = undefined;
    var joltages: [10]f64 = undefined;

    while (line_tokenss.next()) |line| {
        var line_tokens = tokenizeSequence(u8, line, "] (");
        const indicators_string = line_tokens.next().?[1..];

        var light_count: u8 = 0;
        for (indicators_string, 0..) |character, index| {
            indicators[index] = (character == '#');
            light_count += 1;
        }

        var buttons_and_joltage = tokenizeSequence(u8, line_tokens.next().?, ") {");
        const buttons_string = buttons_and_joltage.next().?;

        var buttons_tokens = tokenizeSequence(u8, buttons_string, ") (");
        var button_count: usize = 0;
        while (buttons_tokens.next()) |button_string|: (button_count += 1) {
            var wireing_tokens = tokenizeScalar(u8, button_string, ',');
            @memset(&buttons[button_count], false);
            while (wireing_tokens.next()) |button_character| {
                buttons[button_count][@intCast(button_character[0] - '0')] = true;
            }
        }

        part_1_sum += button_smach_brute_force(light_count, button_count, indicators[0..light_count], buttons[0..button_count], current_indicator[0..light_count]);

        const joltages_string = buttons_and_joltage.next().?;
        var joltage_tokens = tokenizeScalar(u8, joltages_string, ',');

        var counter: usize = 0;
        while (joltage_tokens.next()) |joltage_string| : (counter += 1) {
            joltages[counter] = std.fmt.parseFloat(f64, joltage_string) catch unreachable;
        }
        part_2_sum += ilp(model, buttons[0..button_count], joltages[0..light_count]);
    }
    print("{}\n", .{part_1_sum});
    print("{}\n", .{part_2_sum});
}

inline fn button_smach_brute_force(
    number_of_lights: usize,
    number_of_buttons: usize,
    indicators: []const bool,
    buttons: []const [10]bool,
    current_indicator: []bool,
) u64 {
    const power: u64 = @as(u64, 1) << @intCast(number_of_buttons);

    var min_count: u64 = number_of_buttons + 1;

    for (0..power) |trial| {
        const pc = @popCount(trial);
        if (pc >= min_count) {
            continue;
        }

        @memset(current_indicator, false);
        for (0..number_of_buttons) |button_index| {
            if ((trial >> @intCast(button_index)) & 1 == 1) {
                for (0..number_of_lights) |light_index| {
                    current_indicator[light_index] ^=
                    buttons[button_index][light_index];
                }
            }
        }

        if (std.mem.eql(bool, indicators, current_indicator)) {
            min_count = pc;
        }
    }

    return min_count;
}

fn ilp(model: ?*gurobi.GRBmodel, buttons: [][10]bool, joltages: []f64) u64 {

    clear_ilp_model(model);

    for (0..buttons.len) |_| {
        _ = gurobi.GRBaddvar(model, 0, null, null, 1, 0.0, gurobi.GRB_INFINITY, gurobi.GRB_INTEGER, null);
    }

    for (joltages, 0..) |joltage, joltage_index| {
        var indicators: [15]c_int = undefined;
        var values: [15]f64 = undefined;
        var counter: usize = 0;
        for (buttons, 0..) |button, button_index| {
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

fn clear_ilp_model(model: ?*gurobi.GRBmodel) void {
    var numvars: c_int = 0;
    _ = gurobi.GRBgetintattr(model, gurobi.GRB_INT_ATTR_NUMVARS, &numvars);
    if (numvars > 0) {
        var ind_to_remove: [15]c_int = undefined;
        for (0..@intCast(numvars)) |i| {
            ind_to_remove[i] = @intCast(i);
        }
        _ = gurobi.GRBdelvars(model, numvars, &ind_to_remove);
    }

    var numconstrs: c_int = 0;
    _ = gurobi.GRBgetintattr(model, gurobi.GRB_INT_ATTR_NUMCONSTRS, &numconstrs);
    if (numconstrs > 0) {
        var ind_to_remove: [10]c_int = undefined;
        for (0..@intCast(numconstrs)) |i| {
            ind_to_remove[i] = @intCast(i);
        }
        _ = gurobi.GRBdelconstrs(model, numconstrs, &ind_to_remove);
    }

    _ = gurobi.GRBupdatemodel(model);
}