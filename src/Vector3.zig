const std = @import("std");

const Vector3 = @This();

x: f32,
y: f32,
z: f32,

pub fn print(self: Vector3, out: *std.Io.Writer) !void {
    try out.print("[{d} {d} {d}]", .{ self.x, self.y, self.z });
}
