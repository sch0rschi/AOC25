const std = @import("std");

const Days = struct {
    pub const Day_1 = @import("Day1.zig");
    pub const Day_2 = @import("Day2.zig");
    pub const Day_3 = @import("Day3.zig");
};

pub fn main() !void {
    const info = @typeInfo(Days);

    var total_ns: u64 = 0;

    inline for (info.@"struct".decls) |decl| {
        const day = @field(Days, decl.name);

        const underscore_index = comptime std.mem.indexOfScalar(u8, decl.name, '_').?;
        const num_str = decl.name[underscore_index + 1 ..];

        const day_num = comptime std.fmt.parseInt(u32, num_str, 10) catch @compileError("Invalid day number");

        std.debug.print("=== Day {} ===\n", .{day_num});

        const start = try std.time.Instant.now();
        day.main();
        const end = try std.time.Instant.now();

        const ns = end.since(start);
        total_ns += ns;

        const ms = @as(f64, @floatFromInt(ns)) / 1_000_000.0;
        std.debug.print("=== Day {} finished in {d:.3} ms ===\n\n", .{ day_num, ms });
    }

    const total_ms = @as(f64, @floatFromInt(total_ns)) / 1_000_000.0;
    std.debug.print("=== Total runtime: {d:.3} ms ===\n", .{total_ms});
}
