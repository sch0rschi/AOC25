const std = @import("std");
const parseInt = std.fmt.parseInt;
const L = Dial.Rotation.Direction.L;
const R = Dial.Rotation.Direction.R;

pub const Dial = struct {
    value: i16 = 50,

    pub const Rotation = struct {
        direction: Direction,
        value: i16,

        pub const Direction = enum { L, R };

        pub inline fn parse_rotation(rotation_string: []const u8) Rotation {
            const direction = switch (rotation_string[0]) {
                'L' => Rotation.Direction.L,
                'R' => Rotation.Direction.R,
                else => unreachable,
            };
            const value = parseInt(i16, rotation_string[1..], 10) catch unreachable;
            return Rotation{ .direction = direction, .value = value };
        }
    };

    pub inline fn apply_rotation(self: *Dial, rotation: Rotation) void {
        switch (rotation.direction) {
            Dial.Rotation.Direction.L => {
                self.value -= rotation.value;
            },
            Dial.Rotation.Direction.R => {
                self.value += rotation.value;
            },
        }
        self.value = @mod(self.value, 100);
    }

    pub inline fn calculate_zero_visits(self: *const Dial, rotation: Dial.Rotation) i16 {
        const delta = if (rotation.direction == R) 100 - self.value else @mod(self.value - 1, 100) + 1;
        if (rotation.value < delta) {
            return 0;
        } else {
            return @as(i16, 1) + (std.math.divTrunc(i16, rotation.value - delta, @as(i16, 100)) catch unreachable);
        }
    }
};
