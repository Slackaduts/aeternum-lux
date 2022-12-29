
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 360.0 // windows
#else
#define ITERATIONS 180.0 // others (android, operagx...)
#endif

const float Golden_Angle = 2.39996323;

// >> uniforms
uniform vec2 u_time_n_intensity;
uniform float gaussian_blur_amount;

// >> effect
vec4 gaussian_blur_fx(vec2 uv) {
	vec2 radius = v_TexelSize * gaussian_blur_amount*3.0 * u_time_n_intensity.y;
	vec4 blur;
	float total;
	for(float i = 0.0; i < ITERATIONS; i+=Golden_Angle) {
		blur += texture2D(gm_BaseTexture, uv + vec2(cos(i), sin(i)) * sqrt(i) * radius);
		total++;
	}
	blur /= total;
	return blur;
}

void main() {
	gl_FragColor = gaussian_blur_fx(v_vTexcoord);
}
