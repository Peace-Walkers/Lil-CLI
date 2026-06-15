const std = @import("std");
const Io = std.Io;
const lil = @import("lil");

const host = @import("runtime/host.zig");

const cmd_run = @import("commands/run.zig");
const log = @import("logger/logger.zig");

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.gpa;
    const args = try init.minimal.args.toSlice(arena);
    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdin_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;
    var stdin_file_reader: Io.File.Reader = .init(.stdin(), io, &stdin_buffer);
    const stdin_reader = &stdin_file_reader.interface;

    // init vm io
    const vm_io = lil.VmIo{
        .system = io,
        .in = stdin_reader,
        .out = stdout_writer,
    };

    if (args.len < 2) {
        //TODO: REPL mode
        std.debug.print("REPL ...", .{});
        return;
    }

    log.header("LIL Compiler v0.1.0", .{});

    const cmd_str = args[1];

    if (std.mem.eql(u8, cmd_str, "run")) {
        if (args.len < 3) {
            std.debug.print("Error: usage: lil run <filename>\n", .{});
            std.process.exit(1);
        }
        const file_path = args[2];
        try cmd_run.execute(arena, vm_io, file_path, init);
    } else {
        std.debug.print("Unknown command: {s}\n", .{cmd_str});
        std.process.exit(1);
    }
}
