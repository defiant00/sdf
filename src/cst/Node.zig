const Node = @This();

instance: *anyopaque,
v_print: *const fn (self: *anyopaque, indent: u32) void,

pub fn from(instance: anytype) Node {
    const T: type = @typeInfo(@TypeOf(instance)).pointer.child;
    return .{
        .instance = instance,
        .v_print = @ptrCast(&@field(T, "print")),
    };
}

pub fn print(self: Node, indent: u32) void {
    self.v_print(self.instance, indent);
}
