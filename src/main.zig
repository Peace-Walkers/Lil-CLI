const std = @import("std");
const Io = std.Io;

const lil_cli = @import("lil_cli");

pub fn main(init: std.process.Init) !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const gpa: std.mem.Allocator = init.gpa;

    const args = try init.minimal.args.toSlice(gpa);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    try lil_cli.printAnotherMessage(stdout_writer);

    try stdout_writer.flush();
}
