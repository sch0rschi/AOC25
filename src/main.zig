const std = @import("std");
const print = std.debug.print;

const Days = struct {
    pub const Day_1 = @import("Day1.zig");
    pub const Day_2 = @import("Day2.zig");
    pub const Day_3 = @import("Day3.zig");
};

pub fn main() !void {
    const info = @typeInfo(Days);

    inline for (info.@"struct".decls, 1..) |decl, day_index| {
        const module = @field(Days, decl.name);
        print("=== Starting day {} ===\n", .{day_index});
        module.main();
    }
}
