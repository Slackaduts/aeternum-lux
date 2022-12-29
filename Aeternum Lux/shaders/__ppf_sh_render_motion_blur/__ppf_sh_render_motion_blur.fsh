
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 32.0 // windows
#else
#define ITERATIONS 16.0 // others (android, operagx...)
#endif

// >> uniforms
uniform vec2 u_time_n_intensity;
uniform float motion_blur_direction;
uniform float motion_blur_radius;
uniform vec2 motion_blur_center;
uniform float motion_blur_mask_power;
uniform float motion_blur_mask_scale;
uniform float motion_blur_mask_smoothness;
uniform sampler2D motion_blur_overlay_tex;

// >> dependencies
const float Phi = 1.61803398875;

// (C) 2015, Dominic Cerisano
float gold_noise(in vec2 fpos, in float seed) {
	highp vec2 p = fpos;
	return fract(tan(distance(p*Phi, p)*seed)*p.x);
}

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec4 blend_b(vec4 source, vec4 dest) {
	return dest * dest.a + source * (1.0-dest.a);
}

float mask_radial(vec2 uv, vec2 center, float power, float scale, float smoothness) {
	float smoothh = mix(scale, 0.0, smoothness);
	float sc = scale / 2.0;
	float mask = pow(1.0-saturate((length(uv-center)-sc) / ((smoothh-0.001)-sc)), power);
	return mask;
}

// >> effect
vec4 motion_blur_fx(vec2 uv) {
	float dir = radians(motion_blur_direction);
	vec2 direction = vec2(cos(dir), -sin(dir));
	float mask = mask_radial(uv, motion_blur_center, motion_blur_mask_power, motion_blur_mask_scale, motion_blur_mask_smoothness);
	vec2 dist = direction * mask * motion_blur_radius * 0.05 * u_time_n_intensity.y;
	highp float offset = gold_noise(gl_FragCoord.xy, 1.0);
	vec4 blur = vec4(0.0);
	for(float i = 0.0; i < ITERATIONS; i+=1.0) {
		highp float percent = (i + offset) / ITERATIONS;
		blur += texture2D(gm_BaseTexture, uv + (percent * 2.0 - 1.0) * dist);
	}
	vec4 mblur = blur / ITERATIONS;
	mblur = blend_b(mblur, texture2D(motion_blur_overlay_tex, uv));
	return mblur;
}

void main() {
	gl_FragColor = motion_blur_fx(v_vTexcoord);
}
