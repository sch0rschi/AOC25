const std = @import("std");
const print = std.debug.print;

const simple_regex = @import("regex_utils.zig").simple_regex;

const input: []const u8 = @embedFile("day2_test");

const repetition_divisors: [12]u64 = .{
    1, 1, 11, 0, 101, 0, 1001, 0, 10001, 0, 100001, 0,
};

const repetitions_divisors: [12][]const u64 = .{ // redundant checks removed
    &[_]u64{},
    &[_]u64{},
    &[_]u64{11},
    &[_]u64{111},
    &[_]u64{101},
    &[_]u64{11111},
    &[_]u64{ 1001, 10101, 111111 },
    &[_]u64{1111111},
    &[_]u64{10001},
    &[_]u64{1001001},
    &[_]u64{ 100001, 101010101, 1111111111 },
    &[_]u64{11111111111},
};

const powers_of_10 = [_]usize{ 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 10000000000, 100000000000 };

pub fn main() void {
    var offset: usize = 0;
    var part_1_sum: u64 = 0;
    var part_2_sum: u64 = 0;
    while (offset < input.len) {
        var from: u64 = 0;
        var from_length: usize = 0;
        while (offset < input.len) : (offset += 1) {
            if (input[offset] == '-') {
                offset += 1;
                break;
            }
            if (input[offset] == '\n') {
                offset += 1;
            }
            from *= 10;
            from += input[offset] - '0';
            from_length += 1;
        }
        var to: u64 = 0;
        var to_length: usize = 0;
        while (offset < input.len) : (offset += 1) {
            if (input[offset] == ',' and input[offset] != '\n') {
                offset += 1;
                break;
            }
            to *= 10;
            to += input[offset] - '0';
            to_length += 1;
        }

        var current = from;
        var current_length = from_length;
        while (current <= to) {
            const next_boundary = powers_of_10[current_length];
            const range_end = @min(to, next_boundary - 1);
            const divisors = repetitions_divisors[current_length];

            part_2_sum += calculate_divisions_in_range_for_divisor(current, divisors[0], range_end);
            if (divisors.len == 3) {
                part_2_sum += calculate_divisions_in_range_for_divisor(current, divisors[1], range_end);
                part_2_sum -= calculate_divisions_in_range_for_divisor(current, divisors[2], range_end);
            }
            if (current_length % 2 == 0) {
                part_1_sum += calculate_divisions_in_range_for_divisor(current, repetition_divisors[current_length], range_end);
            }

            current = range_end + 1;
            current_length += 1;
        }
    }
    print("{}\n", .{part_1_sum});
    print("{}\n", .{part_2_sum});
}

inline fn calculate_divisions_in_range_for_divisor(current: usize, divisor: u64, range_end: u64) usize {
    const ceil_division_from = @divFloor(current + divisor - 1, divisor);
    const floor_division_to = @divFloor(range_end, divisor);
    if (ceil_division_from <= floor_division_to) {
        const number_of_repetitions = floor_division_to - ceil_division_from + 1;
        const first_repetition = ceil_division_from * divisor;
        return first_repetition * number_of_repetitions + (number_of_repetitions * (number_of_repetitions - 1)) / 2 * divisor;
    }
    return 0;
}
