import flixel.system.FlxAssets.FlxShader;

class Coolify extends FlxShader
{
    public var activeCount:Int = 0;

	@:glFragmentSource('
        uniform vec3 colorOutline;
        uniform vec3 colorInside;
        #pragma header
        void main()
        {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            float gray = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
            if (gray<= 0.142)
            {
                color.rgb = colorOutline * color.a;
            }
            else
            {
                color.rgb = colorInside * color.a;
            }
            gl_FragColor = color;
        }')
	public function new(red:Float, green:Float, blue:Float)
	{
		super();
        this.colorOutline.value = [red, green, blue];
        this.colorInside.value = [1, 1, 1];
	}
}
