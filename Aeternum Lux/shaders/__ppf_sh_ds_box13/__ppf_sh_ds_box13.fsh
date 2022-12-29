
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

// better, temporally stable box filtering
// [Jimenez14] http://goo.gl/eomGso
vec4 sample_box13(sampler2D tex, vec2 uv, float delta) {
    vec4 A = texture2D(tex, uv + v_TexelSize * vec2(-1.0, -1.0));
    vec4 B = texture2D(tex, uv + v_TexelSize * vec2( 0.0, -1.0));
    vec4 C = texture2D(tex, uv + v_TexelSize * vec2( 1.0, -1.0));
    vec4 D = texture2D(tex, uv + v_TexelSize * vec2(-0.5, -0.5));
    vec4 E = texture2D(tex, uv + v_TexelSize * vec2( 0.5, -0.5));
    vec4 F = texture2D(tex, uv + v_TexelSize * vec2(-1.0,  0.0));
    vec4 G = texture2D(tex, uv);
    vec4 H = texture2D(tex, uv + v_TexelSize * vec2( 1.0,  0.0));
    vec4 I = texture2D(tex, uv + v_TexelSize * vec2(-0.5,  0.5));
    vec4 J = texture2D(tex, uv + v_TexelSize * vec2( 0.5,  0.5));
    vec4 K = texture2D(tex, uv + v_TexelSize * vec2(-1.0,  1.0));
    vec4 L = texture2D(tex, uv + v_TexelSize * vec2( 0.0,  1.0));
    vec4 M = texture2D(tex, uv + v_TexelSize * vec2( 1.0,  1.0));
	
    vec2 div = 0.25 * vec2(0.5, 0.125); //(1.0 / 4.0)
	
    vec4 col = (D + E + I + J) * div.x;
    col += (A + B + G + F) * div.y;
    col += (B + C + H + G) * div.y;
    col += (F + G + L + K) * div.y;
    col += (G + H + M + L) * div.y;
    return col;
}

void main() {
	gl_FragColor = sample_box13(gm_BaseTexture, v_vTexcoord, 0.5);
	if (reduce_banding > 0.5) gl_FragColor.rgb -= gold_noise(gl_FragCoord.xy, 1.0) * 0.0025;
}
