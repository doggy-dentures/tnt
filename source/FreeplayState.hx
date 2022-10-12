package;

import transition.data.IconIn;
import sys.thread.Mutex;
import sys.io.File;
import sys.FileSystem;
import transition.data.IconOut;
import flixel.util.FlxDestroyUtil;
import flixel.addons.display.FlxBackdrop;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var curSelected:Int = 0;

	public static var startingSelected:Int = 0;
	public static var curDifficulty:Int = 1;
	public static var currentP1:String = "bf";
	public static var currentP2:String = "dad";
	public static var useIconIn:Bool = false;

	var dontReset:Bool = false;

	// var scoreText:FlxTextThing;
	var scoreText:FontAtlasThing;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var curPlaying:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	private var songText:FlxTextThing;
	private var diffText:FlxTextThing;

	private var upTri:FlxSprite;
	private var downTri:FlxSprite;

	var currentSetting:Int = 0;

	var currentSong:String = "";

	var eligibleChars:Array<String> = [];

	var musicStream:AudioStreamThing;

	public function new(reset:Bool = false)
	{
		dontReset = !reset;
		super();
	}

	override function create()
	{
		// openfl.Lib.current.stage.frameRate = 144;
		Main.changeFramerate(144);

		PlayState.SONG = null;

		eligibleChars = Main.characters.copy();
		eligibleChars.push("senpai");
		eligibleChars.push("tankman");
		eligibleChars.push("prisma");
		// eligibleChars.push("spirit");

		curSelected = 0;

		// songs.push(new SongMetadata("Tutorial", 1, 'gf', false, false));

		// var isDebug:Bool = true;

		// addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);

		// addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', "monster"]);

		// addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

		// addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		// addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		// addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai-angry', 'spirit']);

		addSong("Tutorial", 1, "gf", 0x010, false);
		addSong("Kickin", 1, "bf");
		addSong("Demoniac", 1, "dad");
		addSong("Revenant", 1, "spooky");
		addSong("Trigger-Happy", 1, "pico");
		addSong("Playtime", 1, "mom");
		addSong("Zombie-Flower", 1, "lily");
		addSong("Tune-A-Fish", 1, "atlanta");
		addSong("Fresnel", 1, "prisma", 0x011, true, false);
		addSong("SiO2", 1, "prisma", 0x011, true, false);
		addSong("Bopeebo", 1, "dad", 0x010);
		addSong("Roses", 1, "senpai", 0x010);
		addSong("Ugh", 1, "tankman", 0x010);

		// LOAD CHARACTERS

		// var backdrop = new FlxBackdrop(Paths.image('tile2'));
		// backdrop.velocity.set(50, 50);
		// backdrop.antialiasing = true;
		var backdrop = new CrappyTile(Paths.getImagePNG('tile2'), 50, 50);
		add(backdrop);

		songText = new FlxTextThing(0, 320, 630, "TUTORIAL", 96);
		songText.antialiasing = true;
		add(songText);

		diffText = new FlxTextThing(960, 320, 320, "NORMAL", 96);
		diffText.antialiasing = true;
		add(diffText);

		iconP1 = new HealthIcon("bf", true);
		iconP1.setPosition(810, 285);
		iconP1.antialiasing = true;
		iconP2 = new HealthIcon("dad", false);
		iconP2.setPosition(640, 285);
		iconP2.antialiasing = true;

		add(iconP1);
		add(iconP2);

		// for (i in 0...songs.length)
		// {
		// }

		upTri = new FlxSprite().loadGraphic(Paths.getImagePNG('freeplay/triangle'));
		upTri.flipY = true;
		upTri.antialiasing = true;
		upTri.y = iconP1.y - upTri.height - 15;
		add(upTri);
		downTri = new FlxSprite().loadGraphic(Paths.getImagePNG('freeplay/triangle'));
		downTri.antialiasing = true;
		downTri.y = iconP1.y + iconP1.height + 15;
		add(downTri);

		// scoreText = new FlxTextThing(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText = new FontAtlasThing(Paths.getSparrowAtlasFunk("fnt/font2"), FlxG.camera, false, FlxG.width * 0.7, 5);
		// scoreText.autoSize = false;
		// scoreText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
		scoreBG.setGraphicSize(Std.int(FlxG.width * 0.35), 66);
		scoreBG.updateHitbox();
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(scoreText);

		changeSelection();
		changeSetting(startingSelected);

		if (useIconIn)
			customTransIn = new IconIn(0.5, PlayState.transIcon, PlayState.transColor, "png");

		super.create();
	}

	function updateSong()
	{
		songText.text = songs[curSelected].songName.toUpperCase();
		var textSize:Int = Std.int(Math.min(Math.floor(600 / songText.text.length), 96));
		songText.setFormat(Paths.font("bungee"), textSize, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songText.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
		songText.screenCenter(Y);
		var diffMusicString = "";

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
				if (songs[curSelected].uniqueDiffSongs)
					diffMusicString = "_Easy";
			case 1:
				diffText.text = "NORMAL";
			case 2:
				diffText.text = "HARD";
				if (songs[curSelected].uniqueDiffSongs)
					diffMusicString = "_Hard";
		}
		var textSize:Int = Std.int(Math.min(Math.floor(300 / diffText.text.length), 96));
		diffText.setFormat(Paths.font("bungee"), textSize, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		diffText.setBorderStyle(OUTLINE, FlxColor.BLACK, 4);
		diffText.screenCenter(Y);

		var newSong = songs[curSelected].songName + diffMusicString + "_Inst";
		if (currentSong != newSong)
		{
			currentSong = newSong;
			// trace("New song: " + newSong);
			// FlxG.sound.playMusic(Paths.music(newSong), 0);
			// FlxG.sound.music.fadeIn(1, 0, 0.8);
			if (musicStream != null)
			{
				musicStream.destroy();
				remove(musicStream);
			}
			musicStream = new AudioStreamThing(Paths.music(newSong));
			musicStream.looping = true;
			add(musicStream);
			musicStream.play();
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, hasDifficulties:Int = 0x111, canAdjustP2:Bool = true, uniqueDiffSongs:Bool = true)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, hasDifficulties, canAdjustP2, uniqueDiffSongs));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var stopInput:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var oldlerpScore = lerpScore;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "Personal Best:" + lerpScore;

		if (stopInput)
			return;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (controls.LEFT_P)
		{
			changeSelection(-1);
		}
		if (controls.RIGHT_P)
		{
			changeSelection(1);
		}

		if (downP)
			changeSetting(1);
		if (upP)
			changeSetting(-1);

		if (controls.DOWN)
			downTri.alpha = 0.5;
		else
			downTri.alpha = 1;

		if (controls.UP)
			upTri.alpha = 0.5;
		else
			upTri.alpha = 1;

		if (controls.BACK)
		{
			stopInput = true;
			// FlxG.sound.music.stop();
			if (musicStream != null)
				musicStream.destroy();
			// AudioStreamThing.destroyEngine();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			switchState(new MainMenuState());
		}

		if (accepted)
		{
			stopInput = true;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.curDifficulty = curDifficulty;
			startingSelected = curSelected;
			PlayState.returnLocation = "freeplay";
			PlayState.storyWeek = songs[curSelected].week;
			PlayState.overridePlayer1 = currentP1;
			PlayState.overridePlayer2 = currentP2;
			PlayState.transIcon = currentP2;
			PlayState.transColor = FlxColor.interpolate(Main.characterColors[currentP2], FlxColor.BLACK, 0.15);
			// PlayState.transColor = FlxColor.BLACK;
			PlayState.transIcon = currentP2;
			customTransOut = new IconOut(0.5, PlayState.transIcon, PlayState.transColor, "png");
			trace('CUR WEEK' + PlayState.storyWeek);
			useIconIn = true;
			switchState(new PlayState());
			// if (FlxG.sound.music != null)
			// 	FlxG.sound.music.stop();
			if (musicStream != null)
				musicStream.destroy();
			// AudioStreamThing.destroyEngine();
			SoundFontThing.asyncSongGen();
		}
	}

	function changeSetting(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		switch (currentSetting)
		{
			case 0:
				curSelected += change;

				if (curSelected < 0)
					curSelected = songs.length - 1;
				if (curSelected >= songs.length)
					curSelected = 0;

				// selector.y = (70 * curSelected) + 30;

				// lerpScore = 0;

				if (dontReset)
				{
					setChar(currentP1, true);
					setChar(currentP2, false);
					dontReset = false;
				}
				else
				{
					setChar("bf", true);
					setChar(songs[curSelected].songCharacter, false);
					curDifficulty = 1;
				}

				var diffStuff = "";
				switch (curDifficulty)
				{
					case 0:
						diffStuff = "_Easy";
					case 2:
						diffStuff = "_Hard";
				}
				intendedScore = Highscore.getScore(songs[curSelected].songName + diffStuff, curDifficulty);
			case 1:
				changeChar(change, false);
			case 2:
				changeChar(change, true);
			case 3:
				var hasHard = songs[curSelected].hasDifficulties & 0x100 == 0x100;
				var hasEasy = songs[curSelected].hasDifficulties & 0x001 == 0x001;
				var lowerRange:Int = hasEasy ? 0 : 1;
				var upperRange:Int = hasHard ? 2 : 1;
				if (hasHard || hasEasy)
				{
					curDifficulty += change;
					if (curDifficulty < lowerRange)
					{
						curDifficulty = upperRange;
					}
					if (curDifficulty > upperRange)
					{
						curDifficulty = lowerRange;
					}
					var diffStuff = "";
					switch (curDifficulty)
					{
						case 0:
							diffStuff = "_Easy";
						case 2:
							diffStuff = "_Hard";
					}
					intendedScore = Highscore.getScore(songs[curSelected].songName + diffStuff, curDifficulty);
				}
		}
		updateSong();
	}

	function changeChar(direction:Int, isPlayer1:Bool)
	{
		if (!isPlayer1 && !songs[curSelected].canAdjustP2)
			return;

		var curChar = "";
		if (isPlayer1)
			curChar = currentP1;
		else
			curChar = currentP2;

		var index = eligibleChars.lastIndexOf(curChar);
		index += direction;
		if (index < 0)
			index = eligibleChars.length - 1;
		else if (index > eligibleChars.length - 1)
			index = 0;

		setChar(eligibleChars[index], isPlayer1);
	}

	function setChar(character:String, isPlayer1:Bool)
	{
		if (isPlayer1)
		{
			currentP1 = character;
			// iconP1.animation.play(currentP1);
			iconP1.changeChar(currentP1);
			iconP1.normal();
		}
		else
		{
			currentP2 = character;
			// iconP2.animation.play(currentP2);
			iconP2.changeChar(currentP2);
			iconP2.normal();
		}
	}

	function changeSelection(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentSetting += change;

		if (currentSetting == 1 && !songs[curSelected].canAdjustP2)
			currentSetting += change;

		var limit = 2;
		if (songs[curSelected].hasDifficulties & 0x100 == 0x100 || songs[curSelected].hasDifficulties & 0x001 == 0x001)
			limit = 3;

		if (currentSetting > limit)
			currentSetting = 0;
		if (currentSetting < 0)
			currentSetting = limit;

		switch (currentSetting)
		{
			case 0:
				upTri.x = songText.x + songText.width / 2 - upTri.width / 2;
				downTri.x = songText.x + songText.width / 2 - downTri.width / 2;
			case 1:
				upTri.x = iconP2.x + iconP2.width / 2 - upTri.width / 2;
				downTri.x = iconP2.x + iconP2.width / 2 - downTri.width / 2;
			case 2:
				upTri.x = iconP1.x + iconP1.width / 2 - upTri.width / 2;
				downTri.x = iconP1.x + iconP1.width / 2 - downTri.width / 2;
			case 3:
				upTri.x = diffText.x + diffText.width / 2 - upTri.width / 2;
				downTri.x = diffText.x + diffText.width / 2 - downTri.width / 2;
		}
	}

	override public function destroy()
	{
		super.destroy();
		// Cashew.destroyAll();
	}

	override public function onFocusLost():Void
	{
		if (musicStream != null && musicStream.playing)
			musicStream.pause();
		super.onFocusLost();
	}

	override public function onFocus()
	{
		if (musicStream != null && !musicStream.playing)
			musicStream.play();
		super.onFocus();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var hasDifficulties:Int = 0x111;
	public var canAdjustP2:Bool = true;
	public var uniqueDiffSongs:Bool = true;

	public function new(song:String, week:Int, songCharacter:String, hasDifficulties:Int, canAdjustP2:Bool, uniqueDiffSongs:Bool)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.hasDifficulties = hasDifficulties;
		this.canAdjustP2 = canAdjustP2;
		this.uniqueDiffSongs = uniqueDiffSongs;
	}
}
