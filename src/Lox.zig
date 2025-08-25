const std = @import("std");
const Reader = std.Io.Reader;
const Writer = std.Io.Writer;

pub const TokenType = enum {
    // Single-character tokens.
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    COMMA,
    DOT,
    MINUS,
    PLUS,
    SEMICOLON,
    SLASH,
    STAR,

    // One or two character tokens.
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,

    // Literals.
    IDENTIFIER,
    STRING,
    NUMBER,

    // Keywords.
    AND,
    CLASS,
    ELSE,
    FALSE,
    FUN,
    FOR,
    IF,
    NIL,
    OR,
    PRINT,
    RETURN,
    SUPER,
    THIS,
    TRUE,
    VAR,
    WHILE,

    EOF,
};

var hadError = false;
pub fn main(args: []const []const u8, reader: *Reader, writer: *Writer) !void {
    if (args.len > 1) {
        try writer.print("Usage: jlox [script]", .{});
    } else if (args.len == 1) {
        try runFile(args[0]);
    } else {
        try runPrompt(reader, writer);
    }
}

fn runFile(path: []const u8) !void {
    var file_buffer: [1024 * 1024]u8 = undefined;
    const cwd = std.fs.cwd();
    const bytes = try cwd.readFile(path, &file_buffer);
    try run(bytes);
    if (hadError) {
        std.process.exit(65);
    }
}

fn runPrompt(reader: *Reader, writer: *Writer) !void {
    try writer.print("> ", .{});
    try writer.flush();
    while (reader.takeDelimiterExclusive('\n')) |line| {
        try run(line);
        hadError = false;
    } else |err| if (err != error.EndOfStream) {
        return err;
    }
}

fn run(_: []const u8) !void {
    // private static void run(String source) {
    //   Scanner scanner = new Scanner(source);
    //   List<Token> tokens = scanner.scanTokens();
    //
    //   // For now, just print the tokens.
    //   for (Token token : tokens) {
    //     System.out.println(token);
    //   }
    // }
}

pub fn @"error"(writer: *Writer, lineNumber: u32, message: []const u8) !void {
    try report(writer, lineNumber, "", message);
}

fn report(writer: *Writer, lineNumber: u32, where: []const u8, message: []const u8) !void {
    try writer.print("[line {d}] Error{s}: {s}\n", .{ lineNumber, where, message });
    try writer.flush();
    hadError = true;
}
