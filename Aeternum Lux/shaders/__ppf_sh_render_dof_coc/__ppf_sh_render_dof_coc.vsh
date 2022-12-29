
attribute vec3 in_Position; // (x,y,z)
attribute vec2 in_TextureCoord; // (u,v)

varying vec2 v_vTexcoord;

void main() {
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.0);
	v_vTexcoord = in_TextureCoord;
}
