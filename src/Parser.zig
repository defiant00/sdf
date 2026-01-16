const std = @import("std");

const Lexer = @import("Lexer.zig");

const Parser = @This();

lexer: Lexer,
current: Lexer.Token,
previous: Lexer.Token,

fn advance(self: *Parser) !void {
    self.previous = self.current;

    while (true) {
        self.current = try self.lexer.lexToken();

        if (self.current.type != .error_) break;
    }
}

pub fn parse(source: []const u8) !void {
    var parser: Parser = .{
        .lexer = .init(source),
        .current = undefined,
        .previous = undefined,
    };

    try parser.advance();

    while (parser.current.type != .eof and parser.current.type != .error_) {
        parser.current.print();
        try parser.advance();
    }
    parser.current.print();
}
