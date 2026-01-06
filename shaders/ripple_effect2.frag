#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec2 iMouse;
uniform float iTime;
uniform float iTapTime;
uniform sampler2D iChannel0;

out vec4 fragColor;

float maxRadius(float aspect, vec2 center) {
// Corners in normalized space
vec2 tl = vec2(0.0, 0.0);
vec2 tr = vec2(1.0, 0.0);
vec2 bl = vec2(0.0, 1.0);
vec2 br = vec2(1.0, 1.0);

// Apply aspect correction to the distance vectors
// This ensures the "boundary" logic matches the circular wave
float d1 = length((tl - center) * vec2(aspect, 1.0));
float d2 = length((tr - center) * vec2(aspect, 1.0));
float d3 = length((bl - center) * vec2(aspect, 1.0));
float d4 = length((br - center) * vec2(aspect, 1.0));

return max(max(d1, d2), max(d3, d4));
}

void main() {
vec2 fragCoord = FlutterFragCoord().xy;
vec2 uv = fragCoord / uSize;
vec2 p = uv - iMouse;

float aspect = uSize.x / uSize.y;
vec2 pRadius = p * vec2(aspect, 1.0);
float r = length(pRadius);


float maxR = maxRadius(aspect, iMouse);

float globalTime = max(iTime - iTapTime, 0.0);

float speed = 0.65;
float frequency = 18.0;
float decay = 3.5;
float amplitude = 0.05;

float delayOut = r / speed;
float tOut = max(globalTime - delayOut, 0.0);

float waveOut = sin(tOut * frequency) * exp(-tOut * decay);

float distFromEdge = maxR - r;
float delayIn = (maxR + distFromEdge) / speed;
float tIn = max(globalTime - delayIn, 0.0);

float waveIn = sin(tIn * frequency + 3.14159) * exp(-tIn * decay) * 0.45;
float rawWave = waveOut + waveIn;

float crest = max(rawWave, 0.0);
crest = pow(crest, 1.8);
float wave = crest + (rawWave * 0.2);

vec2 dir = normalize(pRadius + 0.0001);

vec2 refractUV = uv + (dir * wave * amplitude);

vec4 color = texture(iChannel0, refractUV);

fragColor = color;
}