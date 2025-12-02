const std = @import("std");
const expect = std.testing.expect;

test "test data" {
    const result = try process("test_data.txt");
    try std.testing.expectEqual(result, 1227775554);
}

pub fn process(fname: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();

    var buf: [1024]u8 = undefined;
    var reader = file.reader(&buf);
    var invalid_sum: u64 = 0;
    while (try reader.interface.takeDelimiter(',')) |bare_line| {
        const line = std.mem.trim(u8, bare_line, "\n");
        var it = std.mem.splitScalar(u8, line, '-');
        std.log.info("{s}", .{line});
        const _start = it.next() orelse return error.InvalidFormat;
        const _end = it.next() orelse return error.InvalidFormat;
        if (it.next() != null) return error.TooManyParts;

        const start = try std.fmt.parseInt(u64, _start, 10);
        const end = try std.fmt.parseInt(u64, _end, 10);
        std.log.info(" {d} {d}", .{ start, end });
        for (start..end + 1) |val| {
            const digit_count = std.math.log10(val) + 1;
            if (digit_count % 2 != 0) {
                continue;
            }
            var num_buf: [20]u8 = undefined; // we know its digit_count but must be comptime
            const val_str = try std.fmt.bufPrint(&num_buf, "{}", .{val});
            const first_half = val_str[0 .. digit_count / 2];
            const second_half = val_str[digit_count / 2 .. digit_count];
            if (std.mem.eql(u8, first_half, second_half)) {
                std.log.info(" dc {} even digits {} (str {s} = {s} {s})", .{ digit_count, val, val_str, first_half, second_half });
                invalid_sum += val;
            }
        }
    }
    return invalid_sum;
}
pub fn main() !void {
    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();
    //const gpa = arena.allocator();

    const invalid_sum = try process("problem-1.txt");
    //const invalid_sum = try process("test_data.txt");
    std.log.info(" Invalid sum {d}", .{invalid_sum});
}
