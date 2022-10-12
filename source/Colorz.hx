import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class Colorz extends FlxShader
{
	@:glFragmentSource('
        #pragma header
        uniform vec3 colorInner;
        uniform vec3 colorOuter;
        uniform vec3 colorBase;

        void main()
        {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            vec3 inside = colorInner * color.r;
            vec3 outside = colorOuter * color.b;
            vec3 base = colorBase * color.g;
            color.rgb = inside + outside + base;
            gl_FragColor = color;
        }')
	public function new(inner:FlxColor, outer:FlxColor, base:FlxColor)
	{
		super();
		colorInner.value = [inner.redFloat, inner.greenFloat, inner.blueFloat];
		colorOuter.value = [outer.redFloat, outer.greenFloat, outer.blueFloat];
		colorBase.value = [base.redFloat, base.greenFloat, base.blueFloat];
	}
}
