const std = @import("std");
const print = std.debug.print;
const tokenizeAny = std.mem.tokenizeAny;

const simple_regex = @import("regex_utils.zig").simple_regex;

const input: []const u8 = @embedFile("day3");

pub fn main() void {
    solve_1();
    solve_2();
}

fn solve_1() void {
    const sum: i64 = solve(input, "^(.+)\\1$");
    print("{d}\n", .{sum});
}

fn solve_2() void {
    const sum: i64 = solve("^(.+)\\1+$");
    print("{d}\n", .{sum});
}

fn solve(pattern: [:0]const u8) i64 {
    const regex = simple_regex.setup_regex(pattern);
    defer regex.free();

    var lines = tokenizeAny(u8, input, ",\n");
    var sum: i64 = 0;
    while (lines.next()) |line| {
        var range = std.mem.splitScalar(u8, line, '-');
        const from = std.fmt.parseInt(usize, range.next().?, 10) catch unreachable;
        const to = std.fmt.parseInt(usize, range.next().?, 10) catch unreachable;

        for (from..to + 1) |id| {
            var buf: [20]u8 = undefined;
            const digits_string = std.fmt.bufPrint(&buf, "{d}", .{id}) catch unreachable;
            if (regex.matches(digits_string)) {
                sum = sum + @as(i64, @intCast(id));
            }
        }
    }
    return sum;
}
