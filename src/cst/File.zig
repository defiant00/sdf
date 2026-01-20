const std = @import("std");

const Token = @import("../Token.zig");

const File = @This();

name: []const u8,
t_eof: Token,

pub fn print(self: File, out: *std.Io.Writer) !void {
    try out.print("file ({s})\n", .{self.name});
}
