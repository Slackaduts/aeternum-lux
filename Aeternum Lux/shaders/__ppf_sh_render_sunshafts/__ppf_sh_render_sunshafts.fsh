
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;

uniform vec2 base_res;
uniform vec2 u_time_n_intensity;
uniform vec2 sunshaft_position;
uniform float sunshaft_center_smoothness;
uniform float sunshaft_threshold;
uniform float sunshaft_intensity;
uniform float sunshaft_dimmer;
uniform float sunshaft_scattering;
uniform float sunshaft_noise_enable;
uniform float sunshaft_rays_tiling;
uniform float sunshaft_rays_speed;
uniform float sunshaft_dual_textures;
uniform sampler2D sunshaft_world_tex;
uniform sampler2D sunshaft_sky_tex;
uniform sampler2D sunshaft_noise_tex;

uniform sampler2D base_tex;

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 16.0 // windows
#else
#define ITERATIONS 16.0 // others (android, operagx...)
#endif
const float ITERATIONS_RECIPROCAL = 1.0/ITERATIONS;

const float Phi = 1.61803398875;
const float Tau = 6.2831;

// (C) 2015, Dominic Cerisano
float gold_noise(in vec2 fpos, in float seed) {
	highp vec2 p = fpos;
	return fract(tan(distance(p*Phi, p)*seed)*p.x);
}

vec3 threshold(vec3 color) {
	return max((color - sunshaft_threshold), 0.0);
}

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

float mask_radial(vec2 uv, vec2 center, float power, float scale, float smoothness) {
	float smoothh = mix(scale, 0.0, smoothness);
	float sc = scale / 2.0;
	float mask = pow(1.0-saturate((length(uv-center)-sc) / ((smoothh-0.001)-sc)), power);
	return mask;
}

vec2 get_aspect_ratio(vec2 res, vec2 size) {
	float aspect_ratio = res.x / res.y;
	return (res.x > res.y)
	? vec2(size.x * aspect_ratio, size.y)
	: vec2(size.x, size.y / aspect_ratio);
}

vec3 blend(vec3 source, vec3 dest) {
    return source + dest - source * dest;
}

vec3 blend_a(vec3 source, vec4 dest) {
	return dest.rgb * dest.a + source * (1.0-dest.a);
}

void main() {
	vec2 uv = v_vTexcoord;
	float time = u_time_n_intensity.x * sunshaft_rays_speed;
	
	vec2 center_n = uv - sunshaft_position;
	vec2 uv_n = vec2((length(center_n) * 0.01) - time, atan(center_n.y, center_n.x) * (1.0/Tau) * sunshaft_rays_tiling);
	vec3 noise = vec3(1.0);
	if (sunshaft_noise_enable > 0.5) noise = texture2D(sunshaft_noise_tex, uv_n).rgb + 0.8 * 0.5;
	
	vec2 mask_size = get_aspect_ratio(base_res, vec2(1.0));
	noise *= mask_radial(uv*mask_size, sunshaft_position*mask_size, sunshaft_center_smoothness, sunshaft_center_smoothness, 1.0);
	
	// godrays
    vec4 col_final;
	
	highp float offset = gold_noise(gl_FragCoord.xy, 1.0);
	vec2 center = sunshaft_position - uv;
	
	float lum_decay = sunshaft_dimmer;
	vec2 move;
	float total;
	vec3 shaft;
	
	if (sunshaft_dual_textures < 0.5) {
		// full
		vec4 tex_base = texture2D(base_tex, uv); // using low-res texture instead of gm_BaseTexture
		float scattering = clamp(sunshaft_scattering, 0.0, 1.0);
		for(float i = 0.0; i < ITERATIONS; i++) {
			float percent = (i + offset) / ITERATIONS;
			move = center * percent * scattering;
			vec3 tex = texture2D(base_tex, uv + move).rgb * noise;
			shaft += threshold(tex) * lum_decay;
			lum_decay *= (1.0-ITERATIONS_RECIPROCAL);
			total++;
		}
		vec3 godray = (shaft / total) * sunshaft_intensity;
		vec4 col_tex = texture2D(gm_BaseTexture, uv); 
		col_tex.rgb = blend(col_tex.rgb, godray);
		col_final = col_tex;
	} else {
		// dual
		vec4 col_sky = texture2D(sunshaft_sky_tex, uv);
		vec4 col_world = texture2D(sunshaft_world_tex, uv);
		float scattering = clamp(sunshaft_scattering, 0.0, 1.0);
		for(float i = 0.0; i < ITERATIONS; i++) {
			float percent = (i + offset) / ITERATIONS;
			move = center * percent * scattering;
			vec3 sky = texture2D(sunshaft_sky_tex, uv + move).rgb * noise;
			float mask = texture2D(sunshaft_world_tex, uv + move).a;
			shaft += threshold(sky) * (1.0-mask) * lum_decay;
			lum_decay *= (1.0-ITERATIONS_RECIPROCAL);
			total++;
		}
		vec3 godray = (shaft / total) * sunshaft_intensity;
		vec4 col_tex = texture2D(gm_BaseTexture, uv);
		col_tex.rgb = blend_a(col_tex.rgb, col_sky);
		col_tex.rgb = blend_a(col_tex.rgb, col_world);
		col_tex.rgb = blend(col_tex.rgb, godray);
		col_final = col_tex;
	}
	gl_FragColor = col_final;
}
