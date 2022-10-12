package;

import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Boyfriend extends Character
{
	public var shadow:Character;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		super.playAnim(AnimName, Force, Reversed, Frame);
		if (shadow != null && shadow.alpha > 0)
		{
			shadow.playAnim(AnimName, Force, Reversed, Frame);
		}
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (isModel)
			{
				if (getCurAnim().startsWith('sing'))
				{
					holdTimer += elapsed;
				}
				else
					holdTimer = 0;
			}
			else
			{
				if (getCurAnim().startsWith('sing'))
				{
					holdTimer += elapsed;
				}
				else
					holdTimer = 0;

				if (getCurAnim().endsWith('miss') && getCurAnimFinished() && !debugMode)
				{
					idleEnd();
				}

				if (getCurAnim() == 'firstDeath' && getCurAnimFinished())
				{
					playAnim('deathLoop');
				}
			}
		}

		super.update(elapsed);
	}

	override public function idleEnd(?ignoreDebug:Bool = false)
	{
		if (!debugMode || ignoreDebug)
		{
			if (isModel)
			{
				super.idleEnd(ignoreDebug);
			}
			else if (atlasActive)
			{
				switch (curCharacter)
				{
					case "gf" | "gf-car" | "gf-christmas" | "gf-pixel" | "spooky" | "senpai":
						playAnim('danceRight', true, false, atlasContainer.maxIndex[animRedirect['danceRight']]);
					default:
						playAnim('idle', true, false, atlasContainer.maxIndex[animRedirect['idle']]);
				}
			}
			else
			{
				switch (curCharacter)
				{
					case "gf" | "gf-car" | "gf-christmas" | "gf-pixel" | "spooky" | "senpai":
						playAnim('danceRight', true, false, animation.getByName('danceRight').numFrames - 1);

					default:
						playAnim('idle', true, false, animation.getByName('idle').numFrames - 1);
				}
			}
		}
	}

	override public function dance(?ignoreDebug:Bool = false)
	{
		if (!debugMode || ignoreDebug)
		{
			switch (curCharacter)
			{
				case "gf" | "gf-car" | "gf-christmas" | "gf-pixel" | "spooky" | "senpai":
					if (!getCurAnim().startsWith('sing'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', true);
						else
							playAnim('danceLeft', true);
					}

				default:
					if (!getCurAnim().startsWith('sing') || getCurAnim().endsWith('End'))
					{
						playAnim('idle', true);
					}
			}
		}
	}

	override public function destroy()
	{
		shadow = FlxDestroyUtil.destroy(shadow);
		super.destroy();
	}
}
