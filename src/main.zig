const std = @import("std");
const Lox = @import("./Lox.zig");
const Token = @import("./Token.zig").Token;
pub fn main() !void {
    var stdin_buffer: [1024 * 1024]u8 = undefined;
    var stdout_buffer: [1024 * 1024]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const in = &stdin_reader.interface;
    const out = &stdout_writer.interface;

    const args = [_][]const u8{};
    try Lox.main(&args, in, out);
    try out.flush();
}
