const std = @import("std");

const Token = @This();

pub const Type = enum {
    left_paren,
    right_paren,
    identifier,
    number,
    eof,
};

type: Type,
trivia: []const u8,
value: []const u8,

pub fn print(self: Token, out: *std.Io.Writer) !void {
    try out.print("[{}] \"", .{self.type});
    for (self.trivia) |c| {
        switch (c) {
            '\t' => try out.print("\\t", .{}),
            '\r' => try out.print("\\r", .{}),
            '\n' => try out.print("\\n", .{}),
            else => try out.print("{c}", .{c}),
        }
    }
    try out.print("\" \"{s}\"\n", .{self.value});
}
