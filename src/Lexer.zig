const std = @import("std");

pub const Token = struct {
    pub const Type = enum {
        left_paren,
        right_paren,
        left_bracket,
        right_bracket,
        dot,
        identifier,
        number,
        error_,
        eof,
    };

    type: Type,
    trivia: []const u8,
    value: []const u8,
};

const Lexer = @This();

source: []const u8,

pub fn init(source: []const u8) Lexer {
    return .{
        .source = source,
    };
}

pub fn lexToken(self: *Lexer) Token {
    _ = self;
    return .{
        .type = .eof,
        .trivia = "",
        .value = "",
    };
}
