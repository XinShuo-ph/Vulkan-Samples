#version 320 es
/* Copyright (c) 2019-2020, Arm Limited and Contributors
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 the "License";
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

precision highp float;

#ifdef HAS_BASE_COLOR_TEXTURE
layout(set = 0, binding = 0) uniform sampler2D base_color_texture;
#endif

layout(location = 0) in vec4 in_pos;
layout(location = 1) in vec2 in_uv;
layout(location = 2) in vec3 in_normal;
layout(location = 3) in vec2 in_ndc_pos; // pixel position on image (normalized device coordinates)
layout(location = 4) in vec2 in_ndc_pos_camera; // pixel position of camera 

layout(location = 0) out vec4 o_color;

layout(set = 0, binding = 1) uniform GlobalUniform
{
	mat4 model;
	mat4 view_proj;
	vec3 camera_position;
}
global_uniform;

// Push constants come with a limitation in the size of data.
// The standard requires at least 128 bytes
layout(push_constant, std430) uniform PBRMaterialUniform
{
	vec4  base_color_factor;
	float metallic_factor;
	float roughness_factor;
}
pbr_material_uniform;

#include "lighting.h"

layout(set = 0, binding = 4) uniform LightsInfo
{
	Light directional_lights[MAX_LIGHT_COUNT];
	Light point_lights[MAX_LIGHT_COUNT];
	Light spot_lights[MAX_LIGHT_COUNT];
}
lights_info;

layout(constant_id = 0) const uint DIRECTIONAL_LIGHT_COUNT = 0U;
layout(constant_id = 1) const uint POINT_LIGHT_COUNT       = 0U;
layout(constant_id = 2) const uint SPOT_LIGHT_COUNT        = 0U;

void main(void)
{	
	// compute distance to camera center 
	float radius = sqrt( (in_ndc_pos.x-in_ndc_pos_camera.x)*(in_ndc_pos.x-in_ndc_pos_camera.x) + (in_ndc_pos.y-in_ndc_pos_camera.y)*(in_ndc_pos.y-in_ndc_pos_camera.y) );

    const float centerRadius = 23;
    const float midRadius = 70;

    bool xindex1 = (int(in_ndc_pos.x) % 2) == 0; // Skip 2x2
    bool yindex1 = (int(in_ndc_pos.y) % 2) == 0; // Skip 2x2
    
    bool xindex2 = (int(in_ndc_pos.x) % 4) == 0; // Skip 4x4
    bool yindex2 = (int(in_ndc_pos.y) % 4) == 0; // Skip 4x4
    
    bool flag1 = xindex1 && yindex1;
    bool flag2 = xindex2 && yindex2;

	
    if (radius < centerRadius){
        // normal rendering

		
	vec3 normal = normalize(in_normal);

	vec3 light_contribution = vec3(0.0);

	for (uint i = 0U; i < DIRECTIONAL_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_directional_light(lights_info.directional_lights[i], normal);
	}

	for (uint i = 0U; i < POINT_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_point_light(lights_info.point_lights[i], in_pos.xyz, normal);
	}

	for (uint i = 0U; i < SPOT_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_spot_light(lights_info.spot_lights[i], in_pos.xyz, normal);
	}

	vec4 base_color = vec4(1.0, 0.0, 0.0, 1.0);

#ifdef HAS_BASE_COLOR_TEXTURE
	base_color = texture(base_color_texture, in_uv);
#else
	base_color = pbr_material_uniform.base_color_factor;
#endif

	vec3 ambient_color = vec3(0.2) * base_color.xyz;

	o_color = vec4(ambient_color + light_contribution * base_color.xyz, base_color.w);


    }
    else{
        if(radius < midRadius){
            if(flag1){
                // normal rendering

				
	vec3 normal = normalize(in_normal);

	vec3 light_contribution = vec3(0.0);

	for (uint i = 0U; i < DIRECTIONAL_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_directional_light(lights_info.directional_lights[i], normal);
	}

	for (uint i = 0U; i < POINT_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_point_light(lights_info.point_lights[i], in_pos.xyz, normal);
	}

	for (uint i = 0U; i < SPOT_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_spot_light(lights_info.spot_lights[i], in_pos.xyz, normal);
	}

	vec4 base_color = vec4(1.0, 0.0, 0.0, 1.0);

#ifdef HAS_BASE_COLOR_TEXTURE
	base_color = texture(base_color_texture, in_uv);
#else
	base_color = pbr_material_uniform.base_color_factor;
#endif

	vec3 ambient_color = vec3(0.2) * base_color.xyz;

	o_color = vec4(ambient_color + light_contribution * base_color.xyz, base_color.w);


            }
            else{
                o_color = vec4(1.0, 0.0, 0.0, 1.0); // skip rendering
            }
        }
        else{
            if(flag2){
                //normal rendering 

				
	vec3 normal = normalize(in_normal);

	vec3 light_contribution = vec3(0.0);

	for (uint i = 0U; i < DIRECTIONAL_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_directional_light(lights_info.directional_lights[i], normal);
	}

	for (uint i = 0U; i < POINT_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_point_light(lights_info.point_lights[i], in_pos.xyz, normal);
	}

	for (uint i = 0U; i < SPOT_LIGHT_COUNT; ++i)
	{
		light_contribution += apply_spot_light(lights_info.spot_lights[i], in_pos.xyz, normal);
	}

	vec4 base_color = vec4(1.0, 0.0, 0.0, 1.0);

#ifdef HAS_BASE_COLOR_TEXTURE
	base_color = texture(base_color_texture, in_uv);
#else
	base_color = pbr_material_uniform.base_color_factor;
#endif

	vec3 ambient_color = vec3(0.2) * base_color.xyz;

	o_color = vec4(ambient_color + light_contribution * base_color.xyz, base_color.w);

	
            }
            else{
                o_color = vec4(1.0, 0.0, 0.0, 1.0); // skip rendering
            }
        }
    }


}
