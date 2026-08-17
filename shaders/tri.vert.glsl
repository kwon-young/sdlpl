#version 450
layout(location = 0) in vec2 pos;
layout(location = 1) in vec4 color;
layout(location = 0) out vec4 vcolor;
void main() {
    gl_Position = vec4(pos, 0.0, 1.0);
    vcolor = color;
}
