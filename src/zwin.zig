const std = @import("std");
const glfw = @import("glfw");
const builtin = @import("builtin");

var initialized = false;
var api_window: ?*glfw.Window = null;
var graphics_api: GraphicsAPI = .None;

/// The graphics API to use.
pub const GraphicsAPI = enum {
    None,
    OpenGL,
    GLES,
    Vulkan,
    DirectX,
};

/// Initializes the windowing system with the given graphics API.
/// The version numbers are only used for OpenGL and OpenGL ES.
/// If the API is set to `None` or `Vulkan` or `DirectX`,
/// the window will not have a graphics context attached to it.
/// These contexts will be created later with `createWindow`.
pub fn init(api: GraphicsAPI, ver_maj: i32, ver_min: i32) !void {
    try glfw.init();
    initialized = true;
    graphics_api = api;

    glfw.windowHint(glfw.SRGBCapable, 1);
    glfw.windowHint(glfw.Resizable, 0);

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

            if (builtin.mode == .Debug) {
                glfw.windowHint(glfw.OpenGLDebugContext, 1);
            }
        },

        .GLES => {
            glfw.windowHint(glfw.ClientAPI, glfw.OpenGLESAPI);
            glfw.windowHint(glfw.ContextVersionMajor, ver_maj);
            glfw.windowHint(glfw.ContextVersionMinor, ver_min);
        },
    }
}

/// Deinitializes the windowing system.
/// This will destroy all windows and their contexts.
pub fn deinit() void {
    if (api_window != null) {
        glfw.destroyWindow(api_window);
    }

    glfw.terminate();
}

/// Creates a window with the given dimensions and title.
pub fn createWindow(width: u16, height: u16, title: [:0]const u8, vsync: bool) !void {
    if (!initialized) {
        return error.NotInitialized;
    }

    api_window = try glfw.createWindow(width, height, title, null, null);

    if (graphics_api == .OpenGL or graphics_api == .GLES) {
        glfw.makeContextCurrent(api_window);
    }

    setVsync(vsync);
}

/// Whether the window should close.
pub fn shouldClose() bool {
    if (!initialized or api_window == null) {
        return true;
    }

    return glfw.windowShouldClose(api_window);
}

/// Set whether the window should close.
pub fn setShouldClose(state: bool) void {
    if (initialized and api_window != null) {
        glfw.setWindowShouldClose(api_window, state);
    }
}

/// Sets the window's VSYNC state.
pub fn setVsync(state: bool) void {
    if (initialized and api_window != null) {
        if (graphics_api == .OpenGL or graphics_api == .GLES) {
            glfw.swapInterval(if (state) 1 else 0);
        }
    }
}

/// Swap the draw and display buffers.
pub fn render() void {
    if (graphics_api == .OpenGL or graphics_api == .GLES and api_window != null and initialized) {
        glfw.swapBuffers(api_window);
    }
}

/// Polls for input events.
pub fn update() void {
    glfw.pollEvents();
}

pub fn get_api_window() ?*anyopaque {
    return api_window;
}
