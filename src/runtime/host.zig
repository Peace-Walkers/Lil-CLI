const std = @import("std");
const lil = @import("lil");
const resolver = @import("resolver.zig");
const cli = @import("cli.zig");

pub fn executeScript(allocator: std.mem.Allocator, vm_io: lil.VmIo, source: []const u8, init: std.process.Init) !void {
    var vm = try lil.VM.init(allocator, vm_io);
    defer vm.deinit();

    try lil.stdlib.openAll(&vm); // load lil std explicitly
    const args = try init.minimal.args.toSlice(vm.allocator);
    try vm.inject_args(args);
    try cli.openEnv(&vm);

    vm.import_resolver = resolver.resolve;

    vm.eval(source) catch |err| {
        std.debug.print("\n[CLI] Stopped due to runtime error: {any}\n", .{err});
    };
}
