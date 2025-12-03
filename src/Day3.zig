const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;

const file_utils = @import("file_utils.zig");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input_test = file_utils.read_input(allocator, 3, true) catch unreachable;
    defer allocator.free(input_test);
    const input = file_utils.read_input(allocator, 3, false) catch unreachable;
    defer allocator.free(input);
    solve_1(input_test[0..]);
    solve_1(input[0..]);
    solve_2(input_test[0..]);
    solve_2(input[0..]);
}

fn solve_1(input: []u8) void {
    const sum = solve(input, 2);
    print("{}\n", .{sum});
}

fn solve_2(input: []u8) void {
    const sum = solve(input, 12);
    print("{}\n", .{sum});
}

fn solve(input: []u8, number_of_digits: usize) i64 {
    var banks = tokenizeScalar(u8, input, '\n');
    var sum: i64 = 0;
    while (banks.next()) |bank| sum += calculate_max_digit_selection(bank[0..], number_of_digits);
    return sum;
}

inline fn calculate_max_digit_selection(bank: []const u8, number_of_digits: usize) i64 {
    var digits_buf: [100]u8 = undefined;
    for (bank, 0..) |char, i| {
        digits_buf[i] = std.fmt.charToDigit(char, 10) catch unreachable;
    }
    const digits = digits_buf[0..bank.len];

    var aggregate: i64 = 0;
    var last_max_index: usize = 0;

    for (0..number_of_digits) |position| {
        const search_slice = digits[last_max_index .. digits.len - number_of_digits + 1 + position];
        const max_value_index = std.mem.indexOfMax(u8, search_slice);
        const max_value = search_slice[max_value_index];

        last_max_index += max_value_index + 1;
        aggregate *= 10;
        aggregate += max_value;
    }
    return aggregate;
}
