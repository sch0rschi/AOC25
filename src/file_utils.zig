const std = @import("std");

pub fn read_input(allocator: std.mem.Allocator, day: u8, is_test: bool) ![]u8 {
    const cwd = std.fs.cwd();
    var input_dir = try cwd.openDir("input", .{});
    defer input_dir.close();

    var filename_buf: [10]u8 = undefined;
    const extension = if (is_test) "_test" else "";
    const filename = try std.fmt.bufPrint(&filename_buf, "Day{d}{s}", .{day, extension});

    const file = try input_dir.openFile(filename, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, 15_000_000);
    const bytes_read = try file.read(buffer);
    return allocator.realloc(buffer, bytes_read);
}
