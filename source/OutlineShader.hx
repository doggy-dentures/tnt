import flixel.system.FlxAssets.FlxShader;

class OutlineShader extends FlxShader
{
	@:glFragmentSource('
        uniform vec3 thecolor;
        uniform bool enabled;
        #pragma header
        void main()
        {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            if (enabled)
            {
                float gray = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
                if (gray < 0.2)
                {
                    color.rgb = thecolor * color.a;
                }
            }
            gl_FragColor = color;
        }')
	public function new(red:Float, green:Float, blue:Float)
	{
		super();
		this.thecolor.value = [red, green, blue];
	}
}
