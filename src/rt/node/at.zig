const rt = @import("../all_nodes.zig");
const Vector3 = @import("../../Vector3.zig");
const Vector4 = @import("../../Vector4.zig");

pub const Result = struct {
    dist: f64,
    color: Vector4,

    pub fn fromDist(d: f64) Result {
        return .{ .dist = d, .color = Vector4.ONE };
    }

    pub fn max(a: Result, b: Result) Result {
        return if (b.dist > a.dist) b else a;
    }

    pub fn min(a: Result, b: Result) Result {
        return if (b.dist < a.dist) b else a;
    }

    pub fn negate(self: Result) Result {
        return .{ .dist = -self.dist, .color = self.color };
    }
};

pub fn at(self: rt.Node, point: Vector3) Result {
    switch (self) {
        .color => {
            var res = self.color.target.at(point);
            res.color = self.color.color;
            return res;
        },
        .move => return self.move.target.at(point.sub(self.move.amount)),
        .plane => return Result.fromDist(point.y - self.plane.contact.y),
        .scene => return self.scene.scene.at(point),
        .sphere => return Result.fromDist(point.length() - self.sphere.radius),
        .subtract => return self.subtract.a.at(point).max(self.subtract.b.at(point).negate()),
        ._union => return self._union.a.at(point).min(self._union.b.at(point)),
    }
}
