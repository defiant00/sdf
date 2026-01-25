const std = @import("std");

const item = @import("item.zig");
const Token = @import("Token.zig");
const Vector2 = @import("../Vector2.zig");
const Vector3 = @import("../Vector3.zig");
const Vector4 = @import("../Vector4.zig");

const List = @This();

t_left_paren: Token,
items: std.ArrayList(item.Item),
t_right_paren: Token,

pub fn init(self: *List, alloc: std.mem.Allocator) !void {
    self.items = try std.ArrayList(item.Item).initCapacity(alloc, 4);
}

pub fn getNum(self: List, index: usize) !?f64 {
    if (self.items.items[index] == .number) {
        return try std.fmt.parseFloat(f64, self.items.items[index].number.t_value.value);
    }
    return null;
}

pub fn getVec2(self: List, index: usize) !?Vector2 {
    if (self.items.items[index] == .list) {
        const i = self.items.items[index].list.items.items;
        if (i.len == 2 and i[0] == .number and i[1] == .number) {
            return .{
                .x = try std.fmt.parseFloat(f64, i[0].number.t_value.value),
                .y = try std.fmt.parseFloat(f64, i[1].number.t_value.value),
            };
        }
    }
    return null;
}

pub fn getVec3(self: List, index: usize) !?Vector3 {
    if (self.items.items[index] == .list) {
        const i = self.items.items[index].list.items.items;
        if (i.len == 3 and i[0] == .number and i[1] == .number and i[2] == .number) {
            return .{
                .x = try std.fmt.parseFloat(f64, i[0].number.t_value.value),
                .y = try std.fmt.parseFloat(f64, i[1].number.t_value.value),
                .z = try std.fmt.parseFloat(f64, i[2].number.t_value.value),
            };
        }
    }
    return null;
}

pub fn getVec4(self: List, index: usize) !?Vector4 {
    if (self.items.items[index] == .list) {
        const i = self.items.items[index].list.items.items;
        if (i.len == 4 and i[0] == .number and i[1] == .number and i[2] == .number and i[3] == .number) {
            return .{
                .x = try std.fmt.parseFloat(f64, i[0].number.t_value.value),
                .y = try std.fmt.parseFloat(f64, i[1].number.t_value.value),
                .z = try std.fmt.parseFloat(f64, i[2].number.t_value.value),
                .w = try std.fmt.parseFloat(f64, i[3].number.t_value.value),
            };
        }
    }
    return null;
}
