const std = @import("std");

const Identifier = @import("Identifier.zig");
const List = @import("List.zig");
const Number = @import("Number.zig");

const Type = enum {
    identifier,
    list,
    number,
};

pub fn identifier(i: *Identifier) Node {
    return .{ .identifier = i };
}

pub fn list(l: *List) Node {
    return .{ .list = l };
}

pub fn number(n: *Number) Node {
    return .{ .number = n };
}

pub const Node = union(Type) {
    identifier: *Identifier,
    list: *List,
    number: *Number,

    pub fn print(self: Node, out: *std.Io.Writer, indent: u32) !void {
        for (0..indent) |_| try out.writeAll("  ");

        switch (self) {
            .identifier => |i| try out.print("id ({s})\n", .{i.t_value.value}),
            .list => |l| {
                try out.print("list\n", .{});
                for (l.items.items) |item| try item.print(out, indent + 1);
            },
            .number => |n| try out.print("num {d} ({s})\n", .{ n.value, n.t_value.value }),
        }
    }
};
