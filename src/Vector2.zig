const std = @import("std");

const Vector2 = @This();

x: f32,
y: f32,

pub fn print(self: Vector2, out: *std.Io.Writer) !void {
    try out.print("[{d} {d}]", .{ self.x, self.y });
}
