const std = @import("std");
const TokenType = @import("./Lox.zig").TokenType;

// not impl
pub const Object = union(enum) { null: bool };

pub const Token = struct {
    type: TokenType,
    lexeme: []const u8,
    literal: Object,
    line: u32,

    pub fn init(@"type": TokenType, lexeme: []const u8, literal: Object, line: u32) Token {
        return Token{ .type = @"type", .lexeme = lexeme, .literal = literal, .line = line };
    }

    pub fn toString(token: *Token, buf: []u8) ![]const u8 {
        return try std.fmt.bufPrint(buf, "{t} {s} {t}\n", .{ token.type, token.lexeme, token.literal });
    }
};
