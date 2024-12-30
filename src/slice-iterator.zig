const std = @import("std");

pub fn SliceIterator(S: type) type {
    return struct {
        slice: S,
        pos: usize = 0,

        const Self = @This();

        pub fn init(slice: S) Self {
            return .{ .slice = slice };
        }

        pub fn reset(self: *Self) void {
            self.pos = 0;
        }

        pub fn rest(self: Self) S {
            return self.slice[self.pos..];
        }

        pub fn peek(self: Self) ?slice_to_element_pointer(S) {
            if(self.pos < self.slice.len) {
                return &self.slice[self.pos];
            } else {
                return null;
            }
        }

        pub fn next(self: *Self) ?slice_to_element_pointer(S) {
            if(self.pos < self.slice.len) {
                defer self.pos += 1;
                return &self.slice[self.pos];
            } else {
                return null;
            }
        }
    };
}

pub fn slice_iterator(a: anytype) SliceIterator(@TypeOf(a)) {
    return SliceIterator(@TypeOf(a)).init(a);
}

pub fn slice_to_element_pointer(T: type) type {
    const info = @typeInfo(T);
    const cinfo = @typeInfo(info.Pointer.child);

    var new_info = info;

    if(info.Pointer.size == .One and cinfo == .Array) {
        new_info.Pointer.size = .One;
        new_info.Pointer.child = cinfo.Array.child;
    } else {
        new_info.Pointer.size = .One;
    }

    return @Type(new_info);
}


test "test1" {
    const s1 = [_]i32 {1, 4, -12, -52, 9, 4, 5};

    var s1_iter = slice_iterator(&s1);
    var i: usize = 0;
    while(s1_iter.next()) |x| : (i += 1) {
        try std.testing.expectEqual(x.*, s1[i]);
    }

    const s2 = [_]i32 {9, 3, 6, 0, -1, -5325, 5, 96, 4};

    var s3 = s2;
    var s4 = s2;

    for(&s3) |*x| {
        if(x.* < 0) x.* = -x.*;
    }

    var s4_iter = slice_iterator(&s4);
    while(s4_iter.next()) |x| {
        if(x.* < 0) x.* = -x.*;
    }

    try std.testing.expectEqualSlices(i32, &s3, &s4);
}

