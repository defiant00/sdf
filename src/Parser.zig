const std = @import("std");

const Lexer = @import("Lexer.zig");
const Token = @import("Token.zig");

const Parser = @This();

lexer: Lexer,
current: Token,
previous: Token,

fn advance(self: *Parser) !void {
    self.previous = self.current;

    while (true) {
        self.current = try self.lexer.lexToken();

        if (self.current.type != .error_) break;
    }
}

pub fn parse(source: []const u8, out: *std.Io.Writer) !void {
    var parser: Parser = .{
        .lexer = .init(source),
        .current = undefined,
        .previous = undefined,
    };

    try parser.advance();

    while (parser.current.type != .eof and parser.current.type != .error_) {
        try parser.current.print(out);
        try parser.advance();
    }
    try parser.current.print(out);
}
