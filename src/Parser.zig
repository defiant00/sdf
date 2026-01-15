const std = @import("std");

const Lexer = @import("Lexer.zig");

const Parser = @This();

lexer: Lexer,

// u8 is just a placeholder result type
pub fn parse(source: []const u8) !u8 {
    const p: Parser = .{ .lexer = .init(source) };
    _ = p;
    return 0;
}
