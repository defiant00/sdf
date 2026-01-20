const std = @import("std");

const Vector3 = @import("../Vector3.zig");

const Node = @This();

instance: *anyopaque,
v_deinit: *const fn (*anyopaque) void,
v_dist: *const fn (*anyopaque, Vector3) f32,
v_print: *const fn (*anyopaque, *std.Io.Writer, u32) anyerror!void,

pub fn from(instance: anytype) Node {
    const T: type = @typeInfo(@TypeOf(instance)).pointer.child;

    // deinit
    const deinit_f = @field(T, "deinit");
    const deinit_fn = @typeInfo(@TypeOf(deinit_f)).@"fn";
    if (deinit_fn.params.len != 1 or @typeInfo(deinit_fn.params[0].type.?) != .pointer) {
        @compileError("signature mismatch: deinit(*)");
    }

    // dist
    const dist_f = @field(T, "dist");
    const dist_fn = @typeInfo(@TypeOf(dist_f)).@"fn";
    if (dist_fn.params.len != 2 or
        @typeInfo(dist_fn.params[0].type.?) != .pointer or
        dist_fn.params[1].type.? != Vector3)
    {
        @compileError("signature mismatch: dist(*, Vector3)");
    }

    // print
    const print_f = @field(T, "print");
    const print_fn = @typeInfo(@TypeOf(print_f)).@"fn";
    if (print_fn.params.len != 3 or
        @typeInfo(print_fn.params[0].type.?) != .pointer or
        print_fn.params[1].type.? != *std.Io.Writer or
        print_fn.params[2].type.? != u32)
    {
        @compileError("signature mismatch: print(*, *std.Io.Writer, u32)");
    }

    return .{
        .instance = instance,
        .v_deinit = @ptrCast(&deinit_f),
        .v_dist = @ptrCast(&dist_f),
        .v_print = @ptrCast(&print_f),
    };
}

pub fn deinit(self: Node) void {
    self.v_deinit(self.instance);
}

pub fn dist(self: Node, p: Vector3) f32 {
    return self.v_dist(self.instance, p);
}

pub fn print(self: Node, out: *std.Io.Writer, indent: u32) !void {
    try self.v_print(self.instance, out, indent);
}
