const std = @import("std");

const Token = @import("../Token.zig");

const File = @This();

t_eof: Token,

pub fn print(self: File, out: *std.Io.Writer, indent: u32) !void {
    _ = self;
    for (0..indent) |_| try out.writeAll("  ");
    try out.writeAll("file\n");
}
