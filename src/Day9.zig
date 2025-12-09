const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;

const input: []const u8 = @embedFile("day9");

const NUMBER_OF_RED_TILES = 496;

pub fn main() void {
    var red_tiles: [NUMBER_OF_RED_TILES][2]u32 = undefined;
    var lines = tokenizeScalar(u8, input, '\n');
    var line_counter: usize = 0;
    while (lines.next()) |line| : (line_counter += 1) {
        var numbers = tokenizeScalar(u8, line, ',');
        red_tiles[line_counter][0] = std.fmt.parseInt(u32, numbers.next().?, 10) catch unreachable;
        red_tiles[line_counter][1] = std.fmt.parseInt(u32, numbers.next().?, 10) catch unreachable;
    }

    var edges_min_maxs: [NUMBER_OF_RED_TILES][4]u32 = undefined;
    for (0..NUMBER_OF_RED_TILES) |check_index| {
        const check_tile_from = red_tiles[check_index];
        const check_tile_to = red_tiles[@mod(check_index + 1, NUMBER_OF_RED_TILES)];
        edges_min_maxs[check_index][0] = @min(check_tile_from[0], check_tile_to[0]); // min x
        edges_min_maxs[check_index][1] = @min(check_tile_from[1], check_tile_to[1]); // min y
        edges_min_maxs[check_index][2] = @max(check_tile_from[0], check_tile_to[0]); // max x
        edges_min_maxs[check_index][3] = @max(check_tile_from[1], check_tile_to[1]); // max y
    }


    var prng = std.Random.DefaultPrng.init(12345);
    const rnd = prng.random();
    var shuffle_indices: [NUMBER_OF_RED_TILES]usize = undefined;
    for (&shuffle_indices, 0..) |*array_index, index| {
        array_index.* = index;
    }
    rnd.shuffle(usize, &shuffle_indices);
    rnd.shuffle([4]u32, &edges_min_maxs);

    var max_area_part_1: u64 = 0;
    var max_area_part_2: u64 = 0;
    for (0..NUMBER_OF_RED_TILES) |shuffle_index_tile_1| {
        const red_tile_1 = red_tiles[shuffle_indices[shuffle_index_tile_1]];
        for (shuffle_indices[shuffle_index_tile_1 + 1 .. NUMBER_OF_RED_TILES]) |shuffle_index_tile_2| {
            const red_tile_2 = red_tiles[shuffle_index_tile_2];
            const x_delta: u64 = @intCast(@max(red_tile_1[0], red_tile_2[0]) - @min(red_tile_1[0], red_tile_2[0]));
            const y_delta: u64 = @intCast(@max(red_tile_1[1], red_tile_2[1]) - @min(red_tile_1[1], red_tile_2[1]));
            const current_area = (x_delta + 1) * (y_delta + 1);
            max_area_part_1 = @max(max_area_part_1, current_area);
            if (current_area > max_area_part_2) {
                var square: [4]u32 = undefined;
                square[0] = @max(red_tile_1[0], red_tile_2[0]);
                square[2] = @min(red_tile_1[0], red_tile_2[0]);
                square[1] = @max(red_tile_1[1], red_tile_2[1]);
                square[3] = @min(red_tile_1[1], red_tile_2[1]);
                const is_conflict = for (0..NUMBER_OF_RED_TILES) |check_index| {
                    if (!conflict_free(&square, &edges_min_maxs[@mod(shuffle_index_tile_1 + check_index, NUMBER_OF_RED_TILES)])) {
                        break true;
                    }
                } else false;
                if (!is_conflict) {
                    max_area_part_2 = current_area;
                }
            }
        }
    }
    print("{}\n", .{max_area_part_1});
    print("{}\n", .{max_area_part_2});
}

inline fn conflict_free(square_min_max: *[4]u32, min_max: *[4]u32) bool {
    return square_min_max[0] <= min_max[0] or square_min_max[1] <= min_max[1] or square_min_max[2] >= min_max[2] or square_min_max[3] >= min_max[3];
}
