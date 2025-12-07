const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;

const Dial = @import("Dial.zig").Dial;
const DialZeroVisitCounter = @import("Dial.zig").DialZeroVisitCounter;
const Rotation = Dial.Rotation;

const input: []const u8 = @embedFile("day1");

pub fn main() void {
    solve_1();
    solve_2();
}

fn solve_1() void {
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

fn solve_2() void {
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
