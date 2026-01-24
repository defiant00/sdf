const std = @import("std");

const Vector3 = @This();

x: f64,
y: f64,
z: f64,

pub fn print(self: Vector3, out: *std.Io.Writer) !void {
    try out.print("[{d} {d} {d}]", .{ self.x, self.y, self.z });
}

pub fn add(a: Vector3, b: Vector3) Vector3 {
    return .{
        .x = a.x + b.x,
        .y = a.y + b.y,
        .z = a.z + b.z,
    };
}

pub fn addF(a: Vector3, b: f64) Vector3 {
    return .{
        .x = a.x + b,
        .y = a.y + b,
        .z = a.z + b,
    };
}

pub fn div(a: Vector3, b: Vector3) Vector3 {
    return .{
        .x = a.x / b.x,
        .y = a.y / b.y,
        .z = a.z / b.z,
    };
}

pub fn divF(a: Vector3, b: f64) Vector3 {
    return .{
        .x = a.x / b,
        .y = a.y / b,
        .z = a.z / b,
    };
}

pub fn dot(a: Vector3, b: Vector3) f64 {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

pub fn length(a: Vector3) f64 {
    return @sqrt(a.lengthSquared());
}

pub fn lengthSquared(a: Vector3) f64 {
    return a.x * a.x + a.y * a.y + a.z * a.z;
}

pub fn mul(a: Vector3, b: Vector3) Vector3 {
    return .{
        .x = a.x * b.x,
        .y = a.y * b.y,
        .z = a.z * b.z,
    };
}

pub fn mulF(a: Vector3, b: f64) Vector3 {
    return .{
        .x = a.x * b,
        .y = a.y * b,
        .z = a.z * b,
    };
}

pub fn normalize(a: Vector3) Vector3 {
    return a.divF(a.length());
}

pub fn sub(a: Vector3, b: Vector3) Vector3 {
    return .{
        .x = a.x - b.x,
        .y = a.y - b.y,
        .z = a.z - b.z,
    };
}

pub fn subF(a: Vector3, b: f64) Vector3 {
    return .{
        .x = a.x - b,
        .y = a.y - b,
        .z = a.z - b,
    };
}
