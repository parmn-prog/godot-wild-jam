shader_type spatial;

// Textures
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform sampler2D height_texture : hint_default_black, filter_linear_mipmap;

// Adjustmentsfile:///home/parmn/Downloads/moon_depth_matched.png

uniform float height_scale = 0.05;
uniform float roughness : hint_range(0.0, 1.0) = 0.9;

void vertex() {
	// 1. Get the height value from the grayscale texture
	float height = texture(height_texture, UV).r;
	
	// 2. Displace the vertex OUTWARD along its normal vector (away from the sphere center)
	VERTEX += NORMAL * height * height_scale;
}

void fragment() {
	// 3. Map the color texture
	ALBEDO = texture(albedo_texture, UV).rgb;
	ROUGHNESS = roughness;
	
	// 4. Basic normal reconstruction trick for shadows
	// If shadows look flat, we calculate the slope changes based on texture offsets
	vec2 texel_size = 1.0 / vec2(textureSize(height_texture, 0));
	float h_left  = texture(height_texture, UV + vec2(-texel_size.x, 0.0)).r;
	float h_right = texture(height_texture, UV + vec2(texel_size.x, 0.0)).r;
	float h_down  = texture(height_texture, UV + vec2(0.0, -texel_size.y)).r;
	float h_up    = texture(height_texture, UV + vec2(0.0, texel_size.y)).r;
	
	vec3 normal_tangent = normalize(vec3((h_left - h_right) * height_scale * 10.0, (h_down - h_up) * height_scale * 10.0, 1.0));
	NORMAL_MAP = normal_tangent * 0.5 + 0.5;
}
