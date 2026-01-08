const std = @import("std");
const build = @import("build.zig.zon");

pub fn main() !void {
    var debug_alloc: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_alloc.deinit();
    const alloc = debug_alloc.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var threaded: std.Io.Threaded = .init(alloc, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_file_writer: std.Io.File.Writer = .init(.stderr(), io, &stderr_buffer);
    const stderr_writer = &stderr_file_writer.interface;

    if (args.len == 2 and std.mem.eql(u8, args[1], "help")) {
        try printUsage(stderr_writer);
    } else if (args.len >= 3 and std.mem.eql(u8, args[1], "render")) {
        try stderr_writer.print("render\n", .{});
        for (args[2..]) |file| {
            try stderr_writer.print("  {s}\n", .{file});
        }
    } else if (args.len == 2 and std.mem.eql(u8, args[1], "version")) {
        try stderr_writer.print("SDF Tools     {s}\nSpecification {s}\n", .{
            build.version,
            build.spec_version,
        });
    } else {
        try stderr_writer.print("Error, invalid command\n\n", .{});
        try printUsage(stderr_writer);
    }

    try stderr_writer.flush();
}

fn printUsage(writer: *std.Io.Writer) !void {
    try writer.print(
        \\Usage: sdf [command]
        \\
        \\Commands:
        \\  render [files]    Render files
        \\
        \\  help              Print this help and exit
        \\  version           Print version and exit
        \\
    , .{});
}
