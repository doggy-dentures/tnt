package;

import flixel.ui.FlxBar;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class SpellPrompt extends FlxSprite
{
	var word:String;
	var wordSprite:Array<FlxTextThing> = [];
	var charSize:Int = 24;
	var timeBar:FlxBar;
	var curChar:Int = 0;
	var playstate:PlayState;

	public var ttl:Float = 15;

	override public function new(state:PlayState)
	{
		super();
		playstate = state;
		loadGraphic(Paths.getImagePNG("spell"));
		antialiasing = true;
		updateHitbox();

		x = FlxG.random.float(0, FlxG.width - width);
		y = FlxG.random.float(0, FlxG.height - height);

		cameras = [playstate.camSpellPrompts];
		playstate.add(this);

		word = FlxG.random.getObject(PlayState.validWords);
		charSize = Math.floor(width / (word.length + 2));
		for (i in 0...word.length)
		{
			wordSprite[i] = new FlxTextThing();
			wordSprite[i].text = word.charAt(i);
			wordSprite[i].setFormat(null, charSize, 0x011cb8, LEFT, OUTLINE, FlxColor.BLACK);
			wordSprite[i].updateHitbox();
			wordSprite[i].cameras = [playstate.camSpellPrompts];
			wordSprite[i].x = ((i+1) * width / (word.length + 1)) - wordSprite[i].width / 2 + x;
			wordSprite[i].y = y + height / 2 - wordSprite[i].height / 2;
			playstate.add(wordSprite[i]);
		}

		timeBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(width - 20), 30, this, "ttl", 0, ttl, true);
		timeBar.updateHitbox();
		timeBar.x = x + width / 2 - timeBar.width / 2;
		timeBar.y = y + 50;
		timeBar.createFilledBar(0xFF464646, 0xFFFFFFFF, true, FlxColor.BLACK);
		timeBar.cameras = [playstate.camSpellPrompts];
		playstate.add(timeBar);
	}

	var stopStuff = false;
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (stopStuff)
			return;

		if (curChar >= word.length - 1)
		{
			this.kill();
			stopStuff = true;
			return;
		}
		ttl -= FlxG.elapsed;
		for (key in FlxG.keys.getIsDown())
		{
			if (key.ID.toString().length > 1)
				continue;
			if (key.justPressed && key.ID.toString().toLowerCase() == word.charAt(curChar))
			{
				wordSprite[curChar].color = 0xffd828;
				curChar++;
				FlxG.sound.play('assets/sounds/spellgood' + ".ogg", Conductor.vocalVolume);
			}
			else if (key.justPressed)
			{
				for (sprite in wordSprite)
					sprite.color = 0x011cb8;
				curChar = 0;
				FlxG.sound.play('assets/sounds/spellbad' + ".ogg", Conductor.vocalVolume);
			}
		}
	}

	override public function kill()
	{
		for (i in 0...wordSprite.length)
		{
			wordSprite[i].kill();
		}
		timeBar.kill();
		super.kill();
	}

	override public function destroy()
	{
		wordSprite = FlxDestroyUtil.destroyArray(wordSprite);
		timeBar = FlxDestroyUtil.destroy(timeBar);
		playstate = null;
		super.destroy();
	}
}
