const std = @import("std");
const Token = @import("Token.zig").Token;
const Object = @import("Token.zig").Object;
const TokenType = @import("./Lox.zig").TokenType;
const Lox = @import("./Lox.zig");
const Allocator = std.mem.Allocator;

const Scanner = struct {
    source: []const u8,
    tokens: std.ArrayList(Token),

    start: u32 = 0,
    current: u32 = 0,
    line: u32 = 1,

    writer: *std.Io.Writer,
    gpa: Allocator,
    fn init(gpa: Allocator, writer: *std.Io.Writer, source: []const u8) Scanner {
        return Scanner{
            .source = source,
            .tokens = .empty,
            .writer = writer,
            .gpa = gpa,
        };
    }

    fn deinit(scanner: *Scanner) void {
        scanner.tokens.deinit(scanner.gpa);
    }

    fn scanTokens(scanner: *Scanner) !std.ArrayList(Token) {
        while (!scanner.isAtEnd()) {
            scanner.start = scanner.current;
            try scanner.scanToken();
        }

        try scanner.tokens.append(scanner.gpa, Token.init(.EOF, "", .{ .null = true }, scanner.line));
        return scanner.tokens;
    }

    fn scanToken(scanner: *Scanner) !void {
        const c = scanner.advance();
        switch (c) {
            '(' => try scanner.addToken(.LEFT_PAREN, null),
            ')' => try scanner.addToken(.RIGHT_PAREN, null),
            '{' => try scanner.addToken(.LEFT_BRACE, null),
            '}' => try scanner.addToken(.RIGHT_BRACE, null),
            ',' => try scanner.addToken(.COMMA, null),
            '.' => try scanner.addToken(.DOT, null),
            '-' => try scanner.addToken(.MINUS, null),
            '+' => try scanner.addToken(.PLUS, null),
            ';' => try scanner.addToken(.SEMICOLON, null),
            '*' => try scanner.addToken(.STAR, null),

            '!' => try scanner.addToken(if (scanner.match('=')) .BANG_EQUAL else .BANG, null),
            '=' => try scanner.addToken(if (scanner.match('=')) .EQUAL_EQUAL else .EQUAL, null),
            '<' => try scanner.addToken(if (scanner.match('=')) .LESS_EQUAL else .LESS, null),
            '>' => try scanner.addToken(if (scanner.match('=')) .GREATER_EQUAL else .GREATER, null),
            else => try Lox.@"error"(scanner.writer, scanner.line, "Unexpected character."),
        }
    }

    fn match(scanner: *Scanner, expected: u8) bool {
        if (scanner.isAtEnd()) return false;
        if (scanner.source[scanner.current] != expected) return false;

        scanner.current += 1;
        return true;
    }

    fn isAtEnd(scanner: *Scanner) bool {
        return scanner.current >= scanner.source.len;
    }

    fn advance(scanner: *Scanner) u8 {
        defer scanner.current += 1;
        return scanner.source[scanner.current];
    }

    fn addToken(scanner: *Scanner, @"type": TokenType, literal: ?Object) !void {
        const text = scanner.source[scanner.start..scanner.current];
        try scanner.tokens.append(
            scanner.gpa,
            Token.init(
                @"type",
                text,
                if (literal) |l| l else .{ .null = true },
                scanner.line,
            ),
        );
    }
};

test "can compile" {
    const allocator = std.testing.allocator;
    var buff: [1025]u8 = undefined;
    var writer = std.fs.File.stdout().writer(&buff);
    const out = &writer.interface;
    var scanner = Scanner.init(allocator, out, "()*<<=");
    defer scanner.deinit();
    const tokens = try scanner.scanTokens();
    for (tokens.items) |item| {
        std.debug.print("{t} {s} {t}\n", .{ item.type, item.lexeme, item.literal });
    }
}
