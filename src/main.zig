const std = @import("std");
const build = @import("build.zig.zon");

const usage =
    \\Usage: sdf [command]
    \\
    \\Commands:
    \\  debug [files]     Debug files
    \\
    \\  render [files]    Render files
    \\
    \\  help              Print this help and exit
    \\  version           Print version and exit
    \\
;

pub fn main() !void {
    var debug_alloc: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_alloc.deinit();
    const alloc = debug_alloc.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var threaded: std.Io.Threaded = .init(alloc, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_file_writer = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr_writer = &stderr_file_writer.interface;

    if (args.len == 2 and std.mem.eql(u8, args[1], "help")) {
        try stdout_writer.print("{s}", .{usage});
    } else if (args.len >= 3 and std.mem.eql(u8, args[1], "render")) {
        for (args[2..]) |path| {
            try render(stdout_writer, stderr_writer, path);
        }
    } else if (args.len >= 3 and std.mem.eql(u8, args[1], "validate")) {
        for (args[2..]) |path| {
            try validate(stdout_writer, stderr_writer, path);
        }
    } else if (args.len == 2 and std.mem.eql(u8, args[1], "version")) {
        try stdout_writer.print("SDF Tools     {s}\nSpecification {s}\n", .{
            build.version,
            build.spec_version,
        });
    } else {
        try stderr_writer.print("{s}\n", .{usage});
        try stderr_writer.flush();
        std.process.fatal("invalid command", .{});
    }

    try stdout_writer.flush();
    try stderr_writer.flush();
}

fn render(out: *std.Io.Writer, err: *std.Io.Writer, path: []const u8) !void {
    _ = out;
    try err.print("{s}\n", .{path});
    try err.flush();
}

fn validate(out: *std.Io.Writer, err: *std.Io.Writer, path: []const u8) !void {
    _ = out;
    try err.print("{s}\n", .{path});
    try err.flush();
}
