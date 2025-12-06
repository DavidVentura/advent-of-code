const std = @import("std");

fn println(comptime str: []const u8, any: anytype) void {
    std.debug.print(str, any);
    std.debug.print("\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //const res = try process_file(gpa.allocator(), "test-input2.txt");
    //const res = try process_file(gpa.allocator(), "test-input.txt");
    const res = try process_file(gpa.allocator(), "input.txt");
    std.debug.print("res {}\n", .{res});
}

pub fn process_file(alloc: std.mem.Allocator, fname: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();
    var buf: [32 * 1024]u8 = undefined;
    var reader = file.reader(&buf);
    var res: u64 = 0;

    var lines: std.ArrayList([]u8) = .empty;
    var last_line: []u8 = undefined;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line[0] == '*' or line[0] == '+') {
            last_line = line;
            break;
        }

        try lines.append(alloc, line);
    }

    var ops: std.ArrayList(u8) = .empty;
    var columns_start: std.ArrayList(u64) = .empty;
    for (last_line, 0..) |c, i| {
        if (c == '+' or c == '*') {
            try ops.append(alloc, c);
            try columns_start.append(alloc, i);
        }
    }

    const columns = ops.items.len;
    const rows = lines.items.len;
    println("columns {} rows {}", .{ columns, rows });

    for (0..columns) |column| {
        const col_start = columns_start.items[column];
        const col_end = if (column < columns - 1)
            columns_start.items[column + 1] - 1
        else
            // every line has same width
            last_line.len;

        const max_digits: u64 = col_end - col_start;

        const op = ops.items[column];
        var col_total: u64 = if (op == '+') 0 else 1; // identity
        for (0..max_digits) |di| {
            var vertical_num: u64 = 0;
            for (0..rows) |row| {
                const line = lines.items[row];
                const num_str = line[col_start..col_end];

                const maybe_digit = num_str[di];
                //println("num_str = '{s}', di = {}, maybe = '{c}'", .{ num_str, di, maybe_digit });
                if (maybe_digit == ' ') {
                    continue;
                }
                const digit = try std.fmt.charToDigit(maybe_digit, 10);
                vertical_num = vertical_num * 10 + digit;
            }
            println("vertical_num {}, op {c}", .{ vertical_num, op });
            if (op == '+') {
                col_total += vertical_num;
            } else {
                col_total *= vertical_num;
            }
        }
        println("col_total {}", .{col_total});
        res += col_total;

        println("", .{});
    }

    return res;
}
