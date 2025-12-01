const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;

const file_utils = @import("file_utils.zig");
const Dial = @import("Dial.zig").Dial;
const DialZeroVisitCounter = @import("Dial.zig").DialZeroVisitCounter;
const Rotation = Dial.Rotation;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input_test = try file_utils.read_input(allocator, 1, true);
    defer allocator.free(input_test);
    const input = try file_utils.read_input(allocator, 1, false);
    defer allocator.free(input);
    solve_1(input_test);
    solve_1(input);
    solve_2(input_test);
    solve_2(input);
}

fn solve_1(input: []u8) void {
    var rotations = tokenizeScalar(u8, input, '\n');
    var dial: Dial = Dial{};
    var zero_halt_counter: u32 = 0;
    while (rotations.next()) |rotation_string| {
        const rotation = Rotation.parse_rotation(rotation_string);
        dial.apply_rotation(rotation);
        if (dial.value == 0) {
            zero_halt_counter += 1;
        }
    }
    print("{}\n", .{zero_halt_counter});
}

fn solve_2(input: []u8) void {
    var rotations = tokenizeScalar(u8, input, '\n');
    var dial = Dial{};
    var zero_visit_counter: i32 = 0;
    while (rotations.next()) |rotation_string| {
        const rotation = Rotation.parse_rotation(rotation_string);
        zero_visit_counter += dial.calculate_zero_visits(rotation);
        dial.apply_rotation(rotation);
    }
    print("{}\n", .{zero_visit_counter});
}
