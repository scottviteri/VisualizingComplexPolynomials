#define PI 3.14159

float plot(vec2 st, float pct) {
  return smoothstep(pct-0.04, pct, st.y) -
         smoothstep(pct, pct+0.04, st.y);
}

vec3 hsl_to_rgb(vec3 hsl) {
  float h = hsl.x;
  float s = hsl.y;
  float l = hsl.z;
  float c = (1.0-abs(2.0*l-1.0))*s;
  h *= 6.0;
  float x = c*(1.0-abs(mod(h,2.0)-1.0));
  vec3 rgb = vec3(l-c/2.0);
  if (0.0 <= h && h < 1.0) {
    rgb.x += c;
    rgb.y += x;
  } else if(1.0 <= h && h < 2.0){
    rgb.x += x;
    rgb.y += c;
  } else if(2.0 <= h && h < 3.0) {
    rgb.y += c;
    rgb.z += x;
  } else if(3.0 <= h && h < 4.0) {
    rgb.y += x;
    rgb.z += c;
  } else if(4.0 <= h && h < 5.0) {
    rgb.z += c;
    rgb.x += x;
  } else if(5.0 <= h && h < 6.0) {
    rgb.z += x;
    rgb.x += c;
  }
  return rgb;
}

float max3(float x, float y, float z) {
  return max(max(x,y),z);
}
float min3(float x, float y, float z) {
  return min(min(x,y),z);
}

float helper_f(float n, vec3 hsl) {
  float k = mod(n + hsl.x*12.0,12.0);
  float a = hsl.y * min(hsl.z, 1.0-hsl.z);
  return hsl.z - a*max(-1.0, min3(k-3.0, 9.0-k, 1.0));
}

vec3 hsl_to_rgb_2(vec3 hsl) {
  float h = hsl.x;
  float s = hsl.y;
  float l = hsl.z;
  float r = helper_f(0.0, hsl);
  float g = helper_f(8.0, hsl);
  float b = helper_f(4.0, hsl);
  return vec3(r,g,b);
}

bool close(float x, float y) {
  return abs(x - y) < 0.01;
}
vec3 rgb_to_hsl(vec3 rgb) {
  float r = rgb.x;
  float g = rgb.y;
  float b = rgb.z;
  float x_max = max3(r,g,b);
  float v = x_max;
  float x_min = min3(r,g,b);
  float c = x_max - x_min;
  float l = (x_max + x_min) / 2.0;
  float h;
  if (close(c,0.0)) {
    h = 0.0;
  }
  if (close(v, r)) {
    h = (1.0/6.0)*((g-b)/c);
    h = ((g-b)/c);
  }
  if (close(v, g)) {
    h = (1.0/6.0)*(2.0+(b-r)/c);
  }
  if (close(v, b)) {
    h = (1.0/6.0)*(4.0+(r-g)/c);
  }
  float s;
  if (close(c, 0.0)) {
    s = 0.0;
  } else {
    s = c/(1.0-abs(2.0*l - 1.0));
  }
  return vec3(h,s,l);
}

// need hsl to rgb
// generate hsl in the first place
//  from complex number
float quad(vec2 c){
  return c.x*c.x + c.y*c.y;
}
float mag(vec2 c){
  return pow(quad(c), 0.5);
}
float arg(vec2 c){
  return atan(c.y,c.x);
}
float spread(vec2 c){
  return (c.y*c.y)/quad(c);
}
float atan_01(vec2 c){
  return mod(atan(c.y,c.x),2.0*PI)/(2.0*PI);
}
float atan_011(vec2 c){
  float theta = atan(c.y,c.x);
  if (theta < 0.0) {
    theta += 2.0*PI;
  }
  return theta/(2.0*PI);
}

float l(float x) {
  return pow(x,.5)/(pow(x,.5)+1.0);
}
vec3 c_to_hsl(vec2 c){
  //return vec3(atan_01(c), 1.0, 0.5);
  return vec3(spread(c)/2.0, 1.0, 0.5);
}
//now have complex num to hsl
// so just need to add function

vec2 cmul(vec2 c1, vec2 c2){
  return vec2(c1.x*c2.x-c1.y*c2.y,
              c1.x*c2.y+c1.y*c2.x);
}

vec2 pure(float x){
  return vec2(x,0.0);
}
// I think the color is currently in the wrong direction
// check out the hsl wiki
vec2 f(vec2 c) {
  return cmul(c,c)+pure(1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    float screen_radius = 3.14;
    vec2 c_uv = (2.0*uv-1.0)*screen_radius;
    float y = max3(1.0,c_uv.x,0.1);
    float pct1 = plot(c_uv, y);
    float pct2 = plot(c_uv, 0.0);
    vec3 black = vec3(0.0,0.0,0.0);
    vec3 green = vec3(0.0,1.0,0.0);
    vec3 blue = vec3(0.0,0.0,1.0);
    // if you want to plot a function from R to R
    //vec3 color = (1.0-pct1)*black + pct1*green + pct2*blue;
    vec3 hsl = c_to_hsl(f(c_uv));
    vec3 color = hsl_to_rgb(hsl);
    fragColor = vec4(color.x, color.y, color.z, 1.0);
}
