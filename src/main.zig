const std = @import("std");
const Reader = std.Io.Reader;
const Writer = std.Io.Writer;

const Lox = struct {
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
    }
    fn runPrompt(reader: *Reader, writer: *Writer) !void {
        try writer.print("> ", .{});
        try writer.flush();
        while (reader.takeDelimiterExclusive('\n')) |line| {
            try writer.print("[out]: {s}\n[in]: ", .{line});
            try writer.flush();
            try run(line);
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
};
pub fn main() !void {
    var stdin_buffer: [1024 * 1024]u8 = undefined;
    var stdout_buffer: [1024 * 1024]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const in = &stdin_reader.interface;
    const out = &stdout_writer.interface;

    const args = [_][]const u8{};
    try Lox.main(&args, in, out);
}
