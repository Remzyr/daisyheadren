#define PI 3.14159265
#define HALF_PI 0.5*PI
#define TWO_PI 2.0*PI

uniform float color_freq;
uniform float color_speed;
uniform float color_amp;

uniform float iTime;
uniform vec2 iResolution;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {

    vec2 uv = screen_coords / iResolution;
    float dist = length(vec2(0.5, 0.5) - uv);
    vec2 phase = vec2(0.0, HALF_PI);
    vec2 flare = color_amp * cos(phase + TWO_PI * (color_freq * dist + 2.0 * uv + color_speed * iTime));

    vec2 ouv = uv;
    float fT = iTime;
    float amplitude = 0.9 + 0.2 * sin(fT);

    uv.x += sin(ouv.y * 9.161 + fT) * 0.003 * amplitude;
    uv.y += sin(ouv.x * 6.363 + fT) * 0.003 * amplitude;

    vec2 uv2 = screen_coords / iResolution;
    uv2.x -= sin(ouv.y * 9.861 + fT) * 0.003 * amplitude;
    uv2.y -= sin(ouv.x * 7.395 + fT) * 0.003 * amplitude;

    vec4 tex1 = Texel(texture, uv);
    vec4 tex2 = Texel(texture, uv2);

    vec2 colorShift = (-color_amp + flare);
    tex1.rg -= colorShift;
    tex2.rg += colorShift;

    float am = 0.5;
    vec3 col = mix(tex1.rgb, tex2.rgb, am);
    col.rg -= colorShift;

    return vec4(col, 1.0);
}