#version 450

layout(location = 0) in vec2 v_uv;
layout(location = 1) in vec4 v_color;
layout(location = 2) in float v_shape;

layout(location = 0) out vec4 fragColor;

void main() {
    if (v_shape > 0.5) {
        // Recover the ball phase (0..1) and normalized speed (0..1),
        // both packed into the shape and alpha channels respectively.
        float phase = fract(v_shape - 1.0);
        float speed_n = v_color.a;

        float r = length(v_uv);
        float d = r - 1.0;
        float w = fwidth(d);

        // Anti-aliased solid disc mask.
        float disc = 1.0 - smoothstep(-w * 0.5, w * 0.5, d);

        // Pulsating white-hot core: rate and intensity scale with speed.
        float pulse = 0.5 + 0.5 * sin(phase * 6.28318530718);
        float core_t = pow(1.0 - clamp(r / (0.7 + 0.3 * pulse), 0.0, 1.0), 2.5);
        core_t *= (0.4 + 0.6 * pulse) * mix(0.6, 1.0, speed_n);
        vec3 disc_color = mix(v_color.rgb, vec3(1.0), core_t);

        // Soft halo bleeding past the disc edge into the padded quad.
        float halo = exp(-3.5 * max(d, 0.0)) * mix(0.7, 1.0, speed_n);

        vec3 rgb = disc_color * disc + v_color.rgb * halo * 0.8;
        float alpha = max(disc, halo * 0.5);

        if (alpha <= 0.001) {
            discard;
        }
        fragColor = vec4(rgb, alpha);
    } else {
        fragColor = v_color;
    }
}
