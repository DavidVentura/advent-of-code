const std = @import("std");

test "test data p2" {
    const result1 = try parse_line_part2(12, "987654321111111");
    try std.testing.expectEqual(result1, 987654321111);
    const result2 = try parse_line_part2(12, "811111111111119");
    try std.testing.expectEqual(result2, 811111111119);
    const result3 = try parse_line_part2(12, "234234234234278");
    try std.testing.expectEqual(result3, 434234234278);
    const result4 = try parse_line_part2(12, "818181911112111");
    try std.testing.expectEqual(result4, 888911112111);
}

test "test data p2 real" {
    const result = try parse_line_part2(12, "8253243324523333532224546353152554242525224253255824125264455332262523225422354333245722624625223832");
    try std.testing.expectEqual(result, 887665223832);
}

test "test data example" {
    const result1 = try parse_line_part2(2, "987654321111111");
    try std.testing.expectEqual(result1, 98);
    const result2 = try parse_line_part2(2, "811111111111119");
    try std.testing.expectEqual(result2, 89);
    const result3 = try parse_line_part2(2, "234234234234278");
    try std.testing.expectEqual(result3, 78);
    const result4 = try parse_line_part2(2, "818181911112111");
    try std.testing.expectEqual(result4, 92);
}

pub fn parse_line_part2(comptime N: usize, line: []const u8) !u64 {
    var digits: [N]u8 = .{0} ** N;
    var in_digits: [100]u8 = undefined;

    for (line, 0..) |c, i| {
        in_digits[i] = try std.fmt.charToDigit(c, 10);
    }

    const leftover_digits: u8 = @intCast(line.len - digits.len);
    var res: u64 = 0;
    var skipped: u8 = 0;
    for (0..digits.len) |o| {
        //std.debug.print("range is {}..{}\n", .{ o + skipped, o + leftover_digits + 1 });
        var this_skip: u8 = 0;
        var count: u8 = 0;
        for (in_digits[o + skipped .. o + leftover_digits + 1]) |p| {
            //const p = part[0]; // the slice is 1-long
            //std.debug.print("in {d}\n", .{p});
            if (p > digits[o]) {
                digits[o] = p;
                this_skip = count;
                //std.debug.print("^picked skipped\n", .{});
            }
            count += 1;
        }
        skipped += this_skip;
        std.debug.print("picked {d}, skipped {d}\n", .{ digits[o], this_skip });
        res += digits[o] * std.math.pow(u64, 10, digits.len - o - 1);
    }
    return res;
}
pub fn process(fname: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();

    var buf: [32 * 1024]u8 = undefined;
    var reader = file.reader(&buf);
    var res: u64 = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        std.debug.print("line {s}\n", .{line});
        const line_res = try parse_line_part2(12, line);
        std.debug.print(" res = {d}\n", .{line_res});
        res += line_res;
    }
    return res;
}

pub fn main() !void {
    const res = try process("input.txt");
    //const res = try process("test_input.txt");
    std.log.info(" result {d}", .{res});
}
