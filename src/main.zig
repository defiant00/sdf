const std = @import("std");

const build = @import("build.zig.zon");
const Parser = @import("cst/Parser.zig");
const rt = @import("rt/all_nodes.zig");

const usage =
    \\Usage: sdf [command]
    \\
    \\Commands:
    \\  format   [files]  Format files
    \\  validate [files]  Validate files
    \\
    \\  render   [files]  Render files
    \\
    \\  help              Print this help and exit
    \\  version           Print version and exit
    \\
;

pub fn main() !void {
    var debug_alloc: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_alloc.deinit();
    const gpa = debug_alloc.allocator();

    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const args = try std.process.argsAlloc(arena);

    var threaded: std.Io.Threaded = .init(gpa, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_file_writer = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr_writer = &stderr_file_writer.interface;

    if (args.len >= 3 and std.mem.eql(u8, args[1], "format")) {
        for (args[2..]) |path| {
            try format(stdout_writer, stderr_writer, path);
        }
    } else if (args.len == 2 and std.mem.eql(u8, args[1], "help")) {
        try stdout_writer.print("{s}", .{usage});
    } else if (args.len >= 3 and std.mem.eql(u8, args[1], "render")) {
        for (args[2..]) |path| {
            try render(io, arena, stderr_writer, path);
        }
    } else if (args.len >= 3 and std.mem.eql(u8, args[1], "validate")) {
        for (args[2..]) |path| {
            try validate(io, arena, stderr_writer, path);
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

fn format(out: *std.Io.Writer, err: *std.Io.Writer, path: []const u8) !void {
    _ = out;
    try err.print("{s}\n", .{path});
}

fn render(io: std.Io, arena: std.mem.Allocator, err: *std.Io.Writer, path: []const u8) !void {
    try err.print("{s}\n", .{path});

    const source = try std.Io.Dir.cwd().readFileAlloc(io, path, arena, .unlimited);
    try err.print("---\n{s}\n---\n", .{source});

    const result = try Parser.parse(arena, source, path);
    try err.print("\nsyntax tree:\n\n", .{});
    try result.print(err);

    const node = try rt.Node.fromItem(arena, result.scene);
    try err.print("\nrender tree:\n\n", .{});
    try node.print(err, 0);

    try node.camera.render(io, arena);
}

fn validate(io: std.Io, arena: std.mem.Allocator, err: *std.Io.Writer, path: []const u8) !void {
    try err.print("{s}\n", .{path});

    const source = try std.Io.Dir.cwd().readFileAlloc(io, path, arena, .unlimited);
    try err.print("---\n{s}\n---\n", .{source});

    const result = try Parser.parse(arena, source, path);
    try err.print("\nsyntax tree:\n\n", .{});
    try result.print(err);

    const node = try rt.Node.fromItem(arena, result.scene);
    try err.print("\nrender tree:\n\n", .{});
    try node.print(err, 0);
}
