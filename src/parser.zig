const c = @import("libc");

pub fn Parser(T: type) type {
    switch (@typeInfo(T)) {
        .comptime_float => {},
        .comptime_int => {},
        .float => {},
        .int => {},
        else => @compileError("T is not a numeric type"),
    }

    // ----------------------------------------------------------

    return struct {
        const Self = @This();
        const ParserError = error{ UnknownCharacter, ExpectedRparen, UnexpectedToken };

        const Token = union(enum(u8)) {
            eof,
            plus,
            minus,
            mul,
            div,
            num: T,
            lparen,
            rparen,
        };

        text: []const u8,
        pos: usize = 0,

        // ----------------------------------------------------------

        pub fn evaluate(str: []const u8) T {
            var parser = Self{
                .text = str,
            };
            const value = parser.parse() catch {
                return 0;
            };
            return value;
        }

        pub fn evaluatePrint(str: []const u8) T {
            var parser = Self{
                .text = str,
            };
            _ = c.printf("%.*s = ", str.len, str.ptr);
            if (parser.parse()) |value| {
                const value_float = switch (@typeInfo(T)) {
                    .comptime_float => value,
                    .comptime_int => @as(f64, @floatFromInt(value)),
                    .float => value,
                    .int => @as(f64, @floatFromInt(value)),
                    else => unreachable,
                };
                _ = c.printf("%lf\n", value_float);
                return value;
            } else |_| {
                _ = c.puts("error");
                return 0;
            }
        }

        // ----------------------------------------------------------

        fn char(self: *Self) u8 {
            if (self.pos >= self.text.len) {
                return 0;
            }
            const ch = self.text[self.pos];
            self.pos += 1;
            return ch;
        }

        fn isdigit(ch: u8) bool {
            return ch >= '0' and ch <= '9';
        }

        fn isspace(ch: u8) bool {
            return ch == ' ' or ch == '\t' or ch == '\n';
        }

        // ----------------------------------------------------------

        fn next(self: *Self) ParserError!Token {
            var ch = self.char();
            if (ch == '+') {
                return .plus;
            } else if (ch == '-') {
                return .minus;
            } else if (ch == '*') {
                return .mul;
            } else if (ch == '/') {
                return .div;
            } else if (isdigit(ch)) {
                var num: T = 0;

                while (isdigit(ch)) {
                    num *= 10;
                    num += ch - '0';
                    ch = self.char();
                }
                self.pos -= 1;
                return .{ .num = num };
            } else if (ch == '(') {
                return .lparen;
            } else if (ch == ')') {
                return .rparen;
            } else if (ch == c.EOF or ch == 0) {
                return .eof;
            } else if (isspace(ch)) {
                return self.next();
            } else {
                return ParserError.UnknownCharacter;
            }
        }

        fn primary(self: *Self) ParserError!T {
            const token = try self.next();
            switch (token) {
                .num => |value| return value,
                .lparen => {
                    const value, const rp = try self.expr();
                    if (rp != .rparen) {
                        return ParserError.ExpectedRparen;
                    }
                    return value;
                },
                else => return ParserError.UnexpectedToken,
            }
        }

        fn multiplicative(self: *Self) ParserError!struct { T, Token } {
            var left = try self.primary();

            while (true) {
                const token = try self.next();
                if (token == .mul or token == .div) {
                    const right = try self.primary();
                    if (token == .mul) {
                        left = left * right;
                    } else if (token == .div) {
                        left = switch (@typeInfo(T)) {
                            .comptime_float => left / right,
                            .comptime_int => @divTrunc(left, right),
                            .float => left / right,
                            .int => @divTrunc(left, right),
                            else => unreachable,
                        };
                    }
                } else return .{ left, token };
            }
        }

        fn additive(self: *Self) ParserError!struct { T, Token } {
            var left, var token = try self.multiplicative();

            while (true) {
                if (token == .plus or token == .minus) {
                    const right, const next_token = try self.multiplicative();
                    if (token == .plus) {
                        left = left + right;
                    } else if (token == .minus) {
                        left = left - right;
                    }
                    token = next_token;
                } else return .{ left, token };
            }
        }

        const expr = additive;

        fn parse(self: *Self) ParserError!T {
            const value = (try self.expr()).@"0";
            return value;
        }
    };
}
