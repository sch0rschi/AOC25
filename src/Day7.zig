const std = @import("std");
const print = std.debug.print;

const input: []const u8 = @embedFile("day7");

pub fn main() void {
    var row: [141]u64 = undefined;
    var count: u16 = 0;

    for (0..141) |col| {
        row[col] = @intFromBool(input[col] != '.');
    }

    for (1..71) |half_row_index| {
        const input_offset = 2 * half_row_index * 142;
        for (71-half_row_index.. 70+half_row_index) |i| {
            const is_caret = input[input_offset + i] == '^';
            const grid_val = row[i];

            count += @as(u16, @intFromBool(is_caret and grid_val > 0));

            const val_to_add = @intFromBool(is_caret) * grid_val;
            row[i - 1] += val_to_add;
            row[i + 1] += val_to_add;
            row[i] -= val_to_add;
        }
    }

    print("{}\n", .{count});

    // Sum all non-zero values
    var sum: u64 = 0;
    for (row) |value| {
        sum += value;
    }

    print("{}\n", .{sum});
}
