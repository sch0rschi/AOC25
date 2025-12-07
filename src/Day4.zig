const std = @import("std");
const print = std.debug.print;

const input: []const u8 = @embedFile("day4");

const SIZE_WITH_BORDER: usize = 137 + 2;
const GRID_AREA = SIZE_WITH_BORDER * SIZE_WITH_BORDER;
const SIZE: usize = 137;

pub fn main() void {
    var data: [GRID_AREA]bool = undefined;
    var data_counter: [GRID_AREA]i8 = undefined;
    for (0..SIZE_WITH_BORDER) |column_index| {
        data[column_index] = false;
        data[GRID_AREA - SIZE_WITH_BORDER + column_index] = false;
        data_counter[column_index] = -1;
        data_counter[GRID_AREA - SIZE_WITH_BORDER + column_index] = -1;
    }
    for (0..SIZE_WITH_BORDER) |row_index| {
        data[row_index * SIZE_WITH_BORDER] = false;
        data[row_index * SIZE_WITH_BORDER + SIZE_WITH_BORDER - 1] = false;
        data_counter[row_index * SIZE_WITH_BORDER] = -1;
        data_counter[row_index * SIZE_WITH_BORDER + SIZE_WITH_BORDER - 1] = -1;
    }

    var input_index: usize = 0;
    for (1..SIZE + 1) |row_index| {
        const offset = row_index * SIZE_WITH_BORDER;
        for (1..SIZE + 1) |col_index| {
            data[offset + col_index] = input[input_index] == '@';
            input_index += 1;
        }
        input_index += 1;
    }

    var sum: i16 = 0;
    for (1..SIZE + 1) |row| {
        const offset = row * SIZE_WITH_BORDER;
        for (1..SIZE + 1) |col| {
            if (!data[offset + col]) {
                data_counter[offset + col] = -1;
                continue;
            }

            const counter: i8 = count_neighbours(&data, offset + col);
            data_counter[offset + col] = @max(1, counter);
            if (counter < 4) {
                sum += 1;
            }
        }
    }
    print("{}\n", .{sum});

    sum = 0;
    for (1..SIZE + 1) |row| {
        const offset = row * SIZE_WITH_BORDER;
        for (1..SIZE + 1) |col| {
            if (data_counter[offset + col] > 0 and data_counter[offset + col] < 4) {
                sum += count_removables_recursion(&data_counter, offset + col);
            }
        }
    }

    print("{}\n", .{sum});
}

inline fn count_neighbours(data: *[GRID_AREA]bool, offset: usize) i8 {
    return
        @as(i8, @intFromBool(data[offset - SIZE_WITH_BORDER - 1])) +
        @as(i8, @intFromBool(data[offset - SIZE_WITH_BORDER])) +
        @as(i8, @intFromBool(data[offset - SIZE_WITH_BORDER + 1])) +
        @as(i8, @intFromBool(data[offset - 1])) +
        @as(i8, @intFromBool(data[offset + 1])) +
        @as(i8, @intFromBool(data[offset + SIZE_WITH_BORDER - 1])) +
        @as(i8, @intFromBool(data[offset + SIZE_WITH_BORDER])) +
        @as(i8, @intFromBool(data[offset + SIZE_WITH_BORDER + 1]));
}

fn count_removables_recursion(grid: *[GRID_AREA]i8, offset: usize) i16 {
    var sum: i16 = 0;
    if (grid[offset] >= 0 and grid[offset] < 4) {
        sum += 1;
        grid[offset] = -1;

        grid[offset - SIZE_WITH_BORDER - 1] -= 1;
        grid[offset - SIZE_WITH_BORDER] -= 1;
        grid[offset - SIZE_WITH_BORDER + 1] -= 1;
        grid[offset - 1] -= 1;
        grid[offset + 1] -= 1;
        grid[offset + SIZE_WITH_BORDER - 1] -= 1;
        grid[offset + SIZE_WITH_BORDER] -= 1;
        grid[offset + SIZE_WITH_BORDER + 1] -= 1;
        sum += count_removables_recursion(grid, offset - SIZE_WITH_BORDER - 1);
        sum += count_removables_recursion(grid, offset - SIZE_WITH_BORDER);
        sum += count_removables_recursion(grid, offset - SIZE_WITH_BORDER + 1);
        sum += count_removables_recursion(grid, offset - 1);
        sum += count_removables_recursion(grid, offset + 1);
        sum += count_removables_recursion(grid, offset + SIZE_WITH_BORDER - 1);
        sum += count_removables_recursion(grid, offset + SIZE_WITH_BORDER);
        sum += count_removables_recursion(grid, offset + SIZE_WITH_BORDER + 1);
    }
    return sum;
}
