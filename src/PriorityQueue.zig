const std = @import("std");

const ARITY = 8;
const LOG_2_ARITY = 3;

pub fn PriorityQueue(comptime T: type, comptime lessThan: fn(a: T, b: T) bool) type {
    return struct {
        items: []T,
        len: usize,

        const Self = @This();

        pub fn init(slice: []T) Self {
            return Self{
                .items = slice,
                .len = slice.len,
            };
        }

        pub fn heapify(self: *Self) void {
            var i = (self.len - 2) / ARITY + 1;
            while (i > 0) : (i -= 1) {
                self.siftDown(i);
            }
        }

        pub inline fn pop(self: *Self) T {
            const result = self.items[0];
            self.len -= 1;
            if (self.len > 0) {
                self.items[0] = self.items[self.len];
                self.siftDown(0);
            }
            return result;
        }

        inline fn siftDown(self: *Self, start: usize) void {
            var current_index = start;
            const item = self.items[current_index];
            const items_ptr = self.items.ptr;

            while (true) {
                const first_child = (current_index << LOG_2_ARITY) + 1;
                if (first_child >= self.len) break;

                var min_child = first_child;
                var min_value = items_ptr[first_child];

                inline for (1..ARITY) |offset| {
                    const child_index = first_child + offset;
                    if (child_index >= self.len) break;

                    const child_value = items_ptr[child_index];
                    if (lessThan(child_value, min_value)) {
                        min_child = child_index;
                        min_value = child_value;
                    }
                }

                if (!lessThan(min_value, item)) break;

                items_ptr[current_index] = min_value;
                current_index = min_child;
            }

            items_ptr[current_index] = item;
        }
    };
}
