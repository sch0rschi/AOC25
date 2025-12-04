const std = @import("std");

const Days = struct {
    pub const Day_1 = @import("Day1.zig");
    pub const Day_2 = @import("Day2.zig");
    //pub const Day2_PCRE2 = @import("Day2_PCRE2.zig");
    pub const Day_3 = @import("Day3.zig");
    pub const Day_4 = @import("Day4.zig");
};

pub fn main() !void {
    const info = @typeInfo(Days);

    var total_ns: u64 = 0;

    inline for (info.@"struct".decls) |decl| {
        const day = @field(Days, decl.name);

        std.debug.print("=== Running {s} ===\n", .{decl.name});

        const start = try std.time.Instant.now();
        day.main();
        const end = try std.time.Instant.now();

        const ns = end.since(start);
        total_ns += ns;

        const ms = @as(f64, @floatFromInt(ns)) / 1_000_000.0;
        std.debug.print("=== {s} finished in {:.3} ms ===\n\n", .{decl.name, ms});
    }

    const total_ms = @as(f64, @floatFromInt(total_ns)) / 1_000_000.0;
    std.debug.print("=== Total runtime: {:.3} ms ===\n", .{total_ms});
}
