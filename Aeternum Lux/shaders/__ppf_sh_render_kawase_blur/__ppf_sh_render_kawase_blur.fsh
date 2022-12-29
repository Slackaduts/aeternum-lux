
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;

// >> uniforms
uniform vec2 u_time_n_intensity;
uniform float kawase_blur_mask_power;
uniform float kawase_blur_mask_scale;
uniform float kawase_blur_mask_smoothness;
uniform sampler2D kawase_blur_tex;

// >> dependencies
float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

float mask_radial(vec2 uv, vec2 center, float power, float scale, float smoothness) {
	float smoothh = mix(scale, 0.0, smoothness);
	float sc = scale / 2.0;
	float mask = pow(1.0-saturate((length(uv-center)-sc) / ((smoothh-0.001)-sc)), power);
	return mask;
}

void main() {
	vec2 uv = v_vTexcoord;
	vec4 col_tex = texture2D(gm_BaseTexture, uv);
	vec4 col_final = col_tex;
	vec4 col_blur = texture2D(kawase_blur_tex, uv);
	float mask = mask_radial(uv, vec2(0.5), kawase_blur_mask_power, kawase_blur_mask_scale, kawase_blur_mask_smoothness);
	col_final = mix(col_final, col_blur, mask);
	gl_FragColor = mix(col_tex, col_final, clamp(u_time_n_intensity.y, 0.0, 1.0));
}
