package;

import flixel.util.FlxColor;
import transition.data.IconOut;
import transition.data.IconIn;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class StoryStageState extends UIStateExt
{
	var foes:Array<String>;
	var diffs:Array<String>;
	var heads:FlxTypedSpriteGroup<HealthIcon> = new FlxTypedSpriteGroup<HealthIcon>();
	var diffText:FontAtlasThing;
	var diffText2:FontAtlasThing;
	var nameText:FontAtlasThing;

	override function create()
	{
		SoundFontThing.asyncSongGen();
		// openfl.Lib.current.stage.frameRate = 144;
		Main.changeFramerate(144);
		customTransIn = new IconIn(0.5, PlayState.transIcon, PlayState.transColor, "png");
		PlayState.transIcon = PlayState.SONG.player2;
		PlayState.transColor = FlxColor.interpolate(Main.characterColors[PlayState.SONG.player2], FlxColor.BLACK, 0.15);
		// PlayState.transColor = FlxColor.BLACK;
		customTransOut = new IconOut(0.5, PlayState.transIcon, PlayState.transColor, "png");

		super.create();
		var backdrop = new CrappyTile(Paths.getImagePNG('tile4'), 50, 50);
		add(backdrop);
		add(heads);
		diffs = Main.characterCampaigns[PlayState.overridePlayer1][1];
		foes = Main.characterCampaigns[PlayState.overridePlayer1][2];
		for (i in 0...foes.length)
		{
			var head = new HealthIcon(foes[i]);
			head.setPosition(FlxG.width / 2 - head.width / 2 + 200 * (i + 1), FlxG.height / 2 - head.height / 2);
			heads.add(head);
		}
		var curIndex = foes.indexOf(PlayState.SONG.player2);
		for (i in 0...heads.members.length)
		{
			heads.members[i].x -= 200 * curIndex;
			if (i < curIndex)
				heads.members[i].lose();
		}
		var prevDiff = (curIndex == 0 ? "" : diffThing(diffs[curIndex - 1]));
		var curDiff = diffThing(diffs[curIndex]);
		diffText = new FontAtlasThing(Paths.getSparrowAtlasFunk("fnt/font3"), FlxG.camera, true);
		diffText.text = "Difficulty:";
		diffText.y = FlxG.height / 2 - 150 - diffText.height / 2;
		diffText.screenCenter(X);
		diffText2 = new FontAtlasThing(Paths.getSparrowAtlasFunk("fnt/font3"), FlxG.camera, true);
		diffText2.text = prevDiff;
		diffText2.y = diffText.y + diffText.height;
		diffText2.screenCenter(X);
		add(diffText);
		add(diffText2);

		var prevName = (curIndex == 0 ? " " : Main.characterNames[Main.characters.indexOf(foes[curIndex - 1])]);
		var name = Main.characterNames[Main.characters.indexOf(PlayState.SONG.player2)];
		nameText = new FontAtlasThing(Paths.getSparrowAtlasFunk("fnt/font3"), FlxG.camera, true);
		nameText.text = prevName;
		nameText.y = FlxG.height / 2 + 100 - nameText.height / 2;
		nameText.screenCenter(X);
		add(nameText);

		if (PlayState.SONG.player2 == 'prisma')
		{
			nameText.visible = diffText.visible = diffText2.visible = false;
		}

		new FlxTimer().start(0.25, function(tmr)
		{
			FlxG.sound.play(Paths.sound('bean'), 0.5);
			FlxTween.tween(heads, {"x": -200}, 0.5, {
				onComplete: function(twn)
				{
					heads.members[curIndex].win();
					diffText2.text = curDiff;
					diffText2.screenCenter(X);
					nameText.text = name;
					nameText.screenCenter(X);
					new FlxTimer().start(1, function(tmr2)
					{
						switchState(new PlayState());
						twn.destroy();
						tmr2.destroy();
					});
				},
				ease: FlxEase.quadOut
			});
		});
	}

	function diffThing(input:String)
	{
		switch (input)
		{
			case "-hard":
				return "Hard";
			case "-easy":
				return "Easy";
			default:
				return "Normal";
		}
	}
}
