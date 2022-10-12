package transition.data;

import sys.FileSystem;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxGradient;

class IconOut extends BasicTransition
{
	var icon:FlxSprite;
	var bars:Array<FlxSprite> = [];
	var time:Float;
	var scaleTo:Float;

	override public function new(_time:Float = 0.5, _icon:String = "default", color:FlxColor = FlxColor.BLACK, _assetType:String = 'funk', _startScale:Float = 3)
	{
		super();

		time = _time;

		switch (_assetType)
		{
			case 'funk':
				var file:String = "transitionIcons/default";
				if (FileSystem.exists(Paths.funk("transitionIcons/" + _icon)))
					file = "transitionIcons/" + _icon;
				icon = new FlxSprite().loadGraphic(Paths.getImageFunk(file));
			default:
				var file:String = "transitionIcons/default";
				if (FileSystem.exists(Paths.image("transitionIcons/" + _icon)))
					file = "transitionIcons/" + _icon;
				icon = new FlxSprite().loadGraphic(Paths.getImagePNG(file));
		}
		icon.color = color;
		icon.antialiasing = true;
		icon.scale.x = icon.scale.y = _startScale;
		icon.updateHitbox();
		icon.screenCenter();

		scaleTo = 0;

		for (i in 0...4)
		{
			var bar = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
			bar.color = color;
			switch (i)
			{
				case 0:
					bar.setGraphicSize(FlxG.width, Math.ceil((FlxG.height - icon.height) / 2));
					bar.updateHitbox();
				case 1:
					bar.setGraphicSize(Math.ceil((FlxG.width - icon.width) / 2), FlxG.height);
					bar.updateHitbox();
				case 2:
					bar.setGraphicSize(FlxG.width, Math.ceil((FlxG.height - icon.height) / 2));
					bar.updateHitbox();
				case 3:
					bar.setGraphicSize(Math.ceil((FlxG.width - icon.width) / 2), FlxG.height);
					bar.updateHitbox();
			}
			add(bar);
			bars.push(bar);
		}
		add(icon);
	}

	override public function play()
	{
		FlxTween.tween(icon, {"scale.x": scaleTo, "scale.y": scaleTo}, time, {
			onComplete: function(tween)
			{
				end();
				flixel.util.FlxDestroyUtil.destroy(tween);
			}
		});
	}

	override public function draw()
	{
		icon.updateHitbox();
		icon.screenCenter();
		for (i in 0...bars.length)
		{
			switch (i)
			{
				case 0:
					bars[i].setPosition(0, icon.y - bars[i].height);
				case 1:
					bars[i].setPosition(icon.x - bars[i].width, 0);
				case 2:
					bars[i].setPosition(0, icon.y + icon.height);
				case 3:
					bars[i].setPosition(icon.x + icon.width, 0);
			}
		}
		super.draw();
	}

	override public function destroy()
	{
		icon = flixel.util.FlxDestroyUtil.destroy(icon);
		bars = null;
		super.destroy();
	}
}
