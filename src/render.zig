const std = @import("std");

const Image = @import("Image.zig");
const rt = @import("rt/all_nodes.zig");
const Vector2 = @import("Vector2.zig");
const Vector3 = @import("Vector3.zig");
const Vector4 = @import("Vector4.zig");

const MAX_STEPS = 512;
const MAX_DEPTH = 1000;
const MIN_HIT_DIST = 0.001;

pub fn render(scene: rt.Scene, io: std.Io, alloc: std.mem.Allocator) !void {
    const pw: u32 = @intFromFloat(scene.resolution.x);
    const ph: u32 = @intFromFloat(scene.resolution.y);
    const scale: Vector2 =
        if (scene.resolution.x > scene.resolution.y)
            .{ .x = 1, .y = scene.resolution.y / scene.resolution.x }
        else
            .{ .x = scene.resolution.x / scene.resolution.y, .y = 1 };

    const img = try Image.init(alloc, pw, ph);
    defer img.deinit();

    const lightDir = Vector3.normalize(.{ .x = 5, .y = 4, .z = 3 });

    for (0..ph) |py| {
        for (0..pw) |px| {
            var uv = Vector2.mul(.{
                .x = 2 * (@as(f64, @floatFromInt(px)) + 0.5) / scene.resolution.x - 1,
                .y = -(2 * (@as(f64, @floatFromInt(py)) + 0.5) / scene.resolution.y - 1),
            }, scale);

            const rd = Vector3.normalize(.{ .x = uv.x, .y = uv.y, .z = -1 });
            var depth: f64 = 0;
            var color: Vector4 = .{ .x = 0, .y = 0, .z = 0, .w = 1 };

            for (0..MAX_STEPS) |_| {
                const curPos = rd.mulF(depth);
                const closest = scene.scene.at(curPos);

                if (closest.dist < MIN_HIT_DIST) {
                    var albedo = Vector4.ONE;
                    const normal = calcNormal(scene.scene, curPos);
                    const diffuse = @max(normal.dot(lightDir), 0);
                    const shadow = calcShadow(scene.scene, curPos, lightDir, 0.1, 5, 8);

                    if (closest.color) |c| albedo = c;

                    color = albedo.mulF(diffuse * shadow);
                    break;
                }

                if (depth > MAX_DEPTH) break;

                depth += closest.dist;
            }

            // temporarily force alpha to 1
            color.w = 1;
            img.set(@intCast(px), @intCast(py), color);
        }
    }

    try img.saveTga(io, "test.tga");
}

fn calcNormal(scene: rt.Node, p: Vector3) Vector3 {
    const o = 0.001;
    return Vector3.normalize(.{
        .x = scene.at(.{ .x = p.x + o, .y = p.y, .z = p.z }).dist -
            scene.at(.{ .x = p.x - o, .y = p.y, .z = p.z }).dist,
        .y = scene.at(.{ .x = p.x, .y = p.y + o, .z = p.z }).dist -
            scene.at(.{ .x = p.x, .y = p.y - o, .z = p.z }).dist,
        .z = scene.at(.{ .x = p.x, .y = p.y, .z = p.z + o }).dist -
            scene.at(.{ .x = p.x, .y = p.y, .z = p.z - o }).dist,
    });
}

fn calcShadow(scene: rt.Node, ro: Vector3, rd: Vector3, minT: f64, maxT: f64, k: f64) f64 {
    var res: f64 = 1;
    var t = minT;
    for (0..MAX_STEPS) |_| {
        if (t > maxT) break;

        const h = scene.at(rd.mulF(t).add(ro)).dist;
        if (h < MIN_HIT_DIST) return 0;

        res = @min(res, k * h / t);
        t += h;
    }
    return res;
}
