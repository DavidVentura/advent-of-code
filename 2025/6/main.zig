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

    var sum: std.ArrayList(u64) = .empty;
    var mul: std.ArrayList(u64) = .empty;
    var picked: std.ArrayList(u64) = .empty;

    var last_line: []u8 = undefined;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line[0] == '*' or line[0] == '+') {
            last_line = line;
            break;
        }
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        var i: u64 = 0;
        while (it.next()) |split| {
            const num = try std.fmt.parseUnsigned(u64, split, 10);
            if (sum.items.len <= i) {
                try sum.append(alloc, num);
                try mul.append(alloc, num);
                _ = try picked.addOne(alloc);
            } else {
                sum.items[i] += num;
                mul.items[i] *= num;
            }
            i += 1;
        }
    }

    var it = std.mem.tokenizeScalar(u8, last_line, ' ');
    var i: u64 = 0;
    var item: u64 = 0;
    while (it.next()) |op| {
        if (op[0] == '+') {
            item = sum.items[i];
        } else if (op[0] == '*') {
            item = mul.items[i];
        } else {
            return error.WTF;
        }
        picked.items[i] = item;
        res += item;
        i += 1;
    }
    return res;
}
