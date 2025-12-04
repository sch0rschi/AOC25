const std = @import("std");
const print = std.debug.print;
const tokenizeAny = std.mem.tokenizeAny;

const file_utils = @import("file_utils.zig");
const simple_regex = @import("regex_utils.zig").simple_regex;

const repetitions_divisors: [12][]const u64 = .{ // redundant checks removed
    &[_]u64{},
    &[_]u64{},
    &[_]u64{11},
    &[_]u64{111},
    &[_]u64{101},
    &[_]u64{11111},
    &[_]u64{ 1001, 10101, 111111 },
    &[_]u64{1111111},
    &[_]u64{ 10001 },
    &[_]u64{1001001},
    &[_]u64{ 100001, 101010101, 1111111111 },
    &[_]u64{11111111111},
};

const repetition_divisors: [12]u64 = .{
    1, 0, 11, 0, 101, 0, 1001, 0, 10001, 0, 100001, 0,
};

const powers_of_10 = [_]usize{ 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 10000000000, 100000000000 };

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    //const input_test = file_utils.read_input(allocator, 2, true) catch unreachable;
    //defer allocator.free(input_test);
    const input = file_utils.read_input(allocator, 2, false) catch unreachable;
    defer allocator.free(input);

    //solve_1(input_test);
    solve_1(input);
    //solve_2(input_test);
    solve_2(input);
}

fn solve_1(input: []u8) void {
    var lines = tokenizeAny(u8, input, ",\n");
    var sum: usize = 0;
    while (lines.next()) |line| {
        var range = std.mem.splitScalar(u8, line, '-');
        const from = std.fmt.parseInt(usize, range.next().?, 10) catch unreachable;
        const to = std.fmt.parseInt(usize, range.next().?, 10) catch unreachable;

        var current = from;
        while (current <= to) {
            const len: u8 = 1 + @as(u8, @intCast(std.math.log10(current)));
            const next_boundary = powers_of_10[len];
            const range_end = @min(to, next_boundary - 1);
            const divisor = repetition_divisors[len];

            if (@mod(len, 2) == 0) {
                sum += calculate_divisions_in_range_for_divisor(current, divisor,range_end);
            }

            current = range_end + 1;
        }
    }
    print("{d}\n", .{sum});
}

inline fn calculate_divisions_in_range_for_divisor(current: usize, divisor: u64, range_end: u64) usize {
    var sum : u64 = 0;
    const ceil_division_from = @divFloor(current + divisor - 1, divisor);
    const floor_division_to = @divFloor(range_end, divisor);
    if (ceil_division_from <= floor_division_to) {
        const number_of_repetitions = floor_division_to - ceil_division_from + 1;
        const first_repetition = ceil_division_from * divisor;
        sum += first_repetition * number_of_repetitions;
        sum += (number_of_repetitions * (number_of_repetitions-1))/2 * divisor;
    }
    return sum;
}

fn solve_2(input: []u8) void {
    var lines = tokenizeAny(u8, input, ",\n");
    var sum: usize = 0;
    while (lines.next()) |line| {
        var range = std.mem.splitScalar(u8, line, '-');
        const from = std.fmt.parseInt(usize, range.next().?, 10) catch unreachable;
        const to = std.fmt.parseInt(usize, range.next().?, 10) catch unreachable;

        var current = from;
        while (current <= to) {
            const len: u8 = 1 + @as(u8, @intCast(std.math.log10(current)));
            const next_boundary = powers_of_10[len];
            const range_end = @min(to, next_boundary - 1);
            const divisors = repetitions_divisors[len];

            if (divisors.len == 1) {
                sum += calculate_divisions_in_range_for_divisor(current, divisors[0],range_end);
            } else if (divisors.len == 3) {
                sum += calculate_divisions_in_range_for_divisor(current, divisors[0],range_end);
                sum += calculate_divisions_in_range_for_divisor(current, divisors[1],range_end);
                sum -= calculate_divisions_in_range_for_divisor(current, divisors[2],range_end);
            }

            current = range_end + 1;
        }
    }
    print("{d}\n", .{sum});
}

inline fn is_repeated_patterns(id: u64, len: usize) bool {
    for (repetitions_divisors[len]) |divisor| {
        if (id % divisor == 0) return true;
    }
    return false;
}
