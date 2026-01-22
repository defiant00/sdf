const std = @import("std");

const Vector4 = @This();

x: f32,
y: f32,
z: f32,
w: f32,

pub fn print(self: Vector4, out: *std.Io.Writer) !void {
    try out.print("[{d} {d} {d} {d}]", .{ self.x, self.y, self.z, self.w });
}
