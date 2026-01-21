const std = @import("std");

const item = @import("item.zig");
const Token = @import("../Token.zig");

const List = @This();

t_left_paren: Token,
items: std.ArrayList(item.Item),
t_right_paren: Token,

pub fn init(self: *List, alloc: std.mem.Allocator) !void {
    self.items = try std.ArrayList(item.Item).initCapacity(alloc, 4);
}
