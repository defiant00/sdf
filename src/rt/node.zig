const std = @import("std");

const cst = @import("../cst/item.zig");
const rt = @import("all_nodes.zig");
const Vector3 = @import("../Vector3.zig");

const Type = enum {
    albedo,
    move,
    plane,
    scale,
    scene,
    sphere,
    subtract,
    _union,
};

pub const Node = union(Type) {
    albedo: *rt.Albedo,
    move: *rt.Move,
    plane: void,
    scale: *rt.Scale,
    scene: *rt.Scene,
    sphere: void,
    subtract: *rt.Subtract,
    _union: *rt.Union,

    pub const at = @import("node/at.zig").at;

    pub fn fromItem(alloc: std.mem.Allocator, item: cst.Item) !Node {
        if (item == .list and
            item.list.items.items.len > 0 and
            item.list.items.items[0] == .identifier)
        {
            const len = item.list.items.items.len;
            const id = item.list.items.items[0].identifier.t_value.value;
            if (std.mem.eql(u8, id, "albedo")) {
                if (len != 3) try printSignature(.albedo);

                const albedo_vec = try item.list.getVec4(1);
                const child = try fromItem(alloc, item.list.items.items[2]);
                if (albedo_vec) |av| {
                    const albedo_node = try alloc.create(rt.Albedo);
                    albedo_node.albedo = av;
                    albedo_node.target = child;
                    return .{ .albedo = albedo_node };
                }

                try printSignature(.albedo);
            } else if (std.mem.eql(u8, id, "move")) {
                if (len != 3) try printSignature(.move);

                const amt = try item.list.getVec3(1);
                const child = try fromItem(alloc, item.list.items.items[2]);
                if (amt) |a| {
                    const move = try alloc.create(rt.Move);
                    move.amount = a;
                    move.target = child;
                    return .{ .move = move };
                }

                try printSignature(.move);
            } else if (std.mem.eql(u8, id, "plane")) {
                if (len != 1) try printSignature(.plane);
                return .plane;
            } else if (std.mem.eql(u8, id, "scale")) {
                if (len != 3) try printSignature(.scale);

                const amt = try item.list.getNum(1);
                const child = try fromItem(alloc, item.list.items.items[2]);
                if (amt) |a| {
                    const scale = try alloc.create(rt.Scale);
                    scale.amount = a;
                    scale.target = child;
                    return .{ .scale = scale };
                }

                try printSignature(.scale);
            } else if (std.mem.eql(u8, id, "scene")) {
                if (len != 4) try printSignature(.scene);

                const res = try item.list.getVec2(1);
                const z_dist = try item.list.getNum(2);
                const child = try fromItem(alloc, item.list.items.items[3]);
                if (res != null and z_dist != null) {
                    if (z_dist == 0) {
                        std.debug.print("z distance cannot be zero\n", .{});
                        return error.RenderTree;
                    }

                    const scn = try alloc.create(rt.Scene);
                    scn.resolution = res.?;
                    scn.z_distance = z_dist.?;
                    scn.scene = child;
                    return .{ .scene = scn };
                }

                try printSignature(.scene);
            } else if (std.mem.eql(u8, id, "sphere")) {
                if (len != 1) try printSignature(.sphere);
                return .sphere;
            } else if (std.mem.eql(u8, id, "subtract")) {
                if (len != 3) try printSignature(.subtract);

                const a = try fromItem(alloc, item.list.items.items[1]);
                const b = try fromItem(alloc, item.list.items.items[2]);
                const sub = try alloc.create(rt.Subtract);
                sub.a = a;
                sub.b = b;
                return .{ .subtract = sub };
            } else if (std.mem.eql(u8, id, "union")) {
                if (len != 3) try printSignature(._union);

                const a = try fromItem(alloc, item.list.items.items[1]);
                const b = try fromItem(alloc, item.list.items.items[2]);
                const un = try alloc.create(rt.Union);
                un.a = a;
                un.b = b;
                return .{ ._union = un };
            }

            std.debug.print("unknown render tree command \"{s}\"\n", .{id});
            return error.RenderTree;
        }

        std.debug.print("item must start with a command\n", .{});
        return error.RenderTree;
    }

    fn printSignature(t: Type) !void {
        switch (t) {
            .albedo => std.debug.print("albedo color(4) node\n", .{}),
            .move => std.debug.print("move amount(3) node\n", .{}),
            .plane => std.debug.print("plane\n", .{}),
            .scale => std.debug.print("scale amount node\n", .{}),
            .scene => std.debug.print("scene resolution(2) z_distance node\n", .{}),
            .sphere => std.debug.print("sphere\n", .{}),
            .subtract => std.debug.print("subtract node node\n", .{}),
            ._union => std.debug.print("union node node\n", .{}),
        }
        return error.RenderTree;
    }

    pub fn print(self: Node, out: *std.Io.Writer, indent: u32) !void {
        for (0..indent) |_| try out.writeAll("  ");

        switch (self) {
            .albedo => |a| {
                try out.print("albedo ", .{});
                try a.albedo.print(out);
                try out.print("\n", .{});
                try a.target.print(out, indent + 1);
            },
            .move => |m| {
                try out.print("move ", .{});
                try m.amount.print(out);
                try out.print("\n", .{});
                try m.target.print(out, indent + 1);
            },
            .plane => try out.print("plane\n", .{}),
            .scale => |s| {
                try out.print("scale {d}\n", .{s.amount});
                try s.target.print(out, indent + 1);
            },
            .scene => |s| {
                try out.print("scene ", .{});
                try s.resolution.print(out);
                try out.print(" z {d}\n", .{s.z_distance});
                try s.scene.print(out, indent + 1);
            },
            .sphere => try out.print("sphere\n", .{}),
            .subtract => |s| {
                try out.print("subtract\n", .{});
                try s.a.print(out, indent + 1);
                try s.b.print(out, indent + 1);
            },
            ._union => |u| {
                try out.print("union\n", .{});
                try u.a.print(out, indent + 1);
                try u.b.print(out, indent + 1);
            },
        }
    }
};
