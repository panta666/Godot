shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength : hint_range(0.0, 10.0) = 0.0;
uniform float blink_progress : hint_range(0.0, 1.0) = 0.0; // 0 = Augen offen, 1 = Augen geschlossen
uniform vec2 resolution;

vec4 blur(sampler2D tex, vec2 uv, float strength) {
    vec4 sum = vec4(0.0);
    float radius = strength * 0.002;
    for (float x = -4.0; x <= 4.0; x++) {
        for (float y = -4.0; y <= 4.0; y++) {
            vec2 offset = vec2(x, y) * radius;
            sum += texture(tex, uv + offset);
        }
    }
    return sum / 81.0;
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Blur proportional zum Augen-Schließen
    float effective_blur = blur_strength * blink_progress;
    vec4 scene = blur(SCREEN_TEXTURE, uv, effective_blur);

    // Balken von oben/unten zur Mitte
    float mid_y = 0.5;
    float top = clamp((mid_y - uv.y) / mid_y, 0.0, 1.0);
    float bottom = clamp((uv.y - mid_y) / mid_y, 0.0, 1.0);
    float mask = smoothstep(0.0, 0.05, top * blink_progress) + smoothstep(0.0, 0.1, bottom * blink_progress);
    mask = clamp(mask, 0.0, 1.0);

    vec4 blink_color = vec4(0.0, 0.0, 0.0, mask);

    COLOR = mix(scene, blink_color, blink_color.a);
}
