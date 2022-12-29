
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;

uniform float reduce_banding;

const float Phi = 1.61803398875;

// (C) 2015, Dominic Cerisano
float gold_noise(in vec2 fpos, in float seed) {
	highp vec2 p = fpos;
	return fract(tan(distance(p*Phi, p)*seed)*p.x);
}

// standard box filtering
vec4 sample_box4(sampler2D tex, vec2 uv, float delta) {
	vec4 d = v_TexelSize.xyxy * vec2(-delta, delta).xxyy;
	vec4 col;
	col =  (texture2D(tex, uv + d.xy));
	col += (texture2D(tex, uv + d.zy));
	col += (texture2D(tex, uv + d.xw));
	col += (texture2D(tex, uv + d.zw));
	return col * 0.25; // (1.0 / 4.0)
}

void main() {
	gl_FragColor = sample_box4(gm_BaseTexture, v_vTexcoord, 0.5);
	if (reduce_banding > 0.5) gl_FragColor.rgb -= gold_noise(gl_FragCoord.xy, 1.0) * 0.0025;
}
