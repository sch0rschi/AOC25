const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeSequence = std.mem.tokenizeSequence;
const tokenizeAny = std.mem.tokenizeAny;

const input: []const u8 = @embedFile("day12");

pub fn main() void {
    var separator = tokenizeSequence(u8, input,".##\n..#\n\n");
    _ = separator.next();
    var lines = tokenizeScalar(u8, separator.next().?, '\n');
    var part_1_count: u16 = 0;
    while(lines.next()) |line_string| {
        var number_tokens = tokenizeAny(u8, line_string, "x: ");
        const dimension_1 = std.fmt.parseInt(u16, number_tokens.next().?, 10) catch unreachable;
        const dimension_2 = std.fmt.parseInt(u16, number_tokens.next().?, 10) catch unreachable;
        const count_1 = std.fmt.parseInt(u16, number_tokens.next().?, 10) catch unreachable;
        const count_2 = std.fmt.parseInt(u16, number_tokens.next().?, 10) catch unreachable;
        const count_3 = std.fmt.parseInt(u16, number_tokens.next().?, 10) catch unreachable;
        const count_4 = std.fmt.parseInt(u16, number_tokens.next().?, 10) catch unreachable;
        const count_5 = std.fmt.parseInt(u16, number_tokens.next().?, 10) catch unreachable;
        const count_6 = std.fmt.parseInt(u16, number_tokens.next().?, 10) catch unreachable;
        if (dimension_1 * dimension_2 >= (count_1 + count_2 + count_3 + count_4 + count_5 + count_6) * 9) {
            part_1_count += 1;
        }
    }
    print("{}\n", .{part_1_count});


}
