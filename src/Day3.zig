const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;

const input: []const u8 = @embedFile("day3");

pub fn main() void {
    var sum_part_1: i64 = 0;
    var sum_part_2: i64 = 0;
    for (0..200) |row| {
        const offset = 101 * row;
        sum_part_1 += calculate_max_2_digit_selection(input[offset..offset+100]);
        sum_part_2 += calculate_max_12_digit_selection(input[offset..offset+100]);
    }
    print("{}\n", .{sum_part_1});
    print("{}\n", .{sum_part_2});
}

inline fn calculate_max_2_digit_selection(bank: []const u8) i64 {
    var aggregate: i64 = 0;
    var last_max_index: usize = 0;

    inline for (0..2) |position| {
        const search_slice = bank[last_max_index .. 100 - 2 + 1 + position];
        const max_value_index = std.mem.indexOfMax(u8, search_slice);
        const max_value = search_slice[max_value_index];

        last_max_index += max_value_index + 1;
        aggregate *= 10;
        aggregate += max_value - '0';
    }
    return aggregate;
}

inline fn calculate_max_12_digit_selection(bank: []const u8) i64 {
    var aggregate: i64 = 0;
    var last_max_index: usize = 0;

    inline for (0..12) |position| {
        const search_slice = bank[last_max_index .. 100 - 12 + 1 + position];
        const max_value_index = std.mem.indexOfMax(u8, search_slice);
        const max_value = search_slice[max_value_index];

        last_max_index += max_value_index + 1;
        aggregate *= 10;
        aggregate += max_value - '0';
    }
    return aggregate;
}
