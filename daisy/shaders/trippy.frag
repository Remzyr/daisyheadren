#define PI 3.14159265
#define HALF_PI 0.5*PI
#define TWO_PI 2.0*PI
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    float color_freq = 0.05;
	float color_speed = -0.1;
	float color_amp = 0.05;
    vec2 uv = fragCoord/iResolution.xy;
    float dist = length(vec2(0.5 , 0.5) - uv);
	vec2 phase = vec2(0.0, HALF_PI);
    vec2 flare = color_amp * cos(phase + TWO_PI * (color_freq * dist + 2.0 * uv + color_speed * iTime));
    vec2 uv2 = fragCoord/iResolution.xy;
    vec2 uv3 = fragCoord/iResolution.xy;
    vec2 ouv = uv;
    
    float fT = iTime;
    float amplitude = 0.9 + 0.2 * sin(fT);
        
	uv.x += sin(ouv.y*9.161 + fT)*0.003 * amplitude;
    uv.y += sin(ouv.x*6.363 + fT)*0.003 * amplitude;
    
    uv2.x -= sin(ouv.y*9.861 + fT)*0.003 * amplitude;
    uv2.y -= sin(ouv.x*7.395 + fT)*0.003 * amplitude;
    
    uv3.x += sin(ouv.y*15.161 + fT)*0.02;
    uv3.y -= sin(ouv.x*9.363 + fT)*0.02;
    

    float am = 0.5 + 0.5 * (sin(texture(iChannel2, uv3 / 4.).r + fT)); 
    
    
    am *= 1.8;
 
    am = pow(am, 2.) * 1.4;
    
    vec4 tex1 = texture(iChannel0, uv);
    vec4 tex2 = texture(iChannel0, uv2);
    vec2 colorShift = (-color_amp + flare);
    tex1.rg -= colorShift;
    tex2.rg += colorShift;
    vec3 col = mix(tex1.rgb, tex2.rgb, am);
    //col = vec3(am);
    col.rg -= colorShift;
   // col.br += (-flare_amp + flare);

    fragColor = vec4(col,1.0);
}