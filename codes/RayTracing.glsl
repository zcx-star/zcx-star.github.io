vec4 s1 = vec4(  0.0, 0.0, -5.0, 1.0 );
vec4 s2 = vec4(  3.0, 0.0, -5.0, 1.0 );
vec4 s3 = vec4( -3.0, 0.0, -5.0, 1.0 );
float h = -1.0;

float iSphere(in vec3 ro, in vec3 rd, in vec4 sph) 
{
    vec3 oc = ro - sph.xyz;
    float b = dot( oc, rd ); 
    float c = dot(oc,oc) - sph.w*sph.w;
    float h = b*b - c;
    if( h < 0.0 ) return -1.0;
    float t = -b - sqrt(h);
    return t;
}
vec3 nSphere( in vec3 pos, in vec4 sph ) 
{
    return (pos - sph.xyz) / sph.w;
}
float iPlane(in vec3 ro, in vec3 rd, in float h) 
{
    return (h-ro.y)/rd.y;
}
vec3 nPlane( in vec3 pos ) 
{
    return vec3(0.0, 1.0, 0.0);
}
vec2 intersect(in vec3 ro, in vec3 rd) 
{
    float nearT = 10000.0;
    float id = -1.0;
    float t1 = iSphere( ro, rd, s1 ); 
    float t2 = iSphere( ro, rd, s2 ); 
    float t3 = iSphere( ro, rd, s3 ); 
    float t4 = iPlane( ro, rd, h);
    if( t1 > 0.0 ) 
    {
        id = 1.0; 
        nearT = t1; 
    }
    if( t2>0.0 && t2<nearT ) 
    { 
        id = 2.0;
        nearT = t2;
    }  
    if( t3>0.0 && t3<nearT ) 
    { 
        id = 3.0;
        nearT = t3;
    } 
    if( t4>0.0 && t4<nearT ) 
    { 
        id = 4.0;
        nearT = t4;
    } 
    return vec2(nearT, id);
}

vec3 render(in vec2 tID, in vec3 ro, in vec3 rd)
{
    vec3 light = vec3(0.6);
    float t = tID.x;
    float id = tID.y;

    vec3 col = vec3(0.0);
    if( id > 0.5 && id < 1.5 ) 
    {       
        vec3 pos = ro + t*rd;
        vec3 nor = nSphere( pos, s1 );
        float diff = clamp(  dot(nor,light) , 0.0, 1.0);
        float ao = 0.5 + 0.5*nor.y;
        col = vec3( 0.9, 0.8, 0.6 )*diff*ao + vec3(0.1,0.2,0.4)*ao;
    } 
    else if( id > 1.5 && id < 2.5 ) 
    {       
        vec3 pos = ro + t*rd;
        vec3 nor = nSphere( pos, s2 );
        float diff = clamp(  dot(nor,light) , 0.0, 1.0);
        float ao = 0.5 + 0.5*nor.y;
        col = vec3( 0.9, 0.8, 0.6 )*diff*ao + vec3(0.1,0.2,0.4)*ao;
    } 
    else if( id > 2.5 && id < 3.5 ) 
    {       
        vec3 pos = ro + t*rd;
        vec3 nor = nSphere( pos, s3 );
        float diff = clamp(  dot(nor,light) , 0.0, 1.0);
        float ao = 0.5 + 0.5*nor.y;
        col = vec3( 0.9, 0.8, 0.6 )*diff*ao + vec3(0.1,0.2,0.4)*ao;
    }    
    else if( id > 3.5 ) 
    { 
        vec3 pos = ro + t*rd;
        vec3 nor = nPlane( pos );
        float diff = clamp(  dot(nor,light) , 0.0, 1.0 );
        float amb1 = smoothstep(0.0, 2.0*s1.w, length(pos.xz-s1.xz));
        float amb2 = smoothstep(0.0, 2.0*s2.w, length(pos.xz-s2.xz));
        float amb3 = smoothstep(0.0, 2.0*s3.w, length(pos.xz-s3.xz));
        col = vec3(amb1*amb2*amb3*0.7);
    }    
    col = sqrt(col);
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // camera space
    vec2 uv = (fragCoord * 2.0 - iResolution.xy ) / iResolution.y;    
    vec3 ro = vec3( 0.0, 0.0, 3.0 );//fixed view volume, then you can transform camera
    vec3 rd = normalize( vec3(uv, -2.14) );//view volume is here
    vec2 tID = intersect( ro, rd ); 
    vec3 col = render(tID, ro, rd);
    fragColor = vec4(col,1.0);
} 