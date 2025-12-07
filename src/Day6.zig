const std = @import("std");
const print = std.debug.print;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;

const input: []const u8 = @embedFile("day6");

pub fn main() void {
    var numbers: [1000][4]u64 = undefined;
    var operations: [1000]bool = undefined;
    var input_transposed: [5000][4]u8 = undefined;
    var line_tokens = tokenizeScalar(u8, input, '\n');
    var problem_size: usize = 0;
    const line_length = line_tokens.peek().?.len;
    while (line_tokens.peek().?[0] != '*' and line_tokens.peek().?[0] != '+') : (problem_size += 1) {
        const line = line_tokens.next().?;
        for (line, 0..) |character, index| {
            input_transposed[index][problem_size] = character;
        }
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        var column_index: usize = 0;

        while (it.next()) |number_string| : (column_index += 1) {
            numbers[column_index][problem_size] =
                std.fmt.parseInt(u64, number_string, 10) catch unreachable;
        }
    }

    var subproblems: usize = 0;
    var operations_it = std.mem.tokenizeScalar(u8, line_tokens.next().?, ' ');
    var index: usize = 0;
    while (operations_it.next()) |operation| : (index += 1) {
        operations[index] = std.mem.eql(u8, operation, "+");
        subproblems += 1;
    }

    solve_1(numbers, operations, problem_size, subproblems);
    solve_2(input_transposed[0..line_length], operations[0..subproblems], problem_size);
}

fn solve_1(numberss: [1000][4]u64, operations: [1000]bool, problem_size: usize, subproblems: usize) void {
    var sum: u64 = 0;
    for (operations[0..subproblems], numberss[0..subproblems]) |operation, numbers| {
        if (operation) {
            for (numbers[0..problem_size]) |number| {
                sum += number;
            }
        } else {
            var product: u64 = 1;
            for (numbers[0..problem_size]) |number| {
                product *= number;
            }
            sum += product;
        }
    }
    print("{}\n", .{sum});
}

fn solve_2(input_transposed: [][4]u8, operations: []bool, problem_size: usize) void {
    var sum: u64 = 0;
    var row_index_from: usize = 0;
    operation_blk: for (operations) |operation| {
        if (operation) {
            var sum_part:u64 = 0;
            for (row_index_from..@min(row_index_from + 5, input_transposed.len)) |row_index| {
                if (std.mem.allEqual(u8, input_transposed[row_index][0..problem_size], ' ')) {
                    sum += sum_part;
                    row_index_from = row_index + 1;
                    continue :operation_blk;
                }
                var number_string = tokenizeScalar(u8, input_transposed[row_index][0..problem_size], ' ');
                sum_part += std.fmt.parseInt(u64, number_string.next().?, 10) catch unreachable;
            }
            sum += sum_part;
        } else {
            var product: u64 = 1;
            for (row_index_from..@min(row_index_from + 5, input_transposed.len)) |row_index| {
                if (std.mem.allEqual(u8, input_transposed[row_index][0..problem_size], ' ')) {
                    sum += product;
                    row_index_from = row_index + 1;
                    continue :operation_blk;
                }
                var number_string = tokenizeScalar(u8, input_transposed[row_index][0..problem_size], ' ');
                product *= std.fmt.parseInt(u64, number_string.next().?, 10) catch unreachable;
            }
            sum += product;
        }
    }
    print("{}\n", .{sum});
}

