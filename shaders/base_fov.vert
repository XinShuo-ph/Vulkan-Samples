#version 320 es
/* Copyright (c) 2019, Arm Limited and Contributors
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

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 texcoord_0;
layout(location = 2) in vec3 normal;

layout(set = 0, binding = 1) uniform GlobalUniform {
    mat4 model;
    mat4 view_proj;
    vec3 camera_position;
} global_uniform;

layout (location = 0) out vec4 o_pos;
layout (location = 1) out vec2 o_uv;
layout (location = 2) out vec3 o_normal;
layout (location = 3) out vec2 o_ndc_pos; // pixel position on image (normalized device coordinates)
layout (location = 4) out vec2 o_ndc_pos_camera; // pixel position on camera (normalized device coordinates)

void main(void)
{
    o_pos = global_uniform.model * vec4(position, 1.0);

    o_uv = texcoord_0;

    o_normal = mat3(global_uniform.model) * normal;

    gl_Position = global_uniform.view_proj * o_pos;
    
    // // Calculate NDC positions
    // o_ndc_pos = gl_Position.xy / gl_Position.w; // Convert to NDC space
    // o_ndc_pos_camera = vec2(0.0, 0.0); // Camera is at center in NDC space

    vec4 clip_pos = global_uniform.view_proj * vec4(position, 1.0);
    o_ndc_pos = clip_pos.xy / clip_pos.w; // Normalize to NDC
    vec4 clip_pos_camera = global_uniform.view_proj * vec4(global_uniform.camera_position, 1.0);
    o_ndc_pos_camera = clip_pos_camera.xy / clip_pos_camera.w; // Normalize to NDC
     // should check if o_ndc_pos_camera is 0
     

}
