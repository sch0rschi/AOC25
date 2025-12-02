const std = @import("std");
const print = std.debug.print;
const tokenizeAny = std.mem.tokenizeAny;

const file_utils = @import("file_utils.zig");
const simple_regex = @import("regex_utils.zig").simple_regex;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input_test = file_utils.read_input(allocator, 2, true) catch unreachable;
    defer allocator.free(input_test);
    const input = file_utils.read_input(allocator, 2, false) catch unreachable;
    defer allocator.free(input);
    solve_1(input_test);
    solve_1(input);
    solve_2(input_test);
    solve_2(input);
}

fn solve_1(input: []u8) void {
    const sum: i64 = solve(input, "^(.+)\\1$");
    print("{d}\n", .{sum});
}

fn solve_2(input: []u8) void {
    const sum: i64 = solve(input, "^(.+)\\1+$");
    print("{d}\n", .{sum});
}

fn solve(input: []u8, pattern: [:0]const u8) i64 {
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
