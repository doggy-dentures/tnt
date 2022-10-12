package;

import transition.data.IconOut;
import transition.data.IconIn;
import sys.FileSystem;
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import title.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxTextThing;

	// public static var weekData:Array<Dynamic>;
	var curDifficulty:Int = 1;
	var selectedChar:Int = 0;

	// var backdrop:FlxBackdrop;
	var backdrop:CrappyTile;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var portrait:Map<Int, FlxSprite> = [];
	var portraitSelected:Map<Int, FlxSprite> = [];
	var charName:FlxTextThing;
	var boxQuote:FlxSprite;
	var textQuote:FlxTextThing;
	var boxDesc:FlxSprite;
	var textDesc:FlxTextThing;
	var boxPath:FlxSprite;
	var creditText:FlxSprite;
	var healthIcons:Array<HealthIcon> = [];
	var fadeAway:FlxTypedGroup<FlxSprite>;

	override function create()
	{
		// openfl.Lib.current.stage.frameRate = 144;
		Main.changeFramerate(144);
		super.create();

		if (Main.lol == null)
		{
			Main.music(Paths.music(TitleScreen.titleMusic), 0.75);
		}

		// backdrop = new FlxBackdrop(Paths.image('tile'));
		// backdrop.velocity.set(50, 50);
		// add(backdrop);
		backdrop = new CrappyTile(Paths.getImagePNG('tile'), 50, 50);
		add(backdrop);

		fadeAway = new FlxTypedGroup<FlxSprite>();
		add(fadeAway);

		leftArrow = new FlxSprite().loadGraphic(Paths.getImagePNG("vert/triangle"));
		leftArrow.antialiasing = true;
		leftArrow.setPosition(12, 324);
		fadeAway.add(leftArrow);

		rightArrow = new FlxSprite().loadGraphic(Paths.getImagePNG("vert/triangle"));
		rightArrow.flipX = true;
		rightArrow.antialiasing = true;
		rightArrow.setPosition(368, 324);
		fadeAway.add(rightArrow);

		boxQuote = new FlxSprite().loadGraphic(Paths.getImagePNG("vert/smallbox"));
		boxQuote.setPosition(454, 144);
		fadeAway.add(boxQuote);

		boxDesc = new FlxSprite().loadGraphic(Paths.getImagePNG("vert/bigbox"));
		boxDesc.setPosition(454, 281);
		fadeAway.add(boxDesc);

		boxPath = new FlxSprite().loadGraphic(Paths.getImagePNG("vert/smallbox"));
		boxPath.setPosition(454, 623);
		fadeAway.add(boxPath);

		textQuote = new FlxTextThing(0, 0, 726, "");
		textQuote.antialiasing = true;
		fadeAway.add(textQuote);

		textDesc = new FlxTextThing(0, 0, 710, "");
		textDesc.antialiasing = true;
		fadeAway.add(textDesc);

		scoreText = new FlxTextThing(10, FlxG.height - 36 - 5, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		fadeAway.add(scoreText);

		for (i in 0...Main.characters.length)
		{
			var face = new FlxSprite();
			if (FileSystem.exists(Paths.funk("vert/" + Main.characters[i] + "/deselected")))
			{
				face.antialiasing = true;
				face.frames = Paths.getSparrowAtlasFunk("vert/" + Main.characters[i] + "/deselected");
				face.animation.addByPrefix("deselected", "deselected", 0, false);
				face.animation.play("deselected");
			}
			face.visible = false;
			add(face);
			portrait[i] = face;

			var face2 = new FlxSprite();
			if (FileSystem.exists(Paths.funk("vert/" + Main.characters[i] + "/selected")))
			{
				trace("FOUND THAT BUFF");
				face2.antialiasing = true;
				face2.frames = Paths.getSparrowAtlasFunk("vert/" + Main.characters[i] + "/selected");
				face2.animation.addByPrefix("selected", "selected", 0, false);
				face2.animation.play("selected");
			}
			face2.alpha = 0;
			add(face2);
			portraitSelected[i] = face2;
		}

		charName = new FlxTextThing(0, 0, 912, "");
		charName.antialiasing = true;
		add(charName);

		changeChar();

		persistentUpdate = persistentDraw = true;
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "SCORE:" + lerpScore;

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.RIGHT_P)
					changeChar(1);
				if (controls.LEFT_P)
					changeChar(-1);
				if (controls.RIGHT)
					rightArrow.alpha = 0.5;
				else
					rightArrow.alpha = 1;

				if (controls.LEFT)
					leftArrow.alpha = 0.5;
				else
					leftArrow.alpha = 1;
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function changeChar(dir:Int = 0)
	{
		if (dir != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		var oldChar = selectedChar;

		selectedChar += dir;

		if (selectedChar < 0)
			selectedChar = Main.characters.length - 1;
		if (selectedChar >= Main.characters.length)
			selectedChar = 0;

		for (icon in healthIcons)
		{
			fadeAway.remove(icon);
			icon.active = false;
			icon.visible = false;
			FlxDestroyUtil.destroy(icon);
		}

		portrait[oldChar].visible = false;
		portrait[selectedChar].visible = true;

		textDesc.text = Main.characterDesc[selectedChar] + (Main.characterCredits[selectedChar] == null ? "" : "\nCharacter created by " + Main.characterCredits[selectedChar]);
		var textSize:Int = Std.int(Math.min(Math.floor(Math.sqrt(250 * 700 / textDesc.text.length)), 64));
		textDesc.setFormat(Paths.font("knewave"), textSize, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textDesc.setPosition(boxDesc.x + boxDesc.width / 2 - textDesc.width / 2, boxDesc.y + boxDesc.height / 2 - textDesc.height / 2);

		textQuote.text = Main.characterQuotes[selectedChar] == "" ? "" : ' "' + Main.characterQuotes[selectedChar] + '" ';
		// var textSize:Int = Std.int(Math.min(Math.floor(720 / textQuote.text.length), 36));
		var textSize:Int = 36;
		textQuote.setFormat(Paths.font("knewave"), textSize, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textQuote.setPosition(boxQuote.x + boxQuote.width / 2 - textQuote.width / 2, boxQuote.y + boxQuote.height / 2 - textQuote.height / 2);

		charName.text = Main.characterNames[selectedChar].toUpperCase();
		var textSize:Int = Std.int(Math.min(Math.floor(880 / charName.text.length), 96));
		charName.setFormat(Paths.font("bungee"), textSize, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		charName.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
		charName.setPosition(368, boxQuote.y / 2 - charName.height / 2);

		if (dir != 0)
			Cashew.destroyOne("vert/" + Main.characters[oldChar] + "/tile");

		backdrop.newTile(Paths.getImagePNG("vert/" + Main.characters[selectedChar] + "/tile"));

		intendedScore = Highscore.getWeekScore(selectedChar, 5);

		if (Main.characterCampaigns[Main.characters[selectedChar]] != null)
		{
			var charNames = Main.characterCampaigns[Main.characters[selectedChar]][2];
			for (i in 0...charNames.length)
			{
				var icon = new HealthIcon(charNames[i]);
				healthIcons.push(icon);
				icon.setGraphicSize(Std.int(icon.width / 2));
				icon.iconScale = 0.5;
				icon.updateHitbox();
				icon.x = (i * boxPath.width / charNames.length + boxPath.width / charNames.length / 2) - icon.width / 2 + boxPath.x;
				icon.y = boxPath.y + boxPath.height / 2 - icon.height / 2;
				fadeAway.add(icon);
			}
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (stopspamming == false)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			stopspamming = true;
			if (Main.lol != null)
			{
				Main.unmusic();
			}

			// PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			// var diffic = "";

			// switch (curDifficulty)
			// {
			// 	case 0:
			// 		diffic = '-easy';
			// 	case 2:
			// 		diffic = '-hard';
			// }

			// PlayState.storyDifficulty = curDifficulty;

			PlayState.overridePlayer1 = Main.characters[selectedChar];
			PlayState.overridePlayer2 = "";

			if (Main.characterCampaigns[Main.characters[selectedChar]] != null)
			{
				PlayState.storyPlaylist = Main.characterCampaigns[Main.characters[selectedChar]][0].copy();
				PlayState.storyDifficulties = Main.characterCampaigns[Main.characters[selectedChar]][1].copy();
			}
			else
			{
				PlayState.storyPlaylist = ["Tutorial"];
				PlayState.storyDifficulties = [""];
			}
			PlayState.storyPlaylist.insert(0, Main.charToSong[Main.characters[selectedChar]]);
			PlayState.storyDifficulties.insert(0, "-easy");

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + PlayState.storyDifficulties[0],
				PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = selectedChar;
			PlayState.returnLocation = "main";
			PlayState.campaignScore = 0;
			PlayState.introOnly = true;
			PlayState.transIcon = Main.characters[selectedChar];
			PlayState.transColor = Main.characterColors[PlayState.transIcon];
			FlxTween.tween(portraitSelected[selectedChar], {"alpha": 1}, 0.25, {ease: FlxEase.quadIn});
			for (item in fadeAway.members)
			{
				if (item != null)
					FlxTween.tween(item, {"alpha": 0}, 0.25);
			}
			FlxTween.tween(charName, {"y": FlxG.height / 2 - charName.height / 2}, 0.25, {ease: FlxEase.quadIn});
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				customTransOut = new IconOut(0.5, PlayState.transIcon, PlayState.transColor, "png");
				switchState(new PlayState());
				FlxDestroyUtil.destroy(tmr);
			});
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	override public function destroy()
	{
		portrait.clear();
		portrait = null;
		portraitSelected.clear();
		portraitSelected = null;
		super.destroy();
		//Cashew.destroyAll();
	}
}
