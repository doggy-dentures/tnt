package;

import sys.io.File;
import sys.FileSystem;
import openfl.Assets;
import haxe.Json;
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import config.*;

// import polymod.format.ParseRules.TargetSignatureElement;
using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var realStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var trueNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var notePitch:Int = 60;
	public var notePreset:Int = 0;
	public var noteVolume:Float = 1.0;
	public var noteLength:Float = 0;

	public var noteScore:Float = 1;

	public var playedEditorClick:Bool = false;
	public var editorBFNote:Bool = false;
	public var absoluteNumber:Int;

	public var spinAmount:Float = 0;
	public var rootNote:Note;
	public var isLeafNote:Bool = false;

	public var isMine:Bool = false;
	public var isAlert:Bool = false;
	public var isHeal:Bool = false;
	public var isFreeze:Bool = false;
	public var isFakeHeal:Bool = false;
	public var isScribble:Bool = false;

	public var specialNote:Bool = false;
	public var ignoreMiss:Bool = false;

	public var didLatePenalty:Bool = false;

	public var didSpecialStuff = false;
	public var onStrumTime:Void->Void;
	public var editor = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// var posTween:FlxTween;
	var justMixedUp:Bool = false;

	var song:AudioStreamThing;

	public var useColorz:Bool = false;

	public var isAvailable:Bool = false;

	public static var colorzShaders:Array<Colorz> = [];
	public static var colorz:Array<FlxColor> = [];

	public function resetStuff()
	{
		canBeHit = false;
		tooLate = false;
		wasGoodHit = false;
		spinAmount = 0;
		isMine = false;
		isAlert = false;
		isHeal = false;
		isFreeze = false;
		isFakeHeal = false;
		isScribble = false;
		specialNote = false;
		ignoreMiss = false;
		didLatePenalty = false;
		didSpecialStuff = false;
		onStrumTime = null;
		justMixedUp = false;
		isGhosting = false;
		ghostSpeed = 1;
		ghostSine = false;
		isAvailable = false;
		angle = 0;
		shader = null;
		scale.set(1, 1);
		alpha = 1.0;
		active = true;
		visible = true;
		flipX = false;
		flipY = false;
	}

	public function setupNote(_strumTime:Float, _noteData:Int, ?_editor = false, ?_prevNote:Note, ?_sustainNote:Bool = false, ?_rootNote:Note,
			noteType:Int = 0, _song = null, _mustHit:Bool = false, _isLeafNote:Bool = false, _sustainLength:Float = 0)
	{
		resetStuff();

		prevNote = _prevNote;
		isSustainNote = _sustainNote;
		rootNote = _rootNote;
		song = _song;
		isLeafNote = _isLeafNote;
		sustainLength = _sustainLength;

		switch (noteType)
		{
			case 1:
				isMine = true;
				specialNote = true;
				ignoreMiss = true;
			case 2:
				isAlert = true;
				specialNote = true;
			case 3:
				isHeal = true;
				specialNote = true;
				ignoreMiss = true;
			case 4:
				isFakeHeal = true;
				specialNote = true;
				ignoreMiss = true;
			case 5:
				isFreeze = true;
				specialNote = true;
				ignoreMiss = true;
			case 6:
				isScribble = true;
				specialNote = true;
				ignoreMiss = true;
		}

		// x += 100;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		// y -= 2000;

		editor = _editor;

		if (!editor)
		{
			strumTime = _strumTime + Config.offset;
			if (strumTime < 0)
			{
				strumTime = 0;
			}
			scrollFactor.set();
		}
		else
		{
			strumTime = _strumTime;
		}

		realStrumTime = _strumTime;

		noteData = _noteData;
		trueNoteData = _noteData;

		mustPress = _mustHit;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				switch (noteType)
				{
					case 0:
						loadGraphic(Paths.getImageFunk('weeb/pixelUI/arrows-pixels'), true, 17, 17);

						animation.add('greenScroll', [6]);
						animation.add('redScroll', [7]);
						animation.add('blueScroll', [5]);
						animation.add('purpleScroll', [4]);

						if (Config.noteGlow)
						{
							animation.add('green glow', [22]);
							animation.add('red glow', [23]);
							animation.add('blue glow', [21]);
							animation.add('purple glow', [20]);
						}

						if (isSustainNote)
						{
							loadGraphic(Paths.getImageFunk('weeb/pixelUI/arrowEnds'), true, 7, 6);

							animation.add('purpleholdend', [4]);
							animation.add('greenholdend', [6]);
							animation.add('redholdend', [7]);
							animation.add('blueholdend', [5]);

							animation.add('purplehold', [0]);
							animation.add('greenhold', [2]);
							animation.add('redhold', [3]);
							animation.add('bluehold', [1]);
						}

						if (Config.noteGlow)
						{
							animation.addByPrefix('purple glow', 'Purple Active');
							animation.addByPrefix('green glow', 'Green Active');
							animation.addByPrefix('red glow', 'Red Active');
							animation.addByPrefix('blue glow', 'Blue Active');
						}
					case 1:
						loadGraphic(Paths.getImagePNG("weeb/pixelUI/minenote"));
					case 2:
						loadGraphic(Paths.getImagePNG("weeb/pixelUI/warningnote"));
					case 3:
						loadGraphic(Paths.getImagePNG("weeb/pixelUI/healnote"));
					case 4:
						loadGraphic(Paths.getImagePNG("weeb/pixelUI/fakehealnote"));
					case 5:
						loadGraphic(Paths.getImagePNG("weeb/pixelUI/icenote"));
					case 6:
						loadGraphic(Paths.getImagePNG("weeb/pixelUI/scribblenote"));
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				switch (noteType)
				{
					case 0:
						// frames = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
						useColorz = true;
						frames = Paths.getSparrowAtlasFunk('notes/note');
						animation.addByPrefix('end', 'end', 0, false);
						animation.addByPrefix('hold', 'hold', 0, false);
						animation.addByPrefix('Scroll', 'scroll', 0, false);
						if (Config.noteGlow)
						{
							animation.addByPrefix('active', 'active', 0, false);
						}

					case 1:
						loadGraphic(Paths.getImagePNG("notes/minenote"));
					case 2:
						loadGraphic(Paths.getImagePNG("notes/warningnote"));
					case 3:
						loadGraphic(Paths.getImagePNG("notes/healnote"));
					case 4:
						loadGraphic(Paths.getImagePNG("notes/fakehealnote"));
					case 5:
						loadGraphic(Paths.getImagePNG("notes/icenote"));
					case 6:
						loadGraphic(Paths.getImagePNG("notes/scribblenote"));
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		updateAngle();

		if (specialNote)
			return;

		if (!isSustainNote)
		{
			switch (noteData)
			{
				case 0:
					// x += swagWidth * 0;
					if (useColorz)
					{
						animation.play('Scroll');
						shader = getShader(0, mustPress);
					}
					else
						animation.play('purpleScroll');
				case 1:
					// x += swagWidth * 1;
					if (useColorz)
					{
						animation.play('Scroll');
						shader = getShader(1, mustPress);
					}
					else
						animation.play('blueScroll');
				case 2:
					// x += swagWidth * 2;
					if (useColorz)
					{
						animation.play('Scroll');
						shader = getShader(2, mustPress);
					}
					else
						animation.play('greenScroll');
				case 3:
					// x += swagWidth * 3;
					if (useColorz)
					{
						animation.play('Scroll');
						shader = getShader(3, mustPress);
					}
					else
						animation.play('redScroll');
				case 8:
					loadGraphic('assets/images/FX.png');
			}
			// color = FlxColor.WHITE;
		}
		else if (isLeafNote)
		{
			alpha = 0.6;
			ignoreMiss = true;
			// color = FlxColor.BLACK;
			// if (prevNote != null)
			// 	prevNote.color = FlxColor.RED;

			// x += width / 2;

			updateFlip();

			switch (noteData)
			{
				case 2:
					if (useColorz)
					{
						animation.play('end');
						shader = getShader(2, mustPress);
					}
					else
						animation.play('greenholdend');
				case 3:
					if (useColorz)
					{
						animation.play('end');
						shader = getShader(3, mustPress);
					}
					else
						animation.play('redholdend');
				case 1:
					if (useColorz)
					{
						animation.play('end');
						shader = getShader(1, mustPress);
					}
					else
						animation.play('blueholdend');
				case 0:
					if (useColorz)
					{
						animation.play('end');
						shader = getShader(0, mustPress);
					}
					else
						animation.play('purpleholdend');
			}

			updateHitbox();

			// x -= width / 2;

			// if (PlayState.curStage.startsWith('school'))
			// 	x += 30;
		}
		else
		{
			alpha = 0.6;
			// color = FlxColor.WHITE;

			// x += width / 2;

			updateFlip();

			switch (noteData)
			{
				case 2:
					if (useColorz)
					{
						animation.play('hold');
						shader = getShader(2, mustPress);
					}
					else
						animation.play('greenhold');
				case 3:
					if (useColorz)
					{
						animation.play('hold');
						shader = getShader(3, mustPress);
					}
					else
						animation.play('redhold');
				case 1:
					if (useColorz)
					{
						animation.play('hold');
						shader = getShader(1, mustPress);
					}
					else
						animation.play('bluehold');
				case 0:
					if (useColorz)
					{
						animation.play('hold');
						shader = getShader(0, mustPress);
					}
					else
						animation.play('purplehold');
			}

			updateScale();
			updateHitbox();

			// x -= width / 2;

			// if (PlayState.curStage.startsWith('school'))
			// 	x += 30;
		}
	}

	public function updateAngle()
	{
		if (specialNote)
			return;
		if (useColorz)
		{
			if (!isSustainNote)
			{
				switch (noteData)
				{
					case 0:
						angle = 90;
					case 1:
						angle = 0;
					case 2:
						angle = 180;
					case 3:
						angle = 270;
				}
			}
		}
		else
			angle = 0;
	}

	public static function getShader(index:Int, mustHit:Bool)
	{
		var offset = (mustHit ? 0 : 4);
		return colorzShaders[index + offset];
	}

	public function updateScale()
	{
		if (isSustainNote && !isLeafNote)
		{
			scale.x = scale.y = 1;
			updateHitbox();
			switch (PlayState.curStage)
			{
				case 'school' | 'schoolEvil':
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				default:
					setGraphicSize(Std.int(width * 0.7));
			}
			scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.effectiveScrollSpeed;
			updateHitbox();
		}
	}

	public function updateFlip()
	{
		if (isSustainNote)
		{
			flipY = PlayState.effectiveDownScroll;
			updateHitbox();
		}
	}

	// public function swapPositions()
	// {
	// 	justMixedUp = true;
	// 	if (posTween != null && posTween.active)
	// 		posTween.cancel();
	// 	var newX = FlxG.width / 2
	// 		+ 100
	// 		+ swagWidth * PlayState.notePositions[noteData % 4]
	// 		+ (isSustainNote ? (PlayState.curStage.startsWith('school') ? width * 0.75 : width) : 0);
	// 	posTween = FlxTween.tween(this, {x: newX}, 0.25, {
	// 		onComplete: function(_)
	// 		{
	// 			justMixedUp = false;
	// 		}
	// 	});
	// }
	// function updateXPosition()
	// {
	// 	if (justMixedUp)
	// 		return;
	// 	if (mustPress)
	// 	{
	// 		var newX = FlxG.width / 2
	// 			+ 100
	// 			+ swagWidth * PlayState.notePositions[noteData % 4]
	// 			+ (isSustainNote ? (PlayState.curStage.startsWith('school') ? width * 0.75 : width) : 0);
	// 		x = newX;
	// 	}
	// 	else
	// 	{
	// 		var newX = 0 + 100 + swagWidth * noteData + (isSustainNote ? (PlayState.curStage.startsWith('school') ? width * 0.75 : width) : 0);
	// 		x = newX;
	// 	}
	// }
	public var isGhosting:Bool = false;
	public var ghostSpeed:Float = 1;
	public var ghostSine:Bool = false;

	public function doGhost(?speed:Float, ?sine:Bool)
	{
		if (speed == null)
			speed = FlxG.random.float(0.003, 0.006);
		if (sine == null)
			sine = FlxG.random.bool();

		ghostSine = sine;
		ghostSpeed = speed;
		isGhosting = true;
	}

	public function undoGhost()
	{
		isGhosting = false;
		if (isSustainNote)
			alpha = 0.6;
		else
			alpha = 1.0;
	}

	// public function refreshSprite()
	// {
	// 	if (animation == null || animation.name == null)
	// 		return;
	// 	if (animation.name.contains("Scroll"))
	// 	{
	// 		switch (noteData)
	// 		{
	// 			case 0:
	// 				animation.play('purpleScroll');
	// 			case 1:
	// 				animation.play('blueScroll');
	// 			case 2:
	// 				animation.play('greenScroll');
	// 			case 3:
	// 				animation.play('redScroll');
	// 		}
	// 	}
	// 	else if (animation.name.contains("end"))
	// 	{
	// 		switch (noteData)
	// 		{
	// 			case 2:
	// 				animation.play('greenholdend');
	// 			case 3:
	// 				animation.play('redholdend');
	// 			case 1:
	// 				animation.play('blueholdend');
	// 			case 0:
	// 				animation.play('purpleholdend');
	// 		}
	// 	}
	// 	else if (animation.name.contains("hold"))
	// 	{
	// 		switch (noteData)
	// 		{
	// 			case 2:
	// 				animation.play('greenhold');
	// 			case 3:
	// 				animation.play('redhold');
	// 			case 1:
	// 				animation.play('bluehold');
	// 			case 0:
	// 				animation.play('purplehold');
	// 		}
	// 	}
	// 	updateHitbox();
	// }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isGhosting)
		{
			if (ghostSine)
			{
				alpha = 0.25 + 0.7 * Math.abs(Math.sin(Conductor.songPosition * ghostSpeed));
			}
			else
			{
				alpha = 0.25 + 0.7 * Math.abs(Math.cos(Conductor.songPosition * ghostSpeed));
			}
		}

		if (mustPress)
		{
			if (isSustainNote)
			{
				canBeHit = (strumTime < /*Conductor.songPosition*/ getSongPos() + Conductor.safeZoneOffset * 1
					&& (prevNote == null ? true : prevNote.wasGoodHit));
			}
			else if (isMine || isFreeze || isFakeHeal || isScribble)
			{
				canBeHit = (strumTime > /*Conductor.songPosition*/ getSongPos() - Conductor.safeZoneOffset * 0.55
					&& strumTime < /*Conductor.songPosition*/ getSongPos() + Conductor.safeZoneOffset * 0.55);
			}
			else if (isAlert || isHeal)
			{
				canBeHit = (strumTime > /*Conductor.songPosition*/ getSongPos() - Conductor.safeZoneOffset * 1.2
					&& strumTime < /*Conductor.songPosition*/ getSongPos() + Conductor.safeZoneOffset * 1.2);
			}
			else
			{
				canBeHit = (strumTime > /*Conductor.songPosition*/ getSongPos() - Conductor.safeZoneOffset
					&& strumTime < /*Conductor.songPosition*/ getSongPos() + Conductor.safeZoneOffset);
			}

			if (strumTime < /*Conductor.songPosition*/ getSongPos() - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		// else
		// {
		// 	canBeHit = false;

		// 	if (strumTime >= Conductor.songPosition)
		// 	{
		// 		wasGoodHit = true;
		// 	}
		// }

		// Glow note stuff.

		if (!specialNote && noteData != 8)
		{
			if (canBeHit && Config.noteGlow && !isSustainNote && animation.curAnim.name.contains("Scroll"))
			{
				if (useColorz)
				{
					animation.play('active');
				}
				else
				{
					switch (noteData)
					{
						case 2:
							animation.play('green glow');
						case 3:
							animation.play('red glow');
						case 1:
							animation.play('blue glow');
						case 0:
							animation.play('purple glow');
					}
				}
			}

			if (tooLate && !isSustainNote && !animation.curAnim.name.contains("Scroll"))
			{
				if (useColorz)
				{
					animation.play('Scroll');
				}
				else
				{
					switch (noteData)
					{
						case 2:
							animation.play('greenScroll');
						case 3:
							animation.play('redScroll');
						case 1:
							animation.play('blueScroll');
						case 0:
							animation.play('purpleScroll');
					}
				}
			}

			if (spinAmount != 0)
			{
				angle += FlxG.elapsed * spinAmount;
			}
		}

		if (!editor)
		{
			centerOffsets();
			if (PlayState.xWiggle != null && PlayState.yWiggle != null)
			{
				offset.x += PlayState.xWiggle[noteData % 4];
				offset.y += PlayState.yWiggle[noteData % 4];
			}
			// updateXPosition();
		}
	}

	override public function destroy()
	{
		// if (posTween != null && posTween.active)
		// {
		// 	posTween.cancel();
		// }
		// posTween = FlxDestroyUtil.destroy(posTween);
		clipRect = FlxDestroyUtil.put(clipRect);
		prevNote = null;
		onStrumTime = null;
		song = null;
		super.destroy();
	}

	override public function kill()
	{
		super.kill();
		if (sustainLength > 0 && isLeafNote)
		{
			makeAvailable();
		}
		else if (!(sustainLength > 0))
		{
			makeAvailable();
		}
		clipRect = FlxDestroyUtil.put(clipRect);
	}

	function makeAvailable()
	{
		isAvailable = true;
		if (prevNote != null)
		{
			prevNote.makeAvailable();
		}
	}

	inline function getSongPos()
	{
		if (editor)
			return 0.0;
		else if (PlayState.useStreamPos)
			return (song != null ? song.time : Conductor.songPosition);
		else
			return Conductor.songPosition;
	}

	public static function loadColorz(?palette1:String, ?palette2:String)
	{
		clearColorz();
		if (palette1 == null)
			palette1 = "default";
		if (palette2 == null)
			palette2 = "default";
		for (name in [palette1, palette2])
		{
			switch (name)
			{
				case 'user':
					var colorJson:ColorzJSON = Config.arrowColors;
					colorzShaders.push(new Colorz(Std.parseInt("0x" + colorJson.left.inner), Std.parseInt("0x" + colorJson.left.outer),
						Std.parseInt("0x" + colorJson.left.base)));
					colorzShaders.push(new Colorz(Std.parseInt("0x" + colorJson.down.inner), Std.parseInt("0x" + colorJson.down.outer),
						Std.parseInt("0x" + colorJson.down.base)));
					colorzShaders.push(new Colorz(Std.parseInt("0x" + colorJson.up.inner), Std.parseInt("0x" + colorJson.up.outer),
						Std.parseInt("0x" + colorJson.up.base)));
					colorzShaders.push(new Colorz(Std.parseInt("0x" + colorJson.right.inner), Std.parseInt("0x" + colorJson.right.outer),
						Std.parseInt("0x" + colorJson.right.base)));
					colorz.push(Std.parseInt("0x" + colorJson.left.inner));
					colorz.push(Std.parseInt("0x" + colorJson.down.inner));
					colorz.push(Std.parseInt("0x" + colorJson.up.inner));
					colorz.push(Std.parseInt("0x" + colorJson.right.inner));
				default:
					var rawJson:String = "";
					if (FileSystem.exists(Paths.json('_notecolors/' + name.toLowerCase())))
						rawJson = File.getContent(Paths.json('_notecolors/' + name.toLowerCase())).trim();
					else
						rawJson = File.getContent(Paths.json('_notecolors/default')).trim();
					var colorJson:ColorzJSON = Json.parse(rawJson);
					colorzShaders.push(new Colorz(Std.parseInt("0x" + colorJson.left.inner), Std.parseInt("0x" + colorJson.left.outer),
						Std.parseInt("0x" + colorJson.left.base)));
					colorzShaders.push(new Colorz(Std.parseInt("0x" + colorJson.down.inner), Std.parseInt("0x" + colorJson.down.outer),
						Std.parseInt("0x" + colorJson.down.base)));
					colorzShaders.push(new Colorz(Std.parseInt("0x" + colorJson.up.inner), Std.parseInt("0x" + colorJson.up.outer),
						Std.parseInt("0x" + colorJson.up.base)));
					colorzShaders.push(new Colorz(Std.parseInt("0x" + colorJson.right.inner), Std.parseInt("0x" + colorJson.right.outer),
						Std.parseInt("0x" + colorJson.right.base)));
					colorz.push(Std.parseInt("0x" + colorJson.left.inner));
					colorz.push(Std.parseInt("0x" + colorJson.down.inner));
					colorz.push(Std.parseInt("0x" + colorJson.up.inner));
					colorz.push(Std.parseInt("0x" + colorJson.right.inner));
			}
		}
	}

	public static function clearColorz()
	{
		colorzShaders.resize(0);
		colorz.resize(0);
	}
}

typedef ColorzJSON =
{
	var left:ColorzPalette;
	var down:ColorzPalette;
	var up:ColorzPalette;
	var right:ColorzPalette;
}

typedef ColorzPalette =
{
	var inner:String;
	var outer:String;
	var base:String;
}
