const std = @import("std");

const Vector4 = @This();

x: f32,
y: f32,
z: f32,
w: f32,

pub fn print(self: Vector4, out: *std.Io.Writer) !void {
    try out.print("[{d} {d} {d} {d}]", .{ self.x, self.y, self.z, self.w });
}

pub fn mul(a: Vector4, b: Vector4) Vector4 {
    return .{
        .x = a.x * b.x,
        .y = a.y * b.y,
        .z = a.z * b.z,
        .w = a.w * b.w,
    };
}

pub fn mulF(a: Vector4, b: f32) Vector4 {
    return .{
        .x = a.x * b,
        .y = a.y * b,
        .z = a.z * b,
        .w = a.w * b,
    };
}
