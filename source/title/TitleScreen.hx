package title;

import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
//// //import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

// import polymod.Polymod;
using StringTools;

class TitleScreen extends MusicBeatState
{
	public static var titleMusic:String = "titleRemix";

	var logoTween:FlxTween;
	var bfTween:FlxTween;
	var enterTween:FlxTween;

	var logoBl:FlxSprite;
	var logoBF:FlxSprite;
	var logoEnter:FlxSprite;

	override public function create():Void
	{
		// Polymod.init({modRoot: "mods", dirs: ['introMod']});

		// DEBUG BULLSHIT

		useDefaultTransIn = false;

		persistentUpdate = true;

		var backdrop = new CrappyTile(Paths.getImagePNG('tile4'), 50, 50);
		add(backdrop);

		logoBl = new FlxSprite();
		logoBl.frames = Paths.getSparrowAtlasFunk("title/stuff");
		logoBl.animation.addByPrefix('tntlogo', 'tntlogo', 0, false);
		logoBl.animation.addByPrefix('enterlogo', 'enterlogo', 0, false);
		logoBl.animation.addByPrefix('bflogo', 'bflogo', 0, false);
		logoBl.animation.play('tntlogo');
		logoBl.antialiasing = true;
		logoBl.updateHitbox();
		logoBl.setPosition(25, -logoBl.height);
		add(logoBl);

		logoBF = logoBl.clone();
		logoBF.animation.play('bflogo');
		logoBF.antialiasing = true;
		logoBF.updateHitbox();
		logoBF.setPosition(FlxG.width + logoBF.width, FlxG.height / 2 - logoBF.height / 2);
		add(logoBF);

		logoEnter = logoBl.clone();
		logoEnter.animation.play('enterlogo');
		logoEnter.antialiasing = true;
		logoEnter.updateHitbox();
		logoEnter.setPosition(30, FlxG.height);
		add(logoEnter);

		logoTween = FlxTween.tween(logoBl, {"y": 50}, 0.5, {
			ease: FlxEase.quadOut,
			onComplete: function(twn)
			{
				logoTween = FlxTween.tween(logoBl, {"y": 25}, 1.5, {type: PINGPONG, ease: FlxEase.quadInOut});
				twn.cancel();
				twn.destroy();
			}
		});

		bfTween = FlxTween.tween(logoBF, {"x": FlxG.width - logoBF.width - 50}, 0.5, {
			ease: FlxEase.quadOut,
			onComplete: function(twn)
			{
				bfTween = FlxTween.tween(logoBF, {"x": FlxG.width - logoBF.width - 25}, 1.75, {type: PINGPONG, ease: FlxEase.quadInOut});
				twn.cancel();
				twn.destroy();
			}
		});

		enterTween = FlxTween.tween(logoEnter, {"y": FlxG.height - logoEnter.height - 50 - 15}, 0.5, {
			ease: FlxEase.quadOut,
			onComplete: function(twn)
			{
				enterTween = FlxTween.color(logoEnter, 1.75, FlxColor.WHITE, 0xff0eb9e8, {ease: FlxEase.quadInOut, type: PINGPONG});
				twn.cancel();
				twn.destroy();
			}
		});

		if (Main.lol == null)
		{
			Main.music(Paths.music(TitleScreen.titleMusic), 0.75);
		}
		// else
		// {
		// 	if (!Main.lol.playing)
		// 	{
		// 		Main.music(Paths.music(TitleScreen.titleMusic), 0.75);
		// 		switch (titleMusic)
		// 		{
		// 			case "klaskiiLoop":
		// 				Conductor.changeBPM(158);
		// 			case "freakyMenu":
		// 				Conductor.changeBPM(102);
		// 			case "titleRemix":
		// 				Conductor.changeBPM(102);
		// 		}
		// 	}
		// }

		// FlxG.camera.flash(FlxColor.WHITE, 1);

		super.create();
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		// Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = controls.ACCEPT || controls.PAUSE;

		if (pressedEnter && !transitioning)
		{
			// titleText.animation.play('press');

			// FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			for (twn in [logoTween, bfTween, enterTween])
			{
				twn.cancel();
				twn.destroy();
			}

			logoTween = FlxTween.tween(logoBl, {"y": -logoBl.height}, 0.35, {
				ease: FlxEase.quadIn
			});

			bfTween = FlxTween.tween(logoBF, {"x": FlxG.width}, 0.35, {
				ease: FlxEase.quadIn
			});

			enterTween = FlxTween.tween(logoEnter, {"y": FlxG.height}, 0.35, {
				ease: FlxEase.quadIn
			});

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				switchState(new MainMenuState());
				tmr.cancel();
				tmr.destroy();
			});
		}

		super.update(elapsed);
	}

	override public function destroy()
	{
		logoTween.cancel();
		logoTween = FlxDestroyUtil.destroy(logoTween);
		bfTween.cancel();
		bfTween = FlxDestroyUtil.destroy(bfTween);
		enterTween.cancel();
		enterTween = FlxDestroyUtil.destroy(enterTween);
		super.destroy();
	}

	// override function beatHit()
	// {
	// 	super.beatHit();
	// 	FlxG.log.add(curBeat);
	// }
}
