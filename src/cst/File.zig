const std = @import("std");

const Node = @import("Node.zig");
const Token = @import("../Token.zig");
const Vector3 = @import("../Vector3.zig");

const File = @This();

t_eof: Token,

pub fn node(self: *File) Node {
    return Node.from(self);
}

pub fn deinit(self: *File) void {
    _ = self;
}

pub fn dist(self: *File, p: Vector3) f32 {
    _ = self;
    _ = p;
    return 0;
}

pub fn print(self: *File, out: *std.Io.Writer, indent: u32) !void {
    _ = self;
    for (0..indent) |_| try out.writeAll("  ");
    try out.writeAll("file\n");
}
