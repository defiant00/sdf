const Vector4 = @This();

x: f32,
y: f32,
z: f32,
w: f32,

pub fn r(self: Vector4) f32 {
    return self.x;
}

pub fn g(self: Vector4) f32 {
    return self.y;
}

pub fn b(self: Vector4) f32 {
    return self.z;
}

pub fn a(self: Vector4) f32 {
    return self.w;
}
