const std = @import("std");

const Vector2 = @This();

x: f64,
y: f64,

pub fn print(self: Vector2, out: *std.Io.Writer) !void {
    try out.print("[{d} {d}]", .{ self.x, self.y });
}

pub fn mul(a: Vector2, b: Vector2) Vector2 {
    return .{
        .x = a.x * b.x,
        .y = a.y * b.y,
    };
}

pub fn mulF(a: Vector2, b: f64) Vector2 {
    return .{
        .x = a.x * b,
        .y = a.y * b,
    };
}
