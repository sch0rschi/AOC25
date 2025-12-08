const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;
const splitScalar = std.mem.splitScalar;

const input: []const u8 = @embedFile("day8");

const NUMBER_OF_NODES = 1000;
const NUMBER_OF_EDGES = NUMBER_OF_NODES * (NUMBER_OF_NODES - 1) / 2;
const PART_1_STOP = 1000;

const UnionFind = struct {
    depth: u16 = 1,
    size: u16 = 1,
    parent_index: usize = NUMBER_OF_NODES,
};

const Edge = struct {
    from: usize,
    to: usize,
    weight: i64, // no root
};

pub fn main() void {
    var nodes: [NUMBER_OF_NODES][3]i64 = undefined;

    var union_find: [NUMBER_OF_NODES]UnionFind = undefined;
    for (&union_find) |*uf| {
        uf.*.depth = 1;
        uf.*.size = 1;
        uf.*.parent_index = NUMBER_OF_NODES;
    }
    var line_tokens = tokenizeScalar(u8, input, '\n');
    for (0..NUMBER_OF_NODES) |line_index| {
        const line_string = line_tokens.next().?;
        var char_pointer = line_string.ptr;
        nodes[line_index][0] = 0;
        while (char_pointer[0] != ',') : (char_pointer += 1) {
            nodes[line_index][0] *= 10;
            nodes[line_index][0] += char_pointer[0] - '0';
        }

        char_pointer += 1;
        nodes[line_index][1] = 0;
        while (char_pointer[0] != ',') : (char_pointer += 1) {
            nodes[line_index][1] *= 10;
            nodes[line_index][1] += char_pointer[0] - '0';
        }

        char_pointer += 1;
        nodes[line_index][2] = 0;
        while (char_pointer[0] != '\n') : (char_pointer += 1) {
            nodes[line_index][2] *= 10;
            nodes[line_index][2] += char_pointer[0] - '0';
        }
    }

    var edges: [NUMBER_OF_EDGES]Edge = undefined;
    var offset: usize = 0;
    for (0..NUMBER_OF_NODES) |from_index| {
        for (from_index + 1..NUMBER_OF_NODES) |to_index| {
            const from = nodes[from_index];
            const to = nodes[to_index];
            edges[offset].from = from_index;
            edges[offset].to = to_index;
            const x_delta = from[0] - to[0];
            const y_delta = from[1] - to[1];
            const z_delta = from[2] - to[2];
            edges[offset].weight = x_delta * x_delta + y_delta * y_delta + z_delta * z_delta;
            offset += 1;
        }
    }

    std.mem.sortUnstable(Edge, &edges, {}, less_weight);

    var connected: usize = 0;
    var union_find_from_root_index: usize = undefined;
    var union_find_to_root_index: usize = undefined;
    for (0..PART_1_STOP) |edge_index| {
        union_find_from_root_index = find_root(edges[edge_index].from, &union_find);
        union_find_to_root_index = find_root(edges[edge_index].to, &union_find);
        if(union_find_from_root_index == union_find_to_root_index) {
            continue;
        }
        var union_find_from_root: *UnionFind = &union_find[union_find_from_root_index];
        var union_find_to_root: *UnionFind = &union_find[union_find_to_root_index];

        if (union_find_from_root.depth < union_find_to_root.depth) {
            union_find_from_root.parent_index = union_find_to_root_index;
            union_find_to_root.depth = @max(union_find_to_root.depth, union_find_from_root.depth + 1);
            union_find_to_root.size += union_find_from_root.size;
        } else {
            union_find_to_root.parent_index = union_find_from_root_index;
            union_find_from_root.depth = @max(union_find_from_root.depth, union_find_to_root.depth + 1);
            union_find_from_root.size += union_find_to_root.size;
        }
        connected += 1;
    }

    var multiplyer: [NUMBER_OF_NODES]u16 = undefined;
    var number_of_multiplyer:usize = 0;
    for (union_find) |uf| {
        if(uf.parent_index == NUMBER_OF_NODES) {
            multiplyer[number_of_multiplyer] = uf.size;
            number_of_multiplyer += 1;
        }
    }
    std.mem.sortUnstable(u16, multiplyer[0..number_of_multiplyer], {}, std.sort.desc(u16));
    print("{}\n", .{multiplyer[0] * multiplyer[1] * multiplyer[2] });

    var edge_index: usize = PART_1_STOP + 1;
    while (connected < NUMBER_OF_NODES - 1): (edge_index += 1) {
        union_find_from_root_index = find_root(edges[edge_index].from, &union_find);
        union_find_to_root_index = find_root(edges[edge_index].to, &union_find);
        if(union_find_from_root_index == union_find_to_root_index) {
            continue;
        }
        var union_find_from_root: *UnionFind = &union_find[union_find_from_root_index];
        var union_find_to_root: *UnionFind = &union_find[union_find_to_root_index];

        if (union_find_from_root.depth < union_find_to_root.depth) {
            union_find_from_root.parent_index = union_find_to_root_index;
            union_find_to_root.depth = @max(union_find_to_root.depth, union_find_from_root.depth + 1);
            union_find_to_root.size += union_find_from_root.size;
        } else {
            union_find_to_root.parent_index = union_find_from_root_index;
            union_find_from_root.depth = @max(union_find_from_root.depth, union_find_to_root.depth + 1);
            union_find_from_root.size += union_find_to_root.size;
        }
        connected += 1;
    }
    const edge = edges[edge_index-1];
    const from = nodes[edge.from];
    const to = nodes[edge.to];
    print("{}\n", .{from[0] * to[0]});
}

fn less_weight(_: void, a: Edge, b: Edge) bool {
    return a.weight < b.weight;
}

inline fn find_root(index: usize, unionFind: *[NUMBER_OF_NODES]UnionFind) usize {
    var current = unionFind[index];
    var current_index = index;
    while (current.parent_index < NUMBER_OF_NODES) {
        current_index = current.parent_index;
        current = unionFind[current_index];
    }
    return current_index;
}
