const std = @import("std");
const lil = @import("lil");

fn cliImportResolver(vm: *lil.VM, module_name: []const u8) anyerror![]const u8 {
    const source = std.Io.Dir.cwd().readFile(vm.io.system, module_name, std.math.maxInt(usize)) catch |err| {
        std.debug.print("[CLI] Error: Unknown module '{s}'\n", .{module_name});
        return err;
    };

    return source;
}
