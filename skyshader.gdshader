shader_type sky;

uniform sampler2D star_texture : filter_linear, source_color;

uniform sampler2D constellation_texture : filter_linear, source_color;

uniform float stars_energy : hint_range(0.0, 10.0) = 1.0;
uniform float constellation_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 constellation_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);

void sky() {
    vec2 uv = SKY_COORDS;
    
    vec4 stars = texture(star_texture, uv) * stars_energy;
    vec4 figures = texture(constellation_texture, uv);

    vec3 blended_sky = mix(stars.rgb, constellation_color.rgb * figures.rgb, figures.a * constellation_opacity);

    COLOR = blended_sky;
}
