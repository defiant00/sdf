const std = @import("std");

const Image = @This();

alloc: std.mem.Allocator,
width: u32,
height: u32,
buffer: []f32,

pub fn init(alloc: std.mem.Allocator, width: u32, height: u32) !Image {
    return .{
        .alloc = alloc,
        .width = width,
        .height = height,
        .buffer = try alloc.alloc(f32, width * height * 4),
    };
}

pub fn deinit(self: Image) void {
    self.alloc.free(self.buffer);
}

pub fn set(self: Image, x: u32, y: u32, r: f32, g: f32, b: f32, a: f32) void {
    const index = (y * self.width + x) * 4;
    self.buffer[index] = r;
    self.buffer[index + 1] = g;
    self.buffer[index + 2] = b;
    self.buffer[index + 3] = a;
}

pub fn save(self: Image, io: std.Io, path: []const u8) !void {
    var out = try std.Io.Dir.cwd().createFile(io, path, .{});
    defer out.close(io);

    var buf: [1024]u8 = undefined;
    var file_writer = out.writer(io, &buf);
    const writer = &file_writer.interface;

    try writer.print("P7\nWIDTH {}\nHEIGHT {}\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n", .{ self.width, self.height });
    for (self.buffer) |v| {
        try writer.writeByte(@intFromFloat(v * 255.0));
    }
    try writer.flush();
}
