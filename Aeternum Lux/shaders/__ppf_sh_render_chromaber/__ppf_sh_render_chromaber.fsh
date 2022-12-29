
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec2 v_TexelSize;

uniform vec2 u_time_n_intensity;

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 8.0 // windows
#else
#define ITERATIONS 4.0 // others (android, operagx...)
#endif

// >> uniforms
// chromatic aberration
uniform float chromaber_direction;
uniform float chromaber_intensity;
uniform float chromaber_only_outer;
uniform float chromaber_center_radius;
uniform float chromaber_blur_enable;
uniform sampler2D chromaber_prisma_lut;

const float ITERATIONS_RECIPROCAL = 1.0/ITERATIONS;

// >> effect
vec4 chromaberration_fx(vec2 uv) {
	float dir = radians(chromaber_direction);
	vec2 direction = vec2(cos(dir), -sin(dir));
	vec2 dist;
	if (chromaber_only_outer > 0.5) {
		float inner = pow(length(uv - 0.5), chromaber_center_radius);
		vec2 uv2 = 2.0 * uv - 1.0;
	    float edge = dot(uv2, uv2) * 2.0 * inner * chromaber_intensity;
		vec2 delta = (edge - uv) / 3.0;
		dist = vec2(v_TexelSize * direction * uv2 * delta);
	} else {
		dist = vec2(v_TexelSize * direction * chromaber_intensity);
	}
	dist *= u_time_n_intensity.y;
	vec4 col_prisma_a = texture2D(chromaber_prisma_lut, vec2(0.5/3.0, 0.0));
	vec4 col_prisma_b = texture2D(chromaber_prisma_lut, vec2(1.5/3.0, 0.0));
	vec4 col_prisma_c = texture2D(chromaber_prisma_lut, vec2(2.5/3.0, 0.0));
	vec4 col_chrm;
	if (chromaber_blur_enable > 0.5) {
		float rad = 2.0 * ITERATIONS_RECIPROCAL;
		vec2 move; vec4 col; vec4 col_sum;
		for(float i = 0.0; i < ITERATIONS; ++i) {
			move = (i * dist * rad);
			vec4 col_chroma_a = texture2D(gm_BaseTexture, uv + move);
			vec4 col_chroma_b = texture2D(gm_BaseTexture, uv);
			vec4 col_chroma_c = texture2D(gm_BaseTexture, uv - move);
			col += col_chroma_a*col_prisma_a + col_chroma_b*col_prisma_b + col_chroma_c*col_prisma_c;
		}
		col_chrm = col / ITERATIONS;
	} else {
		vec4 col_chroma_a = texture2D(gm_BaseTexture, uv + dist);
		vec4 col_chroma_b = texture2D(gm_BaseTexture, uv);
		vec4 col_chroma_c = texture2D(gm_BaseTexture, uv - dist);
		vec4 col = col_chroma_a*col_prisma_a + col_chroma_b*col_prisma_b + col_chroma_c*col_prisma_c;
		vec4 col_sum = (col_prisma_a + col_prisma_b + col_prisma_c);
		col_chrm = col / col_sum;
	}
	return col_chrm;
}

void main() {
	gl_FragColor = chromaberration_fx(v_vTexcoord);
}
