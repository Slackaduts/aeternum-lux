
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 col_tex = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(mix(vec3(0.5, 0.5, 1.0), col_tex.rgb, v_vColour.a*col_tex.a), col_tex.a);
}
