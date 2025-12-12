const std = @import("std");
const print = std.debug.print;

const input: []const u8 = @embedFile("day9");

const NUMBER_OF_RED_TILES = 496;

const Tile = struct { x: u32, y: u32 };
const Square = struct {
    min_x: u32,
    min_y: u32,
    max_x: u32,
    max_y: u32,
};

inline fn conflict_free(square: Square, line: Square) bool {
    return square.max_x <= line.min_x or square.max_y <= line.min_y or square.min_x >= line.max_x or square.min_y >= line.max_y;
}

inline fn parse_u32(ptr: *[]const u8) u32 {
    var v: u32 = 0;
    while (ptr.*.len != 0) {
        const c = ptr.*[0];
        if (c < '0' or c > '9') break;
        v = v * 10 + @as(u32, @intCast(c - '0'));
        ptr.* = ptr.*[1..];
    }
    return v;
}

pub fn main() void {
    var rede_tiles: [NUMBER_OF_RED_TILES]Tile = undefined;
    var lines: [NUMBER_OF_RED_TILES]Square = undefined;

    var input_pointer: []const u8 = input;

    // First iteration
    var x = parse_u32(&input_pointer);
    input_pointer = input_pointer[1..];
    var y = parse_u32(&input_pointer);
    if (input_pointer.len != 0) input_pointer = input_pointer[1..];
    rede_tiles[0] = .{ .x = x, .y = y };

    // Rest of iterations
    for (1..NUMBER_OF_RED_TILES) |i| {
        x = parse_u32(&input_pointer);
        input_pointer = input_pointer[1..];
        y = parse_u32(&input_pointer);
        if (input_pointer.len != 0) input_pointer = input_pointer[1..];
        rede_tiles[i] = .{ .x = x, .y = y };

        const a = rede_tiles[i - 1];
        const b = rede_tiles[i];
        lines[i - 1] = .{
            .min_x = @min(a.x, b.x),
            .min_y = @min(a.y, b.y),
            .max_x = @max(a.x, b.x),
            .max_y = @max(a.y, b.y),
        };
    }

    // First iteration with missing information
    const a = rede_tiles[NUMBER_OF_RED_TILES - 1];
    const b = rede_tiles[0];
    lines[NUMBER_OF_RED_TILES - 1] = .{
        .min_x = @min(a.x, b.x),
        .min_y = @min(a.y, b.y),
        .max_x = @max(a.x, b.x),
        .max_y = @max(a.y, b.y),
    };

    var prng = std.Random.DefaultPrng.init(0);
    prng.random().shuffle(Square, &lines);

    var max_part1: u64 = 0;
    var max_part2: u64 = 0;

    for (0..NUMBER_OF_RED_TILES) |index_1| {
        const tile_1 = rede_tiles[index_1];

        for (index_1 + 1..NUMBER_OF_RED_TILES) |index_2| {
            const tile_2 = rede_tiles[index_2];

            const square_max_x = @max(tile_1.x, tile_2.x);
            const square_min_x = @min(tile_1.x, tile_2.x);
            const square_max_y = @max(tile_1.y, tile_2.y);
            const square_min_y = @min(tile_1.y, tile_2.y);

            const current_area =
                (@as(u64, square_max_x - square_min_x) + 1) *
                (@as(u64, square_max_y - square_min_y) + 1);

            if (current_area > max_part2) {
                if (current_area > max_part1) {
                    max_part1 = current_area;
                }

                const sq = Square{
                    .min_x = square_min_x,
                    .min_y = square_min_y,
                    .max_x = square_max_x,
                    .max_y = square_max_y,
                };

                var conflict = false;
                comptime var k: comptime_int = 0;
                inline while (k < NUMBER_OF_RED_TILES) : (k += 1) {
                    if (!conflict_free(sq, lines[k])) {
                        conflict = true;
                        break;
                    }
                }

                if (!conflict)
                    max_part2 = current_area;
            }
        }
    }

    print("{}\n{}\n", .{ max_part1, max_part2 });
}
