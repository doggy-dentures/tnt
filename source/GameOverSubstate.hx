package;

import flixel.graphics.FlxGraphic;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
import flixel.FlxSprite;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var piano:FlxSprite;
	var fallTweens:Array<FlxTween> = [];
	var fadeTweens:Array<FlxTween> = [];
	// var retryText:FlxTextThing;
	var retryText:FlxSprite;
	var textTween:FlxTween;
	var camTween:FlxTween;

	public function new(boyfriend:Boyfriend, follow:FlxObject)
	{
		super();

		FlxTimer.globalManager.forEach(function(tmr)
		{
			if (tmr != null && tmr.active)
				tmr.cancel();
		});

		FlxTween.globalManager.forEach(function(tween)
		{
			if (tween != null && tween.active)
				tween.cancel();
		});

		Conductor.songPosition = 0;

		piano = new FlxSprite();
		piano.frames = Paths.getSparrowAtlasFunk("gameover/piano");
		piano.animation.addByPrefix("drop", "pianoFall", 0, false);
		piano.animation.addByPrefix("crash", "pianoCrash", 0, false);
		piano.animation.addByPrefix("retry", "retry", 0, false);
		piano.antialiasing = true;
		piano.animation.play("drop", true);
		piano.updateHitbox();
		piano.setPosition(boyfriend.x + boyfriend.width / 2 - piano.width / 2, -(FlxG.height * (1 - FlxG.camera.zoom)) - piano.height);
		var black = new FlxSprite().loadGraphic(FlxGraphic.fromRectangle(1, 1, FlxColor.BLACK));
		black.setGraphicSize(Std.int(FlxG.width / FlxG.camera.zoom), Std.int(FlxG.height / FlxG.camera.zoom));
		black.updateHitbox();
		black.setPosition(0, piano.y - black.height + piano.height / 2);

		// retryText = new FlxTextThing();
		// retryText.text = "RETRY?";
		// retryText.setFormat(Paths.font("bungee"), 96, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// retryText.setPosition(piano.x + piano.width / 2 - retryText.width / 2, boyfriend.y + boyfriend.height - piano.height * 0.5);
		// retryText.alpha = 0;
		// retryText.antialiasing = true;

		retryText = piano.clone();
		retryText.animation.play("retry", true);
		retryText.updateHitbox();
		retryText.alpha = 0;
		retryText.setPosition(piano.x + piano.width / 2 - retryText.width / 2, boyfriend.y + boyfriend.height - piano.height * 0.5);

		var tweenPiano = FlxTween.tween(piano, {"y": boyfriend.y + boyfriend.height - piano.height * 0.75}, 0.25, {
			onComplete: function(twn)
			{
				if (!isEnding)
					FlxG.sound.play(Paths.sound('pianofall'));
				piano.animation.play("crash", true);
				FlxG.camera.shake(0.05, 0.7);
				bf.visible = false;
				new FlxTimer().start(2, function(tmr)
				{
					if (!isEnding)
					{
						// FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
						Main.music(Paths.music('gameOver'));
						fadeTweens.push(FlxTween.tween(retryText, {"alpha": 1}, 0.25));
					}
					FlxDestroyUtil.destroy(tmr);
				});
			}
		});

		var tweenBlack = FlxTween.tween(black, {"y": boyfriend.y + boyfriend.height - piano.height * 0.75 - black.height + piano.height / 2}, 0.25, {
			onComplete: function(twn)
			{
			}
		});

		fallTweens = [tweenPiano, tweenBlack];

		bf = boyfriend;
		add(bf);
		add(black);
		add(piano);
		add(retryText);

		if (follow == null)
			follow = new FlxObject(bf.x, bf.y, 1, 1);

		camFollow = new FlxObject(follow.x, follow.y, 1, 1);
		add(camFollow);

		// FlxTween.tween(camFollow, {x: bf.x + bf.width / 2, y: bf.y + bf.height / 2}, 3, {ease: FlxEase.quintOut, startDelay: 0.5});
		camTween = FlxTween.tween(camFollow, {x: piano.x + piano.width / 2, y: boyfriend.y + boyfriend.height - piano.height * 0.33}, 3,
			{ease: FlxEase.quintOut, startDelay: 0.5});

		FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.follow(camFollow, LOCKON);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK && !isEnding)
		{
			// if (FlxG.sound.music != null)
			// 	FlxG.sound.music.stop();

			Main.unmusic();

			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);

			if (PlayState.isStoryMode)
			{
				close();
				FlxG.switchState(new MainMenuState());
			}
			else
			{
				close();
				FreeplayState.useIconIn = false;
				FlxG.switchState(new FreeplayState());
			}
		}

		if (Main.lol != null && Main.lol.playing)
		{
			Conductor.songPosition = Main.lol.time;
		}
	}

	override function beatHit()
	{
		textTween = FlxTween.tween(retryText, {"scale.x": 1.05, "scale.y": 1.05}, Conductor.stepCrochet * 1 / 2000, {
			onComplete: function(twn)
			{
				retryText.scale.x = retryText.scale.y = 1.0;
				FlxDestroyUtil.destroy(twn);
			}
		});
		super.beatHit();
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);
			isEnding = true;
			// if (FlxG.sound.music != null)
			// 	FlxG.sound.music.stop();
			Main.unmusic();
			FlxG.sound.play(Paths.sound('gameOverEnd'));
			fadeTweens.push(FlxTween.tween(piano, {"alpha": 0}, 0.66));
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1.2, false, function()
				{
					close();
					FlxG.switchState(new PlayState());
				});
			});
		}
	}

	override public function close()
	{
		// if (FlxG.sound.music != null)
		// 	FlxG.sound.music.stop();
		Main.unmusic();
		super.close();
	}

	override public function destroy()
	{
		for (twn in fallTweens)
		{
			if (twn.active)
				twn.cancel();
		}
		fallTweens = FlxDestroyUtil.destroyArray(fallTweens);
		for (twn in fadeTweens)
		{
			if (twn.active)
				twn.cancel();
		}
		fadeTweens = FlxDestroyUtil.destroyArray(fadeTweens);
		if (textTween != null && textTween.active)
			textTween.cancel();
		textTween = FlxDestroyUtil.destroy(textTween);
		if (camTween != null && camTween.active)
			camTween.cancel();
		camTween = FlxDestroyUtil.destroy(camTween);
		piano = FlxDestroyUtil.destroy(piano);
		camFollow = FlxDestroyUtil.destroy(camFollow);
		bf = FlxDestroyUtil.destroy(bf);
		// FlxG.sound.music = FlxDestroyUtil.destroy(FlxG.sound.music);
		super.destroy();
	}
}
