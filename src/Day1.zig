const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;

const input: []const u8 = @embedFile("day1");
const mod_value: i16 = 100;

pub fn main() void {
    var dial: i16 = 50;
    var zero_halt_counter: u32 = 0;
    var zero_visit_counter: i32 = 0;

    var i: usize = 0;
    const len = input.len;

    while (i < len - 1) {
        const direction_is_left = input[i] == 'L';
        i += 1;

        var rotation_value: i16 = 0;
        while (input[i] != '\n') : (i += 1) {
            rotation_value *= 10;
            rotation_value += (input[i] - '0');
        }
        i+=1;

        const full_rotations = @divTrunc(rotation_value, mod_value);
        const remainder = @rem(rotation_value, mod_value);
        zero_visit_counter += full_rotations;

        if (direction_is_left) {
            const delta = mod_value * @intFromBool(dial == 0) + dial;
            dial = dial - remainder;
            zero_visit_counter += @intFromBool(remainder >= delta);
        } else {
            const delta = mod_value - dial;
            dial = dial + remainder;
            zero_visit_counter += @intFromBool(remainder >= delta);
        }
        dial = @mod(dial, mod_value);
        zero_halt_counter += @intFromBool(dial == 0);
    }
    print("{}\n", .{zero_halt_counter});
    print("{}\n", .{zero_visit_counter});
}
