const std = @import("std");

const File = @import("cst/File.zig");
const Identifier = @import("cst/Identifier.zig");
const Lexer = @import("Lexer.zig");
const List = @import("cst/List.zig");
const node = @import("cst/node.zig");
const Number = @import("cst/Number.zig");
const Token = @import("Token.zig");

const Parser = @This();

alloc: std.mem.Allocator,
lexer: Lexer,
current: Token,
previous: Token,

fn advance(self: *Parser) !void {
    self.previous = self.current;
    self.current = try self.lexer.lexToken();
}

fn check(self: Parser, expected: Token.Type) bool {
    return self.current.type == expected;
}

fn match(self: *Parser, expected: Token.Type) !bool {
    if (!self.check(expected)) return false;
    try self.advance();
    return true;
}

fn consume(self: *Parser, expected: Token.Type) !Token {
    if (!self.check(expected)) {
        std.debug.print("looking for {} but found {}\n", .{ expected, self.current.type });
        return error.Syntax;
    }

    try self.advance();
    return self.previous;
}

fn parseFile(self: *Parser, path: []const u8) !*File {
    const file = try self.alloc.create(File);
    file.name = path;
    file.scene = try self.parseNode();
    file.t_eof = try self.consume(.eof);
    return file;
}

fn parseNode(self: *Parser) !node.Node {
    if (try self.match(.identifier)) {
        const ident = try self.alloc.create(Identifier);
        ident.t_value = self.previous;
        return node.identifier(ident);
    } else if (try self.match(.number)) {
        const num = try self.alloc.create(Number);
        num.t_value = self.previous;
        num.value = try std.fmt.parseFloat(f32, self.previous.value);
        return node.number(num);
    } else if (try self.match(.left_paren)) {
        const list = try self.alloc.create(List);
        try list.init(self.alloc);
        list.t_left_paren = self.previous;
        while (!try self.match(.right_paren)) {
            try list.items.append(self.alloc, try self.parseNode());
        }
        list.t_right_paren = self.previous;
        return node.list(list);
    }
    std.debug.print("invalid token {} \"{s}\"\n", .{ self.previous.type, self.previous.value });
    return error.Syntax;
}

pub fn parse(alloc: std.mem.Allocator, source: []const u8, path: []const u8) !*File {
    var parser: Parser = .{
        .alloc = alloc,
        .lexer = .init(source),
        .current = undefined,
        .previous = undefined,
    };

    try parser.advance();
    return parser.parseFile(path);
}
