const std = @import("std");
const print = std.debug.print;

const file_utils = @import("file_utils.zig");

const MAX_SIZE = 137 + 2;

const Grid = struct {
    data: [MAX_SIZE * MAX_SIZE]bool,
    width: usize,
    height: usize,

    fn init(input: []const u8) Grid {
        var grid = Grid{
            .data = undefined,
            .width = 0,
            .height = 0,
        };

        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        var row: usize = 1;
        grid.width = lines.peek().?.len + 2;
        while (lines.next()) |line| : (row += 1) {
            for (line, 1..) |char, col| {
                grid.set(row, col, char == '@');
            }
        }
        grid.height = row + 1;
        for (0..grid.width) |column_index| {
            grid.set(0, column_index, false);
            grid.set(grid.height - 1, column_index, false);
        }
        for (0..grid.height) |row_index| {
            grid.set(row_index, 0, false);
            grid.set(row_index, grid.width - 1, false);
        }

        return grid;
    }

    inline fn get(self: *const Grid, row: usize, col: usize) bool {
        return self.data[row * MAX_SIZE + col];
    }

    inline fn set(self: *Grid, row: usize, col: usize, value: bool) void {
        self.data[row * MAX_SIZE + col] = value;
    }
};

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    //const input_test = file_utils.read_input(allocator, 4, true) catch unreachable;
    //defer allocator.free(input_test);
    //var grid_test = Grid.init(input_test);
    const input = file_utils.read_input(allocator, 4, false) catch unreachable;
    defer allocator.free(input);
    var grid = Grid.init(input);

    //solve_1(&grid_test);
    solve_1(&grid);
    //solve_2(&grid_test);
    solve_2(&grid);
}

fn solve_1(grid: *const Grid) void {
    const sum = count_removals(grid);
    print("{}\n", .{sum});
}

inline fn count_removals(grid: *const Grid) i32 {
    var sum: i32 = 0;

    for (1..grid.height - 1) |row| {
        for (1..grid.width - 1) |col| {
            if (!grid.get(row, col)) continue;

            const counter: u8 = count_neighbours(grid, row, col);

            if (counter < 4) sum += 1;
        }
    }

    return sum;
}

inline fn count_neighbours(grid: *const Grid, row: usize, col: usize) u8 {
    return
        @as(u8, @intFromBool(grid.get(row - 1, col - 1))) +
        @as(u8, @intFromBool(grid.get(row - 1, col))) +
        @as(u8, @intFromBool(grid.get(row - 1, col + 1))) +
        @as(u8, @intFromBool(grid.get(row, col - 1))) +
        @as(u8, @intFromBool(grid.get(row, col + 1))) +
        @as(u8, @intFromBool(grid.get(row + 1, col - 1))) +
        @as(u8, @intFromBool(grid.get(row + 1, col))) +
        @as(u8, @intFromBool(grid.get(row + 1, col + 1)));
}

fn solve_2(grid: *Grid) void {
    print("{}\n", .{count_removables(grid)});
}

inline fn count_removables(grid: *Grid) i16 {
    var sum: i16 = 0;
    for (1..grid.height - 1) |row| {
        for (1..grid.width - 1) |col| {
            if (grid.get(row, col)) {
                sum += count_removables_recursion(grid, row, col);
            }
        }
    }

    return sum;
}

fn count_removables_recursion(grid: *Grid, row: usize, col: usize) i16 {
    if (!grid.get(row, col)) {
        return 0;
    }
    var sum: i16 = 0;
    const removed: u8 = count_neighbours(grid, row, col);
    if (removed < 4) {
        sum += 1;
        grid.set(row, col, false);
        sum += count_removables_recursion(grid, row + 1, col);
        sum += count_removables_recursion(grid, row + 1, col + 1);
        sum += count_removables_recursion(grid, row, col + 1);
        sum += count_removables_recursion(grid, row - 1, col + 1);
        sum += count_removables_recursion(grid, row - 1, col);
        sum += count_removables_recursion(grid, row - 1, col - 1);
        sum += count_removables_recursion(grid, row, col - 1);
        sum += count_removables_recursion(grid, row + 1, col - 1);
    }
    return sum;
}
