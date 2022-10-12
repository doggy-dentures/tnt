package;

import flixel.util.FlxDestroyUtil;
import flixel.text.FlxText;
import flixel.util.typeLimit.OneOfTwo;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import config.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxSprite>;
	var grpMenuText:FlxTypedGroup<FlxTextThing>;
	var grpShitTweens:Array<FlxTween> = [];
	var grpTextTweens:Array<FlxTween> = [];

	var menuItems:Array<String> = ['Resume', 'Restart Song', "Options", 'Exit to menu'];
	var curSelected:Int = 0;

	// var pauseMusic:FlxSound;
	var pausedTimers:Array<FlxTimer> = [];
	var pausedTweens:Array<FlxTween> = [];

	var bg:FlxSprite;

	var stopInput:Bool = false;

	override public function create()
	{
		super.create();

		// openfl.Lib.current.stage.frameRate = 144;
		Main.changeFramerate(144);

		FlxTimer.globalManager.forEach(function(tmr)
		{
			if (tmr != null && tmr.active)
			{
				tmr.active = false;
				pausedTimers.push(tmr);
			}
		});

		FlxTween.globalManager.forEach(function(tween)
		{
			if (tween != null && tween.active)
			{
				tween.active = false;
				pausedTweens.push(tween);
			}
		});

		if (PlayState.storyPlaylist.length > 1 && PlayState.isStoryMode)
		{
			menuItems.insert(2, "Skip Song");
		}

		if (!PlayState.isStoryMode)
		{
			menuItems.insert(2, "Chart Editor");
		}

		if (!PlayState.isStoryMode && PlayState.sectionStart)
		{
			menuItems.insert(1, "Restart Section");
		}

		// pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);

		// pauseMusic.volume = 0;
		// pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		// FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<FlxSprite>();
		add(grpMenuShit);
		grpMenuText = new FlxTypedGroup<FlxTextThing>();
		add(grpMenuText);

		var itemY:Float = 200;
		for (i in 0...menuItems.length)
		{
			// var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			var itemBar:FlxSprite = new FlxSprite(100, itemY).loadGraphic(Paths.getImageFunk('pause/pauseItem'));
			itemBar.antialiasing = true;
			itemBar.offset.x = 400;
			grpMenuShit.add(itemBar);
			var itemText = new FlxTextThing(0, 0, itemBar.width * 0.8, menuItems[i]);
			itemText.setFormat(Paths.font("bungee"), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
			itemText.antialiasing = true;
			itemText.setPosition(itemBar.x + itemBar.width / 2 - itemText.width / 2, itemBar.y + itemBar.height / 2 - itemText.height / 2);
			itemText.offset.x = 400;
			grpMenuText.add(itemText);
			// itemText.disposeImage();
			itemY += itemBar.height + 20;
			grpShitTweens.push(null);
			grpTextTweens.push(null);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		// if (pauseMusic.volume < 0.5)
		// 	pauseMusic.volume += 0.05 * elapsed;

		super.update(elapsed);

		if (stopInput)
			return;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					unpause();

				case "Restart Song":
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);
					stopInput = true;
					// FlxG.resetState();
					@:privateAccess
					if (_parentState != null && _parentState.subState == this)
						cast(_parentState, PlayState).switchState(new PlayState());
					PlayState.sectionStart = false;

				case "Restart Section":
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);
					stopInput = true;
					// FlxG.resetState();
					@:privateAccess
					if (_parentState != null && _parentState.subState == this)
						cast(_parentState, PlayState).switchState(new PlayState());

				case "Chart Editor":
					stopInput = true;
					PlayerSettings.menuControls();
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);

					// close();
					FlxG.switchState(new ChartingState());

				case "Skip Song":
					stopInput = true;
					// close();
					@:privateAccess
					if (_parentState != null && _parentState.subState == this)
						cast(_parentState, PlayState).endSongStory();

				case "Options":
					stopInput = true;
					// close();
					// FlxG.switchState(new ConfigMenu());
					@:privateAccess
					if (_parentState != null && _parentState.subState == this)
					{
						cast(_parentState, PlayState).customTransOut = null;
						cast(_parentState, PlayState).switchState(new ConfigMenu());
					}
					ConfigMenu.exitTo = PlayState;

				case "Exit to menu":
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);

					stopInput = true;
					PlayState.sectionStart = false;

					switch (PlayState.returnLocation)
					{
						case "freeplay":
							// close();
							FreeplayState.useIconIn = false;
							FlxG.switchState(new FreeplayState());
						case "story":
							// close();
							FlxG.switchState(new StoryMenuState());
						default:
							// close();
							FlxG.switchState(new MainMenuState());
					}
			}
		}
	}

	function unpause()
	{
		// if (Config.noFpsCap)
		// 	openfl.Lib.current.stage.frameRate = 999;
		Main.fpsSwitch();
		for (timer in pausedTimers)
		{
			timer.active = true;
		}
		for (tween in pausedTweens)
		{
			tween.active = true;
		}
		close();
	}

	override public function destroy()
	{
		// pauseMusic = FlxDestroyUtil.destroy(pauseMusic);
		for (twn in grpShitTweens)
		{
			if (twn != null && twn.active)
				twn.cancel();
		}
		for (twn in grpTextTweens)
		{
			if (twn != null && twn.active)
				twn.cancel();
		}
		grpShitTweens = FlxDestroyUtil.destroyArray(grpShitTweens);
		grpTextTweens = FlxDestroyUtil.destroyArray(grpTextTweens);
		pausedTimers.resize(0);
		pausedTimers = null;
		pausedTweens.resize(0);
		pausedTweens = null;
		bg = FlxDestroyUtil.destroy(bg);
		Cashew.destroyOne('pause/pauseItem');
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		for (i in 0...grpMenuShit.members.length)
		{
			if (grpShitTweens[i] != null)
			{
				grpShitTweens[i].cancel();
				FlxDestroyUtil.destroy(grpShitTweens[i]);
			}
			if (grpTextTweens[i] != null)
			{
				grpTextTweens[i].cancel();
				FlxDestroyUtil.destroy(grpTextTweens[i]);
			}
			if (curSelected == i)
			{
				grpShitTweens[i] = FlxTween.tween(grpMenuShit.members[i], {"offset.x": 0, "offset.y": curSelected * (grpMenuShit.members[i].height + 20)},
					0.15);
				grpTextTweens[i] = FlxTween.tween(grpMenuText.members[i], {"offset.x": 0, "offset.y": curSelected * (grpMenuShit.members[i].height + 20)},
					0.15);
				grpMenuText.members[i].alpha = 1;
				grpMenuShit.members[i].color = FlxColor.WHITE;
			}
			else
			{
				grpShitTweens[i] = FlxTween.tween(grpMenuShit.members[i], {"offset.x": 400, "offset.y": curSelected * (grpMenuShit.members[i].height + 20)},
					0.15);
				grpTextTweens[i] = FlxTween.tween(grpMenuText.members[i], {"offset.x": 400, "offset.y": curSelected * (grpMenuShit.members[i].height + 20)},
					0.15);
				grpMenuText.members[i].alpha = 0.6;
				grpMenuShit.members[i].color = 0x1f1f1f;
			}
		}
	}
}
