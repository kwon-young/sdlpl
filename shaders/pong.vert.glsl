#version 450

layout(location = 0) in vec2 pos;
layout(location = 1) in vec2 uv;
layout(location = 2) in vec4 color;
layout(location = 3) in float shape;

layout(location = 0) out vec2 v_uv;
layout(location = 1) out vec4 v_color;
layout(location = 2) out float v_shape;

void main() {
    gl_Position = vec4(pos, 0.0, 1.0);
    v_uv = uv;
    v_color = color;
    v_shape = shape;
}
