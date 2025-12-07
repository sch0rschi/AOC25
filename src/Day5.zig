const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeSequence = std.mem.tokenizeSequence;
const parseInt = std.fmt.parseInt;

const input: []const u8 = @embedFile("day5");

const Range = struct { from: u64, to: u64 };

pub fn main() void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();

    const parsed = parse_input_merge_ranges(allocator);
    const id_ranges = parsed.ranges;
    defer allocator.free(id_ranges);
    const ids = parsed.ids;
    defer allocator.free(ids);

    solve_1(id_ranges, ids);
    solve_2(id_ranges);
}

fn solve_1(id_ranges: []Range, ids: []u64) void {
    var sum: u16 = 0;
    for (ids) |id| {
        sum += for (id_ranges) |range| {
            if (range.from <= id and id <= range.to) {
                break 1;
            }
        } else 0;
    }

    print("{}\n", .{sum});
}

fn solve_2(id_ranges: []Range) void {
    var sum: u64 = 0;
    for (id_ranges) |id_range| {
        sum += id_range.to - id_range.from + 1;
    }
    print("{}\n", .{sum});
}

inline fn parse_input_merge_ranges(allocator: std.mem.Allocator) struct { ranges: []Range, ids: []u64 } {
    var content = tokenizeSequence(u8, input, "\n\n");
    var id_ranges_string = tokenizeScalar(u8, content.next().?, '\n');
    var id_ranges: []Range = allocator.alloc(Range, 171) catch unreachable;
    var last_range: usize = 0;
    while (id_ranges_string.next()) |id_range_string| {
        var id_range_tokens = tokenizeScalar(u8, id_range_string, '-');
        const from = parseInt(u64, id_range_tokens.next().?, 10) catch unreachable;
        const to = parseInt(u64, id_range_tokens.next().?, 10) catch unreachable;
        id_ranges[last_range] = Range{ .from = from, .to = to };
        last_range += 1;
    }
    id_ranges = allocator.realloc(id_ranges, last_range) catch unreachable;

    var outer_loop_index: usize = 0;
    var inner_loop_index: usize = 0;

    outer_while: while (outer_loop_index < last_range) {
        inner_loop_index = outer_loop_index + 1;
        inner_while: while (inner_loop_index < last_range) {
            const range_1 = id_ranges[outer_loop_index];
            const range_2 = id_ranges[inner_loop_index];
            if (range_1.from <= range_2.from and range_1.to >= range_2.to) {
                id_ranges[inner_loop_index] = id_ranges[last_range - 1];
                last_range -= 1;
                continue :inner_while;
            } else if (range_2.from <= range_1.from and range_2.to >= range_1.to) {
                id_ranges[outer_loop_index] = id_ranges[inner_loop_index];
                id_ranges[inner_loop_index] = id_ranges[last_range - 1];
                last_range -= 1;
                continue :outer_while;
            } else if (range_1.to >= range_2.from and range_1.from <= range_2.to or range_2.to >= range_1.from and range_2.from <= range_1.to) {
                id_ranges[outer_loop_index] = Range{ .from = @min(range_1.from, range_2.from), .to = @max(range_1.to, range_2.to) };
                id_ranges[inner_loop_index] = id_ranges[last_range - 1];
                last_range -= 1;
                continue :outer_while;
            }
            inner_loop_index += 1;
        }
        outer_loop_index += 1;
    }
    id_ranges = allocator.realloc(id_ranges, inner_loop_index) catch unreachable;

    var id_strings = tokenizeScalar(u8, content.next().?, '\n');
    var ids: []u64 = allocator.alloc(u64, 1000) catch unreachable;
    var last_id: usize = 0;
    while (id_strings.next()) |id_string| {
        ids[last_id] = parseInt(u64, id_string, 10) catch unreachable;
        last_id += 1;
    }
    ids = allocator.realloc(ids, last_id) catch unreachable;

    return .{ .ranges = id_ranges, .ids = ids };
}
