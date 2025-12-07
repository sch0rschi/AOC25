const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;

const file_utils = @import("file_utils.zig");

pub fn main() void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();

    const input = file_utils.read_input(allocator, 7, false) catch unreachable;
    defer allocator.free(input);
    var line_tokens = tokenizeScalar(u8, input, '\n');
    var grid: [71][141]i64 = undefined;
    var row_index_counter: usize = 0;
    var width: usize = 0;

    while (line_tokens.next()) |line_string| : (row_index_counter += 1) {
        for (line_string, 0..) |character, column_index| {
            switch (character) {
                '.' => grid[row_index_counter][column_index] = 0,
                '^' => grid[row_index_counter][column_index] = -1,
                else => grid[row_index_counter][column_index] = 1,
            }
            width = column_index+1;
        }
        _ = line_tokens.next();
    }
    var grid_slice = grid[0..row_index_counter];

    var count: i32 = 0;
    for(grid_slice[1..], 1..) |row, row_index| {
        for (row[0..width], 0..) |cell, column_index| {
            switch (cell) {
                -1 => {
                    if (grid_slice[row_index - 1][column_index] >= 1) {
                        count += 1;
                        grid_slice[row_index][column_index-1] += grid_slice[row_index - 1][column_index];
                        grid_slice[row_index][column_index+1] += grid_slice[row_index - 1][column_index];
                    }
                },
                else => {
                    if (grid_slice[row_index - 1][column_index] >= 1) {
                        grid_slice[row_index][column_index] += grid_slice[row_index - 1][column_index];
                    }
                },
            }
        }
    }

    print("{}\n", .{count});
    var sum: i64 = 0;
    for (grid_slice[row_index_counter-1][0..width]) |value| {
        if (value > 0) {
            sum += value;
        }
    }
    print("{}\n", .{sum});
}
