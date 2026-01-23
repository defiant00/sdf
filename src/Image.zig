const std = @import("std");

const Vector4 = @import("Vector4.zig");

const Image = @This();

alloc: std.mem.Allocator,
width: u32,
height: u32,
pixels: []Vector4,

pub fn init(alloc: std.mem.Allocator, width: u32, height: u32) !Image {
    return .{
        .alloc = alloc,
        .width = width,
        .height = height,
        .pixels = try alloc.alloc(Vector4, width * height),
    };
}

pub fn deinit(self: Image) void {
    self.alloc.free(self.pixels);
}

pub fn set(self: Image, x: u32, y: u32, c: Vector4) void {
    self.pixels[y * self.width + x] = c;
}

pub fn saveTga(self: Image, io: std.Io, path: []const u8) !void {
    var out = try std.Io.Dir.cwd().createFile(io, path, .{});
    defer out.close(io);

    var buf: [1024]u8 = undefined;
    var file_writer = out.writer(io, &buf);
    const writer = &file_writer.interface;

    try writer.writeByte(0); // id length
    try writer.writeByte(0); // colop map type - no color map
    try writer.writeByte(2); // image type - uncompressed true color

    // color map
    try writer.writeByte(0);
    try writer.writeByte(0);
    try writer.writeByte(0);
    try writer.writeByte(0);
    try writer.writeByte(0);

    // image spec
    try writer.writeInt(u16, 0, .little); // x origin
    try writer.writeInt(u16, 0, .little); // y origin
    try writer.writeInt(u16, @intCast(self.width), .little);
    try writer.writeInt(u16, @intCast(self.height), .little);
    try writer.writeByte(32); // bits per pixel
    try writer.writeByte(0b00_1_0_1000); // image descriptor

    // image bytes (bgra)
    for (self.pixels) |p| {
        try writer.writeByte(toByte(p.z));
        try writer.writeByte(toByte(p.y));
        try writer.writeByte(toByte(p.x));
        try writer.writeByte(toByte(p.w));
    }

    try writer.flush();
}

fn toByte(val: f32) u8 {
    if (val < 0) return 0;
    if (val > 1) return 255;
    return @intFromFloat(val * 255.0);
}
