const std = @import("std");

const Image = @import("../Image.zig");
const rt = @import("all_nodes.zig");
const Vector2 = @import("../Vector2.zig");
const Vector3 = @import("../Vector3.zig");
const Vector4 = @import("../Vector4.zig");

const Camera = @This();

resolution: Vector2,
position: Vector3,
direction: Vector3,
scene: rt.Node,

const MAX_STEPS = 512;
const MAX_DEPTH = 1000;
const MIN_HIT_DIST = 0.001;

pub fn render(self: Camera, io: std.Io, alloc: std.mem.Allocator) !void {
    const pw: u32 = @intFromFloat(self.resolution.x);
    const ph: u32 = @intFromFloat(self.resolution.y);
    const scale: Vector2 =
        if (self.resolution.x > self.resolution.y)
            .{ .x = 1, .y = self.resolution.y / self.resolution.x }
        else
            .{ .x = self.resolution.x / self.resolution.y, .y = 1 };

    const img = try Image.init(alloc, pw, ph);
    defer img.deinit();

    for (0..ph) |py| {
        for (0..pw) |px| {
            var uv = Vector2.mul(.{
                .x = 2 * (@as(f32, @floatFromInt(px)) + 0.5) / self.resolution.x - 1,
                .y = -(2 * (@as(f32, @floatFromInt(py)) + 0.5) / self.resolution.y - 1),
            }, scale);

            const ro = self.position;
            const rd = Vector3.normalize(.{ .x = uv.x, .y = uv.y, .z = -1 });
            var depth: f32 = 0;
            var color: Vector4 = .{ .x = 0, .y = 0, .z = 0, .w = 0 };

            for (0..MAX_STEPS) |_| {
                const curPos = rd.mulF(depth).add(ro);
                const distClosest = self.scene.dist(curPos);

                if (distClosest < MIN_HIT_DIST) {
                    //  vec3 normal = calcNormal(curPos);
                    //  float shadow = calcShadow(curPos, lightDir, 0.1, 5.0, 8.0);
                    //  float diffuse = max(dot(normal, lightDir), 0.0);

                    color = .{ .x = 0, .y = 0, .z = 1, .w = 1 };

                    //  fragColor = color * diffuse * shadow;

                    break;
                }

                if (depth > MAX_DEPTH) break;

                depth += distClosest;
            }

            img.set(@intCast(px), @intCast(py), color);
        }
    }

    try img.saveTga(io, "test.tga");
}
