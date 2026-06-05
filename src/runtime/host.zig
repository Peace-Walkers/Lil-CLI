const std = @import("std");
const lil = @import("lil");

fn cliImportResolver(vm: *lil.VM, module_name: []const u8) anyerror![]const u8 {
    const source = std.Io.Dir.cwd().readFileAlloc(vm.io.system, module_name, vm.allocator, .unlimited) catch |err| {
        std.debug.print("[CLI] Error: Unknown module '{s}'\n", .{module_name});
        return err;
    };

    return source;
}

pub fn executeScript(allocator: std.mem.Allocator, vm_io: lil.VmIo, source: []const u8) !void {
    var vm = try lil.VM.init(allocator, vm_io);
    defer vm.deinit();

    try lil.stdlib.openAll(&vm); // load lil std explicitly

    vm.import_resolver = cliImportResolver;

    vm.eval(source) catch |err| {
        std.debug.print("\n[CLI] Stopped due to runtime error: {any}\n", .{err});
    };
}
