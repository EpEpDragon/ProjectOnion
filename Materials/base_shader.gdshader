shader_type spatial;
render_mode unshaded;

#define OBJECT_POSITION_LAYER 0x80000u
#define IS_OBJECT_POS_LAYER(layer) ((##layer & OBJECT_POSITION_LAYER) == OBJECT_POSITION_LAYER)

uniform vec2 object_screen_position;

void fragment() {
	if IS_OBJECT_POS_LAYER(CAMERA_VISIBLE_LAYERS) {
		vec2 coord = (FRAGCOORD.xy - object_screen_position);
		ALBEDO = vec3(coord+3000.f, 0);
	}
}