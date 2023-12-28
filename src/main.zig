const std = @import("std");
const zwin = @import("zwin");

pub fn main() !void {
    try zwin.init(.OpenGL, 4, 6);
    defer zwin.deinit();

    try zwin.createWindow(800, 640, "Hello World", false);

    while (!zwin.shouldClose()) {
        zwin.update();
        zwin.render();
    }
}
