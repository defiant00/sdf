const std = @import("std");

const File = @import("File.zig");

const Type = enum {
    file,
};

pub fn file(f: *File) Node {
    return .{ .file = f };
}

pub const Node = union(Type) {
    file: *File,

    pub fn print(self: Node, out: *std.Io.Writer, indent: u32) !void {
        for (0..indent) |_| try out.writeAll("  ");

        switch (self) {
            .file => |f| try f.print(out),
        }
    }
};
