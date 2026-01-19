const std = @import("std");

const Node = @import("Node.zig");
const Token = @import("../Token.zig");

const File = @This();

t_eof: Token,

pub fn node(self: *File) Node {
    return Node.from(self);
}

pub fn print(self: *File, indent: u32) void {
    for (0..indent) |_| std.debug.print(".", .{});
    std.debug.print("print {}\n", .{self.t_eof.type});
}
