package;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import config.*;
import title.TitleScreen;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.text.FlxText;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxTypedGroup<FlxSprite>>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'options', 'credits'];
	var optionTweens:Map<FlxSprite, FlxTween>;

	// var versionText:FlxText;
	var keyWarning:FlxTextThing;

	override function create()
	{
		// openfl.Lib.current.stage.frameRate = 144;
		Main.changeFramerate(144);

		PlayState.SONG = null;

		PlayState.transIcon = "default";
		PlayState.transColor = FlxColor.BLACK;

		FreeplayState.useIconIn = false;

		if (Main.lol == null)
		{
			Main.music(Paths.music(TitleScreen.titleMusic), 0.75);
		}

		persistentUpdate = persistentDraw = true;

		var backdrop = new CrappyTile(Paths.getImagePNG('tile'), 50, 50);
		add(backdrop);

		menuItems = new FlxTypedGroup<FlxTypedGroup<FlxSprite>>();
		add(menuItems);

		// var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		optionTweens = new Map<FlxSprite, FlxTween>();

		for (i in 0...optionShit.length)
		{
			var menuItem = new FlxTypedGroup<FlxSprite>();
			var menuBar = new FlxSprite(-266, 22 + i * 177);
			menuBar.loadGraphic(Paths.getImagePNG("mainmenu/item"));
			var menuText = new FlxTextThing(0, 0, 765, optionShit[i].toUpperCase());
			menuText.setFormat(Paths.font("bungee"), 72, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			menuText.setPosition(menuBar.x + menuBar.width / 2 - menuText.width / 2, menuBar.y + menuBar.height / 2 - menuText.height / 2);
			var menuIcon = new FlxSprite(menuBar.x + menuBar.width + 70, 0).loadGraphic(Paths.getImagePNG("mainmenu/" + optionShit[i].replace(" ", "")));
			menuIcon.y = menuBar.y + menuBar.height / 2 - menuIcon.height / 2;
			menuBar.antialiasing = true;
			menuText.antialiasing = true;
			menuText.antialiasing = true;
			menuIcon.antialiasing = true;
			menuItem.add(menuBar);
			menuItem.add(menuText);
			menuItem.add(menuIcon);
			menuItems.add(menuItem);
			menuText.disposeImage();
		}

		// versionText = new FlxText(5, FlxG.height - 21, 0, Assets.getText(Paths.text("version")), 16);
		// versionText.scrollFactor.set();
		// versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// add(versionText);

		keyWarning = new FlxTextThing(5, FlxG.height - 21 + 16, 0, "If your controls aren't working, try pressing DELETE to reset them.", 16);
		keyWarning.scrollFactor.set();
		keyWarning.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyWarning.alpha = 0;
		add(keyWarning);

		// FlxTween.tween(versionText, {y: versionText.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: 10});
		FlxTween.tween(keyWarning, {alpha: 1, y: keyWarning.y - 16}, 0.75, {ease: FlxEase.quintOut, startDelay: 10});

		changeItem();

		// Offset Stuff
		Config.reload();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (Main.lol != null && Main.lol.volume < 0.8)
		{
			Main.lol.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (FlxG.keys.justPressed.DELETE)
			{
				KeyBinds.resetBinds();
				switchState(new MainMenuState());
			}

			if (controls.BACK)
			{
				switchState(new TitleScreen());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				var daChoice:String = optionShit[curSelected];

				switch (daChoice)
				{
					case 'freeplay':
						Main.unmusic();
					case 'options':
						Main.unmusic();
				}

				for (i in 0...optionShit.length)
				{
					for (sprite in menuItems.members[i])
					{
						if (optionTweens[sprite] != null)
							optionTweens[sprite].cancel();
						if (curSelected == i)
							optionTweens[sprite] = FlxTween.tween(sprite, {"offset.x": -1953}, 0.66, {ease: FlxEase.quadIn});
						else
							optionTweens[sprite] = FlxTween.tween(sprite, {"offset.x": 1616}, 0.66, {ease: FlxEase.quadIn});
					}
				}

				new FlxTimer().start(0.5, function(tmr)
				{
					switch (daChoice)
					{
						case 'story mode':
							switchState(new StoryMenuState());
							trace("Story Menu Selected");
						case 'freeplay':
							FreeplayState.startingSelected = 0;
							FreeplayState.curDifficulty = 1;
							switchState(new FreeplayState(true));
							trace("Freeplay Menu Selected");
						case 'options':
							switchState(new ConfigMenu());
							trace("options time");
						case 'credits':
							switchState(new CreditsMenu());
							// FlxG.resetState();
					}
					FlxDestroyUtil.destroy(tmr);
				});
			}

			if (FlxG.keys.justPressed.SEVEN)
				switchState(new ParticleState());
		}

		super.update(elapsed);

		// menuItems.forEach(function(spr:FlxSprite)
		// {
		// 	spr.screenCenter(X);
		// });

		if (FlxG.keys.justPressed.ANY)
		{
			if (FlxG.keys.checkStatus(code[codeIndex], JUST_PRESSED))
			{
				if (codeIndex >= code.length - 1)
				{
					PlayState.autoPlay = !PlayState.autoPlay;
					var snd:String = (PlayState.autoPlay ? "scrollfaster" : "scrollslower");
					FlxG.sound.play(Paths.sound(snd), 0.5);
					codeIndex = 0;
				}
				else
					codeIndex++;
			}
			else
				codeIndex = 0;
		}
	}

	final code:Array<String> = ["UP", "UP", "DOWN", "DOWN", "LEFT", "RIGHT", "LEFT", "RIGHT", "B", "A"];
	var codeIndex:Int = 0;

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		// menuItems.forEach(function(spr:FlxSprite)
		// {
		// 	spr.animation.play('idle');

		// 	if (spr.ID == curSelected)
		// 	{
		// 		spr.animation.play('selected');
		// 		// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
		// 	}
		// 	spr.updateHitbox();
		// });
		for (i in 0...optionShit.length)
		{
			for (sprite in menuItems.members[i])
			{
				if (optionTweens[sprite] != null)
					optionTweens[sprite].cancel();
				if (curSelected == i)
				{
					optionTweens[sprite] = FlxTween.tween(sprite, {"offset.x": -290}, 0.15);
					if (sprite is FlxText)
						sprite.color = FlxColor.WHITE;
				}
				else
				{
					optionTweens[sprite] = FlxTween.tween(sprite, {"offset.x": 0}, 0.15);
					if (sprite is FlxText)
						sprite.color = FlxColor.GRAY;
				}
			}
		}
	}

	override public function destroy()
	{
		super.destroy();
		//Cashew.destroyAll();
	}
}
