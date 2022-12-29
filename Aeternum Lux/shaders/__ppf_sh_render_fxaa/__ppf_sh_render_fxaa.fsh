
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;

uniform float fxaa_strength;

// >> effect
// Original shader by Timothy Lottes, NVIDIA
// https://developer.download.nvidia.com/assets/gamedev/files/sdk/11/FXAA_WhitePaper.pdf

#define FXAA_REDUCE_MIN (1.0 / 128.0)
#define FXAA_REDUCE_MUL (1.0 / 8.0)

vec4 FXAA() {
	vec3 basecol = texture2D(gm_BaseTexture, v_vTexcoord).rgb;
	vec3 baseNW = texture2D(gm_BaseTexture, v_vTexcoord - v_TexelSize).rgb;
	vec3 baseNE = texture2D(gm_BaseTexture, v_vTexcoord + vec2(v_TexelSize.x, -v_TexelSize.y)).rgb;
	vec3 baseSW = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-v_TexelSize.x, v_TexelSize.y)).rgb;
	vec3 baseSE = texture2D(gm_BaseTexture, v_vTexcoord + v_TexelSize).rgb;
	
	vec3 lum = vec3(0.299, 0.587, 0.114);
	float monocol = dot(basecol, lum);
	float monoNW = dot(baseNW, lum);
	float monoNE = dot(baseNE, lum);
	float monoSW = dot(baseSW, lum);
	float monoSE = dot(baseSE, lum);
	
	float lumaMin = min(monocol, min(min(monoNW, monoNE), min(monoSW, monoSE)));
	float lumaMax = max(monocol, max(max(monoNW, monoNE), max(monoSW, monoSE)));
	
	vec2 dir = vec2(-((monoNW + monoNE) - (monoSW + monoSE)), ((monoNW + monoSW) - (monoNE + monoSE)));
	float dirReduce = max((monoNW + monoNE + monoSW + monoSE) * FXAA_REDUCE_MUL * 0.25, FXAA_REDUCE_MIN);
	float dirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
	dir = min(vec2(fxaa_strength), max(vec2(-fxaa_strength), dir * dirMin)) * v_TexelSize;
	
	vec4 resultA = 0.5 * (texture2D(gm_BaseTexture, v_vTexcoord + dir * -0.166667) +
							texture2D(gm_BaseTexture, v_vTexcoord + dir * 0.166667));
	vec4 resultB = resultA * 0.5 + 0.25 * (texture2D(gm_BaseTexture, v_vTexcoord + dir * -0.5) +
											texture2D(gm_BaseTexture, v_vTexcoord + dir * 0.5));
	float monoB = dot(resultB.rgb, lum);
	return (monoB < lumaMin || monoB > lumaMax) ? resultA : resultB;
}

void main() {
	gl_FragColor = FXAA();
}
