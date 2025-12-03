const std = @import("std");
const expect = std.testing.expect;

test "test data" {
    const result = try process("test_data.txt");
    try std.testing.expectEqual(result, 1227775554);
}
test "test second part" {
    const result = try process("test_data.txt");
    try std.testing.expectEqual(result, 4174379265);
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
            var num_buf: [32]u8 = undefined; // we know its digit_count but must be comptime
            const val_str = try std.fmt.bufPrint(&num_buf, "{}", .{val});

            //std.log.info("dc {d}", .{digit_count});
            for (1..digit_count) |part_size| {
                if (digit_count % part_size != 0) {
                    continue;
                }
                //std.log.info("ps {d}", .{part_size});
                var part_it = std.mem.window(u8, val_str, part_size, part_size);
                const first_part = part_it.next() orelse return error.MissingFirstPart;
                //std.log.info("fp {s}", .{first_part});

                const all_match = while (part_it.next()) |nth_part| {
                    if (!std.mem.eql(u8, first_part, nth_part)) break false;
                } else true;

                if (all_match) {
                    invalid_sum += val;
                    // std.log.info(" dc {} val {} (part_size: {}, part {s})", .{ digit_count, val, part_size, first_part });
                    break; // need to only count the number as bad once, 2222 just counts once not as `2`, `22`
                }
            }
        }
    }
    return invalid_sum;
}
pub fn main() !void {
    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();
    //const gpa = arena.allocator();

    //const invalid_sum = try process("problem-1.txt");
    const invalid_sum = try process("test_data.txt");
    std.log.info(" Invalid sum {d}", .{invalid_sum});
}
