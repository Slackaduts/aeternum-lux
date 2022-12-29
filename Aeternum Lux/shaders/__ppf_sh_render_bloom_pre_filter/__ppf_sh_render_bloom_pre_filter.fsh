
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

/* Original implementation by Keijiro Takahashi
 * GameMaker Integration by Mozart Junior
 *
 * Original License:
 *
 * Kino/Bloom v2 - Bloom filter for Unity
 *
 * Copyright (C) 2015, 2016 Keijiro Takahashi
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
*/

varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;

uniform float bloom_threshold;
uniform float bloom_intensity;

float brightness(vec3 col) {
	return max(max(col.r, col.g), col.b);
}

/*vec3 median(vec3 a, vec3 b, vec3 c) {
	return a + b + c - min(min(a, b), c) - max(max(a, b), c);
}*/

// standard box filtering
/*vec4 sample_box4(sampler2D tex, vec2 uv, float delta) {
	vec4 d = v_TexelSize.xyxy * vec2(-delta, delta).xxyy;
	vec4 col;
	col =  (texture2D(tex, uv + d.xy));
	col += (texture2D(tex, uv + d.zy));
	col += (texture2D(tex, uv + d.xw));
	col += (texture2D(tex, uv + d.zw));
	return col * 0.25; // (1.0 / 4.0)
}*/

// standard box filtering
vec4 sample_box4_antiflicker(sampler2D tex, vec2 uv, float delta) {
	vec4 d = v_TexelSize.xyxy * vec2(-delta, delta).xxyy;
	
	vec4 s1 = texture2D(tex, uv + d.xy);
	vec4 s2 = texture2D(tex, uv + d.zy);
	vec4 s3 = texture2D(tex, uv + d.xw);
	vec4 s4 = texture2D(tex, uv + d.zw);
	
	// Karis's luma weighted average (using brightness instead of luma)
	float s1w = 1.0 / (brightness(s1.rgb) + 1.0);
	float s2w = 1.0 / (brightness(s2.rgb) + 1.0);
	float s3w = 1.0 / (brightness(s3.rgb) + 1.0);
	float s4w = 1.0 / (brightness(s4.rgb) + 1.0);
	float one_div_wsum = 1.0 / (s1w + s2w + s3w + s4w);
	
	return (s1 * s1w + s2 * s2w + s3 * s3w + s4 * s4w) * one_div_wsum;
}

vec3 threshold(vec3 color) {
	return max((color - bloom_threshold) * bloom_intensity, 0.0);
}
		
void main() {
	vec4 col_tex = sample_box4_antiflicker(gm_BaseTexture, v_vTexcoord, 1.0);
	gl_FragColor = vec4(threshold(col_tex.rgb), 1.0);
}
