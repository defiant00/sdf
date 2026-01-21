const std = @import("std");

const node = @import("node.zig");
const Token = @import("../Token.zig");

const List = @This();

t_left_paren: Token,
items: std.ArrayList(node.Node),
t_right_paren: Token,

pub fn init(self: *List, alloc: std.mem.Allocator) !void {
    self.items = try std.ArrayList(node.Node).initCapacity(alloc, 4);
}
