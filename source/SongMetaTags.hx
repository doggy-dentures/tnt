package;

import flixel.util.FlxDestroyUtil;
import flixel.FlxCamera;
#if sys
import sys.io.File;
#end
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;
using flixel.util.FlxSpriteUtil;

class SongMetaTags extends FlxSpriteGroup
{
	public var size:Float = 0;
	public var fontSize:Int = 21;
	var text:FontAtlasThing;
	var bg:FlxSprite;

	public function new(_x:Float, _y:Float, _song:String, cam:FlxCamera)
	{
		super(_x, _y);

		// var text = new FlxTextThing(0, 0, 0, "", fontSize);
		// text.setFormat(Paths.font("vcr"), fontSize, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text = new FontAtlasThing(Paths.getSparrowAtlasFunk("fnt/font"), cam);
		text.text = Assets.getText(Paths.text(_song.toLowerCase() + "/meta"));
		text.text += switch (PlayState.curDifficulty)
		{
			case 0:
				"\nEasy";
			case 1:
				"\nNormal";
			case 2:
				"\nHard";
			default:
				"";
		}

		text.setPosition(0, 0);

		size = text.width;

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.setGraphicSize(Math.floor(text.width + fontSize), Math.floor(text.height + fontSize));
		bg.updateHitbox();
		bg.setPosition(fontSize / -2, fontSize / -2);
		bg.alpha = 0.67;
		bg.cameras = [cam];

		add(bg);
		add(text);

		x -= size;
		visible = false;
	}

	override public function destroy()
	{
		text = FlxDestroyUtil.destroy(text);
		bg = FlxDestroyUtil.destroy(bg);
		super.destroy();
	}

	// public function start()
	// {
	// 	visible = true;
	// 	FlxTween.tween(this, {x: x + size + (fontSize / 2)}, 1, {
	// 		ease: FlxEase.quintOut,
	// 		onComplete: function(twn:FlxTween)
	// 		{
	// 			FlxTween.tween(this, {x: x - size}, 1, {ease: FlxEase.quintIn, startDelay: 2, onComplete: function(twn:FlxTween)
	// 			{
	// 				this.destroy();
	// 			}});
	// 		}
	// 	});
	// }
}
