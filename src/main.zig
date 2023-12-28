const zwin = @import("zwin");
const glfw = @import("glfw");

pub fn main() !void {
    try zwin.init(.OpenGL, 3, 3);
    defer zwin.deinit();

    try zwin.createWindow(800, 640, "Hello World");

    while (!zwin.shouldClose()) {
        if (zwin.getKey(glfw.KeyEscape) == glfw.Press) {
            zwin.setShouldClose(true);
        }

        zwin.swapBuffers();
        zwin.pollEvents();
    }
}
