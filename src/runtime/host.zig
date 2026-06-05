const std = @import("std");
const lil = @import("lil");
const resolver = @import("resolver.zig");

pub fn executeScript(allocator: std.mem.Allocator, vm_io: lil.VmIo, source: []const u8) !void {
    var vm = try lil.VM.init(allocator, vm_io);
    defer vm.deinit();

    try lil.stdlib.openAll(&vm); // load lil std explicitly

    vm.import_resolver = resolver.resolve;

    vm.eval(source) catch |err| {
        std.debug.print("\n[CLI] Stopped due to runtime error: {any}\n", .{err});
    };
}
