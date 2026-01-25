const std = @import("std");

const cst = @import("../cst/item.zig");
const rt = @import("all_nodes.zig");
const Vector3 = @import("../Vector3.zig");

const Type = enum {
    move,
    plane,
    scene,
    sphere,
    subtract,
    _union,
};

pub const Node = union(Type) {
    move: *rt.Move,
    plane: *rt.Plane,
    scene: *rt.Scene,
    sphere: *rt.Sphere,
    subtract: *rt.Subtract,
    _union: *rt.Union,

    pub fn fromItem(alloc: std.mem.Allocator, item: cst.Item) !Node {
        if (item == .list and
            item.list.items.items.len > 0 and
            item.list.items.items[0] == .identifier)
        {
            const len = item.list.items.items.len;
            const id = item.list.items.items[0].identifier.t_value.value;
            if (std.mem.eql(u8, id, "move")) {
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
                if (len != 3) try printSignature(.plane);

                const contact = try item.list.getVec3(1);
                const normal = try item.list.getVec3(2);
                if (contact != null and normal != null) {
                    const plane = try alloc.create(rt.Plane);
                    plane.contact = contact.?;
                    plane.normal = normal.?;
                    return .{ .plane = plane };
                }

                try printSignature(.plane);
            } else if (std.mem.eql(u8, id, "scene")) {
                if (len != 3) try printSignature(.scene);

                const res = try item.list.getVec2(1);
                const child = try fromItem(alloc, item.list.items.items[2]);
                if (res) |r| {
                    const scn = try alloc.create(rt.Scene);
                    scn.resolution = r;
                    scn.scene = child;
                    return .{ .scene = scn };
                }

                try printSignature(.scene);
            } else if (std.mem.eql(u8, id, "sphere")) {
                if (len != 2) try printSignature(.sphere);

                const rad = try item.list.getNum(1);
                if (rad) |r| {
                    const sphere = try alloc.create(rt.Sphere);
                    sphere.radius = r;
                    return .{ .sphere = sphere };
                }

                try printSignature(.sphere);
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
            .move => std.debug.print("move amount(3)\n", .{}),
            .plane => std.debug.print("plane contact(3) normal(3)\n", .{}),
            .scene => std.debug.print("scene resolution(2)\n", .{}),
            .sphere => std.debug.print("sphere radius\n", .{}),
            .subtract => std.debug.print("subtract node node\n", .{}),
            ._union => std.debug.print("union node node\n", .{}),
        }
        return error.RenderTree;
    }

    pub fn dist(self: Node, point: Vector3) f64 {
        switch (self) {
            .move => return self.move.target.dist(point.sub(self.move.amount)),
            .plane => return point.y - self.plane.contact.y,
            .scene => return self.scene.scene.dist(point),
            .sphere => return point.length() - self.sphere.radius,
            .subtract => return @max(self.subtract.a.dist(point), -self.subtract.b.dist(point)),
            ._union => return @min(self._union.a.dist(point), self._union.b.dist(point)),
        }
    }

    pub fn print(self: Node, out: *std.Io.Writer, indent: u32) !void {
        for (0..indent) |_| try out.writeAll("  ");

        switch (self) {
            .move => |m| {
                try out.print("move ", .{});
                try m.amount.print(out);
                try out.print("\n", .{});
                try m.target.print(out, indent + 1);
            },
            .plane => |p| {
                try out.print("plane ", .{});
                try p.contact.print(out);
                try out.print(" n", .{});
                try p.normal.print(out);
                try out.print("\n", .{});
            },
            .scene => |s| {
                try out.print("scene ", .{});
                try s.resolution.print(out);
                try out.print("\n", .{});
                try s.scene.print(out, indent + 1);
            },
            .sphere => |s| try out.print("sphere {d}\n", .{s.radius}),
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
