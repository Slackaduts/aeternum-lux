
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D data_tex;

vec3 blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

// WIP

void main() {
	vec2 uv = v_vTexcoord;
	vec4 col_tex = texture2D(gm_BaseTexture, uv) * v_vColour;
	
	vec3 tex_red = texture2D(data_tex, vec2(uv.x, 0.0)).rgb;
	vec3 red = vec3(1.0, 0.0, 0.0) * step(1.0-uv.y, tex_red.r);
	
	col_tex.rgb = blend(col_tex.rgb, red);
    gl_FragColor = col_tex;
}
