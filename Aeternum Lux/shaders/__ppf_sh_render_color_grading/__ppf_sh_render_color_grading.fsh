
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;
varying vec4 v_PosRes;

uniform vec2 u_time_n_intensity;
uniform float u_enabled[15];

// >> uniforms
uniform float lut3d_intensity;
uniform vec2 lut3d_size;
uniform float lut3d_squares;
uniform sampler2D lut3d_tex;

uniform vec3 shadow_color;
uniform vec3 midtone_color;
uniform vec3 highlight_color;
uniform float shadow_range;
uniform float highlight_range;

uniform float exposure;

uniform float brightness;

uniform float contrast;

uniform int tone_mapping_mode;

uniform vec3 lift_rgb;
uniform vec3 gamma_rgb;
uniform vec3 gain_rgb;

uniform vec3 hue_shift;

uniform float saturation;

uniform vec3 colorize_color;
uniform float colorize_intesity;
uniform float colorize_darkness;

uniform float posterization_col_factor;

uniform float invert_colors_intensity;

uniform float texture_overlay_intensity;
uniform sampler2D texture_overlay_tex;
uniform bool texture_overlay_is_outside;
uniform float texture_overlay_zoom;

// >> dependencies

uniform float lens_distortion_amount;
vec2 lens_distortion_uv(vec2 uv) {
	vec2 _uv = uv;
	vec2 uv2 = _uv - 0.5;
	float at = atan(uv2.x, uv2.y);
	float uvd = length(uv2);
	float dist = lens_distortion_amount * u_time_n_intensity.y;
	uvd *= (pow(uvd, 2.0) * dist + 1.0);
	_uv = vec2(0.5) + vec2(sin(at), cos(at)) * uvd;
	return _uv;
}

uniform float border_curvature;
uniform float border_smooth;
uniform vec3 border_color;
vec3 border_fx(vec3 color, vec2 uv) {
	vec3 _col = color;
	float curvature = border_curvature;
	if (curvature <= 0.005) curvature = 0.005;
	vec2 corner = pow(abs(uv*2.0-1.0), vec2(1.0/curvature));
	float edge = pow(length(corner), curvature);
	float border = smoothstep(1.0-border_smooth, 1.0, edge);
	return mix(_col, border_color, border);
}

// start of ACES
#region ACES - License
/*-------------------------------[ License Terms for Academy Color Encoding System Components ]-------------------------------
Academy Color Encoding System (ACES) software and tools are provided by the Academy under the following terms and conditions:
A worldwide, royalty-free, non-exclusive right to copy, modify, create derivatives, and use, in source and binary forms, is
hereby granted, subject to acceptance of this license.

Copyright © 2015 Academy of Motion Picture Arts and Sciences (A.M.P.A.S.). Portions contributed by others as indicated.
All rights reserved.

Performance of any of the aforementioned acts indicates acceptance to be bound by the following terms and conditions:

* Copies of source code, in whole or in part, must retain the above copyright notice, this list of conditions and the Disclaimer
of Warranty.

* Use in binary form must retain the above copyright notice, this list of conditions and the Disclaimer of Warranty in the
documentation and/or other materials provided with the distribution.

* Nothing in this license shall be deemed to grant any rights to trademarks, copyrights, patents, trade secrets or any other
intellectual property of A.M.P.A.S. or any contributors, except as expressly stated herein.

* Neither the name "A.M.P.A.S." nor the name of any other contributors to this software may be used to endorse or promote products
derivative of or based on this software without express prior written permission of A.M.P.A.S. or the contributors, as appropriate.

This license shall be construed pursuant to the laws of the State of California, and any disputes related thereto shall be subject
to the jurisdiction of the courts therein.

Disclaimer of Warranty: THIS SOFTWARE IS PROVIDED BY A.M.P.A.S. AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT
ARE DISCLAIMED. IN NO EVENT SHALL A.M.P.A.S., OR ANY CONTRIBUTORS OR DISTRIBUTORS, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, RESITUTIONARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE ACADEMY SPECIFICALLY DISCLAIMS ANY REPRESENTATIONS OR WARRANTIES WHATSOEVER
RELATED TO PATENT OR OTHER INTELLECTUAL PROPERTY RIGHTS IN THE ACADEMY COLOR ENCODING SYSTEM, OR APPLICATIONS THEREOF, HELD BY
PARTIES OTHER THAN A.M.P.A.S., WHETHER DISCLOSED OR UNDISCLOSED.
-------------------------------------------------------------------------------------------*/
#endregion

const mat3 AP1_2_XYZ_MAT = mat3 (
	0.6624541811, 0.1340042065, 0.1561876870,
	0.2722287168, 0.6740817658, 0.0536895174,
	-0.0055746495, 0.0040607335, 1.0103391003
);

const vec3 AP1_RGB2Y = vec3(AP1_2_XYZ_MAT[0][1], AP1_2_XYZ_MAT[1][1], AP1_2_XYZ_MAT[2][1]);

float get_luminance_ACES(vec3 color) {
	return dot(color, AP1_RGB2Y);
}

// Narkowicz 2015, "ACES Filmic Tone Mapping Curve"
vec3 tonemap_ACESFilm(vec3 x) {
	return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}
// end of ACES

// Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines" (modified)
vec3 tonemap_lottes(vec3 x) {
	vec3 a = vec3(1.6);
	vec3 d = vec3(0.977);
	vec3 hdrMax = vec3(1.0);
	vec3 midIn = vec3(0.2);
	vec3 midOut = vec3(0.267);
	vec3 b = (-pow(midIn, a) + pow(hdrMax, a) * midOut) / ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
	vec3 c = (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) / ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
	return pow(x, a) / (pow(x, a * d) * b + c);
}

// Unreal 3, Documentation: "Color Grading"
vec3 tonemap_unreal3(vec3 x) {
	return x / (x + 0.155) * 1.019;
}

// http://filmicgames.com/archives/75
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

const vec3 lum_weights = vec3(0.299, 0.587, 0.114);

float get_luminance(vec3 color) {
	return dot(color, lum_weights);
}

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec3 saturate3(vec3 x) {
    return clamp(x, 0.0, 1.0);
}

vec3 hsv2rgb(in vec3 color) {
	vec3 rgb = clamp(abs(mod(color.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	return color.z * mix(vec3(1.0), rgb, color.y);
}

vec3 blend_a(vec3 source, vec4 dest) {
	return dest.rgb * dest.a + source * (1.0-dest.a);
}

// >> effects
vec3 lut3d_fx(vec3 color) {
	vec3 _col = color;
	float _lut_area = (lut3d_squares * lut3d_squares);
	float _blue = _col.b * _lut_area-color.b;
	
	vec2 quad1 = vec2(0.0);
	quad1.y = floor(floor(_blue) / lut3d_squares);
	quad1.x = floor(_blue) - (quad1.y * lut3d_squares);
	
	vec2 quad2 = vec2(0.0);
	quad2.y = floor(ceil(_blue) / lut3d_squares);
	quad2.x = ceil(_blue) - (quad2.y * lut3d_squares);
	
	float pd = lut3d_squares / _lut_area;
	
	vec2 uv1 = vec2(0.0);
	uv1.x = (quad1.x * pd) + 0.5/lut3d_size.x + ((pd - 1.0/lut3d_size.x) * _col.r);
	uv1.y = (quad1.y * pd) + 0.5/lut3d_size.y + ((pd - 1.0/lut3d_size.y) * _col.g);
	
	vec2 uv2 = vec2(0.0);
	uv2.x = (quad2.x * pd) + 0.5/lut3d_size.x + ((pd - 1.0/lut3d_size.x) * _col.r);
	uv2.y = (quad2.y * pd) + 0.5/lut3d_size.y + ((pd - 1.0/lut3d_size.y) * _col.g);
	
	vec3 col1 = texture2D(lut3d_tex, uv1).rgb;
	vec3 col2 = texture2D(lut3d_tex, uv2).rgb;
	
	_col = mix(col1, col2, fract(_blue));
	return mix(color, _col, lut3d_intensity);
}

vec3 shadow_midtone_highlight_fx(vec3 color) {
	vec3 _col = color;
	float lum = get_luminance_ACES(_col);
	float shadow_factor = 1.0 - smoothstep(0.0, shadow_range, lum);
	float highlight_factor = smoothstep(highlight_range, 1.0, lum);
	float midtone_factor = 1.0 - shadow_factor - highlight_factor;
	_col *= (shadow_factor * shadow_color) + (midtone_factor * midtone_color + (highlight_factor * highlight_color));
	return _col;
}

vec3 exposure_fx(vec3 color) {
	return exposure * color;
}

vec3 brightness_fx(vec3 color) {
	return color + (brightness - 1.0);
}

vec3 contrast_fx(vec3 color) {
	return saturate3(((color - 0.5) * max(contrast, 0.0)) + 0.5);
}

vec3 tone_mapping_fx(vec3 color) {
	vec3 _col = color;
	if (tone_mapping_mode == 0) {
		_col = tonemap_ACESFilm(_col);
	} else
	if (tone_mapping_mode == 1) {
		_col = tonemap_lottes(_col);
	} else
	if (tone_mapping_mode == 2) {
		_col = tonemap_uncharted2(_col);
	} else
	if (tone_mapping_mode == 3) {
		_col = tonemap_unreal3(_col);
	}
	return _col;
}

vec3 lift_gamma_gain_fx(vec3 color) {
	vec3 _col = color;
	_col = saturate3(_col * (1.5-0.5 * lift_rgb) + 0.5 * lift_rgb - 0.5);
	_col *= gain_rgb;
	_col = saturate3(pow(_col, 1.0/gamma_rgb));
	return _col;
}

vec3 hue_shift_fx(vec3 color) {
	return color * hsv2rgb(hue_shift);
}

vec3 saturation_fx(vec3 color) {
	float lum = get_luminance(color);
	return mix(vec3(lum), color, saturation);
}

vec3 colorize_fx(vec3 color) {
	vec3 _col = color;
	float lum = get_luminance(color);
	float aa = clamp(2.0 * lum, 0.0, 1.0);
	float cc = clamp(2.0 * (1.0 - lum), 0.0, 1.0);
	float bb = 1.0 - aa - cc;
	_col = 1.0 - (bb * colorize_color * (1.0-colorize_darkness) + cc);
	return mix(color, _col, colorize_intesity);
}

vec3 posterization_fx(vec3 color) {
	vec3 _col = color;
	_col = floor(_col * posterization_col_factor) / posterization_col_factor;
	return _col;
}

vec3 invert_colors_fx(vec3 color) {
	vec3 _col = color;
	_col = 1.0 - _col;
	float intensity = (invert_colors_intensity == 0.5) ? 0.51 : invert_colors_intensity;
	return mix(color, _col, intensity);
}

vec3 texture_overlay_fx(vec3 color, vec2 uv) {
	vec3 _col = color;
	_col = blend_a(_col, texture2D(texture_overlay_tex, (uv - 0.5) * (1.0-texture_overlay_zoom+1.0) + 0.5));
	return mix(color, _col, texture_overlay_intensity);
}

void main() {
	vec2 vPos = (v_vPosition - v_PosRes.xy);
	vec2 uv = v_vTexcoord;
	
	// [d] lens distortion
	vec2 uvl = uv;
	if (u_enabled[0] > 0.5) uvl = lens_distortion_uv(uv);
	
	// image
	vec4 col_tex = texture2D(gm_BaseTexture, uv);
	vec4 col_final = col_tex;
	
	// lut3d
	if (u_enabled[1] > 0.5) col_final.rgb = lut3d_fx(col_final.rgb);
	
	// shadow_midtone_highlight_fx
	if (u_enabled[2] > 0.5) col_final.rgb = shadow_midtone_highlight_fx(col_final.rgb);
	
	// exposure_fx
	if (u_enabled[3] > 0.5) col_final.rgb = exposure_fx(col_final.rgb);
	
	// brightness_fx
	if (u_enabled[4] > 0.5) col_final.rgb = brightness_fx(col_final.rgb);
	
	// saturation_fx
	if (u_enabled[5] > 0.5) col_final.rgb = saturation_fx(col_final.rgb);
	
	// contrast_fx
	if (u_enabled[6] > 0.5) col_final.rgb = contrast_fx(col_final.rgb);
	
	// tone_mapping_fx
	if (u_enabled[7] > 0.5) col_final.rgb = tone_mapping_fx(col_final.rgb);
	
	// lift_gamma_gain_fx
	if (u_enabled[8] > 0.5) col_final.rgb = lift_gamma_gain_fx(col_final.rgb);
	
	// hue_shift_fx
	if (u_enabled[9] > 0.5) col_final.rgb = hue_shift_fx(col_final.rgb);
	
	// colorize_fx
	if (u_enabled[10] > 0.5) col_final.rgb = colorize_fx(col_final.rgb);
	
	// posterization_fx
	if (u_enabled[11] > 0.5) col_final.rgb = posterization_fx(col_final.rgb);
	
	// invert_colors_fx
	if (u_enabled[12] > 0.5) col_final.rgb = invert_colors_fx(col_final.rgb);
	
	// texture_overlay_fx
	if (u_enabled[13] > 0.5) col_final.rgb = texture_overlay_fx(col_final.rgb, uvl);
	
	// border_fx
	if (u_enabled[14] > 0.5) col_final.rgb = border_fx(col_final.rgb, uvl);
	
	gl_FragColor = mix(col_tex, col_final, u_time_n_intensity.y);
}
