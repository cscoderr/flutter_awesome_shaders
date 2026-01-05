#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec2 iMouse;
uniform float iTime;
uniform float iTapTime;
uniform sampler2D iChannel0;

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uSize;
    
    float aspect = uSize.x / uSize.y;
    vec2 p = uv - iMouse;
    vec2 pRadius = p * vec2(aspect, 1.0);
    float r = length(pRadius);

    float globalTime = max(iTime - iTapTime, 0.0);
    float speed = 0.65;
    float frequency = 18.0;
    float decay = 3.5;
    float amplitude = 0.05; 

    float tOut = max(globalTime - (r / speed), 0.0);
    
    float wave = 0.0;
    if (tOut > 0.0) {
        wave = sin(tOut * frequency) * exp(-tOut * decay);
        
        float crest = pow(max(wave, 0.0), 1.8);
        wave = crest + (wave * 0.2);
    }

    vec2 dir = normalize(pRadius + 0.0001);
    
    float rChannel = texture(iChannel0, uv + (dir * wave * amplitude * 1.2)).r;
    float gChannel = texture(iChannel0, uv + (dir * wave * amplitude)).g;
    float bChannel = texture(iChannel0, uv + (dir * wave * amplitude * 0.8)).b;
    
    vec4 color = vec4(rChannel, gChannel, bChannel, 1.0);

    float blowout = wave * exp(-globalTime * 3.0) * 0.4;
    color.rgb += blowout;

    fragColor = color;
}