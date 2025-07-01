/*
* nearest_supersampling_font.script
* Garden Lies, 													   09/11/24
*/

/*
* Version d'OpenGL minimum : 3.0
*
* Interpolation des textures selon la taille de celles-ci dans la vue
* sans arrondir les pixels. Adapté pour les textes.
*
* Source : https://github.com/britzl/template-lowres
*/

varying highp vec2 var_texcoord0;
varying lowp vec4 var_face_color;
varying lowp vec4 var_outline_color;
varying lowp vec4 var_shadow_color;
varying lowp vec4 var_layer_mask;
varying lowp float var_is_single_layer;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 sharpness;

float sharpen(float pix_coord) {
    float norm = (fract(pix_coord) - .5) * 2.0;
    float norm2 = norm * norm;
    return floor(pix_coord) + norm * pow(norm2, sharpness.x) * .5 + .5;
}

void main() {
    
    vec2 vres = vec2(textureSize(DIFFUSE_TEXTURE, 0));

    lowp vec3 texture_sample = texture(DIFFUSE_TEXTURE, vec2(
        sharpen(var_texcoord0.x * vres.x) / vres.x,
        sharpen(var_texcoord0.y * vres.y) / vres.y
    )).xyz;

    // Calcul des opacités de chaque couche
    float face_alpha = var_face_color.w * texture_sample.x;
    float raw_outline_alpha = var_outline_color.w * texture_sample.y;
    float max_outline_alpha = 1.0 - face_alpha * var_is_single_layer;
    float outline_alpha = min(raw_outline_alpha, max_outline_alpha);

    float raw_shadow_alpha = var_shadow_color.w * texture_sample.z;
    float max_shadow_alpha = 1.0 - (face_alpha + outline_alpha)
                                  * var_is_single_layer;
    
    float shadow_alpha = min(raw_shadow_alpha, max_shadow_alpha);

    // Application des masques de couche pour chaque couleur
    lowp vec4 face_color =  vec4(var_face_color.rgb, 1.0) 
                          * face_alpha * var_layer_mask.x;
    
    lowp vec4 shadow_color = vec4(var_shadow_color.rgb, 1.0) 
                           * shadow_alpha * var_layer_mask.z ;
                        
    // lowp vec4 outline_color = vec4(var_outline_color.rgb, 1.0) 
    //                         * outline_alpha * var_layer_mask.y ;

    // Combinaison des couleurs

    // L'addition du contour produit un scintillement.
    // gl_FragColor = face_color + outline_color + shadow_color;
    
    gl_FragColor = face_color + shadow_color;
}
