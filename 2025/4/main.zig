const std = @import("std");

const Neighbors = packed struct {
    p: u3,
    c: u2,
    n: u3,
};

pub fn count(n: Neighbors) u8 {
    return @popCount(@as(u8, @bitCast(n)));
}

pub fn main() !void {
    // for each position, store 8 bits: pppccnnn (prev cur next line bit)
    // each line: calcs self, adds itself to prev, adds prev to self.. then no need to do it?
    //const res = try process(3, "test-input.txt");
    //const res = try process(10, "test-input2.txt");
    const n = 138;
    var bitmap: [n][n]u1 = undefined;
    var neighbors: [n][n]u8 = undefined;
    @memset(std.mem.asBytes(&neighbors), 0);
    _ = try process_file_to_bitmap(138, "input.txt", &bitmap);

    try update_neighbors(n, &bitmap, &neighbors);
    var res: u64 = 0;

    for (0..n) |y| {
        for (0..n) |x| {
            if (bitmap[y][x] == 1 and neighbors[y][x] < 4) {
                res += 1;
            }
        }
    }
    std.log.info(" result {d}", .{res});
}

pub fn process_line(comptime N: usize, line_ascii: []const u8) [N]u1 {
    var bitmap: [N]u1 = undefined;
    for (line_ascii, 0..) |c, i| {
        const val = @intFromBool(c == '@');
        bitmap[i] = val;
    }
    return bitmap;
}

const Data = struct {
    bitmap: [][]u1,
    neighbors: [][]u8,
};

pub fn update_neighbors(comptime N: usize, bitmap: *const [N][N]u1, neighbors: *[N][N]u8) !void {
    for (0..bitmap.len) |line_count| {
        for (0..bitmap.len) |i| {
            const val = bitmap[line_count][i];
            //std.debug.print("{d} ", .{val});
            //std.debug.print("input x:{}, y:{} bit = {}\n", .{ i, line_count, val });
            if (val == 0) {
                continue;
            }
            for (0..3) |dx| {
                for (0..3) |dy| {
                    const y = line_count + dy;
                    const x = i + dx;
                    // assume: square grid, every line has the same width
                    if (y > 0 and x > 0 and (dx != 1 or dy != 1) and x <= bitmap.len and y <= bitmap.len) {
                        neighbors[y - 1][x - 1] += 1;
                        // std.debug.print("  output x:{}, y:{} = {}\n", .{ x - 1, y - 1, neighbors[y - 1][x - 1] });
                    }
                }
            }
        }
    }
}
pub fn process_file_to_bitmap(comptime N: usize, fname: []const u8, bitmap: *[N][N]u1) !void { //, neighbors: *[N][N]u8) !void {
    const file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();
    var buf: [32 * 1024]u8 = undefined;
    var reader = file.reader(&buf);

    var line_count: u8 = 0;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        //std.debug.print("  ", .{});
        bitmap[line_count] = process_line(N, line);
        line_count += 1;
    }
}
