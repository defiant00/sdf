const rt = @import("../all_nodes.zig");
const Vector3 = @import("../../Vector3.zig");
const Vector4 = @import("../../Vector4.zig");

pub const Result = struct {
    dist: f64,
    albedo: ?Vector4,

    pub fn fromDist(d: f64) Result {
        return .{ .dist = d, .albedo = null };
    }

    pub fn max(a: Result, b: Result) Result {
        return if (b.dist > a.dist) b else a;
    }

    pub fn min(a: Result, b: Result) Result {
        return if (b.dist < a.dist) b else a;
    }

    pub fn mul(a: Result, b: f64) Result {
        return .{ .dist = a.dist * b, .albedo = a.albedo };
    }

    pub fn negate(self: Result) Result {
        return .{ .dist = -self.dist, .albedo = self.albedo };
    }
};

pub fn at(self: rt.Node, point: Vector3) Result {
    switch (self) {
        .albedo => |a| {
            var res = a.target.at(point);
            res.albedo = a.albedo;
            return res;
        },
        .move => |m| return m.target.at(point.sub(m.amount)),
        .plane => return Result.fromDist(point.y),
        .scale => |s| return s.target.at(point.divF(s.amount)).mul(s.amount),
        .scene => |s| return s.scene.at(point),
        .sphere => return Result.fromDist(point.length() - 1),
        .subtract => |s| return s.a.at(point).max(s.b.at(point).negate()),
        ._union => |u| return u.a.at(point).min(u.b.at(point)),
    }
}
