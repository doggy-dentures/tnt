package config;

import transition.data.*;
import transition.*;
import flixel.FlxState;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class ConfigMenu extends MusicBeatState
{
	public static var startSong = true;

	public static var exitTo:Class<FlxState>;

	var configText:FlxTextThing;
	var descText:FlxTextThing;
	var tabDisplay:FlxTextThing;
	var configSelected:Int = 0;

	var offsetValue:Float;
	var accuracyType:String;
	var accuracyTypeInt:Int;
	var accuracyTypes:Array<String> = ["none", "simple", "complex"];
	var healthValue:Int;
	var healthDrainValue:Int;
	var comboValue:Int;
	var comboTypes:Array<String> = ["world", "hud", "off"];
	var downValue:Bool;
	// var glowValue:Bool;
	var randomTapValue:Int;
	var randomTapTypes:Array<String> = ["never", "not singing", "always"];
	var noCapValue:Bool;
	var scheme:Int;
	var dimValue:Int;
	var splashValue:Bool;
	var fpsDisplayValue:Int;
	var comboParticlesValue:Bool;
	var scrollSpeedValue:Int;

	var tabKeys:Array<String> = [];

	var canChangeItems:Bool = true;

	var leftRightCount:Int = 0;

	final genericOnOff:Array<String> = ["on", "off"];

	final settingText:Array<String> = [
		"NOTE OFFSET",
		"SCROLL SPEED",
		"ACCURACY DISPLAY",
		"UNCAPPED FRAMERATE",
		"ALLOW GHOST TAPPING",
		"HP GAIN MULTIPLIER",
		"HP DRAIN MULTIPLIER",
		"DOWNSCROLL",
		"COMBO EFFECTS",
		"COMBO DISPLAY",
		"BACKGROUND DIM",
		// "[PRELOAD SETTINGS]",
		"NOTE SPLASH",
		"FPS DISPLAY",
		"CONTROLLER SCHEME",
		"EDIT KEY BINDS",
		"EDIT NOTE COLORS",
	];

	// Any descriptions that say TEMP are replaced with a changing description based on the current config setting.
	final settingDesc:Array<String> = [
		"Adjust note timings.\nPress \"ENTER\" to start the offset calibration." +
		(FlxG.save.data.ee1 ? "\nHold \"SHIFT\" to force the pixel calibration.\nHold \"CTRL\" to force the normal calibration." : ""),
		"Adjust scroll speeds of songs to a custom value.\nA value of 0 means using the song's default value.",
		"What type of accuracy calculation you want to use. Simple is just notes hit / total notes. Complex also factors in how early or late a note was.",
		#if desktop "Uncaps the framerate during gameplay (this will eat up your GPU)." #else "Disabled on Web builds." #end,
		"TEMP",
		"Modifies how much Health you gain when hitting a note.",
		"Modifies how much Health you lose when missing a note.",
		"Makes notes appear from the top instead the bottom.",
		"Graphical effects on-screen when reaching high combos.",
		"TEMP",
		"Adjusts how dark the background is.\nIt is recommended that you use the HUD combo display with a high background dim.",
		// "Change what assets the game preloads on startup.\n[A restart is required for these changes.]",
		"Plays animations on the strumline when you get a Sick rating.",
		"Shows a FPS counter in the top-left corner",
		"TEMP",
		"Change key binds.",
		"Change the colors of your notes"
	];

	final ghostTapDesc:Array<String> = [
		"Any key press that isn't for a valid note will cause you to miss.",
		"You can only  miss while you need to sing.",
		"You cannot miss unless you do not hit a note.\n[Note that this makes the game very easy and can remove a lot of the challenge.]"
	];

	final comboDisplayDesc:Array<String> = [
		"Ratings and combo count are a part of the world and move around with the camera.",
		"Ratings and combo count are a part of the hud and stay in a static position.",
		"Ratings and combo count are hidden."
	];

	final controlSchemes:Array<String> = ["DEFAULT", "ALT 1", "ALT 2", "[CUSTOM]"];

	final controlSchemesDesc:Array<String> = [
		"LEFT: DPAD LEFT / X (SQUARE) / LEFT TRIGGER\nDOWN: DPAD DOWN / X (CROSS) / LEFT BUMPER\nUP: DPAD UP / Y (TRIANGLE) / RIGHT BUMPER\nRIGHT: DPAD RIGHT / B (CIRCLE) / RIGHT TRIGGER",
		"LEFT: DPAD LEFT / DPAD DOWN / LEFT TRIGGER\nDOWN: DPAD UP / DPAD RIGHT / LEFT BUMPER\nUP: X (SQUARE) / Y (TRIANGLE) / RIGHT BUMPER\nRIGHT: A (CROSS) / B (CIRCLE) / RIGHT TRIGGER",
		"LEFT: ALL DPAD DIRECTIONS\nDOWN: LEFT BUMPER / LEFT TRIGGER\nUP: RIGHT BUMPER / RIGHT TRIGGER\nRIGHT: ALL FACE BUTTONS",
		"Press A (CROSS) to change controller binds."
	];

	final fpsDisplays:Array<String> = ["FPS & Mem Usage", "Only FPS", "None"];

	override function create()
	{
		if (exitTo == null)
		{
			exitTo = MainMenuState;
		}

		if (startSong)
		{
			// FlxG.sound.playMusic(Paths.music('configurator'));
			if (Main.lol == null)
			{
				Main.music(Paths.music('configurator'));
			}
		}
		else
			startSong = true;

		// persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.getImageFunk('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF5C6CA5;
		add(bg);

		Config.reload();

		offsetValue = Config.offset;
		accuracyType = Config.accuracy;
		accuracyTypeInt = accuracyTypes.indexOf(Config.accuracy);
		healthValue = Std.int(Config.healthMultiplier * 10);
		healthDrainValue = Std.int(Config.healthDrainMultiplier * 10);
		comboValue = Config.comboType;
		downValue = Config.downscroll;
		comboParticlesValue = Config.comboParticles;
		randomTapValue = Config.ghostTapType;
		noCapValue = Config.noFpsCap;
		scheme = Config.controllerScheme;
		dimValue = Config.bgDim;
		splashValue = Config.noteSplash;
		fpsDisplayValue = Config.fpsDisplayValue;
		scrollSpeedValue = Std.int(Config.scrollSpeed * 10);

		var tex = Paths.getSparrowAtlasFunk('FNF_main_menu_assets');
		var optionTitle:FlxSprite = new FlxSprite(0, 5);
		optionTitle.frames = tex;
		optionTitle.animation.addByPrefix('selected', "options white", 24);
		optionTitle.animation.play('selected');
		optionTitle.scrollFactor.set();
		optionTitle.antialiasing = true;
		optionTitle.updateHitbox();
		optionTitle.screenCenter(X);

		add(optionTitle);

		configText = new FlxTextThing(0, 165, 1280, "", 38);
		configText.scrollFactor.set(0, 0);
		configText.setFormat(Paths.font("Funkin-Bold", "otf"), 38, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		configText.borderSize = 3;
		configText.borderQuality = 1;
		configText.antialiasing = true;

		descText = new FlxTextThing(320, 638, 640, "", 20);
		descText.scrollFactor.set(0, 0);
		descText.setFormat(Paths.font("vcr"), 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// descText.borderSize = 3;
		descText.borderQuality = 1;

		tabDisplay = new FlxTextThing(5, FlxG.height - 53, 0, Std.string(tabKeys), 16);
		tabDisplay.scrollFactor.set();
		tabDisplay.visible = false;
		tabDisplay.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		var backText = new FlxTextThing(5, FlxG.height - 37, 0, "ESCAPE/BACKSPACE - Back to Menu\nDELETE - Reset to Defaults\n", 16);
		backText.scrollFactor.set();
		backText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(configText);
		add(descText);
		add(tabDisplay);
		add(backText);

		textUpdate();

		customTransIn = new WeirdBounceIn(0.6);
		customTransOut = new WeirdBounceOut(0.6);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (Main.lol != null && Main.lol.volume < 0.8)
		{
			Main.lol.volume += 0.5 * FlxG.elapsed;
		}

		if (canChangeItems && !FlxG.keys.pressed.TAB)
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

			switch (configSelected)
			{
				case 0: // Offset
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						offsetValue += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						offsetValue -= 1;
					}

					if (controls.RIGHT)
					{
						leftRightCount++;

						if (leftRightCount > 64)
						{
							offsetValue += 1;
							textUpdate();
						}
					}

					if (controls.LEFT)
					{
						leftRightCount++;

						if (leftRightCount > 64)
						{
							offsetValue -= 1;
							textUpdate();
						}
					}

					if (!controls.RIGHT && !controls.LEFT)
					{
						leftRightCount = 0;
					}

					if (FlxG.keys.justPressed.ENTER)
					{
						canChangeItems = false;
						// FlxG.sound.music.fadeOut(0.3);
						Main.unmusic();
						writeToConfig();
						AutoOffsetState.forceEasterEgg = FlxG.keys.pressed.SHIFT ? 1 : (FlxG.keys.pressed.CONTROL ? -1 : 0);
						switchState(new AutoOffsetState());
					}

				case 1: // Scroll Speed
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						scrollSpeedValue += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						scrollSpeedValue -= 1;
					}

					if (scrollSpeedValue > 50)
						scrollSpeedValue = 0;
					if (scrollSpeedValue < 0)
						scrollSpeedValue = 50;

					if (controls.RIGHT)
					{
						leftRightCount++;

						if (leftRightCount > 64 && leftRightCount % 10 == 0)
						{
							scrollSpeedValue += 1;
							textUpdate();
						}
					}

					if (controls.LEFT)
					{
						leftRightCount++;

						if (leftRightCount > 64 && leftRightCount % 10 == 0)
						{
							scrollSpeedValue -= 1;
							textUpdate();
						}
					}

					if (!controls.RIGHT && !controls.LEFT)
					{
						leftRightCount = 0;
					}

					if (!controls.RIGHT && !controls.LEFT)
					{
						leftRightCount = 0;
					}
				case 2: // Accuracy
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						accuracyTypeInt += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						accuracyTypeInt -= 1;
					}

					if (accuracyTypeInt > 2)
						accuracyTypeInt = 0;
					if (accuracyTypeInt < 0)
						accuracyTypeInt = 2;

					accuracyType = accuracyTypes[accuracyTypeInt];
				case 3: // FPS Cap
					#if desktop
					if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						noCapValue = !noCapValue;
					}
					#end
				case 4: // Random Tap
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						randomTapValue += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						randomTapValue -= 1;
					}

					if (randomTapValue > 2)
						randomTapValue = 0;
					if (randomTapValue < 0)
						randomTapValue = 2;
				case 5: // Health Multiplier
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						healthValue += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						healthValue -= 1;
					}

					if (healthValue > 100)
						healthValue = 0;
					if (healthValue < 0)
						healthValue = 100;

					if (controls.RIGHT)
					{
						leftRightCount++;

						if (leftRightCount > 64 && leftRightCount % 10 == 0)
						{
							healthValue += 1;
							textUpdate();
						}
					}

					if (controls.LEFT)
					{
						leftRightCount++;

						if (leftRightCount > 64 && leftRightCount % 10 == 0)
						{
							healthValue -= 1;
							textUpdate();
						}
					}

					if (!controls.RIGHT && !controls.LEFT)
					{
						leftRightCount = 0;
					}

					if (!controls.RIGHT && !controls.LEFT)
					{
						leftRightCount = 0;
					}
				case 6: // Health Drain Multiplier
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						healthDrainValue += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						healthDrainValue -= 1;
					}

					if (healthDrainValue > 100)
						healthDrainValue = 0;
					if (healthDrainValue < 0)
						healthDrainValue = 100;

					if (controls.RIGHT)
					{
						leftRightCount++;

						if (leftRightCount > 64 && leftRightCount % 10 == 0)
						{
							healthDrainValue += 1;
							textUpdate();
						}
					}

					if (controls.LEFT)
					{
						leftRightCount++;

						if (leftRightCount > 64 && leftRightCount % 10 == 0)
						{
							healthDrainValue -= 1;
							textUpdate();
						}
					}

					if (!controls.RIGHT && !controls.LEFT)
					{
						leftRightCount = 0;
					}
				case 7: // Downscroll
					if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						downValue = !downValue;
					}
				// case 7: // Note Glow
				// 	if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT)
				// 	{
				// 		FlxG.sound.play(Paths.sound('scrollMenu'));
				// 		glowValue = !glowValue;
				// 	}
				case 8: // Combo Particles
					if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						comboParticlesValue = !comboParticlesValue;
					}
				case 9: // Combo Display
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						comboValue += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						comboValue -= 1;
					}

					if (comboValue >= comboTypes.length)
						comboValue = 0;
					if (comboValue < 0)
						comboValue = comboTypes.length - 1;
				case 10: // BG Dim
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						dimValue += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						dimValue -= 1;
					}

					if (dimValue > 10)
						dimValue = 0;
					if (dimValue < 0)
						dimValue = 10;

				// case 10: //Preload settings
				// 	if (controls.ACCEPT) {
				// 		#if desktop
				// 		FlxG.sound.play(Paths.sound('scrollMenu'));
				// 		canChangeItems = false;
				// 		writeToConfig();
				// 		switchState(new CacheSettings());
				// 		CacheSettings.returnLoc = new ConfigMenu();
				// 		#end
				// 	}

				case 11: // Note splash
					if (controls.RIGHT_P || controls.LEFT_P || controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						splashValue = !splashValue;
					}

				case 12: // FPS Display
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						fpsDisplayValue = (fpsDisplayValue + 1) % 3;
					}
					else if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						fpsDisplayValue = ((fpsDisplayValue - 1) + 3) % 3;
					}
					fpsDisplayStuff(fpsDisplayValue);

				case 13: // Controller Stuff
					if (controls.RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						scheme += 1;
					}

					if (controls.LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						scheme -= 1;
					}

					if (scheme >= controlSchemes.length)
						scheme = 0;
					if (scheme < 0)
						scheme = controlSchemes.length - 1;

					if (controls.ACCEPT && scheme == controlSchemes.length - 1)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						canChangeItems = false;
						writeToConfig();
						switchState(new KeyBindMenuController());
					}

				case 14: // Binds
					if (controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						canChangeItems = false;
						writeToConfig();
						switchState(new KeyBindMenu());
					}

				case 15: // Note colors
					if (FlxG.keys.justPressed.ENTER)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						canChangeItems = false;
						writeToConfig();
						switchState(new ArrowColorState());
					}
			}
		}
		else if (FlxG.keys.pressed.TAB)
		{
			if (FlxG.keys.justPressed.ANY)
			{
				if (FlxG.keys.getIsDown()[0].ID.toString() != "TAB")
				{
					tabKeys.push(FlxG.keys.getIsDown()[0].ID.toString());
				}
			}
		}

		if (FlxG.keys.justPressed.TAB)
		{
			tabDisplay.visible = true;
		}

		if (FlxG.keys.justReleased.TAB)
		{
			secretPresetTest(tabKeys);
			tabKeys = [];
			tabDisplay.visible = false;
		}

		if (controls.BACK && canChangeItems)
		{
			writeToConfig();
			exit();
		}

		if (FlxG.keys.justPressed.DELETE && canChangeItems)
		{
			Config.resetSettings();
			FlxG.save.data.ee1 = false;
			exit();
		}

		super.update(elapsed);

		if (controls.LEFT_P || controls.RIGHT_P || controls.UP_P || controls.DOWN_P || controls.ACCEPT || FlxG.keys.justPressed.ANY)
			textUpdate();
	}

	function changeItem(huh:Int = 0)
	{
		configSelected += huh;

		if (configSelected > settingText.length - 1)
			configSelected = 0;
		if (configSelected < 0)
			configSelected = settingText.length - 1;
	}

	function textUpdate()
	{
		configText.clearFormats();
		configText.text = "";

		for (i in 0...settingText.length)
		{
			var sectionStart = configText.text.length;
			configText.text += settingText[i] + getSetting(i) + "\n";
			var sectionEnd = configText.text.length - 1;

			if (i == configSelected)
			{
				// Might change to applyMarkup later.
				configText.addFormat(new FlxTextFormat(0xFFFFFF00), sectionStart, sectionEnd);
			}
		}

		switch (configSelected)
		{
			case 4:
				descText.text = ghostTapDesc[randomTapValue];

			case 9:
				descText.text = comboDisplayDesc[comboValue];

			// case 10:
			// 	descText.text = settingDesc[configSelected];
			// 	#if web
			// 	descText.text = "Disabled.";
			// 	#end

			case 13:
				descText.text = controlSchemesDesc[scheme];

			default:
				descText.text = settingDesc[configSelected];
		}

		tabDisplay.text = Std.string(tabKeys);
	}

	function getSetting(r:Int):String
	{
		switch (r)
		{
			case 0:
				return ": " + offsetValue;
			case 1:
				return ": " + scrollSpeedValue / 10.0;
			case 2:
				return ": " + accuracyType;
			case 3: #if desktop return ": " + genericOnOff[noCapValue ? 0 : 1]; #else return ": disabled"; #end
			case 4:
				return ": " + randomTapTypes[randomTapValue];
			case 5:
				return ": " + healthValue / 10.0;
			case 6:
				return ": " + healthDrainValue / 10.0;
			case 7:
				return ": " + genericOnOff[downValue ? 0 : 1];
			case 8:
				return ": " + genericOnOff[comboParticlesValue ? 0 : 1];
			case 9:
				return ": " + comboTypes[comboValue];
			case 10:
				return ": " + (dimValue * 10) + "%";
			case 11:
				return ": " + genericOnOff[splashValue ? 0 : 1];
			case 12:
				return ": " + fpsDisplays[fpsDisplayValue];
			case 13:
				return ": " + controlSchemes[scheme];
		}

		return "";
	}

	function exit()
	{
		canChangeItems = false;
		// FlxG.sound.music.stop();
		Main.unmusic();
		FlxG.sound.play(Paths.sound('cancelMenu'));
		fpsDisplayStuff(FlxG.save.data.fpsDisplayValue);
		switchState(Type.createInstance(exitTo, []));
		exitTo = null;
	}

	function fpsDisplayStuff(val:Int)
	{
		switch (val)
		{
			case 0:
				Main.fpsDisplay.showFPS = true;
				Main.fpsDisplay.showMem = true;
			case 1:
				Main.fpsDisplay.showFPS = true;
				Main.fpsDisplay.showMem = false;
			case 2:
				Main.fpsDisplay.showFPS = false;
		}
	}

	function secretPresetTest(_combo:Array<String>):Void
	{
		var combo:String = "";

		for (x in _combo)
		{
			combo += x;
		}

		switch (combo)
		{
			case "KADE":
				Config.write(offsetValue, "complex", 5, 5, 1, downValue, false, 2, noCapValue, scheme, dimValue, splashValue, fpsDisplayValue,
					Config.arrowColors, Config.comboParticles, scrollSpeedValue / 10.0);
				exit();
			case "ROZE":
				Config.write(offsetValue, "simple", 1, 1, 0, true, true, 0, noCapValue, scheme, dimValue, splashValue, fpsDisplayValue, Config.arrowColors,
					Config.comboParticles, scrollSpeedValue / 10.0);
				exit();
			case "CVAL":
				Config.write(offsetValue, "simple", 1, 1, comboValue, false, false, 1, noCapValue, scheme, dimValue, splashValue, fpsDisplayValue,
					Config.arrowColors, Config.comboParticles, scrollSpeedValue / 10.0);
				exit();
			case "GOTOHELLORSOMETHING":
				System.exit(0); // I am very funny.
		}
	}

	function writeToConfig()
	{
		Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0, comboValue, downValue, false, randomTapValue, noCapValue, scheme,
			dimValue, splashValue, fpsDisplayValue, Config.arrowColors, comboParticlesValue, scrollSpeedValue / 10.0);
	}
}
