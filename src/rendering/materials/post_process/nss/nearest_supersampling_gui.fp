/*
 * nearest_supersampling_gui.script
 * Garden Lies, 													   09/11/24
 */

/*
 * Version d'OpenGL minimum : 3.0
 *
 * Interpolation des textures selon la taille de celles-ci dans la vue
 * sans arrondir les pixels. Adapté pour les GUIs.
 *
 * Source : https://github.com/britzl/template-lowres
 */

varying highp vec2 var_texcoord0;
varying lowp vec4 var_color;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 sharpness;

float sharpen(float pix_coord) {
    float norm = (fract(pix_coord) - .5) * 2.0;
    float norm2 = norm * norm;
    return floor(pix_coord) + norm * pow(norm2, sharpness.x) * .5 + .5;
}

void main() {

    /*
     * Indisponible dans OpenGL 2.1
     *
     * Impossible de le faire autrement, sinon,
     * disponible pour une seule texture.
     */
    vec2 vres = vec2(textureSize(DIFFUSE_TEXTURE, 0));
    
    gl_FragColor = texture(DIFFUSE_TEXTURE, vec2(
        sharpen(var_texcoord0.x * vres.x) / vres.x,
        sharpen(var_texcoord0.y * vres.y) / vres.y
    )) * var_color;
}
    