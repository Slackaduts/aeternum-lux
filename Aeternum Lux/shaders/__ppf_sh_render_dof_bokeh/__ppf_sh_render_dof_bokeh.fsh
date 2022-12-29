
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 20.0 // windows
#else
#define ITERATIONS 12.0 // others (android, operagx...)
#endif

const float Pi = 3.14159265;
const float Tau = 6.28318;
const float Golden_Angle = 2.39996323;

// >> uniforms
uniform vec2 u_time_n_intensity;
uniform float bokeh_radius;
uniform float bokeh_intensity;
uniform float bokeh_shaped;
uniform float bokeh_blades_aperture;
uniform float bokeh_blades_angle;
uniform float dof_debug;
uniform sampler2D coc_tex;

// smaller: more quality | larger: faster
const float rad_scale = 1.0;

// Based on DOF by Dennis Gustafsson.

vec2 hash22(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx+33.33);
	return normalize(fract((p3.xx+p3.yz)*p3.zy));
}

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec3 blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

float get_luminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 uncharted2Tonemap(vec3 x) {
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}
vec3 tonemap_uncharted2(vec3 color) {
	float W = 11.2;
	float exposureBias = 8.0;
	vec3 curr = uncharted2Tonemap(exposureBias * color);
	vec3 whiteScale = 1.0 / uncharted2Tonemap(vec3(W));
	return curr * whiteScale;
}

// >> effect
vec4 dof_fx(vec2 uv, vec2 fpos) {
	float center_depth = texture2D(coc_tex, uv).r;
	float center_size = center_depth * bokeh_radius;
	float total = 1.0;
	float radius = rad_scale;
	float bokeh_intensity = bokeh_intensity * 64.0;
	float shape_a = radians(bokeh_blades_angle); 
	mat2 shape_ang = mat2(cos(shape_a), -sin(shape_a), sin(shape_a), cos(shape_a));
	vec4 blur = texture2D(gm_BaseTexture, uv);
	vec4 weight;
	vec2 offset;
	for(float ang = 0.0; ang < 360.0; ang += Golden_Angle) {
		if (radius > ITERATIONS) break;
		if (bokeh_shaped > 0.5) {
			float rt = Pi/bokeh_blades_aperture;
			float geo = cos(rt) / cos(mod(ang, 2.0*rt) - rt);
			offset = vec2(sin(ang), cos(ang)) * geo * shape_ang;
		} else {
			offset = vec2(cos(ang), sin(ang));
		}
		vec2 uv2 = uv + offset * v_TexelSize * radius;
		vec4 tex = texture2D(gm_BaseTexture, uv2);
		float depth = texture2D(coc_tex, uv2).r;
		float coc = depth * bokeh_radius;
		if (depth > center_depth) coc = clamp(coc, 0.0, center_size*2.0);
        float m = smoothstep(radius-0.5, radius+0.5, coc);
		vec4 bok = pow(tex, vec4(vec3(8.0), 1.0)) * bokeh_intensity;
		blur += mix(blur/total, tex, m);
		weight += bok * m;
		total += 1.0;
		radius += rad_scale/radius;
	}
	vec4 bokeh = blur / total;
	vec4 lights = weight / total;
	lights.rgb = uncharted2Tonemap(lights.rgb);
	vec4 _col = bokeh;
	_col.rgb = blend(_col.rgb, lights.rgb);
	if (dof_debug > 0.5) {
		vec3 col_debug = mix(vec3(0.0, 1.0, 1.0), vec3(1.0), saturate(-center_depth));
		col_debug = mix(vec3(0.6), col_debug, saturate(center_depth));
		col_debug *= get_luminance(_col.rgb) + 0.5;
		_col.rgb = col_debug;
	}
	return _col;
}

void main() {
	gl_FragColor = dof_fx(v_vTexcoord, gl_FragCoord.xy);
}
