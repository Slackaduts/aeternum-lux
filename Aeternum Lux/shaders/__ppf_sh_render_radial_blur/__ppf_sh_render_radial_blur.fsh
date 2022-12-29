
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
// blur radial
uniform vec2 u_time_n_intensity;
uniform float radial_blur_radius;
uniform vec2 radial_blur_center;
uniform float radial_blur_inner;

// >> dependencies
const float Phi = 1.61803398875;

// (C) 2015, Dominic Cerisano
float gold_noise(in vec2 fpos, in float seed) {
	highp vec2 p = fpos;
	return fract(tan(distance(p*Phi, p)*seed)*p.x);
}

// >> effect
vec4 blur_radial_fx(vec2 uv) {
	float dist = pow(length(uv - radial_blur_center), radial_blur_inner) * radial_blur_radius * u_time_n_intensity.y;
	vec2 center = radial_blur_center - uv;
	highp float offset = gold_noise(gl_FragCoord.xy, 1.0);
	vec4 blur = vec4(0.0);
	for(float i = 0.0; i < ITERATIONS; i+=1.0) {
		highp float percent = (i + offset) / ITERATIONS;
		blur += texture2D(gm_BaseTexture, uv + center * percent * dist);
	}
	return blur / ITERATIONS;
}

void main() {
	gl_FragColor = blur_radial_fx(v_vTexcoord);
}
