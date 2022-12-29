
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;

uniform sampler2D coc_tex;
uniform sampler2D dof_tex;

void main() {
	vec4 col_tex = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 dof = texture2D(dof_tex, v_vTexcoord);
	float coc = texture2D(coc_tex, v_vTexcoord).r;
	
	gl_FragColor = mix(col_tex, dof, coc);
}
