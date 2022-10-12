import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import title.TitleVideo;
import lime.graphics.OpenGLRenderContext;
import sys.io.File;
import lime.ui.FileDialog;
import cpp.UInt8;
import cpp.Pointer;
import haxe.io.Bytes;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class CheckGLState extends FlxState
{
	override public function create()
	{
		super.create();
		#if HXCPP_M64
		@:privateAccess
		var gl:OpenGLRenderContext = cast flixel.FlxG.stage.context3D.gl;
		var major = gl.getInteger(0x821B);
		var minor = gl.getInteger(0x821C);
		var version = Std.parseFloat((major + "." + minor));	
		if (version >= 4.2)
			FlxG.switchState(new TitleVideo());
		else
		{
			var backdrop = new CrappyTile(Paths.getImagePNG('tile4'), 50, 50);
			add(backdrop);
			var oops = new FlxText(0, 0, 1280,
				"Your system's supported OpenGL version is too low to play the 64-bit version of the mod (OpenGL 4.2 or higher is required, but your system only supports OpenGL " +
				version +
				"). This usually means that your GPU is pretty old.\n\nDownload the 32-bit version of the mod instead, which contains alternate assets for lower-end hardware.",
				32);
			oops.alignment = CENTER;
			oops.font = Paths.font("vcr");
			oops.screenCenter(XY);
			add(oops);
		}
		#else
		FlxG.switchState(new TitleVideo());
		#end

	}
}
