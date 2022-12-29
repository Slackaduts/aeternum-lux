
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 render_pos_res;
uniform sampler2D render_tex;

void main() {
	vec2 vPos = (v_vPosition - render_pos_res.xy);
	vec2 uv2 = vPos / render_pos_res.zw;
	gl_FragColor = vec4(texture2D(render_tex, uv2).rgb, texture2D(gm_BaseTexture, v_vTexcoord).a) * v_vColour;
}
