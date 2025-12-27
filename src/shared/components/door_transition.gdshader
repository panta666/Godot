shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE;
uniform float radius : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    float dist = distance(UV, center);
    float alpha = smoothstep(radius, radius + 0.01, dist); 
    // dist > radius → schwarz, dist < radius → Bild sichtbar
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
