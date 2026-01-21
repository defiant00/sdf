const std = @import("std");

const Identifier = @import("Identifier.zig");
const List = @import("List.zig");
const Number = @import("Number.zig");

const Type = enum {
    identifier,
    list,
    number,
};

pub fn identifier(i: *Identifier) Item {
    return .{ .identifier = i };
}

pub fn list(l: *List) Item {
    return .{ .list = l };
}

pub fn number(n: *Number) Item {
    return .{ .number = n };
}

pub const Item = union(Type) {
    identifier: *Identifier,
    list: *List,
    number: *Number,

    pub fn print(self: Item, out: *std.Io.Writer, indent: u32) !void {
        for (0..indent) |_| try out.writeAll("  ");

        switch (self) {
            .identifier => |i| try out.print("id ({s})\n", .{i.t_value.value}),
            .list => |l| {
                try out.print("list\n", .{});
                for (l.items.items) |item| try item.print(out, indent + 1);
            },
            .number => |n| try out.print("num ({s})\n", .{n.t_value.value}),
        }
    }
};
