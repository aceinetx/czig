const c = @import("libc");
const mem = @import("mem.zig");

pub fn ArrayList(T: type) type {
    return struct {
        items: []T,
        capacity: usize,
        settings: ArrayListSettings,

        // ----------------------------------------------------------

        const Self = @This();
        const ExpandMethod = union(enum) {
            scalar: f64,
            linear: usize,
        };
        const ArrayListSettings = struct {
            initial_capacity: usize = 16,
            expand_method: ExpandMethod = .{ .scalar = 1.5 },
        };
        const AppendError = error{CapacityDidNotIncrease} || mem.AllocationError;

        // ----------------------------------------------------------

        pub fn init(settings: ArrayListSettings) Self {
            var self: Self = undefined;
            self.capacity = 0;
            self.items.len = 0;
            self.settings = settings;
            return self;
        }

        pub fn deinit(self: *Self) void {
            mem.free(self.items.ptr);
        }

        // ----------------------------------------------------------

        pub fn append(self: *Self, item: T) AppendError!void {
            if (self.items.len >= self.capacity) {
                if (self.capacity != 0) {
                    _ = c.printf("expand\n");

                    const new_capacity: usize = switch (self.settings.expand_method) {
                        .scalar => |scale| @intFromFloat(@as(f64, @floatFromInt(self.capacity)) * scale),
                        .linear => |value| self.capacity + value,
                    };
                    if (new_capacity <= self.capacity) {
                        return AppendError.CapacityDidNotIncrease;
                    }
                    self.capacity = new_capacity;

                    const len = self.items.len;
                    self.items = try mem.realloc(self.items, self.capacity);
                    self.items.len = len;
                } else {
                    _ = c.printf("initial expand\n");

                    const new_capacity = self.settings.initial_capacity;
                    if (new_capacity <= self.capacity) {
                        return AppendError.CapacityDidNotIncrease;
                    }
                    self.capacity = new_capacity;

                    self.items = try mem.alloc(T, self.capacity);
                    self.items.len = 0;
                }
            }

            self.items.len += 1;
            self.items[self.items.len - 1] = item;
        }

        pub fn appendMany(self: *Self, items: []const T) AppendError!void {
            for (items) |item| {
                try self.append(item);
            }
        }

        pub fn pop(self: *Self) ?T {
            if (self.items.len == 0) return null;
            const item = self.items[self.items.len - 1];
            self.items.len -= 1;
            return item;
        }

        // ----------------------------------------------------------

        pub fn clearAndFree(self: *Self) void {
            mem.free(self.items.ptr);
            self.items.len = 0;
            self.capacity = 0;
        }

        pub fn clearRetainingCapacity(self: *Self) void {
            self.items.len = 0;
        }
    };
}
