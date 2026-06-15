const std = @import("std");
const lil = @import("lil");

pub fn openEnv(vm: *lil.VM) !void {
    var env_module = try vm.createTable();
    try vm.bindNative(env_module, "parse_args", parse_args);

    try vm.setGlobal("env", .{ .Object = &env_module.obj });
}

pub fn parse_args(vm: *anyopaque, arg_count: u8, args: [*]lil.Value) !lil.Value {
    _ = arg_count;
    _ = args;
    const v: *lil.VM = @ptrCast(@alignCast(vm));

    const argv = v.args orelse return error.NoArgsProvidedByHost;
    const args_table = try v.createTable();
    for (argv[3..argv.len]) |arg| {
        const duped_arg = try v.allocator.dupe(u8, arg);
        const arg_object = try v.createString(duped_arg);
        try args_table.elements.append(v.allocator, .{ .Object = &arg_object.obj });
    }

    return .{ .Object = &args_table.obj };
}
