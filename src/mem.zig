const c = @import("libc");

pub const AllocationError = error{AllocationError};
const debug_allocations = false;

pub fn alloc(T: type, n: usize) AllocationError![]T {
    if (c.malloc(@sizeOf(T) * n)) |ptr| {
        if (debug_allocations)
            _ = c.printf("alloc %p\n", ptr);
        const ptr_casted: [*]T = @ptrCast(@alignCast(ptr));
        const slice = ptr_casted[0..n];
        return slice;
    } else {
        return AllocationError.AllocationError;
    }
}

pub fn realloc(old_mem: anytype, n: usize) AllocationError!@TypeOf(old_mem) {
    const T = @TypeOf(old_mem[0]);

    if (c.realloc(old_mem.ptr, @sizeOf(T) * n)) |ptr| {
        if (debug_allocations)
            _ = c.printf("alloc %p\n", ptr);
        const ptr_casted: [*]T = @ptrCast(@alignCast(ptr));
        const slice = ptr_casted[0..n];
        return slice;
    } else {
        return AllocationError.AllocationError;
    }
}

pub fn create(T: type) AllocationError!*T {
    if (c.malloc(@sizeOf(T))) |ptr| {
        if (debug_allocations)
            _ = c.printf("alloc %p\n", ptr);
        const ptr_casted: *T = @ptrCast(@alignCast(ptr));
        return ptr_casted;
    } else {
        return AllocationError.AllocationError;
    }
}

pub fn free(ptr: ?*anyopaque) void {
    if (debug_allocations)
        _ = c.printf("free %p\n", ptr);
    c.free(ptr);
}
