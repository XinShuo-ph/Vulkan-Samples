#version 450
/* Copyright (c) 2019-2024, Sascha Willems
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

// Vertex attributes
layout (location = 0) in vec3 inPos;
layout (location = 1) in vec3 inNormal;
layout (location = 2) in vec2 inUV;

// Instanced attributes
layout (location = 3) in vec3 instancePos;
layout (location = 4) in vec3 instanceRot;
layout (location = 5) in float instanceScale;
layout (location = 6) in int instanceTexIndex;

layout (binding = 0) uniform UBO 
{
	mat4 projection;
	mat4 modelview;
	vec4 lightPos;
	float locSpeed;
	float globSpeed;
} ubo;

layout (location = 0) out vec3 outNormal;
layout (location = 1) out vec3 outColor;
layout (location = 2) out vec3 outUV;
layout (location = 3) out vec3 outViewVec;
layout (location = 4) out vec3 outLightVec;

void main() 
{

	outColor = vec3(1.0);
	outUV = vec3(inUV, instanceTexIndex);

	mat3 mx, my, mz;
	
	// rotate around x
	float s = sin(instanceRot.x + ubo.locSpeed);
	float c = cos(instanceRot.x + ubo.locSpeed);

	mx[0] = vec3(c, s, 0.0);
	mx[1] = vec3(-s, c, 0.0);
	mx[2] = vec3(0.0, 0.0, 1.0);
	
	// rotate around y
	s = sin(instanceRot.y + ubo.locSpeed);
	c = cos(instanceRot.y + ubo.locSpeed);

	my[0] = vec3(c, 0.0, s);
	my[1] = vec3(0.0, 1.0, 0.0);
	my[2] = vec3(-s, 0.0, c);
	
	// rot around z
	s = sin(instanceRot.z + ubo.locSpeed);
	c = cos(instanceRot.z + ubo.locSpeed);	
	
	mz[0] = vec3(1.0, 0.0, 0.0);
	mz[1] = vec3(0.0, c, s);
	mz[2] = vec3(0.0, -s, c);
	
	mat3 rotMat = mz * my * mx;

	mat4 gRotMat;
	s = sin(instanceRot.y + ubo.globSpeed);
	c = cos(instanceRot.y + ubo.globSpeed);
	gRotMat[0] = vec4(c, 0.0, s, 0.0);
	gRotMat[1] = vec4(0.0, 1.0, 0.0, 0.0);
	gRotMat[2] = vec4(-s, 0.0, c, 0.0);
	gRotMat[3] = vec4(0.0, 0.0, 0.0, 1.0);	
	
	vec4 locPos = vec4(inPos.xyz * rotMat, 1.0);
	vec4 pos = vec4((locPos.xyz * instanceScale) + instancePos, 1.0);

	// from global position to the pixel position, should be same as what's in gl_FragCoord
	
	vec2 resolution = vec2(640.0, 480.0); // Replace with actual resolution, we can also read res from code, but that needs more work
    vec2 center = resolution * 0.5;
	vec4 my_gl_Position = ubo.projection * ubo.modelview * gRotMat * vec4(instancePos, 1.0);
    // Calculate pixel position
    vec2 my_outFragCoord = (my_gl_Position.xy / my_gl_Position.w) * 0.5 + 0.5;
    my_outFragCoord.x *= float(resolution.x);
    my_outFragCoord.y *= float(resolution.y);
    float distance = length(my_outFragCoord - center);
    // float maxDistance = length(center);
    float maxDistance = 1e5;
	
	// in this example the instances are large in number (8000+), so we can try skipping some of the instances, according to there distance from the center
	// We can do this in a similar way as we did for the fragments. But we should be careful about the skiprate, we need to decide which instances to skip and
	// skip the entire instance 
	float tile_size = 10.0; 
	

	int skiprate1 = 4*4; // skip every 4th tile
	int skiprate2 = 2*2; 

	int creterion = int(instanceScale*1e4);

	
	// if (distance > 0.5 * maxDistance){
    //     // if (int(floor(my_outFragCoord.x/tile_size)) % skiprate1 != 0 || int(floor(my_outFragCoord.y/tile_size)) % skiprate1 != 0) {
	// 	// instead of pixel positions, try setting the creterion as "random", but fixed for each instance, e.g. 4th digit of distance
	// 	// if (int(distance*1e4) % skiprate1 != 0) {
	// 	// distance changes in time, how about scale?
	// 	if ( creterion % (skiprate1) != 0) {
	// 	// or skip according to TexIndex (is this unique for each instance?)
	// 	// if (instanceTexIndex % skiprate1 != 0) {


	if (distance > 0.5 * maxDistance && creterion % (skiprate1) != 0) {
			gl_Position = vec4(2.0, 0.0, 0.0, 0.0); // skip instance by putting it outside the screen
			return; 
    }
    if (distance > 0.25 * maxDistance && creterion % (skiprate2) != 0) {
		// if (instanceTexIndex % skiprate1 != 0) {
            gl_Position = vec4(2.0, 0.0, 0.0, 0.0); // skip instance by putting it outside the screen
			return; 
    }
	{
		gl_Position = ubo.projection * ubo.modelview * gRotMat * pos;
		outNormal = mat3(ubo.modelview * gRotMat) * inverse(rotMat) * inNormal;

		pos = ubo.modelview * vec4(inPos.xyz + instancePos, 1.0);
		vec3 lPos = mat3(ubo.modelview) * ubo.lightPos.xyz;
		outLightVec = lPos - pos.xyz;
		outViewVec = -pos.xyz;		
	}
}
