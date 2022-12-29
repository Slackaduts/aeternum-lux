
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_TexelSize;
varying vec2 v_Res;

uniform vec2 u_time_n_intensity;
uniform float bloom_threshold;
uniform float bloom_intensity;
uniform vec3 bloom_color;
uniform float bloom_dirt_enable;
uniform float bloom_dirt_intensity;
uniform float bloom_dirt_scale;
uniform float bloom_debug;
uniform sampler2D bloom_dirt_tex;
uniform sampler2D bloom_tex;

vec3 saturate3(vec3 x) {
    return clamp(x, 0.0, 1.0);
}

vec2 tiling_mirror(vec2 uv, vec2 tiling) {
	uv = (uv - 0.5) * tiling + 0.5;
	uv = abs(mod(uv - 1.0, 2.0) - 1.0);
	return uv;
}

vec4 sample_box4(sampler2D tex, vec2 uv, float delta) {
	vec4 d = v_TexelSize.xyxy * vec2(-delta, delta).xxyy;
	vec4 col;
	col =  (texture2D(tex, uv + d.xy));
	col += (texture2D(tex, uv + d.zy));
	col += (texture2D(tex, uv + d.xw));
	col += (texture2D(tex, uv + d.zw));
	return col * 0.25; // (1.0 / 4.0)
}

vec3 tonemap_jodie_reinhard(vec3 c) {
	float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
	vec3 tc = c / (c + 1.0);
	return mix(c / (l + 1.0), tc, tc);
}

vec3 blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

vec2 get_aspect_ratio(vec2 res, vec2 size) {
	float aspect_ratio = res.x / res.y;
	return (res.x > res.y)
	? vec2(size.x * aspect_ratio, size.y)
	: vec2(size.x, size.y / aspect_ratio);
}

void main() {
	vec2 uv = v_vTexcoord;
	vec4 col_tex = texture2D(gm_BaseTexture, uv);
	vec3 main_col = col_tex.rgb;
	vec3 bloom = sample_box4(bloom_tex, uv, 0.5).rgb * bloom_color * bloom_intensity * u_time_n_intensity.y;
	bloom = tonemap_jodie_reinhard(bloom);
	bloom = saturate3(bloom);
	if (bloom_dirt_enable > 0.5) {
		vec2 size = get_aspect_ratio(v_Res, vec2(bloom_dirt_scale));
		vec2 uv2 = tiling_mirror(uv, size);
		vec3 col_dirt = texture2D(bloom_dirt_tex, uv2).rgb * bloom * bloom_dirt_intensity * 5.0;
		bloom = blend(bloom, col_dirt);
	}
	main_col = (bloom_debug > 0.5) ? texture2D(bloom_tex, uv).rgb : blend(main_col, bloom);
	gl_FragColor = vec4(main_col, col_tex.a);
}
