const std = @import("std");
const lil = @import("lil");
const log = @import("../logger/logger.zig");

pub fn resolve(vm: *lil.VM, module_name: []const u8) anyerror![]const u8 {
    log.beginStep("Resolving import");
    defer log.endStep();

    log.trace("target: '{s}'", .{module_name});

    if (std.mem.startsWith(u8, module_name, "http://") or std.mem.startsWith(u8, module_name, "https://")) {
        return resolveUrl(vm, module_name);
    } else if (std.mem.endsWith(u8, module_name, ".lil")) {
        return resolvePath(vm, module_name);
    } else {
        return resolveAlias(vm, module_name);
    }
}

fn resolvePath(vm: *lil.VM, path: []const u8) ![]const u8 {
    log.trace("type: local path", .{});

    const source = std.Io.Dir.cwd().readFileAlloc(vm.io.system, path, vm.allocator, .unlimited) catch |err| {
        log.err("Cannot find local module at '{s}'", .{path});
        return err;
    };

    log.trace("module loaded from disk", .{});
    return source;
}

fn resolveUrl(vm: *lil.VM, url: []const u8) ![]const u8 {
    _ = vm;
    log.trace("type: remote URL", .{});
    log.trace("fetching: {s}", .{url});

    //TODO: implement http client to download repository
    //TODO: move lib in .cache

    log.err("URL import not implemented yet", .{});
    return error.NotImplemented;
}

fn resolveAlias(vm: *lil.VM, alias: []const u8) ![]const u8 {
    _ = vm;
    log.trace("type: manifest alias", .{});
    log.trace("looking up '{s}' in lil.toml", .{alias});

    //TODO: parse lil.toml
    //TOOD: Find corresponding key
    //TODO: call resolvePath or ResolveUrl

    log.err("Manifest aliases are not implemented yet.", .{});
    return error.NotImplemented;
}
