const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeSequence = std.mem.tokenizeSequence;

const input: []const u8 = @embedFile("day10");

pub fn main() void {
    var line_tokenss = tokenizeScalar(u8, input, '\n');
    var result_sum: u64 = 0;
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
        var buttons_list: std.array_list.Managed([]bool) = std.array_list.Managed([]bool).init(allocator);
        defer buttons_list.deinit();

        var buttons_tokens = tokenizeSequence(u8, buttons_string, ") (");
        while (buttons_tokens.next()) |button_string| {
            var button = allocator.alloc(bool, indicators.len) catch unreachable;
            @memset(button, false);
            var wireing_tokens = tokenizeScalar(u8, button_string, ',');
            while (wireing_tokens.next()) |button_character| {
                button[@intCast(button_character[0] - '0')] = true;
            }
            _ = buttons_list.append(button) catch unreachable;
        }

        var current_indicator = allocator.alloc(bool, indicators.len) catch unreachable;
        result_sum += button_smach_brute_force(&indicators, buttons_list, &current_indicator);
    }
    print("{}\n", .{result_sum});
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
