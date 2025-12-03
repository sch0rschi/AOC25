const std = @import("std");

const Days = struct {
    pub const Day_1 = @import("Day1.zig");
    pub const Day_2 = @import("Day2.zig");
    pub const Day_3 = @import("Day3.zig");
};

pub fn main() !void {
    const info = @typeInfo(Days);

    var total_ns: u64 = 0;

    inline for (info.@"struct".decls, 1..) |decl, day_index| {
        const module = @field(Days, decl.name);

        std.debug.print("=== Day {} ===\n", .{day_index});

        const start = try std.time.Instant.now();
        module.main();
        const end = try std.time.Instant.now();

        const ns = end.since(start);
        total_ns += ns;

        const ms = @as(f64, @floatFromInt(ns)) / 1_000_000.0;
        std.debug.print("Day {} finished in {d:.3} ms\n\n", .{ day_index, ms });
    }

    const total_ms = @as(f64, @floatFromInt(total_ns)) / 1_000_000.0;
    std.debug.print("=== Total runtime: {d:.3} ms ===\n", .{total_ms});
}
