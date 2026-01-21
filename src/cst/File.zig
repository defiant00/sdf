const std = @import("std");

const node = @import("node.zig");
const Token = @import("../Token.zig");

const File = @This();

name: []const u8,
scene: node.Node,
t_eof: Token,

pub fn print(self: File, out: *std.Io.Writer) !void {
    try out.print("file ({s})\n", .{self.name});
    try self.scene.print(out, 1);
}
