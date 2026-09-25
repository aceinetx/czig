const c = @import("libc");
const util = @import("util.zig");
const Parser = @import("parser.zig").Parser;

// fn input() [1024:0]u8 {
//     const len = 1024;
//     var str: [len:0]u8 = .{0} ** len;
//     var i: usize = 0;
//
//     while (true) {
//         const ch = c.getchar();
//         if (ch == c.EOF) break;
//
//         if (i < str.len) {
//             str[i] = @intCast(ch);
//         }
//
//         i += 1;
//     }
//     return str;
// }

pub export fn main(argc: c_int, argv: [*][*:0]const u8) c_int {
    const x: [Parser(usize).evaluate("1024 / 2 * 2 + 2 - 2")]u8 = undefined;
    const y: [1024 / 2 * 2 + 2 - 2]u8 = undefined;
    if (x.len != y.len) {
        @compileError("doesn't match");
    }

    // ----------------------------------------------------------

    _ = Parser(f64).evaluatePrint("1/10 + 2/10");
    _ = Parser(comptime_float).evaluate("1/10 + 2/10");

    // ----------------------------------------------------------

    if (argc >= 1) {
        for (1..@intCast(argc)) |i| {
            const cstr = argv[i];
            const str = cstr[0..c.strlen(cstr)];
            _ = Parser(f64).evaluatePrint(str);
        }
    }

    // ----------------------------------------------------------

    const ptr = util.create(i32) catch {
        unreachable;
    };
    defer util.free(ptr);
    ptr.* = 0;

    // ----------------------------------------------------------

    const array = util.alloc(i32, 5) catch {
        unreachable;
    };
    defer util.free(array.ptr);
    array[4] = 0;

    // ----------------------------------------------------------

    return 0;
}
