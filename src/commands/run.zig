const std = @import("std");
const host = @import("../runtime/host.zig");
const lil = @import("lil");

pub fn execute(allocator: std.mem.Allocator, vm_io: lil.VmIo, file_path: []const u8) !void {
    const source = std.Io.Dir.cwd().readFileAlloc(vm_io.system, file_path, allocator, .unlimited) catch |err| {
        std.debug.print("Error: Failed to read '{s}' ({any})\n", .{ file_path, err });
        std.process.exit(1);
    };

    defer allocator.free(source);
    try host.executeScript(allocator, vm_io, source);
}
