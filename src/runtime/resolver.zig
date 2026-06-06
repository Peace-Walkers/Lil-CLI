const std = @import("std");
const lil = @import("lil");
const log = @import("../logger/logger.zig");

pub fn resolve(vm: *lil.VM, module_name: []const u8, caller_path: []const u8) anyerror!lil.ResolvedModule {
    log.beginStep("Resolving import");
    defer log.endStep();

    log.trace("target: '{s}'", .{module_name});

    if (std.mem.startsWith(u8, module_name, "http://") or std.mem.startsWith(u8, module_name, "https://")) {
        return resolveUrl(vm, module_name);
    } else if (std.mem.endsWith(u8, module_name, ".lil")) {
        return resolvePath(vm, caller_path, module_name);
    } else {
        return resolveAlias(vm, module_name);
    }
}

fn resolvePath(vm: *lil.VM, caller_path: []const u8, target_path: []const u8) !lil.ResolvedModule {
    log.beginStep("Resolve path");
    defer log.endStep();
    log.trace("type: local path", .{});

    const base_dir = std.fs.path.dirname(caller_path) orelse ".";
    const absolute_path = try std.fs.path.join(vm.allocator, &[_][]const u8{ base_dir, target_path });

    const source = std.Io.Dir.cwd().readFileAlloc(vm.io.system, absolute_path, vm.allocator, .unlimited) catch |err| {
        log.err("Cannot find local module at '{s}'", .{absolute_path});
        return err;
    };

    log.trace("module loaded from disk", .{});

    return .{
        .source = source,
        .file_path = absolute_path,
    };
}

fn resolveUrl(vm: *lil.VM, url: []const u8) !lil.ResolvedModule {
    log.beginStep("Resolve url");
    defer log.endStep();
    log.trace("type: git repository", .{});
    log.trace("fetching: {s}", .{url});

    var hasher = std.hash.Fnv1a_64.init();
    hasher.update(url);
    const hash = hasher.final();

    var dest_buf: [std.fs.max_path_bytes]u8 = undefined;

    const dest_path = std.fmt.bufPrint(&dest_buf, ".dependencies/{x}", .{hash}) catch return error.PathToLong;
    const already_exists = if (std.Io.Dir.cwd().access(vm.io.system, dest_path, .{})) |_| true else |_| false;

    if (!already_exists) {
        log.trace("initializing download...", .{});
        std.Io.Dir.cwd().createDirPath(vm.io.system, ".dependencies") catch {};

        var child = vm.allocator.create(std.process.Child) catch return error.AllocationFailed;

        const options = std.process.SpawnOptions{
            .stderr = .pipe,
            .stdout = .ignore,
            .argv = &[_][]const u8{ "git", "clone", "--depth", "1", "--progress", url, dest_path },
        };

        child.* = std.process.spawn(vm.io.system, options) catch return error.SpawnFailed;

        if (child.stderr) |*stderr_stream| {
            var io_buffer: [1024]u8 = undefined;
            var reader = stderr_stream.reader(vm.io.system, &io_buffer);

            var chunk_buf: [256]u8 = undefined;

            var line_acc: [512]u8 = undefined;
            var line_len: usize = 0;

            while (true) {
                const bytes_read = reader.interface.readSliceShort(&chunk_buf) catch |err| {
                    return err;
                };

                if (bytes_read == 0) break;

                for (chunk_buf[0..bytes_read]) |byte| {
                    if (byte == '\r' or byte == '\n') {
                        if (line_len > 0) {
                            log.trace("{s}", .{line_acc[0..line_len]});
                            line_len = 0;
                        }
                    } else {
                        if (line_len < line_acc.len) {
                            line_acc[line_len] = byte;
                            line_len += 1;
                        }
                    }
                }
            }
        }

        _ = child.wait(vm.io.system) catch {};
    }

    var entry_buf: [std.fs.max_path_bytes]u8 = undefined;
    const entry_path = std.fmt.bufPrint(&entry_buf, "{s}/lib.lil", .{dest_path}) catch return error.PathToLong;

    log.trace("loading entry point: {s}", .{entry_path});

    const source = std.Io.Dir.cwd().readFileAlloc(vm.io.system, entry_path, vm.allocator, .unlimited) catch |err| {
        log.err("Repository downloaded but 'lib.lil' is missing!", .{});
        return err;
    };

    const final_path = try vm.allocator.dupe(u8, entry_path);

    return .{
        .source = source,
        .file_path = final_path,
    };
}

fn resolveAlias(vm: *lil.VM, alias: []const u8) !lil.ResolvedModule {
    log.beginStep("Resolve url");
    defer log.endStep();
    _ = vm;
    log.trace("type: manifest alias", .{});
    log.trace("looking up '{s}' in lil.toml", .{alias});

    //TODO: parse lil.toml
    //TOOD: Find corresponding key
    //TODO: call resolvePath or ResolveUrl

    log.err("Manifest aliases are not implemented yet.", .{});
    return error.NotImplemented;
}
