const std = @import("std");

const Color = @import("Color.zig");

const Image = @This();

alloc: std.mem.Allocator,
width: u32,
height: u32,
buffer: []Color,

pub fn init(alloc: std.mem.Allocator, width: u32, height: u32) !Image {
    return .{
        .alloc = alloc,
        .width = width,
        .height = height,
        .buffer = try alloc.alloc(Color, width * height),
    };
}

pub fn deinit(self: Image) void {
    self.alloc.free(self.buffer);
}

pub fn set(self: Image, x: u32, y: u32, r: f32, g: f32, b: f32, a: f32) void {
    self.buffer[y * self.width + x] = .{ .r = r, .g = g, .b = b, .a = a };
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

    // image bytes
    for (self.buffer) |c| {
        try writer.writeByte(toByte(c.b));
        try writer.writeByte(toByte(c.g));
        try writer.writeByte(toByte(c.r));
        try writer.writeByte(toByte(c.a));
    }

    try writer.flush();
}

fn toByte(val: f32) u8 {
    if (val < 0) return 0;
    if (val > 1) return 255;
    return @intFromFloat(val * 255.0);
}
