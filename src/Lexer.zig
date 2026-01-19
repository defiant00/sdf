const std = @import("std");
const unicode = std.unicode;

const Token = @import("Token.zig");

const Lexer = @This();

source: []const u8,
trivia_start_index: usize,
value_start_index: usize,
current_index: usize,

pub fn init(source: []const u8) Lexer {
    return .{
        .source = source,
        .trivia_start_index = 0,
        .value_start_index = 0,
        .current_index = 0,
    };
}

fn isAtEnd(self: Lexer) bool {
    return self.current_index >= self.source.len;
}

fn currentLength(self: Lexer) !u3 {
    return unicode.utf8ByteSequenceLength(self.source[self.current_index]);
}

fn advance(self: *Lexer) !void {
    if (!self.isAtEnd()) self.current_index += try self.currentLength();
}

fn peek(self: Lexer) !u21 {
    return unicode.utf8Decode(self.source[self.current_index .. self.current_index + try self.currentLength()]);
}

fn discard(self: *Lexer) void {
    self.trivia_start_index = self.current_index;
}

fn token(self: *Lexer, token_type: Token.Type) Token {
    const tok: Token = .{
        .type = token_type,
        .trivia = self.source[self.trivia_start_index..self.value_start_index],
        .value = self.source[self.value_start_index..self.current_index],
    };
    self.discard();
    return tok;
}

fn errorToken(self: *Lexer, message: []const u8) Token {
    const tok: Token = .{
        .type = .error_,
        .trivia = "",
        .value = message,
    };
    self.discard();
    return tok;
}

fn isIdentifier(c: u21) bool {
    return switch (c) {
        '(', ')', '[', ']', '.', ';' => false,
        else => !isWhitespace(c),
    };
}

fn isNumber(c: u21) bool {
    return switch (c) {
        '0'...'9' => true,
        else => false,
    };
}

fn isWhitespace(c: u21) bool {
    return switch (c) {
        ' ', '\t', '\r', '\n' => true,
        else => false,
    };
}

fn identifier(self: *Lexer) !Token {
    while (!self.isAtEnd() and isIdentifier(try self.peek())) try self.advance();
    return self.token(.identifier);
}

fn number(self: *Lexer) !Token {
    // digits
    while (!self.isAtEnd() and isNumber(try self.peek())) try self.advance();

    // optional decimal
    if (!self.isAtEnd() and try self.peek() == '.') {
        try self.advance(); // .

        // digits
        while (!self.isAtEnd() and isNumber(try self.peek())) try self.advance();
    }

    return self.token(.number);
}

pub fn lexToken(self: *Lexer) !Token {
    // trivia
    while (!self.isAtEnd()) {
        const c = try self.peek();
        switch (c) {
            ' ', '\t', '\r', '\n' => try self.advance(),
            ';' => while (!self.isAtEnd() and try self.peek() != '\n') try self.advance(),
            else => break,
        }
    }

    // value
    self.value_start_index = self.current_index;
    while (!self.isAtEnd()) {
        const c = try self.peek();
        try self.advance();

        switch (c) {
            '(' => return self.token(.left_paren),
            ')' => return self.token(.right_paren),
            '[' => return self.token(.left_bracket),
            ']' => return self.token(.right_bracket),
            '.' => return self.token(.dot),
            else => {
                if (isNumber(c)) return self.number();
                return self.identifier();
            },
        }
    }

    return self.token(.eof);
}
