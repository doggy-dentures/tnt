package;

import flixel.system.FlxAssets.FlxShader;

class HueShader extends FlxShader
{
	@:glFragmentSource('
        uniform float hue;

        #pragma header
        void main()
        {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            const vec3 k = vec3(0.57735, 0.57735, 0.57735);
            float cosAngle = cos(hue);
            vec3 finalcolor = vec3(color * cosAngle + cross(k, color) * sin(hue) + k * dot(k, color) * (1.0 - cosAngle));
            gl_FragColor = vec4(finalcolor.r, finalcolor.g, finalcolor.b, color.a);
        }')
	public function new(hue:Float)
	{
		super();
		this.hue.value = [hue];
	}
}
