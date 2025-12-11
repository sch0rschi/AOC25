const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;

const input: []const u8 = @embedFile("day11");

const Node = struct {
    children: std.ArrayList(*Node),
    number_of_unprocessed_parents: u8,
    number_of_paths: u64,
    reachable_from: bool,
};

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var nodes = std.StringHashMap(*Node).init(allocator);
    defer {
        var it = nodes.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.*.children.deinit(allocator);
            allocator.destroy(entry.value_ptr.*);
        }
        nodes.deinit();
    }

    var line_tokens = tokenizeScalar(u8, input, '\n');
    while (line_tokens.next()) |line_string| {
        var connection_tokens = tokenizeAny(u8, line_string, ": ");
        const parent_key = connection_tokens.next().?;
        if (!nodes.contains(parent_key)) {
            var parent_node = allocator.create(Node) catch unreachable;
            parent_node.children = std.ArrayList(*Node).empty;
            parent_node.number_of_unprocessed_parents = 0;
            parent_node.number_of_paths = 0;
            parent_node.reachable_from = false;
            nodes.put(parent_key, parent_node) catch unreachable;
        }
        var parent_node: *Node = nodes.get(parent_key).?;
        while (connection_tokens.next()) |child_string| {
            if (nodes.contains(child_string)) {} else {
                var child_node = allocator.create(Node) catch unreachable;
                child_node.children = std.ArrayList(*Node).empty;
                child_node.number_of_unprocessed_parents = 0;
                child_node.number_of_paths = 0;
                child_node.reachable_from = false;
                nodes.put(child_string, child_node) catch unreachable;
            }
            parent_node.children.append(allocator, nodes.get(child_string).?) catch unreachable;
        }
    }

    const out_node = nodes.get("out").?;
    const you_node = nodes.get("you").?;
    fill_paths_from(you_node, &nodes);
    print("{}\n", .{out_node.number_of_paths});

    const svr_node = nodes.get("svr").?;
    const dac_node = nodes.get("dac").?;
    const fft_node = nodes.get("fft").?;
    fill_paths_from(svr_node, &nodes);
    const from_svr_to_dac = dac_node.number_of_paths;
    const from_svr_to_fft = fft_node.number_of_paths;
    fill_paths_from(dac_node, &nodes);
    const from_dac_to_fft = fft_node.number_of_paths;
    const from_dac_to_out = out_node.number_of_paths;
    fill_paths_from(fft_node, &nodes);
    const from_fft_to_dac = dac_node.number_of_paths;
    const from_fft_to_out = out_node.number_of_paths;
    print("{}\n", .{from_svr_to_dac * from_dac_to_fft * from_fft_to_out +
        from_svr_to_fft * from_fft_to_dac * from_dac_to_out});
}

fn fill_paths_from(from: *Node, nodes: *std.StringHashMap(*Node)) void {
    reset_nodes(nodes);
    from.reachable_from = true;
    from.number_of_paths = 1;
    set_hull(from);
    set_unprocessed_parents(nodes);
    fill_paths_counter(from);
}

fn reset_nodes(nodes: *std.StringHashMap(*Node)) void {
    var nodes_it = nodes.valueIterator();
    while (nodes_it.next()) |node| {
        node.*.number_of_paths = 0;
        node.*.number_of_unprocessed_parents = 0;
        node.*.reachable_from = false;
    }
}

fn set_hull(node: *Node) void {
    for (node.children.items) |child| {
        if (!child.reachable_from) {
            child.reachable_from = true;
            set_hull(child);
        }
    }
}

fn set_unprocessed_parents(nodes: *std.StringHashMap(*Node)) void {
    var nodes_it = nodes.valueIterator();
    while (nodes_it.next()) |child_node| {
        if (child_node.*.*.reachable_from) {
            for (child_node.*.children.items) |child| {
                child.number_of_unprocessed_parents += 1;
            }
        }
    }
}

fn fill_paths_counter(node: *Node) void {
    for (node.children.items) |child| {
        child.number_of_unprocessed_parents -= 1;
        child.number_of_paths += node.number_of_paths;
        if (child.number_of_unprocessed_parents == 0) {
            fill_paths_counter(child);
        }
    }
}
