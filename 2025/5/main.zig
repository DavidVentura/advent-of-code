const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //const res = try process_file(gpa.allocator(), "test-input2.txt");
    //const res = try process_file(gpa.allocator(), "test-input.txt");
    const res = try process_file(gpa.allocator(), "input.txt");
    std.debug.print("res {}\n", .{res});
}

const Node = struct {
    next: ?*Node,
    prev: ?*Node,
    start: u64,
    end: u64,
    valid: bool,
};

fn println(comptime str: []const u8, any: anytype) void {
    std.debug.print(str, any);
    std.debug.print("\n", .{});
}

fn print_node(node: *const Node) void {
    std.debug.print(" [start: {}, end: {}]", .{ node.start, node.end });
}

fn print_list(node: *const Node) void {
    if (!node.valid) {
        std.debug.print(" [invalid head]", .{});
        return;
    }
    var cur = node;
    print_node(cur);
    std.debug.print("\n", .{});
    while (cur.next != null) {
        cur = cur.next.?;
        print_node(cur);
        std.debug.print("\n", .{});
    }
}

pub fn collapse_list(head: *Node) void {
    var node: ?*Node = head;
    while (node) |c| {
        if (c.next) |next| {
            if (next.start > c.end + 1) {
                // disconnected (+1 for adjacent checks eg 5-6, 7-8)
                node = c.next;
                continue;
            }
            // connected -- take max in case of full overlap
            // 3-10 + 5-7 => 3-10
            c.end = @max(c.end, next.end);
            // skip next node
            c.next = next.next;
            if (next.next) |nn| {
                nn.prev = c;
            }
            //node = next.next;
            continue;
        }
        node = c.next;
    }
}
pub fn sort_list(head: *Node) void {
    // its gonna be N^2 ok
    // and head will end up pointing somewhere, not necessarily
    // the start. gl
    var swapped = true;
    while (swapped) {
        swapped = false;
        var node = head;
        while (node.next != null) {
            const n = node;
            const next = n.next.?;
            if (next.start < n.start) {
                // Swap n and next by updating values, not pointers
                const tmp_start = n.start;
                const tmp_end = n.end;
                n.start = next.start;
                n.end = next.end;
                next.start = tmp_start;
                next.end = tmp_end;
                swapped = true;
            }
            node = next;
        }
    }
}
pub fn insert_range(alloc: std.mem.Allocator, head: *Node, start: u64, end: u64) !void {
    if (!head.valid) {
        head.next = null;
        head.prev = null;
        head.start = start;
        head.end = end;
        head.valid = true;
        std.debug.print("head {any}\n", .{head});
        return;
    }
    var node: *Node = try alloc.create(Node);
    node.start = start;
    node.end = end;
    const next = head.next;
    head.next = node;
    node.next = next;
    node.prev = head;
    if (next != null) {
        next.?.prev = node;
    }
}

fn is_in_range(n: u64, head: *Node) bool {
    var node = head;
    while (node.next != null) {
        if (n >= node.start and n <= node.end) {
            return true;
        }
        node = node.next.?;
    }
    return (n >= node.start and n <= node.end);
}

pub fn process_file(alloc: std.mem.Allocator, fname: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();
    var buf: [32 * 1024]u8 = undefined;
    var reader = file.reader(&buf);
    var res: u64 = 0;

    var head: *Node = try alloc.create(Node);
    var reading_ranges = true;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) {
            reading_ranges = false;
            continue;
        }
        if (reading_ranges) {
            var it = std.mem.splitScalar(u8, line, '-');
            const start_ = it.next() orelse return error.MissingPart;
            const end_ = it.next() orelse return error.MissingPart;
            const start = try std.fmt.parseInt(u64, start_, 10);
            const end = try std.fmt.parseInt(u64, end_, 10);

            //std.debug.print("range {d}-{d}\n", .{ start, end });
            //println("list before insert:", .{});
            //print_list(head);
            //std.debug.print("\n", .{});
            try insert_range(alloc, head, start, end);
            while (head.prev != null) {
                head = head.prev.?;
            }
            //std.debug.print("list after insert:\n", .{});
            //print_list(head);
            //std.debug.print("\n\n", .{});
        } else {
            const num = try std.fmt.parseInt(u64, line, 10);
            const in_range = is_in_range(num, head);
            if (in_range) {
                res += 1;
            }
            //std.debug.print("num {d} in_range {}\n", .{ num, in_range });
        }
    }

    sort_list(head);
    while (head.prev != null) {
        head = head.prev.?;
    }
    println("ok", .{});
    print_list(head);

    collapse_list(head);
    while (head.prev != null) {
        head = head.prev.?;
    }
    println("collapsed", .{});
    print_list(head);
    while (head.prev != null) {
        head = head.prev.?;
    }
    res = 0;
    while (head.next) |hn| {
        res += head.end - head.start + 1;
        head = hn;
    }
    res += head.end - head.start + 1;
    return res;
}
