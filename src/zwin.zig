const std = @import("std");
const glfw = @import("glfw");

var initialized = false;
var api_window: ?*glfw.Window = null;

pub const GraphicsAPI = enum {
    None,
    OpenGL,
    GLES,
    Vulkan,
    DirectX,
};

pub fn init(api: GraphicsAPI, ver_maj: i32, ver_min: i32) !void {
    try glfw.init();
    initialized = true;

    glfw.windowHint(glfw.SRGBCapable, 1);

    switch (api) {
        .None, .Vulkan, .DirectX => {
            glfw.windowHint(glfw.ClientAPI, glfw.NoAPI);
        },

        .OpenGL => {
            glfw.windowHint(glfw.ClientAPI, glfw.OpenGLAPI);

            if (ver_maj > 3) {
                glfw.windowHint(glfw.OpenGLProfile, glfw.OpenGLCoreProfile);
            }

            glfw.windowHint(glfw.ContextVersionMajor, ver_maj);
            glfw.windowHint(glfw.ContextVersionMinor, ver_min);

            glfw.makeContextCurrent(api_window);
        },

        .GLES => {
            glfw.windowHint(glfw.ClientAPI, glfw.OpenGLESAPI);
            glfw.windowHint(glfw.ContextVersionMajor, ver_maj);
            glfw.windowHint(glfw.ContextVersionMinor, ver_min);

            glfw.makeContextCurrent(api_window);
        },
    }
}

pub fn deinit() void {
    if (api_window != null) {
        glfw.destroyWindow(api_window);
    }

    glfw.terminate();
}

pub fn createWindow(width: u16, height: u16, title: [:0]const u8) !void {
    if (!initialized) {
        return error.NotInitialized;
    }

    api_window = try glfw.createWindow(width, height, title, null, null);
}

pub fn shouldClose() bool {
    if (!initialized or api_window == null) {
        return true;
    }

    return glfw.windowShouldClose(api_window);
}

pub fn setShouldClose(state: bool) void {
    if (initialized and api_window != null) {
        glfw.setWindowShouldClose(api_window, state);
    }
}

pub fn setVsync(state: bool) void {
    if (initialized and api_window != null) {
        glfw.swapInterval(if (state) 1 else 0);
    }
}

pub fn swapBuffers() void {
    glfw.swapBuffers(api_window);
}

pub fn pollEvents() void {
    glfw.pollEvents();
}

pub fn getKey(key: i32) glfw.KeyState {
    if (!initialized or api_window == null) {
        return glfw.Release;
    }

    return glfw.getKey(api_window, key);
}
