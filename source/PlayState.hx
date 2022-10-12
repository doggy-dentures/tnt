package;

import flixel.input.FlxKeyManager;
import openfl.particle.GPUParticleSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.addons.effects.FlxSkewedSprite;
import cpp.Pointer;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import lime.media.vorbis.VorbisFile;
import cpp.ConstCharStar;
import cpp.RawPointer;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import openfl.display.Bitmap;
import cpp.abi.Abi;
import cpp.Int16;
import cpp.NativeArray;
import sys.io.File;
import haxe.io.Bytes;
// import io.newgrounds.objects.Session.SessionStatus;
import openfl.media.ID3Info;
import lime.media.openal.AL;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.misc.NumTween;
import flixel.math.FlxRandom;
import flixel.FlxState;
import flixel.util.FlxDestroyUtil;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.BitmapFilter;
import haxe.Json;
#if sys
import sys.FileSystem;
#end
import config.*;
import title.*;
import transition.data.*;
import lime.utils.Assets;
import flixel.math.FlxRect;
import openfl.system.System;
import openfl.ui.KeyLocation;
import flixel.input.keyboard.FlxKey;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import sys.FileSystem;
// import polymod.fs.SysFileSystem;
import Section.SwagSection;
import Song.SwagSong;
// import WiggleEffect.WiggleEffectType;
// import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
// import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
// import flixel.FlxState;
import flixel.FlxSubState;
// import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
// import flixel.addons.effects.FlxTrailArea;
// import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
// import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
// import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
// import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
// import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends MusicBeatState
{
	// public static var instance:PlayState = null;
	// public static var commands:Array<String> = [];
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulties:Array<String> = [];
	public static var curDifficulty:Int = 1;

	public static var returnLocation:String = "main";
	public static var returnSong:Int = 0;

	public static var introOnly:Bool = false;
	public static var transIcon:String = "default";
	public static var transColor:FlxColor = FlxColor.BLACK;

	public static var autoPlay:Bool = false;

	private var canHit:Bool = false;
	private var noMissCount:Int = 0;

	public static final stageSongs = ["tutorial", "bopeebo", "fresh", "dadbattle"]; // List isn't really used since stage is default, but whatever.
	public static final spookySongs = ["spookeez", "south", "monster"];
	public static final phillySongs = ["pico", "philly", "blammed"];
	public static final limoSongs = ["satin-panties", "high", "milf"];
	public static final mallSongs = ["cocoa", "eggnog"];
	public static final evilMallSongs = ["winter-horrorland"];
	public static final schoolSongs = ["senpai", "roses"];
	public static final schoolScared = ["roses"];
	public static final evilSchoolSongs = ["thorns"];
	public static final pixelSongs = ["senpai", "roses", "thorns"];

	private var camFocus:String = "";
	private var camTween:FlxTween;
	private var camZoomTween:FlxTween;
	private var uiZoomTween:FlxTween;
	private var camFollow:FlxObject;
	private var autoCam:Bool = true;
	private var autoZoom:Bool = true;
	private var autoUi:Bool = true;

	private var bopSpeed:Int = 1;

	private var sectionHasOppNotes:Bool = false;
	private var sectionHasBFNotes:Bool = false;
	private var sectionHaveNotes:Array<Array<Bool>> = [];

	// private var vocals:FlxSound;
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	// // Wacky input stuff=========================
	// private var skipListener:Bool = false;
	// private var upTime:Int = 0;
	// private var downTime:Int = 0;
	// private var leftTime:Int = 0;
	// private var rightTime:Int = 0;
	// private var upPress:Bool = false;
	// private var downPress:Bool = false;
	// private var leftPress:Bool = false;
	// private var rightPress:Bool = false;
	// private var upRelease:Bool = false;
	// private var downRelease:Bool = false;
	// private var leftRelease:Bool = false;
	// private var rightRelease:Bool = false;
	// private var upHold:Bool = false;
	// private var downHold:Bool = false;
	// private var leftHold:Bool = false;
	// private var rightHold:Bool = false;
	// End of wacky input stuff===================
	private var invuln:Bool = false;
	private var invulnCount:Int = 0;

	private var notes:NotePool;
	private var arrowNotes:FlxTypedGroup<Note>;
	private var sustainNotes:FlxTypedGroup<Note>;
	// private var unspawnNotes:Array<Note> = [];
	var pendingNotes:Array<PendingNote> = [];
	var noteMap:Map<PendingNote, Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	// private static var prevCamFollow:FlxObject;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;
	var confirmGlows:FlxTypedGroup<FlxSprite>;
	var pressGlows:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	// private var healthBar:FlxBar;
	private var healthBarP1:FlxSprite;
	private var healthBarP2:FlxSprite;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	private var camUnderTop:FlxCamera;
	private var camScore:FlxCamera;

	public var camSpellPrompts:FlxCamera;

	private var camTop:FlxCamera;
	private var camNotes:FlxCamera;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camParticles:ParticleCam;
	private var camOverlay:FlxCamera;

	private var comboUI:ComboPopup;

	public static final minCombo:Int = 10;

	private var rsg:FlxSprite = new FlxSprite();

	// var dialogue:Array<String> = [':bf:strange code', ':dad:>:]'];
	/*var bfPos:Array<Array<Float>> = [
										[975.5, 862],
										[975.5, 862],
										[975.5, 862],
										[1235.5, 642],
										[1175.5, 866],
										[1295.5, 866],
										[1189, 1108],
										[1189, 1108]
										];

		var dadPos:Array<Array<Float>> = [
										 [314.5, 867],
										 [346, 849],
										 [326.5, 875],
										 [339.5, 914],
										 [42, 882],
										 [342, 861],
										 [625, 1446],
										 [334, 968]
										 ]; */
	// var halloweenBG:FlxSprite;
	var halloweenBG:FlxSprite;
	var halloweenWindow:FlxSprite;
	var halloweenOutline:FlxSprite;
	var halloweenFloor:FlxSprite;

	var phillyCityLights:FlxSprite;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var bgGirls:BackgroundGirls;

	var skewGrid:FlxSkewedSprite;
	var mtn:FlxSprite;

	// var wiggleShit:WiggleEffect = new WiggleEffect();
	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxTextThing;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var dadBeats:Array<Int> = [0, 2];
	var bfBeats:Array<Int> = [1, 3];

	public static var sectionStart:Bool = false;
	public static var sectionStartPoint:Int = 0;
	public static var sectionStartTime:Float = 0;

	private var meta:SongMetaTags;

	var noteSplash:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var splashTweens:Array<FlxTween> = [null, null, null, null];
	var splashTweens2:Array<FlxTween> = [null, null, null, null];

	var filters:Array<BitmapFilter> = [];
	var filtersGame:Array<BitmapFilter> = [];
	var filterMap:Map<String, BitmapFilter> = [];

	public static var effectiveScrollSpeed:Float;
	public static var effectiveDownScroll:Bool;

	var musicStream:AudioStreamThing;
	// var vocals:AudioThing;
	var dadVoice:AudioStreamThing;
	var bfVoice:AudioStreamThing;
	var voices:FlxTypedGroup<AudioStreamThing> = new FlxTypedGroup<AudioStreamThing>();

	var effectsActive:Map<String, Int> = new Map<String, Int>();

	var effectTimer:FlxTimer = new FlxTimer();

	public static var xWiggle:Array<Float> = [0, 0, 0, 0];
	public static var yWiggle:Array<Float> = [0, 0, 0, 0];

	var xWiggleTween:Array<NumTween> = [null, null, null, null];
	var yWiggleTween:Array<NumTween> = [null, null, null, null];

	var severInputs:Array<Bool> = [false, false, false, false];

	var drainHealth:Bool = false;

	var drunkTween:NumTween = null;

	var lagOn:Bool = false;

	// var addedMP4s:Array<VideoHandlerMP4> = [];
	var flashbangTimer:FlxTimer = new FlxTimer();

	// var errorMessages:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var noiseSound:FlxSound = new FlxSound();

	var camAngle:Float = 0;

	var dmgMultiplier:Float = 1;

	var delayOffset:Float = 0;
	var volumeMultiplier:Float = 1;

	var frozenInput:Int = 0;

	var notePositions:Array<Int> = [0, 1, 2, 3];

	// var blurEffect:MosaicEffect = new MosaicEffect();
	public static var validWords:Array<String>;

	var spellPrompts:Array<SpellPrompt> = [];

	// var shieldSprite:FlxSprite = new FlxSprite();
	var scribbleCount:Int = 0;
	var scribbleScreen:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var poisonScreen:FlxTypedSpriteGroup<FlxSprite>;

	var allFX:Array<Array<Dynamic>> = [];

	var bopSprites:Array<Void->Void> = [];
	// var onDestroy:Array<Void->Void> = [];
	var frontSprites:Array<FlxSprite> = [];

	var waterFilter:Displace;
	var waterFilter2:ShaderFilter;
	var waterSprite:FlxSprite;
	var waterTween1:FlxTween;
	var waterTween2:FlxTween;
	var waterTween3:FlxTween;
	var ghotis:FlxTypedGroup<FlxSprite>;
	var fishBack:FlxTypedGroup<FlxSprite>;
	var fishFront:FlxTypedGroup<FlxSprite>;

	var bfVert:FlxSprite;
	var dadVert:FlxSprite;

	var goodParticle:ParticleThing;
	var coolParticle:ParticleThing;
	var powerupParticle:ParticleThing;
	var outlineShader:OutlineShader;

	var coolnessSprite:FlxSprite;
	var coolnessTween:FlxTween;

	// var originalNoteColors:Map<Int, Array<Array<Float>>> = [];
	var horiBars:FlxTypedGroup<FlxSprite>;
	var horiBarTween1:FlxTween;
	var horiBarTween2:FlxTween;

	public static var overridePlayer1:String = "";
	public static var overridePlayer2:String = "";

	public static var p1WriteDone:Bool = true;
	public static var p2WriteDone:Bool = true;

	public static final useStreamPos:Bool = true;

	override public function create()
	{
		// instance = this;
		FlxG.mouse.visible = false;
		PlayerSettings.gameControls();

		// resetChatData();

		Conductor.playbackSpeed = 1.0;

		if (overridePlayer1 != "")
			SONG.player1 = overridePlayer1;
		if (overridePlayer2 != "")
			SONG.player2 = overridePlayer2;

		if (Config.scrollSpeed > 0)
			SONG.speed = Config.scrollSpeed;

		Note.loadColorz("user", SONG.player2);
		// for (i in 0...4)
		// {
		// 	originalNoteColors[i] = [
		// 		Note.colorzShaders[i].colorBase.value,
		// 		Note.colorzShaders[i].colorOuter.value,
		// 		Note.colorzShaders[i].colorInner.value
		// 	];
		// }

		if (Config.comboParticles)
		{
			if (FileSystem.exists(Paths.json('_particles/' + SONG.player2)))
				goodParticle = ParticleThing.fromJson(SONG.player2);
			else
				goodParticle = ParticleThing.fromJson("dots");
			goodParticle.start();
			goodParticle.stop();

			if (FileSystem.exists(Paths.json('_particles/' + SONG.player2 + "2")))
				coolParticle = ParticleThing.fromJson(SONG.player2 + "2");
			else
				coolParticle = ParticleThing.fromJson("square");
			coolParticle.start();
			coolParticle.stop();

			coolnessSprite = new FlxSprite();
			coolnessSprite.frames = Paths.getSparrowAtlasFunk('combo/coolcombos');
			coolnessSprite.animation.addByPrefix('supercombo', 'supercombo', 0, false);
			coolnessSprite.animation.addByPrefix('ultracombo', 'ultracombo', 0, false);
			coolnessSprite.alpha = 0;
			coolnessSprite.antialiasing = true;
			coolnessSprite.scale.set(0.8, 0.8);

			powerupParticle = ParticleThing.fromJson("powerup");
			powerupParticle.start();
			powerupParticle.stop();
		}

		effectiveScrollSpeed = PlayState.SONG.speed;
		effectiveDownScroll = Config.downscroll;
		notePositions = [0, 1, 2, 3];

		// blurEffect.setStrength(0, 0);

		// FlxG.sound.cache("assets/music/" + SONG.song + "_Inst" + ".ogg");
		// FlxG.sound.cache("assets/music/" + SONG.song + "_Voices" + ".ogg");

		musicStream = new AudioStreamThing(Paths.music(SONG.song + "_Inst"), true);
		// vocals = new AudioThing(Paths.music(SONG.song + "_Voices"));

		add(musicStream);
		// add(vocals);
		add(voices);

		// customTransIn = new ScreenWipeIn(0.25);
		// customTransOut = new ScreenWipeOut(0.25);
		customTransIn = new IconIn(0.5, transIcon, transColor, "png");
		customTransOut = new IconOut(0.5, transIcon, transColor, "png");

		// FlxG.sound.cache(Paths.music(SONG.song + "_Inst"));
		// FlxG.sound.cache(Paths.music(SONG.song + "_Voices"));

		// if (Config.noFpsCap)
		// 	openfl.Lib.current.stage.frameRate = 999;
		// else
		// 	openfl.Lib.current.stage.frameRate = 144;
		Main.fpsSwitch();

		camTween = FlxTween.tween(this, {}, 0);
		camZoomTween = FlxTween.tween(this, {}, 0);
		uiZoomTween = FlxTween.tween(this, {}, 0);

		for (i in 0...SONG.notes.length)
		{
			var array = [false, false];

			array[0] = sectionContainsBfNotes(i);
			array[1] = sectionContainsOppNotes(i);

			sectionHaveNotes.push(array);
		}

		canHit = !(Config.ghostTapType > 0);
		noMissCount = 0;
		invulnCount = 0;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camNotes = new FlxCamera();
		camTop = new FlxCamera();
		camScore = new FlxCamera();
		camUnderTop = new FlxCamera();
		camSpellPrompts = new FlxCamera();
		camParticles = new ParticleCam();
		camHUD.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camTop.bgColor.alpha = 0;
		camScore.bgColor.alpha = 0;
		camUnderTop.bgColor.alpha = 0;
		camSpellPrompts.bgColor.alpha = 0;
		camParticles.bgColor.alpha = 0;

		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camParticles);
		FlxG.cameras.add(camOverlay);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camUnderTop);
		FlxG.cameras.add(camSpellPrompts);
		FlxG.cameras.add(camTop);
		FlxG.cameras.add(camScore);

		FlxCamera.defaultCameras = [camGame];

		// errorMessages.cameras = [camUnderTop];
		// add(errorMessages);

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		var checkifVolumeNull:Null<Float> = SONG.vocalVolume;
		if (checkifVolumeNull == null)
		{
			SONG.vocalVolume = 1.0;
		}

		Conductor.changeBPM(SONG.bpm);
		Conductor.volumeChange(SONG);
		musicStream.volume = Conductor.songVolume;

		// if (Assets.exists(Paths.text(SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue")))
		// {
		// 	try
		// 	{
		// 		dialogue = CoolUtil.coolTextFile(Paths.text(SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue"));
		// 	}
		// 	catch (e)
		// 	{
		// 	}
		// }

		if (FileSystem.exists(Paths.funk("vert/" + SONG.player1 + "/selected"))
			&& FileSystem.exists(Paths.funk("vert/" + SONG.player2 + "/selected")))
		{
			bfVert = new FlxSprite();
			bfVert.frames = Paths.getSparrowAtlasFunk("vert/" + SONG.player1 + "/selected");
			bfVert.animation.addByPrefix("selected", "selected", 0, false);
			bfVert.animation.play("selected");
			bfVert.cameras = [camUnderTop];
			bfVert.flipX = true;
			bfVert.antialiasing = true;
			bfVert.setPosition(0, 720);
			dadVert = new FlxSprite();
			dadVert.frames = Paths.getSparrowAtlasFunk("vert/" + SONG.player2 + "/selected");
			dadVert.animation.addByPrefix("selected", "selected", 0, false);
			dadVert.animation.play("selected");
			dadVert.cameras = [camUnderTop];
			dadVert.antialiasing = true;
			dadVert.setPosition(0, -720);
		}

		var stageCheck:String = 'stage';
		if (SONG.stage == null)
		{
			if (spookySongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'spooky';
			}
			else if (phillySongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'philly';
			}
			else if (limoSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'limo';
			}
			else if (mallSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'mall';
			}
			else if (evilMallSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'mallEvil';
			}
			else if (schoolSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'school';
			}
			else if (evilSchoolSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'schoolEvil';
			}

			SONG.stage = stageCheck;
		}
		else
		{
			stageCheck = SONG.stage;
		}

		switch (stageCheck)
		{
			case "spooky":
				curStage = "spooky";

				// halloweenBG = new FlxSprite(-200, -100);
				// halloweenBG.frames = Paths.getSparrowAtlasATF("spookyStage/halloween_bg");
				// halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				// halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				// halloweenBG.animation.play('idle');
				// halloweenBG.antialiasing = true;
				// add(halloweenBG);

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = Paths.getSparrowAtlasFunk("spookyStage/stuff");
				halloweenBG.animation.addByPrefix("idle", "bg", 0, false);
				halloweenBG.animation.play("idle", true);
				halloweenBG.setGraphicSize(2100, 1000);
				halloweenBG.updateHitbox();
				halloweenBG.active = false;
				add(halloweenBG);

				halloweenWindow = new FlxSprite(-200 + 440, -100 + 164);
				halloweenWindow.frames = Paths.getSparrowAtlasFunk("spookyStage/stuff");
				halloweenWindow.animation.addByPrefix("idle", "windowback", 0, false);
				halloweenWindow.antialiasing = true;
				halloweenWindow.active = false;
				halloweenWindow.animation.play("idle", true);
				add(halloweenWindow);

				halloweenOutline = new FlxSprite(-200, -100);
				halloweenOutline.frames = Paths.getSparrowAtlasFunk("spookyStage/stuff");
				halloweenOutline.animation.addByPrefix("idle", "outline", 0, false);
				halloweenOutline.antialiasing = true;
				halloweenOutline.active = false;
				halloweenOutline.animation.play("idle", true);
				add(halloweenOutline);

				halloweenFloor = new FlxSprite(-200 + 496, -100 + 701);
				halloweenFloor.frames = Paths.getSparrowAtlasFunk("spookyStage/stuff");
				halloweenFloor.animation.addByPrefix("idle", "windowfloor", 0, false);
				halloweenFloor.antialiasing = true;
				halloweenFloor.active = false;
				halloweenFloor.animation.play("idle", true);
				add(halloweenFloor);
			case 'philly':
				curStage = 'philly';

				defaultCamZoom = 0.85;

				var bg:FlxSprite = new FlxSprite(-225, -75).loadGraphic(Paths.getImageFunk('philly/sky2'));
				bg.scrollFactor.set(0, 0);
				bg.antialiasing = true;
				bg.active = false;
				add(bg);

				// var city:FlxSprite = new FlxSprite(0, -52 * Math.abs(FlxG.height / defaultCamZoom - FlxG.height) / 2).loadGraphic(Paths.getImageBC7('philly/city'));
				// city.scrollFactor.set(0.3, 0.3);
				// // city.setGraphicSize(Std.int(city.width * 0.85));
				// // city.updateHitbox();
				// city.x = bg.x;
				// city.antialiasing = true;
				// add(city);
				var city:FlxSprite = new FlxSprite(-175, -1 * Math.abs(FlxG.height / defaultCamZoom - FlxG.height) / 2);
				city.frames = Paths.getSparrowAtlasFunk("philly/stuff");
				city.animation.addByPrefix("idle", "city", 24, false);
				city.scrollFactor.set(0.3, 0.3);
				city.antialiasing = true;
				city.animation.play("idle", true);
				city.active = false;
				add(city);

				// phillyCityLights = new FlxSprite(city.x, city.y).loadGraphic(Paths.getImageBC7('philly/win'));
				// phillyCityLights.antialiasing = true;
				// phillyCityLights.scrollFactor.set(0.3, 0.3);
				// phillyCityLights.color = 0x31a2fd;
				// add(phillyCityLights);
				phillyCityLights = new FlxSprite(city.x, city.y);
				phillyCityLights.frames = Paths.getSparrowAtlasFunk("philly/stuff");
				phillyCityLights.animation.addByPrefix("idle", "win", 24, false);
				phillyCityLights.scrollFactor.set(0.3, 0.3);
				phillyCityLights.antialiasing = true;
				phillyCityLights.active = false;
				phillyCityLights.animation.play("idle", true);
				phillyCityLights.color = 0x31a2fd;
				add(phillyCityLights);

				// var streetBehind:FlxSprite = new FlxSprite(-336, 50).loadGraphic(Paths.getImageATF('philly/behindTrain'));
				// streetBehind.antialiasing = true;
				// add(streetBehind);
				var streetBehind:FlxSprite = new FlxSprite(-336, 50);
				streetBehind.frames = Paths.getSparrowAtlasFunk("philly/stuff");
				streetBehind.animation.addByPrefix("idle", "behindTrain", 24, false);
				streetBehind.antialiasing = true;
				streetBehind.active = false;
				streetBehind.animation.play("idle", true);
				add(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.getImageFunk('philly/train'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				trainSound.volume = 0.4;
				// FlxG.sound.list.add(trainSound);
				add(trainSound);

				// var street:FlxSprite = new FlxSprite(-336, streetBehind.y).loadGraphic(Paths.getImagePNG('philly/street'));
				// add(street);
				var street:FlxSprite = new FlxSprite(-336, streetBehind.y);
				street.frames = Paths.getSparrowAtlasFunk("philly/stuff");
				street.animation.addByPrefix("idle", "street", 24, false);
				street.antialiasing = true;
				street.active = false;
				street.animation.play("idle", true);
				add(street);

			case 'limo':
				curStage = 'limo';
				defaultCamZoom = 0.90;

				var skyBG:FlxSprite = new FlxSprite(-120, -337).loadGraphic(Paths.getImageFunk("limo/limoSunset"));
				skyBG.scrollFactor.set(0.1, 0.1);
				skyBG.antialiasing = true;
				skyBG.active = false;
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlasFunk("limo/stuff");
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				bgLimo.antialiasing = true;
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...4)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					if (i > 0)
						dancer.shader = new HueShader(i * (i % 2 == 0 ? -1 : 1) * 45);
					grpLimoDancers.add(dancer);
				}

				// overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.images("limo/limoOverlay"));
				// overlayShit.alpha = 0.5;
				// add(overlayShit);

				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

				// overlayShit.shader = shaderBullshit;

				limo = new FlxSprite(-120, 550);
				limo.frames = Paths.getSparrowAtlasFunk("limo/limoDrive");
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				// fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.getImageBC7("limo/fastCarLol"));
				fastCar = new FlxSprite(-300, 160);
				fastCar.frames = Paths.getSparrowAtlasFunk("limo/stuff");
				fastCar.animation.addByPrefix('idle', "fastCarLol", 24);
				fastCar.animation.play('idle');
			// add(limo);

			case 'school':
				curStage = 'school';

				// defaultCamZoom = 0.9;

				var bgSky = new FlxSprite();
				bgSky.frames = Paths.getSparrowAtlasFunk("weeb/stuff");
				bgSky.animation.addByPrefix("weebSky", "weebSky", 0, false);
				bgSky.animation.addByPrefix("weebSchool", "weebSchool", 0, false);
				bgSky.animation.addByPrefix("weebStreet", "weebStreet", 0, false);
				bgSky.animation.addByPrefix("treesBack", "treesBack", 0, false);
				bgSky.animation.addByPrefix("weebTrees", "weebTrees", 12);
				bgSky.animation.addByPrefix("petals", "PETALS ALL", 24);
				bgSky.animation.play("weebSky", true);
				bgSky.updateHitbox();
				bgSky.scrollFactor.set(0.1, 0.1);
				bgSky.active = false;
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = bgSky.clone();
				bgSchool.setPosition(repositionShit, 0);
				bgSchool.animation.play("weebSchool", true);
				bgSchool.updateHitbox();
				bgSchool.scrollFactor.set(0.6, 0.90);
				bgSchool.active = false;
				add(bgSchool);

				var bgStreet:FlxSprite = bgSky.clone();
				bgStreet.setPosition(repositionShit);
				bgStreet.animation.play("weebStreet", true);
				bgStreet.updateHitbox();
				bgStreet.scrollFactor.set(0.95, 0.95);
				bgStreet.active = false;
				add(bgStreet);

				var fgTrees:FlxSprite = bgSky.clone();
				fgTrees.setPosition(repositionShit + 170, 130);
				fgTrees.animation.play("treesBack", true);
				fgTrees.updateHitbox();
				fgTrees.scrollFactor.set(0.9, 0.9);
				fgTrees.active = false;
				add(fgTrees);

				var bgTrees:FlxSprite = bgSky.clone();
				bgTrees.setPosition(repositionShit - 430, -1000);
				bgTrees.animation.play('weebTrees');
				bgTrees.updateHitbox();
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = bgSky.clone();
				treeLeaves.setPosition(repositionShit, -40);
				treeLeaves.animation.play('petals');
				treeLeaves.updateHitbox();
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				// if (schoolScared.contains(SONG.song.toLowerCase()))
				// {
				// 	bgGirls.getScared();
				// }

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			case 'lilyStage':
				curStage = 'lilyStage';

				defaultCamZoom = 0.80;

				var bg:FlxSprite = new FlxSprite(-600, -300);
				bg.frames = Paths.getSparrowAtlasFunk("lily/stuff");
				bg.animation.addByPrefix("idle", "stage", 24, false);
				bg.scrollFactor.set(0.7, 0.7);
				bg.antialiasing = true;
				bg.active = false;
				bg.animation.play("idle", true);
				add(bg);

				var roadinner = new FlxSprite();
				roadinner.frames = Paths.getSparrowAtlasFunk("lily/stuff");
				roadinner.animation.addByPrefix("idle", "roadinner", 24, false);
				roadinner.scrollFactor.set(0.8, 0.8);
				roadinner.antialiasing = true;
				roadinner.animation.play("idle", true);
				roadinner.scale.x = 10;
				roadinner.updateHitbox();
				roadinner.setPosition(-600, 274);
				roadinner.active = false;
				add(roadinner);

				var light = new FlxSprite(80, 0);
				light.frames = Paths.getSparrowAtlasFunk("lily/morestuff");
				light.animation.addByPrefix("idle", "light", 24, false);
				light.antialiasing = true;
				light.scrollFactor.set(0.9, 0.9);
				add(light);
				bopSprites.push(function()
				{
					light.animation.play("idle", true);
				});
				light.animation.play("idle", true);

				var light2 = light.clone();
				light2.x += 1053;
				add(light2);
				bopSprites.push(function()
				{
					light2.animation.play("idle", true);
				});
				light2.animation.play("idle", true);

				var lilySoil = new FlxSprite(-200, 400);
				lilySoil.frames = Paths.getSparrowAtlasFunk("lily/morestuff");
				lilySoil.animation.addByPrefix("idle", "soil", 24, false);
				lilySoil.antialiasing = true;
				lilySoil.scrollFactor.set(0.9, 0.9);
				add(lilySoil);
				bopSprites.push(function()
				{
					lilySoil.animation.play("idle", true);
				});
				lilySoil.animation.play("idle", true);

				var roadfront = new FlxSprite(-600, 581);
				roadfront.frames = Paths.getSparrowAtlasFunk("lily/stuff");
				roadfront.animation.addByPrefix("idle", "roadfront", 24, false);
				roadfront.scrollFactor.set(0.9, 0.9);
				roadfront.antialiasing = true;
				roadfront.active = false;
				roadfront.animation.play("idle", true);
				add(roadfront);

				var glasses = new FlxTypedGroup<FlxSprite>();

				var glass = new FlxSprite(0, 0);
				glass.frames = Paths.getSparrowAtlasFunk("lily/morestuff");
				glass.antialiasing = true;
				glass.animation.addByPrefix("1", "glassOne", 24, false);
				glass.animation.addByPrefix("2", "glassTwo", 24, false);
				glass.animation.addByPrefix("3", "glassThree", 24, false);
				glass.animation.addByPrefix("4", "glassFour", 24, false);
				glass.animation.addByPrefix("5", "glassFive", 24, false);
				glass.scrollFactor.set(1, 1);
				glass.animation.play("1");
				glass.setPosition(-670, 850);
				glass.active = false;
				glasses.add(glass);
				for (i in [[2, 608], [3, 1239], [4, 1948], [5, 2521]])
				{
					var moreGlass = glass.clone();
					moreGlass.animation.play(Std.string(i[0]));
					moreGlass.setPosition(-670 + i[1], 850);
					moreGlass.active = false;
					glasses.add(moreGlass);
				}
				// var theTweens:Map<FlxSprite, FlxTween> = [];
				// bopSprites.push(function()
				// {
				// 	glasses.forEachAlive(function(sprite)
				// 	{
				// 		sprite.offset.y = 0;
				// 		if (theTweens[sprite] != null)
				// 		{
				// 			theTweens[sprite].start();
				// 		}
				// 		else
				// 		{
				// 			theTweens[sprite] = FlxTween.tween(sprite, {"offset.y": -25}, Conductor.crochet / 1000 / 2, {type: PINGPONG});
				// 		}
				// 	});
				// });
				// onDestroy.push(function()
				// {
				// 	for (twn in theTweens)
				// 	{
				// 		if (twn != null && twn.active)
				// 		{
				// 			twn.cancel();
				// 			twn.camFollow);
				// 		}
				// 		twn = null;
				// 	}
				// 	theTweens.clear();
				// });

				add(glasses);
			case 'bfStage':
				curStage = 'bfStage';

				defaultCamZoom = 0.75;

				var bg:FlxSprite = new FlxSprite(-500, -200).loadGraphic(Paths.getImageFunk('bfStage/bg2'));
				bg.antialiasing = true;
				bg.active = false;
				bg.scrollFactor.set(0.3, 0.3);
				add(bg);

				var fore:FlxSprite = new FlxSprite(-500, -200).loadGraphic(Paths.getImageFunk('bfStage/fg'));
				fore.antialiasing = true;
				fore.active = false;
				add(fore);
			case 'atlantaStage':
				curStage = 'atlantaStage';

				defaultCamZoom = 0.7;

				var bg:FlxSprite = new FlxSprite(-625, -200).loadGraphic(Paths.getImageFunk('ghoti/bg'));
				bg.antialiasing = true;
				bg.active = false;
				add(bg);
			case 'tankStage':
				curStage = 'tankStage';
				defaultCamZoom = 0.8;

				var sky = new FlxSprite(-400, -400).loadGraphic(Paths.getImageFunk("tank/tankSky"));
				sky.scrollFactor.set();
				sky.antialiasing = true;
				add(sky);

				var clouds = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20));
				clouds.frames = Paths.getSparrowAtlasFunk("tank/stuff");
				clouds.animation.addByPrefix("tankClouds", "tankClouds", 0, false);
				clouds.animation.addByPrefix("tankGround", "tankGround", 0, false);
				clouds.animation.addByPrefix("tankMountains", "tankMountains", 0, false);
				clouds.animation.addByPrefix("tankBuildings", "tankBuildings", 0, false);
				clouds.animation.addByPrefix("tankRuins", "tankRuins", 0, false);
				clouds.animation.addByPrefix("watchtower", "watchtower gradient color", 24, false);
				clouds.animation.addByPrefix("tank3", "fg tankhead 4", 24, false);
				clouds.animation.addByPrefix("tank1", "fg tankhead 5", 24, false);
				clouds.animation.addByPrefix("tank0", "fg tankhead far right", 24, false);
				clouds.animation.addByPrefix("tank2", "foreground man 3", 24, false);
				clouds.animation.addByPrefix("tank4", "fg tankman bobbin 3", 24, false);
				clouds.animation.addByPrefix("tank5", "fg tankhead far right", 24, false, true);
				clouds.animation.play("tankClouds");
				clouds.updateHitbox();
				clouds.scrollFactor.set(0.1, 0.1);
				clouds.velocity.x = FlxG.random.float(5, 15);
				clouds.antialiasing = true;
				add(clouds);

				var mtn = clouds.clone();
				mtn.setPosition(-300, -20);
				mtn.scrollFactor.set(0.2, 0.2);
				mtn.animation.play("tankMountains");
				mtn.updateHitbox();
				mtn.setGraphicSize(Std.int(mtn.width * 1.2));
				mtn.updateHitbox();
				mtn.antialiasing = true;
				add(mtn);

				var bld = clouds.clone();
				bld.setPosition(-200, 0);
				bld.animation.play("tankBuildings");
				bld.updateHitbox();
				bld.scrollFactor.set(0.3, 0.3);
				bld.setGraphicSize(Std.int(bld.width * 1.1));
				bld.updateHitbox();
				bld.antialiasing = true;
				add(bld);

				var ruin = clouds.clone();
				ruin.setPosition(-200, 0);
				ruin.animation.play("tankRuins");
				ruin.updateHitbox();
				ruin.scrollFactor.set(0.35, 0.35);
				ruin.setGraphicSize(Std.int(ruin.width * 1.1));
				ruin.updateHitbox();
				ruin.antialiasing = true;
				add(ruin);

				var smokeL = new FlxSprite(-200, -100);
				smokeL.scrollFactor.set(0.4, 0.4);
				smokeL.frames = Paths.getSparrowAtlasFunk("tank/stuff2");
				smokeL.animation.addByPrefix("SmokeBlurLeft", "SmokeBlurLeft", 24);
				smokeL.animation.play("SmokeBlurLeft");
				smokeL.updateHitbox();
				smokeL.antialiasing = true;
				add(smokeL);

				var smokeR = new FlxSprite(1100, -100);
				smokeR.scrollFactor.set(0.4, 0.4);
				smokeR.frames = Paths.getSparrowAtlasFunk("tank/stuff2");
				smokeR.animation.addByPrefix("SmokeRight", "SmokeRight", 24);
				smokeR.animation.play("SmokeRight");
				smokeR.updateHitbox();
				smokeR.antialiasing = true;
				add(smokeR);

				var twr = clouds.clone();
				twr.setPosition(100, 50);
				twr.animation.play("watchtower");
				twr.scrollFactor.set(0.5, 0.5);
				twr.updateHitbox();
				twr.antialiasing = true;
				add(twr);

				var gnd = clouds.clone();
				gnd.setPosition(-420, -150);
				gnd.animation.play("tankGround");
				gnd.updateHitbox();
				gnd.setGraphicSize(Std.int(ruin.width * 1.15));
				gnd.updateHitbox();
				gnd.antialiasing = true;
				add(gnd);

				var man = clouds.clone();
				man.setPosition(-500, 650);
				man.animation.play("tank0");
				man.scrollFactor.set(1.7, 1.5);
				man.updateHitbox();
				man.antialiasing = true;
				add(man);

				var man2 = clouds.clone();
				man2.setPosition(-300, 875);
				man2.scrollFactor.set(2, 1);
				man2.animation.play("tank1");
				man2.updateHitbox();
				man2.antialiasing = true;
				add(man2);

				var man3 = clouds.clone();
				man3.setPosition(450, 940);
				man3.scrollFactor.set(1.5, 1.5);
				man3.animation.play("tank2");
				man3.updateHitbox();
				man3.antialiasing = true;
				add(man3);

				var man4 = clouds.clone();
				man4.setPosition(1300, 900);
				man4.scrollFactor.set(1.5, 1.5);
				man4.animation.play("tank4");
				man4.updateHitbox();
				man4.antialiasing = true;
				add(man4);

				var man5 = clouds.clone();
				man5.setPosition(1620, 700);
				man5.scrollFactor.set(1.5, 1.5);
				man5.animation.play("tank5");
				man5.updateHitbox();
				man5.antialiasing = true;
				add(man5);

				var man6 = clouds.clone();
				man6.setPosition(1300, 1200);
				man6.scrollFactor.set(3.5, 2.5);
				man6.animation.play("tank3");
				man6.updateHitbox();
				man6.antialiasing = true;
				add(man6);

				bopSprites.push(function()
				{
					twr.animation.play("watchtower");
					man.animation.play("tank0");
					man2.animation.play("tank1");
					man3.animation.play("tank2");
					man4.animation.play("tank4");
					man5.animation.play("tank5");
					man6.animation.play("tank3");
				});

			case 'prismaStage':
				defaultCamZoom = 0.8;
				curStage = 'prismaStage';
				var bg = new FlxSprite().loadGraphic(Paths.getImageFunk("prismaStage/space"));
				bg.antialiasing = true;
				bg.scrollFactor.set();
				bg.screenCenter(XY);
				add(bg);

				var sun = new FlxSprite().loadGraphic(Paths.getImageFunk("prismaStage/sun"));
				sun.setPosition(FlxG.width / 2 - sun.width / 2, -125);
				sun.antialiasing = true;
				sun.scrollFactor.set(0.2, 0.2);
				add(sun);

				mtn = new FlxSprite().loadGraphic(Paths.getImageFunk("prismaStage/mountain"));
				mtn.setPosition(FlxG.width / 2 - mtn.width / 2, 100);
				mtn.antialiasing = true;
				mtn.scrollFactor.set(0.33, 0.33);
				add(mtn);

				skewScale = -0.1;
				skewGrid = new FlxSkewedSprite();
				skewGrid.loadGraphic(Paths.getImageFunk("prismaStage/tile"));
				skewGrid.antialiasing = true;
				skewGrid.setPosition(FlxG.width / 2 - skewGrid.width / 2, 600);
				add(skewGrid);
			case 'prismaStage2':
				defaultCamZoom = 0.8;
				curStage = 'prismaStage';
				var bg = new FlxSprite().loadGraphic(Paths.getImageFunk("prismaStage/space"));
				bg.antialiasing = true;
				bg.scrollFactor.set();
				bg.screenCenter(XY);
				add(bg);

				var sun = new FlxSprite().loadGraphic(Paths.getImageFunk("prismaStage/moon"));
				sun.setPosition(FlxG.width / 2 - sun.width / 2, -175);
				sun.antialiasing = true;
				sun.scrollFactor.set(0.2, 0.2);
				add(sun);

				mtn = new FlxSprite().loadGraphic(Paths.getImageFunk("prismaStage/city"));
				mtn.setPosition(FlxG.width / 2 - mtn.width / 2, -100);
				mtn.antialiasing = true;
				mtn.scrollFactor.set(0.33, 0.33);
				add(mtn);

				skewScale = -0.07;
				skewGrid = new FlxSkewedSprite();
				skewGrid.loadGraphic(Paths.getImageFunk("prismaStage/tile2"));
				skewGrid.antialiasing = true;
				skewGrid.setPosition(FlxG.width / 2 - skewGrid.width / 2, 600);
				add(skewGrid);
			default:
				defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.getImageFunk("stage/stageback2"));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				bg.antialiasing = true;
				add(bg);

				// var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.getImagePNG("stage/stagefront"));
				// stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				// stageFront.updateHitbox();
				// stageFront.antialiasing = true;
				// stageFront.scrollFactor.set(0.9, 0.9);
				// stageFront.active = false;
				// stageFront.antialiasing = true;
				// add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.getImageFunk("stage/stagecurtains"));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
				stageCurtains.antialiasing = true;
				add(stageCurtains);
		}

		switch (SONG.song.toLowerCase())
		{
			case "tutorial":
				autoZoom = false;
				dadBeats = [0, 1, 2, 3];
			case "bopeebo":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "fresh":
				camZooming = false;
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "spookeez":
				dadBeats = [0, 1, 2, 3];
			case "south":
				dadBeats = [0, 1, 2, 3];
			case "monster":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "cocoa":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "thorns":
				dadBeats = [0, 1, 2, 3];
		}

		var player = [SONG.player1, SONG.player2];
		var beats = [bfBeats, dadBeats];
		for (i in 0...player.length)
		{
			switch (player[i])
			{
				case 'spooky':
					beats[i].resize(0);
					beats[i].push(0);
					beats[i].push(1);
					beats[i].push(2);
					beats[i].push(3);
			}
		}

		var gfVersion:String = 'gf';

		// var gfCheck:String = 'gf';

		// if (SONG.gf == null)
		// {
		// 	switch (storyWeek)
		// 	{
		// 		case 4:
		// 			gfCheck = 'gf-car';
		// 		case 5:
		// 			gfCheck = 'gf-christmas';
		// 		case 6:
		// 			gfCheck = 'gf-pixel';
		// 	}

		// 	SONG.gf = gfCheck;
		// }
		// else
		// {
		// 	gfCheck = SONG.gf;
		// }

		// switch (gfCheck)
		// {
		// 	case 'gf':
		// 		gfVersion = 'gf';
		// 	case 'gf-car':
		// 		gfVersion = 'gf-car';
		// 	case 'gf-christmas':
		// 		gfVersion = 'gf-christmas';
		// 	case 'gf-pixel':
		// 		gfVersion = 'gf-pixel';
		// 	case 'nogf':
		// 		gfVersion = 'nogf';
		// }

		if (SONG.player2 == 'gf' || SONG.player2 == 'gfSinger' || introOnly)
			gfVersion = 'nothing';
		else if (SONG.player1 == 'bf' || SONG.player2 == 'bf')
			gfVersion = 'gf';
		else
			gfVersion = 'nogf';

		gf = new Character(400, 130, gfVersion);
		// gf.scrollFactor.set(0.95, 0.95);

		if (introOnly)
			dad = new Character(0, 0, "nothing");
		else
			dad = new Character(100, 100, SONG.player2);

		// var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				// if (isStoryMode)
				// {
				// 	camPos.x += 600;
				// 	camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
				// }

				// case "spooky":
				// 	dad.y += 200;
				// 	camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
				// case "monster":
				// 	dad.y += 100;
				// 	camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
				// case 'monster-christmas':
				// 	dad.y += 130;
				// case 'dad':
				// 	camPos.x += 400;
				// case 'pico':
				// 	camPos.x += 600;
				// 	dad.y += 300;
				// case 'parents-christmas':
				// 	dad.x -= 500;
				// case 'senpai':
				// 	dad.x += 150;
				// 	dad.y += 360;
				// 	camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				// case 'senpai-angry':
				// 	dad.x += 150;
				// 	dad.y += 360;
				// 	camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				// case 'spirit':
				// 	dad.x -= 150;
				// 	dad.y += 100;
				// 	camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				// boyfriend.y -= 220;
				// boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
			// boyfriend.x += 200;

			case 'mallEvil':
			// boyfriend.x += 320;
			// dad.y -= 80;
			case 'school':
			// boyfriend.x += 200;
			// boyfriend.y += 220;
			// gf.x += 180;
			// gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new DeltaTrail(dad, null, 4, 24 / 60, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				// boyfriend.x += 200;
				// boyfriend.y += 220;
				// gf.x += 180;
				// gf.y += 300;
		}

		switch (curStage)
		{
			case 'tankStage':
				posChar(dad, 240, 850);
			case 'prismaStage':
				posChar(dad, 220, 850);
			default:
				posChar(dad, 335, 850);
		}

		switch (curStage)
		{
			case 'limo':
				posChar(boyfriend, 1250, 630);
			case 'tankStage':
				posChar(boyfriend, 895, 850);
			case 'prismaStage':
				posChar(boyfriend, 1090, 850);
			default:
				posChar(boyfriend, 990, 850);
		}

		switch (curStage)
		{
			case 'tankStage':
				posChar(gf, 568, 778);
			case 'prismaStage':
				posChar(gf, 663, 800);
			default:
				posChar(gf, 663, 778);
		}

		add(gf);

		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);
		// add(shieldSprite);

		// if (!pixelSongs.contains(SONG.song.toLowerCase()))
		// {
		// 	comboUI = new ComboPopup(boyfriend.x - 250, boyfriend.y - 75, [Paths.image("ratings"), 403, 163, true], [Paths.image("numbers"), 100, 120, true],
		// 		[Paths.image("comboBreak"), 348, 211, true]);
		// }
		// else
		// {
		// 	comboUI = new ComboPopup(boyfriend.x - 250, boyfriend.y - 75, [Paths.image("weeb/pixelUI/ratings-pixel"), 51, 20, false],
		// 		[Paths.image("weeb/pixelUI/numbers-pixel"), 11, 12, false], [Paths.image("weeb/pixelUI/comboBreak-pixel"), 53, 32, false],
		// 		[daPixelZoom * 0.7, daPixelZoom * 0.8, daPixelZoom * 0.7]);
		// 	comboUI.numberPosition[0] -= 120;
		// }

		// comboUI = new ComboPopup(gf.x + gf.width / 2 - 100, gf.y + gf.height - 400, [Paths.image("ratings"), 403, 163, true],
		// 	[Paths.image("numbers"), 100, 120, true], [Paths.image("comboBreak"), 348, 211, true]);
		comboUI = new ComboPopup(boyfriend.x - 250, boyfriend.y + boyfriend.height / 4, {
			graphic: "combo/ratings",
			width: 403,
			height: 163,
			antialiasing: true
		}, {
			graphic: "combo/numbers",
			width: 100,
			height: 120,
			antialiasing: true
		}, {
			graphic: "combo/comboBreak",
			width: 348,
			height: 211,
			antialiasing: true
		});

		if (Config.comboType == 1)
		{
			comboUI.cameras = [camHUD];
			comboUI.setPosition(0, 0);
			comboUI.scrollFactor.set(0, 0);
			comboUI.setScales([comboUI.ratingScale * 0.8, comboUI.numberScale, comboUI.breakScale * 0.8]);
			comboUI.accelScale = 0.2;
			comboUI.velocityScale = 0.2;

			if (!Config.downscroll)
			{
				comboUI.ratingPosition = [700, 510];
				comboUI.numberPosition = [320, 480];
				comboUI.breakPosition = [690, 465];
			}
			else
			{
				comboUI.ratingPosition = [700, 80];
				comboUI.numberPosition = [320, 100];
				comboUI.breakPosition = [690, 85];
			}

			if (pixelSongs.contains(SONG.song.toLowerCase()))
			{
				comboUI.numberPosition[0] -= 120;
				comboUI.setPosition(160, 60);
			}
		}

		if (Config.comboType < 2)
		{
			add(comboUI);
		}

		// var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		// doof.scrollFactor.set();
		// doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		if (effectiveDownScroll)
		{
			strumLine = new FlxSprite(0, 570).makeGraphic(1, 1);
			strumLine.setGraphicSize(FlxG.width, 10);
			strumLine.updateHitbox();
			strumLine.graphic.bitmap.disposeImage();
		}
		else
		{
			strumLine = new FlxSprite(0, 30).makeGraphic(1, 1);
			strumLine.setGraphicSize(FlxG.width, 10);
			strumLine.updateHitbox();
			strumLine.graphic.bitmap.disposeImage();
		}
		strumLine.scrollFactor.set();

		fishBack = new FlxTypedGroup<FlxSprite>();
		add(fishBack);

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();
		confirmGlows = new FlxTypedGroup<FlxSprite>();
		pressGlows = new FlxTypedGroup<FlxSprite>();
		add(pressGlows);
		add(confirmGlows);

		// startCountdown();

		add(scribbleScreen);

		generateSong(SONG.song);

		for (sprite in frontSprites)
		{
			add(sprite);
		}

		haxe.ds.ArraySort.sort(allFX, (a, b) -> Std.int(a[0] - b[0]));

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(FlxG.width / 2, FlxG.height / 2);

		// if (prevCamFollow != null)
		// {
		// 	camFollow = prevCamFollow;
		// 	prevCamFollow = null;
		// }

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON);

		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		var tmpPoint = camFollow.getPosition();
		FlxG.camera.focusOn(tmpPoint);
		tmpPoint.put();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		var rawSongTitle = SONG.song.replace("_Easy", "").replace("_Hard", "").toLowerCase();

		if (FileSystem.exists(Paths.text(rawSongTitle + "/meta")))
		{
			meta = new SongMetaTags(0, 144, rawSongTitle, camTop);
			meta.cameras = [camTop];
			add(meta);
		}

		healthBarBG = new FlxSprite(0, Config.downscroll ? FlxG.height * 0.075 : FlxG.height * 0.875).loadGraphic(Paths.getImagePNG('healthBar2'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = true;

		// healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
		// 	'health', 0, 2);
		// healthBar.scrollFactor.set();
		// healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar

		healthBarP1 = new FlxSprite().loadGraphic(Paths.getImagePNG("healthBar2Inner"));
		healthBarP1.setPosition(healthBarBG.x
			+ healthBarBG.width / 2
			- healthBarP1.width / 2,
			healthBarBG.y
			+ healthBarBG.height / 2
			- healthBarP1.height / 2);
		healthBarP1.antialiasing = true;

		healthBarP2 = new FlxSprite().loadGraphic(Paths.getImagePNG("healthBar2Inner"));
		healthBarP2.setPosition(healthBarBG.x
			+ healthBarBG.width / 2
			- healthBarP2.width / 2,
			healthBarBG.y
			+ healthBarBG.height / 2
			- healthBarP2.height / 2);
		healthBarP2.antialiasing = true;

		healthBarP1.color = (Main.characterColors[SONG.player1] != null ? Main.characterColors[SONG.player1] : 0xFF66FF33);
		healthBarP2.color = (Main.characterColors[SONG.player2] != null ? Main.characterColors[SONG.player2] : 0xFFFF0000);

		if (healthBarP1.color == healthBarP2.color)
			healthBarP2.color = FlxColor.interpolate(healthBarP2.color, FlxColor.BLACK);

		healthBarP2.clipRect = FlxRect.get(0, 0, healthBarP2.width, healthBarP2.height);

		scoreTxt = new FlxTextThing(healthBarBG.x + healthBarBG.width / 2 - 400, (FlxG.height * 0.9) + 36, 800, "", 21);
		scoreTxt.setFormat(Paths.font("vcr"), 21, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBarBG.y + healthBarBG.height / 2 - (iconP1.height / 2);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBarBG.y + healthBarBG.height / 2 - (iconP2.height / 2);

		add(healthBarP1);
		add(healthBarP2);
		add(healthBarBG);
		add(iconP2);
		add(iconP1);
		add(scoreTxt);
		add(bfVert);
		add(dadVert);
		if (Config.comboParticles)
			add(coolnessSprite);

		strumLineNotes.cameras = [camNotes];
		confirmGlows.cameras = [camNotes];
		pressGlows.cameras = [camNotes];
		scribbleScreen.cameras = [camNotes];
		notes.cameras = [camNotes];
		sustainNotes.cameras = [camNotes];
		arrowNotes.cameras = [camNotes];
		noteSplash.cameras = [camNotes];
		healthBarP1.cameras = [camHUD];
		healthBarP2.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camScore];
		if (Config.comboParticles)
			coolnessSprite.cameras = [camHUD];
		// doof.cameras = [camHUD];

		healthBarP1.visible = false;
		healthBarP2.visible = false;
		healthBarBG.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;
		scoreTxt.visible = false;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		// FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

		var bgDim = new FlxSprite(1280 / -2, 720 / -2).makeGraphic(1, 1, FlxColor.BLACK);
		bgDim.cameras = [camOverlay];
		bgDim.alpha = Config.bgDim / 10;
		bgDim.setGraphicSize(1280 * 2, 720 * 2);
		bgDim.updateHitbox();
		bgDim.graphic.bitmap.disposeImage();
		add(bgDim);

		super.create();

		// if (curStage.startsWith('school'))
		// {
		// 	shieldSprite.loadGraphic("assets/images/weeb/pixelUI/shield.png");
		// 	shieldSprite.alpha = 0.85;
		// 	shieldSprite.setGraphicSize(Std.int(shieldSprite.width * PlayState.daPixelZoom));
		// 	shieldSprite.updateHitbox();
		// 	shieldSprite.antialiasing = false;
		// }
		// else
		// {
		// 	shieldSprite.loadGraphic("assets/images/shield.png");
		// 	shieldSprite.alpha = 0.85;
		// 	shieldSprite.scale.x = shieldSprite.scale.y = 0.8;
		// 	shieldSprite.updateHitbox();
		// }
		// shieldSprite.visible = false;

		if (!introOnly)
		{
			// while (!FileSystem.exists("assets/temp/dad.wav") && !FileSystem.exists("assets/temp/bf.wav"))
			while (!p1WriteDone && !p2WriteDone)
			{
				Sys.sleep(0.01);
			}

			dadVoice = new AudioStreamThing("assets/temp/dad.wav", true);
			bfVoice = new AudioStreamThing("assets/temp/bf.wav", true);

			voices.add(dadVoice);
			voices.add(bfVoice);
		}
		else
		{
			dadVoice = new AudioStreamThing("", false);
			bfVoice = new AudioStreamThing("", false);
			voices.add(dadVoice);
			voices.add(bfVoice);
		}

		if (sectionStart)
		{
			Conductor.songPosition = sectionStartTime;
			musicStream.time = sectionStartTime;
			// vocals.time = sectionStartTime;
			voices.forEach(function(snd)
			{
				snd.time = sectionStartTime;
			});
		}

		if (isStoryMode)
		{
			paused = true;
			inCutscene = true;
			boyfriend.idleEnd();
			dad.idleEnd();
			gf.idleEnd();
			openSubState(new DialogueSubstate(SONG.song.split("_")[0], SONG.player1, introOnly ? endSong : startCountdown));
		}
		else
		{
			startCountdown();
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyShitTap, false, 1);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyShitRelease, false);
	}

	function posChar(char:Character, xPos:Float, yPos:Float)
	{
		// trace(char.curCharacter + " " + char.initWidth + " " + char.initHeight);
		char.x = xPos - char.initWidth / 2 + (char.facing == char.initFacing ? 1 : -1) * char.posOffsets[0] * char.scale.x;
		char.y = yPos - char.initHeight + char.posOffsets[1] * char.scale.y;
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
		if (accuracy >= 100)
		{
			accuracy = 100;
		}
	}

	// function schoolIntro(?dialogueBox:DialogueBox):Void
	// {
	// 	var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
	// 	black.scrollFactor.set();
	// 	add(black);
	// 	var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
	// 	red.scrollFactor.set();
	// 	var senpaiEvil:FlxSprite = new FlxSprite();
	// 	senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
	// 	senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
	// 	senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 5.5));
	// 	senpaiEvil.updateHitbox();
	// 	senpaiEvil.screenCenter();
	// 	// senpaiEvil.x -= 120;
	// 	senpaiEvil.y -= 115;
	// 	if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
	// 	{
	// 		remove(black);
	// 		if (SONG.song.toLowerCase() == 'thorns')
	// 		{
	// 			add(red);
	// 		}
	// 	}
	// 	new FlxTimer().start(0.3, function(tmr:FlxTimer)
	// 	{
	// 		black.alpha -= 0.15;
	// 		if (black.alpha > 0)
	// 		{
	// 			tmr.reset(0.3);
	// 		}
	// 		else
	// 		{
	// 			if (dialogueBox != null)
	// 			{
	// 				inCutscene = true;
	// 				if (SONG.song.toLowerCase() == 'thorns')
	// 				{
	// 					add(senpaiEvil);
	// 					senpaiEvil.alpha = 0;
	// 					new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
	// 					{
	// 						senpaiEvil.alpha += 0.15;
	// 						if (senpaiEvil.alpha < 1)
	// 						{
	// 							swagTimer.reset();
	// 						}
	// 						else
	// 						{
	// 							senpaiEvil.animation.play('idle');
	// 							FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
	// 							{
	// 								remove(senpaiEvil);
	// 								remove(red);
	// 								FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
	// 								{
	// 									add(dialogueBox);
	// 								}, true);
	// 							});
	// 							new FlxTimer().start(3.2, function(deadTime:FlxTimer)
	// 							{
	// 								FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
	// 							});
	// 						}
	// 					});
	// 				}
	// 				else
	// 				{
	// 					add(dialogueBox);
	// 				}
	// 			}
	// 			else
	// 				startCountdown();
	// 			remove(black);
	// 		}
	// 	});
	// }
	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		healthBarP1.visible = true;
		healthBarP2.visible = true;
		healthBarBG.visible = true;
		iconP1.visible = true;
		iconP2.visible = true;
		scoreTxt.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		var altSuffix:String = "";
		var path:String = "";
		var rsgTween:FlxTween = null;

		if (curStage.startsWith('school'))
		{
			path = 'weeb/pixelUI/rsg';
			rsg.frames = Paths.getSparrowAtlasFunk(path);
			altSuffix = '-pixel';
			rsg.scale.x = rsg.scale.y = daPixelZoom * 0.8;
		}
		else
		{
			path = 'rsg';
			rsg.frames = Paths.getSparrowAtlasFunk(path);
			rsg.antialiasing = true;
		}
		rsg.animation.addByPrefix("ready", "ready", 0, false);
		rsg.animation.addByPrefix("set", "set", 0, false);
		rsg.animation.addByPrefix("go", "go", 0, false);
		rsg.active = false;
		rsg.cameras = [camTop];
		rsg.scrollFactor.set();
		rsg.alpha = 0;
		add(rsg);

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (dadBeats.contains((swagCounter % 4)))
				dad.dance();

			gf.dance();

			if (bfBeats.contains((swagCounter % 4)))
				boyfriend.dance();

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					// metaPopup();
					if (bfVert != null && dadVert != null)
					{
						FlxTween.tween(bfVert, {"y": 0}, Conductor.crochet / 1000 * 1.5, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								twn.destroy();
								FlxTween.tween(bfVert, {"y": -720}, Conductor.crochet / 1000 * 1.5, {
									ease: FlxEase.quadIn,
									onComplete: function(twn:FlxTween)
									{
										remove(bfVert);
										bfVert = FlxDestroyUtil.destroy(bfVert);
										Cashew.destroyOne("vert/" + SONG.player1 + "/selected");
										twn.destroy();
									}
								});
							}
						});
						FlxTween.tween(dadVert, {"y": 0}, Conductor.crochet / 1000 * 1.5, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								twn.destroy();
								FlxTween.tween(dadVert, {"y": 720}, Conductor.crochet / 1000 * 1.5, {
									ease: FlxEase.quadIn,
									onComplete: function(twn:FlxTween)
									{
										remove(dadVert);
										dadVert = FlxDestroyUtil.destroy(dadVert);
										Cashew.destroyOne("vert/" + SONG.player2 + "/selected");
										twn.destroy();
									}
								});
							}
						});
						var black = new FlxSprite().loadGraphic(FlxGraphic.fromRectangle(1, 1, FlxColor.BLACK));
						black.setGraphicSize(FlxG.width, FlxG.height);
						black.updateHitbox();
						black.cameras = [camHUD, camNotes];
						black.alpha = 0;
						add(black);
						FlxTween.tween(black, {"alpha": 0.7}, Conductor.crochet / 1000 * 1.5, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								twn.destroy();
								FlxTween.tween(black, {"alpha": 0}, Conductor.crochet / 1000 * 1.5, {
									ease: FlxEase.quadIn,
									onComplete: function(twn:FlxTween)
									{
										twn.destroy();
										remove(black);
										FlxDestroyUtil.destroy(black);
									}
								});
							}
						});
					}
				case 1:
					rsg.animation.play("ready", true);
					rsg.alpha = 1;
					var ready = rsg;

					ready.updateHitbox();

					ready.screenCenter();
					ready.y -= 120;
					rsgTween = FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					rsg.animation.play("set", true);
					rsg.alpha = 1;
					var set = rsg;

					set.updateHitbox();

					set.screenCenter();
					set.y -= 120;
					rsgTween.cancel();
					FlxDestroyUtil.destroy(rsgTween);
					rsgTween = FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					rsg.animation.play("go", true);
					rsg.alpha = 1;
					var go = rsg;
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					go.y -= 120;
					rsgTween.cancel();
					FlxDestroyUtil.destroy(rsgTween);
					rsgTween = FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
					metaPopup();
					rsgTween.cancel();
					rsgTween = FlxDestroyUtil.destroy(rsgTween);
					rsg = FlxDestroyUtil.destroy(rsg);
					Cashew.destroyOne(path);
					tmr.cancel();
					FlxDestroyUtil.destroy(tmr);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	function metaPopup()
	{
		if (meta != null)
		{
			// meta.start();
			meta.visible = true;

			FlxTween.tween(meta, {"x": meta.x + meta.size + (meta.fontSize / 2)}, 1, {
				ease: FlxEase.quintOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(meta, {"x": meta.x - meta.size}, 1, {
						ease: FlxEase.quintIn,
						startDelay: 2,
						onComplete: function(twn:FlxTween)
						{
							meta = FlxDestroyUtil.destroy(meta);
							twn.destroy();
						}
					});
					twn.destroy();
				}
			});
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		// if (sectionStart)
		// {
		// 	Conductor.songPosition = sectionStartTime;
		// 	musicStream.time = sectionStartTime;
		// 	// vocals.time = sectionStartTime;
		// 	voices.forEach(function(snd)
		// 	{
		// 		snd.time = sectionStartTime;
		// 	});
		// }

		if (!paused)
		{
			AudioStreamThing.playGroup();
			musicStream.play();
			bfVoice.play();
			dadVoice.play();
		}

		// FlxG.sound.music.onComplete = endSong;
		// vocals.play();
		// voices.forEach(function(snd)
		// {
		// 	snd.play(true);
		// });

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (!paused)
				resyncVocals();
			FlxDestroyUtil.destroy(tmr);
		});

		effectTimer.start(5, function(timer)
		{
			if (paused)
				return;
			if (startingSong)
				return;
			if (endingSong)
				return;
			// readChatData();
		}, 0);
	}

	// // var dadShort:Array<Int16>;
	// // var bfShort:Array<Int16>;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		// if (SONG.needsVoices)
		// {
		// 	vocals = new FlxSound().loadEmbedded(Paths.music(curSong + "_Voices"));
		// }
		// else
		// 	vocals = new FlxSound();

		// FlxG.sound.list.add(vocals);

		notes = new NotePool();
		// add(notes);
		arrowNotes = new FlxTypedGroup<Note>();
		sustainNotes = new FlxTypedGroup<Note>();
		add(sustainNotes);
		add(arrowNotes);

		for (i in 0...10)
		{
			var pooledNote:Note = new Note();
			pooledNote.kill();
			notes.add(pooledNote);
		}

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		// for (section in noteData)
		for (section in noteData)
		{
			if (sectionStart && daBeats < sectionStartPoint)
			{
				daBeats++;
				continue;
			}

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var daNotePitch:Int = 1;
				var daNotePreset:Int = -1;
				var daNoteVolume:Float = 1.0;
				var daNoteLength:Float = 0;
				var daNoteType:Int = 0;
				if (songNotes[3] != null)
					daNotePitch = songNotes[3];
				if (songNotes[4] != null)
					daNotePreset = songNotes[4];
				if (songNotes[5] != null)
					daNoteVolume = songNotes[5];
				if (songNotes[6] != null)
					daNoteLength = songNotes[6];
				if (songNotes[7] != null)
					daNoteType = songNotes[7];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				if (songNotes[1] < 8)
				{
					var swagNote:PendingNote = new PendingNote(daStrumTime, daNoteData, null, false, songNotes[2], null, daNoteType, gottaHitNote,
						daNotePitch, daNotePreset, daNoteVolume, daNoteLength);
					swagNote.sustainLength = songNotes[2];

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					pendingNotes.push(swagNote);

					for (susNote in 0...Math.round(susLength))
					{
						var oldNote = pendingNotes[pendingNotes.length - 1];
						var sustainNote = new PendingNote(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,
							(Math.floor(susLength) - susNote) * Conductor.stepCrochet, swagNote, 0, gottaHitNote, daNotePitch, daNotePreset, daNoteVolume,
							daNoteLength);

						pendingNotes.push(sustainNote);

						sustainNote.notePreset = swagNote.notePreset;
						sustainNote.notePitch = swagNote.notePitch;
						sustainNote.noteVolume = swagNote.noteVolume;
						sustainNote.sustainLength = (Math.floor(susLength) - susNote) * Conductor.stepCrochet;

						if (susNote == Math.round(susLength) - 1)
						{
							sustainNote.isLeafNote = true;
						}
					}
					preloadNoteFX(daNoteType);
				}
				else
				{
					// trace("FX Note Detected");
					allFX.push([songNotes[0], songNotes[3], songNotes[4], songNotes[5]]);
					preloadFX(Std.string(songNotes[3]));
				}
			}
			daBeats++;
		}
		// playerCounter += 1;

		pendingNotes.sort(sortByShit);

		// if (ghotis != null)
		// 	add(ghotis);

		if (fishFront != null)
			add(fishFront);

		generatedMusic = true;
	}

	// static inline function fade(data:Int16, index:Int, length:Int):Int16
	// {
	// 	if (length < 1000)
	// 		return 0;
	// 	var stop:Int = 440;
	// 	if (index < stop)
	// 	{
	// 		return Std.int((index / stop) * data);
	// 	}
	// 	else if (index > length - stop)
	// 	{
	// 		return Std.int(((length - index) / stop) * data);
	// 	}
	// 	else
	// 	{
	// 		return data;
	// 	}
	// }
	// function append_short(target:Array<Int16>, src:Array<Int16>, index:Int, length:Int)
	// {
	// 	for (i in 0...length)
	// 	{
	// 		if (target[index + i] == 0)
	// 			target[index + i] = fade(src[i], i, length);
	// 		else
	// 			target[index + i] = Std.int((target[index + i] + fade(src[i], i, length)) / Math.sqrt(2));
	// 	}
	// }

	function sortByShit(Obj1:PendingNote, Obj2:PendingNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var useColorz:Bool = false;

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.getImageFunk('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					useColorz = true;
					babyArrow.frames = Paths.getSparrowAtlasFunk('notes/note');
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down pressB', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirmB', 24, false);

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.angle = 180;
						// babyArrow.animation.addByPrefix('static', 'arrowUP');
						// babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
						// babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.angle = 270;
						// babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
						// babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
						// babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
						// babyArrow.animation.addByPrefix('static', 'arrowDOWN');
						// babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
						// babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.angle = 90;
							// babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							// babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							// babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {
				ease: FlxEase.circOut,
				startDelay: 0.5 + (0.2 * i),
				onComplete: function(twn)
				{
					FlxDestroyUtil.destroy(twn);
				}
			});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
				if (autoPlay)
				{
					babyArrow.animation.finishCallback = function(name:String)
					{
						if (name == "confirm")
						{
							babyArrow.animation.play('static', true);
							resetGlows(i);
						}
					}
				}
			}
			else
			{
				enemyStrums.add(babyArrow);
				babyArrow.animation.finishCallback = function(name:String)
				{
					if (name == "confirm")
					{
						babyArrow.animation.play('static', true);
						resetGlows(i + 4);
					}
				}
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);

			if (useColorz)
			{
				var confirmGlow = new FlxSprite();
				confirmGlow.frames = Paths.getSparrowAtlasFunk('notes/note');
				confirmGlow.animation.addByPrefix('glow', 'down confirmA', 24, false);
				confirmGlow.antialiasing = true;
				confirmGlow.scale.set(babyArrow.scale.x, babyArrow.scale.y);
				confirmGlow.angle = babyArrow.angle;
				confirmGlow.updateHitbox();
				confirmGlow.scrollFactor.set();
				confirmGlow.exists = false;
				confirmGlow.ID = (player == 1 ? 0 : 4) + i;
				confirmGlow.setPosition(babyArrow.x, babyArrow.y + 10);
				confirmGlow.shader = Note.colorzShaders[i + (player == 1 ? 0 : 4)];
				confirmGlow.blend = ADD;
				confirmGlows.insert(i, confirmGlow);

				if (player == 1)
				{
					var pressGlow = new FlxSprite();
					pressGlow.frames = Paths.getSparrowAtlasFunk('notes/note');
					pressGlow.animation.addByPrefix('press', 'down pressA', 24, false);
					pressGlow.antialiasing = true;
					pressGlow.scale.set(babyArrow.scale.x, babyArrow.scale.y);
					pressGlow.angle = babyArrow.angle;
					pressGlow.updateHitbox();
					pressGlow.color = FlxColor.fromHSB(Note.colorz[i].hue, Note.colorz[i].saturation * 0.5, Note.colorz[i].brightness * 0.75);
					pressGlow.scrollFactor.set();
					pressGlow.exists = false;
					pressGlow.alpha = 0;
					pressGlow.ID = (player == 1 ? 0 : 4) + i;
					pressGlow.setPosition(babyArrow.x, babyArrow.y);
					// FlxTween.tween(pressGlow, {y: pressGlow.y + 10, alpha: 1}, 1, {
					// 	ease: FlxEase.circOut,
					// 	startDelay: 0.5 + (0.2 * i),
					// 	onComplete: function(twn)
					// 	{
					// 		FlxDestroyUtil.destroy(twn);
					// 	}
					// });
					pressGlows.add(pressGlow);
				}
			}
		}
		if (player == 1 && Config.noteSplash)
		{
			add(noteSplash);
			for (i in 0...4)
			{
				var splash = new FlxSprite();
				if (FileSystem.exists(Paths.image("notes/splash/" + SONG.player1)))
					splash.loadGraphic(Paths.getImagePNG("notes/splash/" + SONG.player1));
				else
					splash.loadGraphic(Paths.getImagePNG("notes/splash/default"));
				if (SONG.player1 != 'senpai')
					splash.antialiasing = true;
				// splash.x = playerStrums.members[i].x + playerStrums.members[i].width / 2 - splash.width / 2;
				// splash.y = playerStrums.members[i].y + playerStrums.members[i].height / 2 - splash.height / 2;
				splash.alpha = 0;
				splash.ID = i;
				// splash.color = switch (i)
				// {
				// 	case 0:
				// 		0xc24b99;
				// 	case 1:
				// 		0x00c6ff;
				// 	case 2:
				// 		0x12fa05;
				// 	case 3:
				// 		0xf9393f;
				// 	default:
				// 		0xffffff;
				// }
				splash.color = Note.colorz[i];
				noteSplash.add(splash);
			}
		}
		if (Config.comboParticles /*&& useColorz*/)
		{
			outlineShader = new OutlineShader(0, 0, 0);
			outlineShader.enabled.value = [false];
			if (!boyfriend.isModel)
				boyfriend.shader = outlineShader;
		}
	}

	var donePreloads:Array<String> = [];

	function preloadFX(effect:String)
	{
		// trace("LOOK AT THIS: " + effect);
		if (donePreloads.contains(effect))
			return;

		switch (effect)
		{
			case 'poison':
				poisonScreen = new FlxTypedSpriteGroup();
				poisonScreen.cameras = [camOverlay];
				var screenQuarter = new FlxSprite();
				screenQuarter.frames = Paths.getSparrowAtlasFunk("overlays/poisonOverlay");
				screenQuarter.animation.addByPrefix("idle", "poison", 24, false);
				screenQuarter.scrollFactor.set();
				screenQuarter.antialiasing = true;
				screenQuarter.animation.play("idle", true);
				screenQuarter.setGraphicSize(640, 360);
				screenQuarter.updateHitbox();
				poisonScreen.add(screenQuarter);
				for (stuff in [[1, 0, 640, 0], [0, 1, 0, 360], [1, 1, 640, 360]])
				{
					var nextQuarter = screenQuarter.clone();
					nextQuarter.flipX = stuff[0] == 1;
					nextQuarter.flipY = stuff[1] == 1;
					nextQuarter.setGraphicSize(640, 360);
					nextQuarter.updateHitbox();
					nextQuarter.setPosition(stuff[2], stuff[3]);
					poisonScreen.add(nextQuarter);
				}
				poisonScreen.visible = false;
				add(poisonScreen);
			case 'spell':
				Paths.getImagePNG("spell");
				var wordList:Array<String> = [];

				if (FileSystem.exists("assets/data/words.txt"))
				{
					var content:String = sys.io.File.getContent("assets/data/words.txt");
					wordList = content.split("\n");
				}

				validWords = [];

				for (word in wordList)
				{
					if (StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.leftBind).toLowerCase())
						|| StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.downBind).toLowerCase())
						|| StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.upBind).toLowerCase())
						|| StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.rightBind).toLowerCase())
						|| StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.killBind).toLowerCase()))
					{
						continue;
					}
					else
					{
						validWords.push(word.toLowerCase());
					}
				}
				if (validWords.length <= 0)
				{
					trace("wtf no valid words");
					validWords = ["iamerror"];
				}
			case 'sever':
				Paths.getSparrowAtlasPNG('explosion2');
			// case 'colorblind':
			// 	var matrix:Array<Float> = [
			// 		0.5, 0.5, 0.5, 0, 0,
			// 		0.5, 0.5, 0.5, 0, 0,
			// 		0.5, 0.5, 0.5, 0, 0,
			// 		  0,   0,   0, 1, 0,
			// 	];
			// 	filterMap.set("Grayscale", new ColorMatrixFilter(matrix));
			// 	enableFilters();
			// case 'blur':
			// 	filterMap.set("BlurLittle", new BlurFilter());
			// 	enableFilters();
			case 'water':
				waterFilter = new Displace(40, 0, 0);
				waterFilter2 = new ShaderFilter(waterFilter);
				filterMap.set("Water", waterFilter2);
				enableFilters();
				waterSprite = FlxGradient.createGradientFlxSprite(1, 1024, [0x60c9f6ff, 0x6517c5ff, 0x7017c5ff]);
				waterSprite.cameras = [camGame];
				waterSprite.antialiasing = true;
				waterSprite.setGraphicSize(Std.int(FlxG.width / defaultCamZoom) * 2, Std.int(FlxG.height / defaultCamZoom) * 2);
				waterSprite.updateHitbox();
				waterSprite.graphic.bitmap.disposeImage();
				waterSprite.setPosition(-FlxG.width / defaultCamZoom, Math.ceil(FlxG.height / defaultCamZoom));
				waterSprite.active = false;
				if (!filters.contains(filterMap.get("Water")))
				{
					filters.push(filterMap.get("Water"));
					filtersGame.push(filterMap.get("Water"));
				}
			case 'fish':
				ghotis = new FlxTypedGroup<FlxSprite>();
				fishFront = new FlxTypedGroup<FlxSprite>();
				var fish = new FlxSprite();
				fish.frames = Paths.getSparrowAtlasFunk("ghoti/ghotis");
				fish.animation.addByPrefix("tuna", "tuna", 7);
				fish.animation.addByPrefix("ray", "ray", 6);
				fish.animation.addByPrefix("herring", "herring", 7);
				fish.animation.addByPrefix("puffer", "puffer", 6);
				fish.animation.addByPrefix("shark", "shark", 5);
				fish.antialiasing = true;
				fish.kill();
				ghotis.add(fish);
				for (i in 0...16)
				{
					var fish2 = fish.clone();
					fish2.kill();
					ghotis.add(fish2);
				}
				// ghotis.cameras = [camNotes];
				fishBack.cameras = fishFront.cameras = [camNotes];
			case 'shadow':
				if (boyfriend.isModel)
					return;
				if (boyfriend.curCharacter != 'senpai')
				{
					boyfriend.shadow = new Character(0, 0, boyfriend.curCharacter, true);
					var clr = Main.characterColors[SONG.player1];
					boyfriend.shadow.shader = new Coolify(clr.redFloat, clr.greenFloat, clr.blueFloat);
					boyfriend.shadow.alpha = 0;
					add(boyfriend.shadow);
				}
				else
				{
					boyfriend.shadow = new Character(0, 0, "spirit", true);
					boyfriend.shadow.alpha = 0.0001;
					add(boyfriend.shadow);
				}
			case 'bars':
				horiBars = new FlxTypedGroup<FlxSprite>();
				add(horiBars);
				horiBars.cameras = [camOverlay];
				for (i in 0...2)
				{
					var bar = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
					bar.setGraphicSize(FlxG.width, Math.ceil(FlxG.height / 2));
					bar.updateHitbox();
					horiBars.add(bar);
				}
				horiBars.members[0].setPosition(0, -horiBars.members[0].height);
				horiBars.members[1].setPosition(0, FlxG.height);
		}
		donePreloads.push(effect);
	}

	function enableFilters()
	{
		camNotes.setFilters(filters);
		camNotes.filtersEnabled = true;

		camGame.setFilters(filtersGame);
		camGame.filtersEnabled = true;
	}

	var doneNotePreloads:Array<Int> = [];

	function preloadNoteFX(noteType:Int)
	{
		if (noteType == 0)
			return;

		// trace("LOOK AT THIS NOTE: " + noteType);

		if (doneNotePreloads.contains(noteType))
			return;

		var prefix:String = "notes/";
		if (curStage.startsWith('school'))
			prefix = "weeb/pixelUI/";
		switch (noteType)
		{
			case 1:
				FlxG.sound.cache(Paths.sound('mine'));
				Paths.getImagePNG(prefix + "minenote");
			case 2:
				FlxG.sound.cache(Paths.sound('gunshot'));
				Paths.getImagePNG(prefix + "warningnote");
			case 3:
				FlxG.sound.cache(Paths.sound('heal'));
				Paths.getImagePNG(prefix + "healnote");
			case 4:
				FlxG.sound.cache(Paths.sound('mine'));
				Paths.getImagePNG(prefix + "fakehealnote");
			case 5:
				FlxG.sound.cache(Paths.sound('freeze'));
				Paths.getImagePNG(prefix + "icenote");
			case 6:
				FlxG.sound.cache(Paths.sound('paper'));
				Paths.getImagePNG(prefix + "scribblenote");
				// scribbleScreen = new FlxTypedGroup<FlxSprite>();
				var overlay:FlxSprite = new FlxSprite();
				overlay.frames = Paths.getSparrowAtlasFunk("overlays/scribbleOverlays");
				overlay.animation.addByPrefix("1", "scribbleOne", 24, false);
				overlay.animation.addByPrefix("2", "scribbleTwo", 24, false);
				overlay.animation.addByPrefix("3", "scribbleThree", 24, false);
				overlay.animation.addByPrefix("4", "scribbleFour", 24, false);
				overlay.animation.addByPrefix("5", "scribbleFive", 24, false);
				overlay.scrollFactor.set();
				overlay.antialiasing = true;
				overlay.animation.play("1", true);
				overlay.alpha = 0;
				scribbleScreen.add(overlay);
				for (i in [2, 3, 4, 5])
				{
					var nextOverlay = overlay.clone();
					nextOverlay.animation.play(Std.string(i), true);
					nextOverlay.alpha = 0;
					scribbleScreen.add(nextOverlay);
				}
		}
		doneNotePreloads.push(noteType);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			// if (musicStream != null)
			// {
			// 	musicStream.pause();
			// 	// vocals.pause();
			// 	voices.forEach(function(snd)
			// 	{
			// 		snd.pause();
			// 	});
			// }
			AudioStreamThing.pauseGroup();

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		PlayerSettings.gameControls();

		if (paused)
		{
			if (musicStream != null && !startingSong)
			{
				resyncVocals();
			}

			AudioStreamThing.playGroup();

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;

			paused = false;

			// resumeMP4s();
			noiseSound.resume();
		}

		setBoyfriendInvuln(1 / 60);

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		trace("NOW RESYNCING");
		// vocals.pause();
		// voices.forEach(function(snd)
		// {
		// 	snd.pause();
		// });
		Conductor.songPosition = musicStream.time + delayOffset;
		// vocals.time = Conductor.songPosition;
		// voices.forEach(function(snd)
		// {
		// 	snd.time = Conductor.songPosition;
		// });
		// // vocals.play();
		// voices.forEach(function(snd)
		// {
		// 	snd.play();
		// });
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override public function update(elapsed:Float)
	{
		#if debug
		if (FlxG.keys.justPressed.Q)
		{
			trace("CONDUCTOR TIME: " + Conductor.songPosition);
			trace("MUSIC TIME: " + musicStream.time + " vs " + " BF TIME: " + bfVoice.time + " vs " + " DAD TIME: " + dadVoice.time);
			trace("MUSIC VOL: " + musicStream.volume + " vs " + " BF VOL: " + bfVoice.volume + " vs " + " DAD VOL: " + dadVoice.volume);
			trace("MUSIC PLAY: "
				+ musicStream.playing
				+ " vs "
				+ " BF PLAY: "
				+ bfVoice.playing
				+ " vs "
				+ " DAD PLAY: "
				+ dadVoice.playing);
			trace("UPDATE RATE: " + FlxG.updateFramerate + " DRAW RATE: " + FlxG.drawFramerate);
		}
		#end
		/*New keyboard input stuff. Disables the listener when using controller because controller uses the other input set thing I did.

			if(skipListener) {keyCheck();}

			if(FlxG.gamepads.anyJustPressed(ANY) && !skipListener) {
				skipListener = true;
				trace("Using controller.");
			}

			if(FlxG.keys.justPressed.ANY && skipListener) {
				skipListener = false;
				trace("Using keyboard.");
			}

			//============================================================= */

		// keyCheck(); // Gonna stick with this for right now. I have the other stuff on standby in case this still is not working for people.

		if (!inCutscene)
			keyShit();

		// if (FlxG.keys.justPressed.NINE)
		// {
		// 	if (iconP1.animation.curAnim.name == 'bf-old')
		// 		iconP1.animation.play(SONG.player1);
		// 	else
		// 		iconP1.animation.play('bf-old');
		// }

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		if (confirmGlows != null)
		{
			confirmGlows.forEach(function(spr)
			{
				var offset = (spr.ID > 3 ? 0 : 4);
				spr.setPosition(strumLineNotes.members[spr.ID % 4 + offset].x, strumLineNotes.members[spr.ID % 4 + offset].y);
				spr.centerOffsets();
				additionalOffset(spr);
				spr.visible = strumLineNotes.members[spr.ID % 4 + offset].visible;
				spr.alpha = strumLineNotes.members[spr.ID % 4 + offset].alpha;
			});
		}
		if (pressGlows != null)
		{
			pressGlows.forEach(function(spr)
			{
				spr.setPosition(playerStrums.members[spr.ID].x, playerStrums.members[spr.ID].y);
				spr.centerOffsets();
				additionalOffset(spr);
				spr.visible = playerStrums.members[spr.ID].visible;
				spr.alpha = playerStrums.members[spr.ID].alpha;
			});
		}
		if (noteSplash != null)
		{
			noteSplash.forEach(function(spr)
			{
				var target = playerStrums.members[spr.ID];
				spr.setPosition(target.x + target.width / 2 - spr.width / 2, target.y + target.height / 2 - spr.height / 2);
				spr.centerOffsets();
				additionalOffset(spr);
				spr.visible = playerStrums.members[spr.ID].visible;
			});
		}

		super.update(elapsed);

		if (!inCutscene && !endingSong && musicStream != null && musicStream.isDone)
		{
			// musicStream.stop();
			// // vocals.stop();
			// voices.forEach(function(snd)
			// {
			// 	snd.stop();
			// });
			AudioStreamThing.pauseGroup();
			if (isStoryMode && !introOnly)
			{
				endSongStory();
			}
			else
				endSong();
		}

		if (allFX.length > 0 && allFX[0][0] <= /*Conductor.songPosition*/ getSongPos())
		{
			doEffect(Std.string(allFX[0][1]), allFX[0][2], allFX[0][3]);
			// trace("FX: " + allFX[0][1] + " TIME: " + allFX[0][0] + " TARGET: " + allFX[0][2] + " VALUE: " + allFX[0][3]);
			allFX.remove(allFX[0]);
		}

		switch (Config.accuracy)
		{
			case "none":
				scoreTxt.text = "Score:" + songScore;
			default:
				scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "%";
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			doPause();
		}

		if (FlxG.keys.justPressed.SEVEN && !isStoryMode)
		{
			PlayerSettings.menuControls();
			// switchState(new ChartingState());
			FlxG.switchState(new ChartingState());
			sectionStart = false;
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);
		}

		// var iconOffset:Int = 26;

		// iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		// iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		iconP1.x = healthBarP1.x + (1 - health / 2.0) * healthBarP1.width;
		iconP2.x = healthBarP1.x + (1 - health / 2.0) * healthBarP1.width - iconP2.width;

		healthBarP2.clipRect.set(0, 0, (1 - health / 2.0) * healthBarP2.frameWidth, healthBarP2.frameHeight);
		healthBarP2.clipRect = healthBarP2.clipRect;

		// Heath Icons
		if (health / 2.0 < 0.2 && iconP1.status != "lose")
		{
			iconP1.lose();
			iconP2.win();
		}
		else if (health / 2.0 > 0.8 && iconP1.status != "win")
		{
			iconP1.win();
			iconP2.lose();
		}
		else if (health / 2.0 <= 0.8 && health / 2.0 >= 0.2 && iconP1.status != "normal")
		{
			iconP1.normal();
			iconP2.normal();
		}

		/* if (FlxG.keys.justPressed.NINE)
			switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT)
		{
			PlayerSettings.menuControls();
			sectionStart = false;
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			if (FlxG.keys.pressed.SHIFT)
			{
				switchState(new AnimationDebug(SONG.player1, true));
			}
			else if (FlxG.keys.pressed.CONTROL)
			{
				switchState(new AnimationDebug(gf.curCharacter));
			}
			else
			{
				switchState(new AnimationDebug(SONG.player2));
			}
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000 * Conductor.playbackSpeed;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * Conductor.playbackSpeed;

			// if (!paused)
			// {
			// 	songTime += FlxG.game.ticks - previousFrameTime;
			// 	previousFrameTime = FlxG.game.ticks;

			// 	// Interpolation type beat
			// 	if (Conductor.lastSongPos != Conductor.songPosition)
			// 	{
			// 		songTime = (songTime + Conductor.songPosition) / 2;
			// 		Conductor.lastSongPos = Conductor.songPosition;
			// 		// Conductor.songPosition += FlxG.elapsed * 1000;
			// 		// trace('MISSED FRAME');
			// 	}
			// }

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFocus != "dad" && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusOpponent();
			}

			if (camFocus != "bf" && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusBF();
			}
		}

		// FlxG.watch.addQuick("totalBeats: ", totalBeats);

		// if (curSong == 'Fresh')
		// {
		// 	switch (totalBeats)
		// 	{
		// 		case 16:
		// 			camZooming = true;
		// 			bopSpeed = 2;
		// 			dadBeats = [0, 2];
		// 			bfBeats = [1, 3];
		// 		case 48:
		// 			bopSpeed = 1;
		// 			dadBeats = [0, 1, 2, 3];
		// 			bfBeats = [0, 1, 2, 3];
		// 		case 80:
		// 			bopSpeed = 2;
		// 			dadBeats = [0, 2];
		// 			bfBeats = [1, 3];
		// 		case 112:
		// 			bopSpeed = 1;
		// 			dadBeats = [0, 1, 2, 3];
		// 			bfBeats = [0, 1, 2, 3];
		// 		case 163:
		// 	}
		// }

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			if (!startingSong && !endingSong)
				health = 0;
			// trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			// trace("User is cheating!");
		}

		if (health <= 0)
		{
			// boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			if (effectTimer != null && effectTimer.active)
				effectTimer.cancel();

			// vocals.pause();
			// voices.forEach(function(snd)
			// {
			// 	snd.pause();
			// });
			// musicStream.pause();
			// pauseMP4s();
			AudioStreamThing.pauseGroup();
			noiseSound.pause();

			PlayerSettings.menuControls();
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			if (Config.comboParticles)
			{
				coolness = 0;
				doParticles();
			}

			openSubState(new GameOverSubstate(boyfriend, camFollow));
			sectionStart = false;
		}

		if (pendingNotes[0] != null)
		{
			while (pendingNotes.length > 0
				&& pendingNotes[0].strumTime - /*Conductor.songPosition*/ getSongPos() < (FlxG.height / camNotes.zoom) / 0.45 / FlxMath.roundDecimal(effectiveScrollSpeed,
					2))
			{
				var pending:PendingNote = pendingNotes[0];
				var prev:Note = (pending.prevNote == null ? null : noteMap[pending.prevNote]);
				var root:Note = (pending.rootNote == null ? null : noteMap[pending.rootNote]);
				var dunceNote:Note = notes.recycle(Note);
				// var dunceNote:Note = new Note();
				dunceNote.setupNote(pending.strumTime, pending.noteData, false, prev, pending.isSustainNote, root, pending.noteType, musicStream,
					pending.mustPress, pending.isLeafNote, pending.sustainLength);
				notes.remove(dunceNote);
				sustainNotes.remove(dunceNote);
				arrowNotes.remove(dunceNote);
				additionalNoteSetup(dunceNote);
				notes.add(dunceNote);
				noteMap[pending] = dunceNote;
				if (dunceNote.isSustainNote)
					sustainNotes.add(dunceNote);
				else
					arrowNotes.add(dunceNote);
				pendingNotes.splice(0, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				// if (daNote.y > FlxG.height / camGame.zoom + 50)
				// {
				// 	daNote.active = false;
				// 	daNote.visible = false;
				// }
				// else
				// {
				// 	daNote.visible = true;
				// 	daNote.active = true;
				// }

				if (daNote.mustPress)
					daNote.x = playerStrums.members[daNote.noteData % 4].x + playerStrums.members[daNote.noteData % 4].width / 2 - daNote.width / 2;
				else
					daNote.x = enemyStrums.members[daNote.noteData % 4].x + enemyStrums.members[daNote.noteData % 4].width / 2 - daNote.width / 2;

				if (!daNote.mustPress && !daNote.wasGoodHit && daNote.strumTime <= /*Conductor.songPosition*/ getSongPos())
				{
					daNote.wasGoodHit = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					// trace("DA ALT THO?: " + SONG.notes[Math.floor(curStep / 16)].altAnim);

					if (dad.canAutoAnim && (!dad.isModel || !daNote.isSustainNote))
					{
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}
					}

					enemyStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
							doConfirmGlow(spr.ID + 4);
							// spr.updateHitbox();
						}
					});

					// if (dad.isModel || !daNote.isSustainNote)
					dad.holdTimer = 0;

					// if (SONG.needsVoices)
					// 	unmuteBF();

					if (!daNote.isSustainNote)
					{
						killNote(daNote);
					}
				}
				else if (autoPlay && daNote.mustPress && !daNote.wasGoodHit && daNote.strumTime <= /*Conductor.songPosition*/ getSongPos())
				{
					if (!daNote.isFakeHeal && !daNote.isMine && !daNote.isFreeze && !daNote.isScribble)
					{
						goodNoteHit(daNote);
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								boyfriend.holdTimer = 0;
								spr.animation.play('confirm', true);
								doConfirmGlow(spr.ID);
								// spr.updateHitbox();
							}
						});
					}
				}

				var shouldMove = false;
				if (!lagOn || (lagOn && curStep % 2 == 0))
					shouldMove = true;

				if (effectiveDownScroll && shouldMove)
				{
					daNote.y = (strumLine.y
						+ (/*Conductor.songPosition*/ getSongPos() - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(effectiveScrollSpeed, 2)));

					if (daNote.isSustainNote)
					{
						daNote.y -= daNote.height;
						daNote.y += 125;

						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect:FlxRect = null;
							if (daNote.clipRect == null)
								swagRect = FlxRect.get();
							else
								swagRect = daNote.clipRect;
							swagRect.set(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
							swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else if (shouldMove)
				{
					daNote.y = (strumLine.y
						- (/*Conductor.songPosition*/ getSongPos() - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(effectiveScrollSpeed, 2)));

					if (daNote.isSustainNote)
					{
						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect:FlxRect = null;
							if (daNote.clipRect == null)
								swagRect = FlxRect.get();
							else
								swagRect = daNote.clipRect;
							swagRect.set(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// MOVE NOTE TRANSPARENCY CODE BECAUSE REASONS
				if (daNote.tooLate)
				{
					if (!daNote.didLatePenalty)
					{
						if (!daNote.ignoreMiss)
						{
							noteMiss(daNote.noteData, (daNote.isAlert ? FlxG.random.float(0.25, 0.5) : 0.04), false, true, daNote.isAlert);
							muteBF();
							daNote.didLatePenalty = true;
							if (!daNote.isGhosting)
								daNote.alpha = 0.3;
						}
					}
				}

				if (effectiveDownScroll ? (daNote.y > strumLine.y + daNote.height + 50) : (daNote.y < strumLine.y - daNote.height - 50))
				{
					if (daNote.tooLate || daNote.wasGoodHit)
					{
						daNote.active = false;
						daNote.visible = false;

						killNote(daNote);
					}
				}
			});

			notes.forEach(function(daNote:Note)
			{
				if (daNote.onStrumTime != null
					&& !daNote.didSpecialStuff
					&& daNote.realStrumTime - /*Conductor.songPosition*/ getSongPos() <= 0)
				{
					daNote.onStrumTime();
					daNote.didSpecialStuff = true;
				}
			});
		}

		enemyStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.animation.curAnim.name)
			{
				case "confirm":
					// spr.updateHitbox();
					spr.centerOffsets();

				default:
					spr.centerOffsets();
			}

			additionalOffset(spr);
		});

		#if debug
		if (FlxG.keys.justPressed.ONE)
		{
			endSongStory();
		}
		#end

		// leftPress = false;
		// leftRelease = false;
		// downPress = false;
		// downRelease = false;
		// upPress = false;
		// upRelease = false;
		// rightPress = false;
		// rightRelease = false;

		if (drainHealth)
		{
			health = Math.max(0.25, health - (FlxG.elapsed * 0.125 * dmgMultiplier));
		}

		for (i in 0...spellPrompts.length)
		{
			if (spellPrompts[i] == null)
			{
				continue;
			}
			else if (spellPrompts[i].ttl <= 0)
			{
				health -= 0.5 * dmgMultiplier;
				FlxG.sound.play('assets/sounds/spellfail' + ".ogg", Conductor.vocalVolume);
				camSpellPrompts.flash(0x75ff0000, 1, null, true);
				spellPrompts[i].kill();
				remove(spellPrompts[i]);
				spellPrompts[i] = FlxDestroyUtil.destroy(spellPrompts[i]);
			}
			else if (!spellPrompts[i].alive)
			{
				remove(spellPrompts[i]);
				spellPrompts[i] = FlxDestroyUtil.destroy(spellPrompts[i]);
			}
		}

		if (halloweenColors)
		{
			halloweenWindow.setColorTransform(1, 1, 1, 1, halloweenRed, halloweenGreen, halloweenBlue);
			halloweenFloor.setColorTransform(1, 1, 1, 1, halloweenRed, halloweenGreen, halloweenBlue);
		}

		if (scribbleScreen != null)
		{
			for (i in 0...scribbleScreen.members.length)
			{
				if (scribbleCount >= (i + 1) && scribbleScreen.members[i].alpha < 1.0)
				{
					if (i == 4)
						scribbleScreen.members[i].alpha = 1;
					else
						scribbleScreen.members[i].alpha = Math.min(scribbleScreen.members[i].alpha + elapsed * 7, 1.0);
				}
				else if (scribbleCount < (i + 1) && scribbleScreen.members[i].alpha > 0)
					scribbleScreen.members[i].alpha = Math.max(scribbleScreen.members[i].alpha - elapsed * 7, 0);
			}
		}

		if (waterSprite != null && waterSprite.active)
		{
			var tmp = waterSprite.getScreenPosition(null, camGame);
			var mid = FlxG.height / 2;
			var midPoint = tmp.y - mid;
			var newShit = midPoint * camGame.zoom;
			var newPoint = Math.max(0, mid + newShit);
			waterLimitTween(newPoint / FlxG.height);
			tmp.put();
		}

		if (skewGrid != null && camFollow != null)
		{
			// var shit = FlxAngle.asDegrees(Math.atan2(camFollow.x - FlxG.width / 2, camFollow.y - FlxG.height / 2));
			// var shit2 = FlxAngle.asDegrees(Math.atan2(camFollow.y - FlxG.height / 2, camFollow.x - FlxG.width / 2));
			// var shit2 = -FlxAngle.asDegrees(Math.atan((camFollow.x - FlxG.width/2) / (camFollow.y - FlxG.height / 2)));
			var xSkew = (camFollow.x - FlxG.width / 2) * skewScale;
			skewGrid.skew.set(xSkew, 0);
			skewGrid.color = FlxColor.fromHSB((getSongPos() * 0.01) % 360, 0.9, 0.9);
		}
		if (mtn != null)
		{
			mtn.color = FlxColor.fromHSB((getSongPos() * 0.01 + 180) % 360, 0.9, 0.9);
		}
		if (boyfriend.shadow != null && boyfriend.shadow.shader != null && boyfriend.shadow.alpha > 0)
		{
			var stuff = cast(boyfriend.shadow.shader, Coolify);
			var rgb = FlxColor.fromHSB((getSongPos() * 0.1 + 180) % 360, FlxMath.bound(Main.characterColors[boyfriend.curCharacter].saturation / 2, 0.2, 1),
				FlxMath.bound(Main.characterColors[boyfriend.curCharacter].brightness * 2, 0.25, 1));
			stuff.colorInside.value = [rgb.redFloat, rgb.greenFloat, rgb.blueFloat];
		}
		if (Config.comboParticles && coolness >= 2 && useColorz)
		{
			var inner = FlxColor.fromHSB((getSongPos() * 0.1) % 360, 1, 1);
			var outer = FlxColor.fromHSB((getSongPos() * 0.1 + 180) % 360, 1, 0.6);
			// for (i in 0...4)
			// {
			// 	Note.colorzShaders[i].colorInner.value = [inner.redFloat, inner.greenFloat, inner.blueFloat];
			// 	Note.colorzShaders[i].colorOuter.value = [outer.redFloat, outer.greenFloat, outer.blueFloat];
			// 	Note.colorzShaders[i].colorBase.value = [1, 1, 1];
			// }
			var outlineColor = FlxColor.fromHSB(inner.hue, 0.8, 0.5);
			outlineShader.thecolor.value = [outlineColor.redFloat, outlineColor.greenFloat, outlineColor.blueFloat];
			healthBarP1.color = FlxColor.fromHSB((getSongPos() * 0.1) % 360, 0.8, 0.9);
		}
	}

	var skewScale:Float = -0.1;

	function doConfirmGlow(index:Int)
	{
		if (!useColorz)
			return;
		if (confirmGlows.members[index] == null)
			return;
		confirmGlows.members[index].exists = true;
		confirmGlows.members[index].animation.play('glow');
	}

	function doPressGlow(index:Int)
	{
		if (!useColorz)
			return;
		if (confirmGlows.members[index] == null)
			return;
		pressGlows.members[index].exists = true;
		pressGlows.members[index].animation.play('press');
	}

	function resetGlows(index:Int)
	{
		if (!useColorz)
			return;
		if (confirmGlows.members[index] != null)
			confirmGlows.members[index].exists = false;
		if (pressGlows.members[index] != null)
			pressGlows.members[index].exists = false;
	}

	function additionalNoteSetup(note:Note)
	{
		if (note.isAlert)
		{
			note.onStrumTime = function()
			{
				FlxG.sound.play(Paths.sound('gunshot'));
				dad.playAnim("attack", true);
				dad.canAutoIdle = false;
			};
		}
		for (effect in effectsActive.keys())
		{
			if (effectsActive[effect] <= 0)
				continue;
			switch (effect)
			{
				case 'spin':
					spinNote(note, true);
				case 'ghost':
					ghostNote(note, true);
			}
		}
	}

	function spinNote(note:Note, enable:Bool)
	{
		if (note == null)
			return;
		if (enable)
		{
			if (!note.isSustainNote)
				note.spinAmount = (FlxG.random.bool() ? 1 : -1) * FlxG.random.float(333 * 0.8, 333 * 1.15);
		}
		else
		{
			if (!note.isSustainNote)
			{
				note.spinAmount = 0;
				note.updateAngle();
			}
		}
	}

	function ghostNote(note:Note, enable:Bool)
	{
		if (note == null)
			return;
		if (enable)
		{
			if (!note.isSustainNote)
				note.doGhost();
			else if (note.isSustainNote)
				note.doGhost(note.rootNote.ghostSpeed, note.rootNote.ghostSine);
		}
		else
		{
			note.undoGhost();
		}
	}

	function doEffect(effect:String, target:Float, value:Float)
	{
		if (paused)
			return;
		if (endingSong)
			return;
		if (inCutscene)
			return;

		var ttl:Float = 0;
		var onEnd:(Void->Void) = null;
		var alwaysEnd:Bool = false;
		var playSound:String = "";
		var playSoundVol:Float = 1;
		var noIcon:Bool = false;
		var unEffect:Bool = false;
		// trace(effect);
		switch (effect)
		{
			case 'lag':
				lagOn = true;
				playSound = "lag";
				playSoundVol = 0.7;
				ttl = 12;
				onEnd = function()
				{
					lagOn = false;
				}
			case 'spin':
				if (value > 0)
				{
					for (daNote in notes)
					{
						spinNote(daNote, true);
					}
				}
				else
				{
					for (daNote in notes)
					{
						spinNote(daNote, false);
					}
					noIcon = true;
					unEffect = true;
				}
			case 'songslower':
				var desiredChangeAmount:Float = FlxG.random.float(0.1, 0.3);
				var changeAmount = Conductor.playbackSpeed - Math.max(Conductor.playbackSpeed - desiredChangeAmount, 0.2);
				Conductor.playbackSpeed = Conductor.playbackSpeed - changeAmount;
				AudioStreamThing.pauseGroup();
				musicStream.speed = Conductor.playbackSpeed;
				voices.forEach(function(snd)
				{
					snd.speed = Conductor.playbackSpeed;
				});
				AudioStreamThing.playGroup();
				playSound = "songslower";
				ttl = 15;
				alwaysEnd = true;
				onEnd = function()
				{
					Conductor.playbackSpeed = Conductor.playbackSpeed + changeAmount;
					AudioStreamThing.pauseGroup();
					musicStream.speed = Conductor.playbackSpeed;
					voices.forEach(function(snd)
					{
						snd.speed = Conductor.playbackSpeed;
					});
					AudioStreamThing.playGroup();
				};
			case 'songfaster':
				var changeAmount:Float = FlxG.random.float(0.1, 0.3);
				Conductor.playbackSpeed = Conductor.playbackSpeed + changeAmount;
				AudioStreamThing.pauseGroup();
				musicStream.speed = Conductor.playbackSpeed;
				voices.forEach(function(snd)
				{
					snd.speed = Conductor.playbackSpeed;
				});
				AudioStreamThing.playGroup();
				playSound = "songfaster";
				ttl = 15;
				alwaysEnd = true;
				onEnd = function()
				{
					Conductor.playbackSpeed = Conductor.playbackSpeed - changeAmount;
					AudioStreamThing.pauseGroup();
					musicStream.speed = Conductor.playbackSpeed;
					voices.forEach(function(snd)
					{
						snd.speed = Conductor.playbackSpeed;
					});
					AudioStreamThing.playGroup();
				};
			case 'scrollswitch':
				effectiveDownScroll = !effectiveDownScroll;
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					daNote.updateFlip();
				}
				playSound = "scrollswitch";
				updateScrollUI();
			case 'scrollfaster':
				var changeAmount:Float = FlxG.random.float(0.4, 0.6);
				effectiveScrollSpeed += changeAmount;
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					daNote.updateScale();
				}
				playSound = "scrollfaster";
				ttl = 20;
				alwaysEnd = true;
				onEnd = function()
				{
					effectiveScrollSpeed -= changeAmount;
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						daNote.updateScale();
					}
				}
			case 'scrollslower':
				var desiredChangeAmount:Float = FlxG.random.float(0.4, 0.6);
				var changeAmount = effectiveScrollSpeed - Math.max(effectiveScrollSpeed - desiredChangeAmount, 0.2);
				effectiveScrollSpeed -= changeAmount;
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					daNote.updateScale();
				}
				playSound = "scrollslower";
				ttl = 20;
				alwaysEnd = true;
				onEnd = function()
				{
					effectiveScrollSpeed += changeAmount;
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						daNote.updateScale();
					}
				}

			case 'mixup':
				mixUp();
				playSound = "mixup";
				ttl = 7;
				onEnd = function()
				{
					mixUp(true);
				}
			case 'ghost':
				if (value >= 1)
				{
					for (daNote in notes)
					{
						ghostNote(daNote, true);
					}
					// playSound = "ghost";
					// playSoundVol = 0.5;
				}
				else
				{
					for (daNote in notes)
					{
						ghostNote(daNote, false);
					}
					noIcon = true;
					unEffect = true;
				};
			case 'wiggle':
				for (i in [xWiggleTween, yWiggleTween])
				{
					for (j in i)
					{
						if (j != null && j.active)
						{
							j.cancel();
							j.destroy();
						}
					}
				}

				if (value >= 1)
				{
					xWiggle = [0, 0, 0, 0];
					yWiggle = [0, 0, 0, 0];
					var xFrom:Array<Float> = [0, 0, 0, 0];
					var xTo:Array<Float> = [0, 0, 0, 0];
					var yFrom:Array<Float> = [0, 0, 0, 0];
					var yTo:Array<Float> = [0, 0, 0, 0];
					var xTime:Array<Float> = [0, 0, 0, 0];
					var yTime:Array<Float> = [0, 0, 0, 0];
					var disableX = false;
					var disableY = false;
					var selector:Int = Std.int(target);
					if (target >= 7)
						selector = FlxG.random.int(0, 6);
					switch (selector)
					{
						case 0:
							var ranTime = FlxG.random.float(0.3, 0.9);
							var ranMove = FlxG.random.float(25, 50);
							for (i in 0...xFrom.length)
								xFrom[i] = -ranMove;
							for (i in 0...xTo.length)
								xTo[i] = ranMove;
							for (i in 0...xTime.length)
								xTime[i] = ranTime;
							disableY = true;
						case 1:
							var ranTime = FlxG.random.float(0.3, 0.9);
							var ranMove = FlxG.random.float(25, 50);
							for (i in 0...yFrom.length)
								yFrom[i] = -ranMove;
							for (i in 0...yTo.length)
								yTo[i] = ranMove;
							for (i in 0...yTime.length)
								yTime[i] = ranTime;
							disableX = true;
						case 2:
							var ranTime = FlxG.random.float(0.3, 0.9);
							var ranMove = FlxG.random.float(25, 50);
							for (i in 0...xFrom.length)
								xFrom[i] = -ranMove;
							for (i in 0...xTo.length)
								xTo[i] = ranMove;
							for (i in 0...xTime.length)
								xTime[i] = ranTime;
							for (i in 0...yFrom.length)
								yFrom[i] = -ranMove * (i % 2 == 0 ? 1 : -1);
							for (i in 0...yTo.length)
								yTo[i] = ranMove * (i % 2 == 0 ? 1 : -1);
							for (i in 0...yTime.length)
								yTime[i] = ranTime;
						case 3:
							var ranTime = FlxG.random.float(0.3, 0.9);
							var ranMove = FlxG.random.float(25, 50);
							for (i in 0...xFrom.length)
								xFrom[i] = -ranMove * (i % 2 == 0 ? -1 : 1);
							for (i in 0...xTo.length)
								xTo[i] = ranMove * (i % 2 == 0 ? -1 : 1);
							for (i in 0...xTime.length)
								xTime[i] = ranTime;
							for (i in 0...yFrom.length)
								yFrom[i] = -ranMove;
							for (i in 0...yTo.length)
								yTo[i] = ranMove;
							for (i in 0...yTime.length)
								yTime[i] = ranTime;
						case 4:
							var ranTime = FlxG.random.float(0.3, 0.9);
							var ranMove = FlxG.random.float(25, 50);
							for (i in 0...xFrom.length)
								xFrom[i] = -ranMove * (i % 2 == 0 ? -1 : 1);
							for (i in 0...xTo.length)
								xTo[i] = ranMove * (i % 2 == 0 ? -1 : 1);
							for (i in 0...xTime.length)
								xTime[i] = ranTime;
							for (i in 0...yFrom.length)
								yFrom[i] = -ranMove * (i % 2 == 0 ? 1 : -1);
							for (i in 0...yTo.length)
								yTo[i] = ranMove * (i % 2 == 0 ? 1 : -1);
							for (i in 0...yTime.length)
								yTime[i] = ranTime;
						case 5:
							var ranTime = FlxG.random.float(0.3, 0.9);
							var ranMoveX = FlxG.random.float(25, 50);
							var ranMoveY = FlxG.random.float(25, 50);
							for (i in 0...xFrom.length)
								xFrom[i] = -ranMoveX * (i % 2 == 0 ? -1 : 1);
							for (i in 0...xTo.length)
								xTo[i] = ranMoveX * (i % 2 == 0 ? -1 : 1);
							for (i in 0...xTime.length)
								xTime[i] = ranTime;
							for (i in 0...yFrom.length)
								yFrom[i] = -ranMoveY;
							for (i in 0...yTo.length)
								yTo[i] = ranMoveY;
							for (i in 0...yTime.length)
								yTime[i] = ranTime;
						case 6:
							var ranTime = FlxG.random.float(0.3, 0.9);
							for (i in 0...xFrom.length)
								xFrom[i] = -FlxG.random.float(25, 50) * (i % 2 == 0 ? -1 : 1);
							for (i in 0...xTo.length)
								xTo[i] = FlxG.random.float(25, 50) * (i % 2 == 0 ? -1 : 1);
							for (i in 0...xTime.length)
								xTime[i] = ranTime;
							for (i in 0...yFrom.length)
								yFrom[i] = -FlxG.random.float(25, 50) * (i % 2 == 0 ? 1 : -1);
							for (i in 0...yTo.length)
								yTo[i] = FlxG.random.float(25, 50) * (i % 2 == 0 ? 1 : -1);
							for (i in 0...yTime.length)
								yTime[i] = ranTime;
							// case 7:
							// 	var ranTime = FlxG.random.float(0.3, 0.9);
							// 	for (i in 0...xFrom.length)
							// 		xFrom[i] = FlxG.random.float(25, 50) * (FlxG.random.bool() ? 1 : -1);
							// 	for (i in 0...xTo.length)
							// 		xTo[i] = FlxG.random.float(25, 50) * (FlxG.random.bool() ? 1 : -1);
							// 	for (i in 0...xTime.length)
							// 		xTime[i] = ranTime;
							// 	for (i in 0...yFrom.length)
							// 		yFrom[i] = -FlxG.random.float(25, 50) * (FlxG.random.bool() ? 1 : -1);
							// 	for (i in 0...yTo.length)
							// 		yTo[i] = FlxG.random.float(25, 50) * (FlxG.random.bool() ? 1 : -1);
							// 	for (i in 0...yTime.length)
							// 		yTime[i] = ranTime;
					}

					for (i in 0...xWiggleTween.length)
					{
						if (!disableX)
						{
							xWiggleTween[i] = FlxTween.num(xFrom[i], xTo[i], xTime[i], {
								onUpdate: function(tween)
								{
									xWiggle[i] = cast(tween, NumTween).value;
								},
								type: PINGPONG
							});
						}
						if (!disableY)
						{
							yWiggleTween[i] = FlxTween.num(yFrom[i], yTo[i], yTime[i], {
								onUpdate: function(tween)
								{
									yWiggle[i] = cast(tween, NumTween).value;
								},
								type: PINGPONG
							});
						}
					}
				}
				else
				{
					for (i in 0...xWiggleTween.length)
					{
						xWiggleTween[i] = FlxTween.num(xWiggle[i], 0, 0.3, {
							onUpdate: function(tween)
							{
								xWiggle[i] = cast(tween, NumTween).value;
							}
						});

						yWiggleTween[i] = FlxTween.num(yWiggle[i], 0, 0.3, {
							onUpdate: function(tween)
							{
								yWiggle[i] = cast(tween, NumTween).value;
							}
						});
					}

					unEffect = true;
					noIcon = true;
				}
			case 'flashbang':
				playSound = "bang";
				if (flashbangTimer != null && flashbangTimer.active)
					flashbangTimer.cancel();
				var whiteScreen:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
				whiteScreen.scrollFactor.set();
				whiteScreen.cameras = [camUnderTop];
				whiteScreen.setGraphicSize(FlxG.width, FlxG.height);
				whiteScreen.updateHitbox();
				add(whiteScreen);
				flashbangTimer.start(0.4, function(timer)
				{
					camUnderTop.flash(FlxColor.WHITE, 7, null, true);
					remove(whiteScreen);
					FlxG.sound.play('assets/sounds/ringing' + ".ogg", 0.4);
				});

			case 'nostrum':
				playerStrums.forEach(function(sprite)
				{
					sprite.visible = false;
				});
				playSound = "nostrum";
				ttl = 13;
				onEnd = function()
				{
					playerStrums.forEach(function(sprite)
					{
						sprite.visible = true;
					});
				}
			// case 'jackspam':
			// 	var startingPoint = FlxG.random.int(5, 9);
			// 	var endingPoint = FlxG.random.int(startingPoint + 6, startingPoint + 12);
			// 	var dataPicked = FlxG.random.int(0, 3);
			// 	for (i in startingPoint...endingPoint)
			// 	{
			// 		addNote(0, i, i, dataPicked);
			// 	}
			// case 'spam':
			// 	var startingPoint = FlxG.random.int(5, 9);
			// 	var endingPoint = FlxG.random.int(startingPoint + 5, startingPoint + 10);
			// 	for (i in startingPoint...endingPoint)
			// 	{
			// 		addNote(0, i, i);
			// 	}
			case 'sever':
				var chooseFrom:Array<Int> = [];
				for (i in 0...severInputs.length)
				{
					if (!severInputs[i])
						chooseFrom.push(i);
				}

				var picked:Int = 0;
				if (chooseFrom.length <= 0)
					picked = FlxG.random.int(0, 3);
				else
					picked = chooseFrom[FlxG.random.int(0, chooseFrom.length - 1)];
				playerStrums.members[picked].alpha = 0;
				severInputs[picked] = true;

				var okayden:Array<Int> = [];
				for (i in 0...64)
				{
					okayden.push(i);
				}
				var explosion = new FlxSprite();
				explosion.frames = Paths.getSparrowAtlasPNG('explosion2');
				explosion.animation.addByPrefix('boom', 'tile', 24, false);
				explosion.animation.finishCallback = function(name)
				{
					explosion.visible = false;
					explosion.kill();
					remove(explosion);
					FlxDestroyUtil.destroy(explosion);
				};
				explosion.cameras = [camHUD];
				explosion.x = playerStrums.members[picked].x + playerStrums.members[picked].width / 2 - explosion.width / 2;
				explosion.y = playerStrums.members[picked].y + playerStrums.members[picked].height / 2 - explosion.height / 2;
				explosion.animation.play("boom", true);
				add(explosion);

				playSound = "sever";
				ttl = 6;
				alwaysEnd = true;
				onEnd = function()
				{
					playerStrums.members[picked].alpha = 1;
					severInputs[picked] = false;
				}
			case 'shake':
				playSound = "shake";
				playSoundVol = 0.5;
				camHUD.shake(FlxG.random.float(0.03, 0.06), 9, null, true);
				camNotes.shake(FlxG.random.float(0.03, 0.06), 9, null, true);
			// case 'poison':
			// 	drainHealth = true;
			// 	playSound = "poison";
			// 	playSoundVol = 0.6;
			// 	ttl = 5;
			// 	// boyfriend.color = 0xf003fc;
			// 	poisonScreen.visible = true;
			// 	onEnd = function()
			// 	{
			// 		drainHealth = false;
			// 		// boyfriend.color = 0xffffff;
			// 		poisonScreen.visible = false;
			// 	}
			case 'poison':
				if (value >= 1)
				{
					drainHealth = true;
					// playSound = "poison";
					playSoundVol = 0.6;
					poisonScreen.visible = true;
				}
				else
				{
					drainHealth = false;
					poisonScreen.visible = false;
					noIcon = true;
				}
			case 'dizzy':
				if (effectsActive[effect] == null || effectsActive[effect] <= 0)
				{
					if (drunkTween != null && drunkTween.active)
					{
						drunkTween.cancel();
						FlxDestroyUtil.destroy(drunkTween);
					}
					drunkTween = FlxTween.num(0, 24, FlxG.random.float(1.2, 1.4), {
						onUpdate: function(tween)
						{
							camNotes.angle = (tween.executions % 4 > 1 ? 1 : -1) * cast(tween, NumTween).value + camAngle;
							camHUD.angle = (tween.executions % 4 > 1 ? 1 : -1) * cast(tween, NumTween).value + camAngle;
							camGame.angle = (tween.executions % 4 > 1 ? -1 : 1) * cast(tween, NumTween).value / 2 + camAngle;
						},
						type: PINGPONG
					});
				}

				playSound = "dizzy";
				ttl = 8;
				onEnd = function()
				{
					if (drunkTween != null && drunkTween.active)
					{
						drunkTween.cancel();
						FlxDestroyUtil.destroy(drunkTween);
					}
					camNotes.angle = camAngle;
					camHUD.angle = camAngle;
					camGame.angle = camAngle;
				}
			case 'noise':
				var noisysound:String = "";
				var noisysoundVol:Float = 1.0;
				switch (FlxG.random.int(0, 9))
				{
					case 0:
						noisysound = "dialup";
						noisysoundVol = 0.5;
					case 1:
						noisysound = "crowd";
						noisysoundVol = 0.3;
					case 2:
						noisysound = "airhorn";
						noisysoundVol = 0.6;
					case 3:
						noisysound = "copter";
						noisysoundVol = 0.5;
					case 4:
						noisysound = "magicmissile";
						noisysoundVol = 0.9;
					case 5:
						noisysound = "ping";
						noisysoundVol = 1.0;
					case 6:
						noisysound = "call";
						noisysoundVol = 1.0;
					case 7:
						noisysound = "knock";
						noisysoundVol = 1.0;
					case 8:
						noisysound = "fuse";
						noisysoundVol = 0.7;
					case 9:
						noisysound = "hallway";
						noisysoundVol = 0.9;
				}
				noiseSound.stop();
				noiseSound.loadEmbedded('assets/sounds/' + noisysound + ".ogg");
				noiseSound.volume = noisysoundVol;
				noiseSound.play(true);

			case 'flip':
				playSound = "flip";
				ttl = 5;
				camAngle = 180;
				camNotes.angle = camAngle;
				camHUD.angle = camAngle;
				camGame.angle = camAngle;
				onEnd = function()
				{
					camAngle = 0;
					camNotes.angle = camAngle;
					camHUD.angle = camAngle;
					camGame.angle = camAngle;
				}

			case 'spell':
				var spellThing = new SpellPrompt(this);
				spellPrompts.push(spellThing);
				playSound = "spell";
				playSoundVol = Conductor.vocalVolume;
				noIcon = true;

			case 'beatzoom':
				uiBop(target / 100, value / 100);

			case 'water':
				if (!filters.contains(filterMap.get("Water")))
				{
					filters.push(filterMap.get("Water"));
					filtersGame.push(filterMap.get("Water"));
				}

				for (tweenThing in [waterTween1, waterTween2, waterTween3])
				{
					if (tweenThing != null && tweenThing.active)
					{
						tweenThing.cancel();
						FlxDestroyUtil.destroy(tweenThing);
					}
				}

				waterSprite.active = true;

				waterTween1 = FlxTween.num(2, 4, 2, {type: PINGPONG, ease: FlxEase.elasticInOut}, waterIntensityTween);
				waterTween2 = FlxTween.num(0, Math.PI, 1, {type: LOOPING}, waterTimeTween);
				waterTween3 = FlxTween.tween(waterSprite, {"y": value}, target, {
					// onUpdate: function(_)
					// {
					// 	var tmp = waterSprite.getScreenBounds();
					// 	waterLimitTween(tmp.y / FlxG.height);
					// 	tmp.put();
					// },
					onComplete: function(tween)
					{
						if (waterSprite.y >= FlxG.height)
						{
							// filters.remove(filterMap.get("Water"));
							// filtersGame.remove(filterMap.get("Water"));
							remove(waterSprite);
							waterSprite.active = false;
							waterTween1.cancel();
							waterTween1 = FlxDestroyUtil.destroy(waterTween1);
							waterTween2.cancel();
							waterTween2 = FlxDestroyUtil.destroy(waterTween2);
						}
						waterTween3 = FlxDestroyUtil.destroy(waterTween3);
					}
				});
				add(waterSprite);

			case 'fish':
				var cloneFactory = function()
				{
					var sprite = ghotis.members[0].clone();
					return sprite;
				};
				var fish = ghotis.recycle(FlxSprite, cloneFactory);
				var speed:Float = 8;
				if (target != -1)
				{
					switch (FlxG.random.int(0, 3))
					{
						case 0:
							fish.animation.play("tuna");
						case 1:
							fish.animation.play("ray");
						case 2:
							fish.animation.play("herring");
						case 3:
							fish.animation.play("puffer");
					}
					fish.scale.x = fish.scale.y = switch (target)
					{
						case 0:
							FlxG.random.float(0.4, 0.7);
						case 1:
							FlxG.random.float(0.5, 0.8);
						case 2:
							FlxG.random.float(0.6, 1);
						case 3:
							FlxG.random.float(0.75, 1);
						default:
							1.0;
					}
					speed = switch (target)
					{
						case 0:
							FlxG.random.float(6, 10);
						case 1:
							FlxG.random.float(8, 12);
						case 2:
							FlxG.random.float(10, 14);
						case 3:
							FlxG.random.float(11, 15);
						default:
							FlxG.random.float(6, 14);
					}
				}
				else
				{
					fish.animation.play("shark");
					fish.scale.x = fish.scale.y = 1.0;
					fish.updateHitbox();
					speed = FlxG.random.float(5, 8);
				}
				fish.updateHitbox();
				var startLeft = FlxG.random.bool();
				var yStart = FlxG.random.float(value, FlxG.height - fish.height);
				var yEnd = FlxG.random.float(value, FlxG.height - fish.height);
				var xEnd:Float = 0;
				if (startLeft)
				{
					fish.flipX = false;
					fish.setPosition(-fish.width, yStart);
					xEnd = FlxG.width;
				}
				else
				{
					fish.flipX = true;
					fish.setPosition(FlxG.width, yStart);
					xEnd = -fish.width;
				}
				FlxTween.tween(fish, {"x": xEnd, "y": yEnd}, speed, {
					onComplete: function(twn)
					{
						fish.kill();
						twn.destroy();
					}
				});

				fishFront.remove(fish);
				fishBack.remove(fish);

				if (target == -1 || FlxG.random.bool(66))
					fishFront.add(fish);
				else
					fishBack.add(fish);

			case 'shadow':
				if (boyfriend.shadow == null)
					return;
				if (target != 0)
				{
					if (boyfriend.curCharacter != 'senpai')
						boyfriend.shadow.setPosition(boyfriend.x, boyfriend.y);
					else
						boyfriend.shadow.setPosition(boyfriend.x
							+ boyfriend.width / 2
							- boyfriend.shadow.width / 2,
							boyfriend.y
							+ boyfriend.height / 2
							- boyfriend.shadow.height / 2);
					FlxTween.tween(boyfriend.shadow, {"x": boyfriend.x + boyfriend.initWidth + 20, "alpha": 1}, value / 10, {
						ease: FlxEase.quadOut,
						onComplete: function(twn)
						{
							twn.destroy();
						}
					});
				}
				else
				{
					if (boyfriend.curCharacter != 'senpai')
						FlxTween.tween(boyfriend.shadow, {"x": boyfriend.x, "alpha": 0}, value / 10, {
							ease: FlxEase.quadOut,
							onComplete: function(twn)
							{
								twn.destroy();
							}
						});
					else
						FlxTween.tween(boyfriend.shadow, {
							"x": boyfriend.x + boyfriend.width / 2 - boyfriend.shadow.width / 2,
							"alpha": 0
						}, value / 10, {
							ease: FlxEase.quadOut,
							onComplete: function(twn)
							{
								twn.destroy();
							}
						});
				}

			case 'zoom':
				autoZoom = false;
				camChangeZoom(target, value, FlxEase.linear, function(_)
				{
					defaultCamZoom = FlxG.camera.zoom;
					autoZoom = true;
				});

			case 'bars':
				if (horiBarTween1 != null && horiBarTween1.active)
				{
					horiBarTween1.cancel();
					horiBarTween1.destroy();
				}
				if (horiBarTween2 != null && horiBarTween2.active)
				{
					horiBarTween2.cancel();
					horiBarTween2.destroy();
				}
				if (value > 0)
				{
					horiBarTween1 = FlxTween.tween(horiBars.members[0], {"y": -horiBars.members[0].height + target}, value, {
						onComplete: function(twn)
						{
							twn.destroy();
						}
					});
					horiBarTween2 = FlxTween.tween(horiBars.members[1], {"y": FlxG.height - target}, value, {
						onComplete: function(twn)
						{
							twn.destroy();
						}
					});
				}
				else
				{
					horiBars.members[0].y = -horiBars.members[0].height + target;
					horiBars.members[1].y = FlxG.height - target;
				}

			case 'headfocus':
				if (target < 0)
					autoCam = true;
				else
				{
					if (camTween.active)
						camTween.cancel();
					autoCam = false;
					var followX:Float = 0;
					var followY:Float = 0;
					var multiplier:Float = 0.35;
					var charStr:String = 'bf';
					var char:Character = boyfriend;
					if (target > 0)
					{
						char = dad;
						charStr = 'dad';
					}
					if (char.initHeight > 500)
						multiplier = 0.2;
					followX = char.x + char.initWidth / 2 + (char.facing == char.initFacing ? 1 : -1) * char.camOffsets[0] * char.scale.x;
					followY = char.y + char.initHeight * multiplier + char.camOffsets[1] * char.scale.y;

					if (value > 0)
						camMove(followX, followY, value, FlxEase.quintOut, charStr);
					else
					{
						camFollow.x = followX;
						camFollow.y = followY;
						camFocus = charStr;
					}
				}

			default:
				return;
		}

		if (playSound != "")
		{
			FlxG.sound.play('assets/sounds/' + playSound + ".ogg", playSoundVol);
		}

		if (!unEffect)
			effectsActive[effect] = (effectsActive[effect] == null ? 1 : effectsActive[effect] + 1);
		else
			effectsActive[effect] = (effectsActive[effect] == null ? 0 : effectsActive[effect] - 1);

		if (ttl > 0)
		{
			new FlxTimer().start(ttl, function(tmr:FlxTimer)
			{
				effectsActive[effect]--;
				if (effectsActive[effect] < 0)
					effectsActive[effect] = 0;

				if (onEnd != null && (effectsActive[effect] <= 0 || alwaysEnd))
					onEnd();

				FlxDestroyUtil.destroy(tmr);
			});
		}

		if (!noIcon && Assets.exists("assets/images/icons/" + effect + ".png"))
		{
			var icon = new FlxSprite().loadGraphic(Paths.getImagePNG("icons/" + effect));
			icon.cameras = [camUnderTop];
			icon.screenCenter(X);
			var beginY = (effectiveDownScroll ? FlxG.height + icon.height : -icon.height);
			var finalY = (effectiveDownScroll ? FlxG.height - icon.height - 10 : 10);
			icon.y = beginY;
			icon.antialiasing = true;
			add(icon);
			FlxTween.tween(icon, {"y": finalY}, 0.25);
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxDestroyUtil.destroy(tmr);
				FlxTween.tween(icon, {"y": beginY}, 0.25, {
					onComplete: function(tween)
					{
						icon.kill();
						remove(icon);
						FlxDestroyUtil.destroy(icon);
						FlxDestroyUtil.destroy(tween);
					}
				});
			});
		}

		// resetChatData();
	}

	function waterIntensityTween(value:Float)
	{
		waterFilter.intensity.value = [value];
	}

	function waterTimeTween(value:Float)
	{
		waterFilter.uTime.value = [value];
	}

	function waterLimitTween(value:Float)
	{
		waterFilter.limit.value = [value];
	}

	// function addNote(type:Int = 0, min:Int = 0, max:Int = 0, ?specificData:Int)
	// {
	// if (startingSong)
	// 	return;
	// var pickSteps = FlxG.random.int(min, max);
	// var pickTime = /*Conductor.songPosition*/ getSongPos() + pickSteps * Conductor.stepCrochet;
	// var pickData:Int = 0;
	// if (SONG.notes.length <= Math.floor((curStep + pickSteps + 1) / 16))
	// 	return;
	// if (SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)] == null)
	// 	return;
	// if (specificData == null)
	// {
	// 	if (SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)].mustHitSection)
	// 	{
	// 		pickData = FlxG.random.int(0, 3);
	// 	}
	// 	else
	// 	{
	// 		// pickData = FlxG.random.int(4, 7);
	// 		pickData = FlxG.random.int(0, 3);
	// 	}
	// }
	// else if (specificData == -1)
	// {
	// 	var chooseFrom:Array<Int> = [];
	// 	for (i in 0...severInputs.length)
	// 	{
	// 		if (!severInputs[i])
	// 			chooseFrom.push(i);
	// 	}
	// 	if (chooseFrom.length <= 0)
	// 		pickData = FlxG.random.int(0, 3);
	// 	else
	// 		pickData = chooseFrom[FlxG.random.int(0, chooseFrom.length - 1)];
	// }
	// else
	// {
	// 	if (SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)].mustHitSection)
	// 	{
	// 		pickData = specificData % 4;
	// 	}
	// 	else
	// 	{
	// 		// pickData = specificData % 4 + 4;
	// 		pickData = specificData % 4;
	// 	}
	// }
	// var swagNote:Note = new Note(pickTime, pickData, false, null, false, null, type, false, musicStream);
	// swagNote.mustPress = true;
	// swagNote.x += FlxG.width / 2;
	// unspawnNotes.push(swagNote);
	// unspawnNotes.sort(sortByShit);
	// }

	function updateScrollUI()
	{
		strumLine.y = (effectiveDownScroll ? 570 : 30);
		healthBarBG.y = (effectiveDownScroll ? FlxG.height * 0.075 : FlxG.height * 0.875);
		healthBarP1.setPosition(healthBarBG.x
			+ healthBarBG.width / 2
			- healthBarP1.width / 2,
			healthBarBG.y
			+ healthBarBG.height / 2
			- healthBarP1.height / 2);
		iconP1.y = healthBarBG.y + healthBarBG.height / 2 - (iconP1.height / 2);
		iconP2.y = healthBarBG.y + healthBarBG.height / 2 - (iconP2.height / 2);
		strumLineNotes.forEach(function(sprite)
		{
			sprite.y = strumLine.y;
		});
		scoreTxt.y = (effectiveDownScroll ? FlxG.height * 0.1 - 72 : FlxG.height * 0.9 + 36);
	}

	var strumTweens:Array<FlxTween> = new Array<FlxTween>();

	function mixUp(reset:Bool = false)
	{
		var available = [0, 1, 2, 3];
		if (!reset)
		{
			FlxG.random.shuffle(available);
			switch (available)
			{
				case [0, 1, 2, 3]:
					available = [3, 2, 1, 0];
				default:
			}
		}

		notePositions = available;

		playerStrums.forEach(function(sprite)
		{
			if (strumTweens[sprite.ID] != null)
			{
				strumTweens[sprite.ID].cancel();
				strumTweens[sprite.ID].destroy();
			}
			strumTweens[sprite.ID] = FlxTween.tween(sprite, {x: 50 + Note.swagWidth * notePositions[sprite.ID] + 50 + (FlxG.width / 2)}, 0.25);
		});
	}

	function endSongStory()
	{
		if (isStoryMode && !introOnly)
		{
			startTimer.cancel();
			paused = true;
			inCutscene = true;
			musicStream.stop();
			bfVoice.stop();
			dadVoice.stop();
			openSubState(new DialogueSubstate(SONG.song.split("_")[0], SONG.player1, endSong, 0, "-end"));
		}
		else
			endSong();
	}

	public function endSong():Void
	{
		if (endingSong)
			return;

		if (effectTimer != null && effectTimer.active)
			effectTimer.cancel();

		canPause = false;
		endingSong = true;
		introOnly = false;
		musicStream.volume = 0;
		bfVoice.volume = 0;
		dadVoice.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, curDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);
			storyDifficulties.remove(storyDifficulties[0]);

			if (storyPlaylist.length <= 0)
			{
				// FlxG.sound.playMusic(Paths.music(TitleScreen.titleMusic), 0.75);

				PlayerSettings.menuControls();
				// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
				// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

				// switchState(new StoryMenuState());
				customTransOut = null;
				switchState(new MainMenuState());
				sectionStart = false;

				// if ()
				// StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, 5);
				}

				// FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				// var difficulty:String = "";

				// if (storyDifficulty == 0)
				// 	difficulty = '-easy';

				// if (storyDifficulty == 2)
				// 	difficulty = '-hard';

				// trace('LOADING NEXT SONG');
				// trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				// if (SONG.song.toLowerCase() == 'eggnog')
				// {
				// 	var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
				// 		-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				// 	blackShit.scrollFactor.set();
				// 	add(blackShit);
				// 	camHUD.visible = false;

				// 	FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				// }

				// if (SONG.song.toLowerCase() == 'senpai')
				// {
				// 	transIn = null;
				// 	transOut = null;
				// 	// prevCamFollow = camFollow;
				// }

				if (storyDifficulties[0].contains("easy"))
					curDifficulty = 0;
				else if (storyDifficulties[0].contains("hard"))
					curDifficulty = 2;
				else
					curDifficulty = 1;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + storyDifficulties[0], PlayState.storyPlaylist[0]);
				// musicStream.pause();
				AudioStreamThing.pauseGroup();

				switchState(new StoryStageState());

				// switchState(new PlayState());

				// transIn = FlxTransitionableState.defaultTransIn;
				// transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		else
		{
			PlayerSettings.menuControls();
			sectionStart = false;
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, noteData:Int):Void
	{
		var noteDiff:Float = Math.abs(strumtime - /*Conductor.songPosition*/ getSongPos());
		var score:Int = 350;

		unmuteBF();

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * Conductor.shitZone)
		{
			daRating = 'shit';
			if (Config.accuracy == "complex")
			{
				totalNotesHit += 1 - Conductor.shitZone;
			}
			else
			{
				totalNotesHit += 1;
			}
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.badZone)
		{
			daRating = 'bad';
			score = 100;
			if (Config.accuracy == "complex")
			{
				totalNotesHit += 1 - Conductor.badZone;
			}
			else
			{
				totalNotesHit += 1;
			}
		}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.goodZone)
		{
			daRating = 'good';
			if (Config.accuracy == "complex")
			{
				totalNotesHit += 1 - Conductor.goodZone;
			}
			else
			{
				totalNotesHit += 1;
			}
			score = 200;
		}
		if (daRating == 'sick')
		{
			totalNotesHit += 1;
			noteSplasher(noteData);
		}

		// trace('hit ' + daRating);

		songScore += score;

		comboUI.ratingPopup(daRating);

		if (combo >= minCombo)
			comboUI.comboPopup(combo);

		if (Config.comboParticles)
		{
			if (coolness == 0 && combo >= 50)
			{
				comboGood();
			}
			else if (coolness == 1 && combo >= 100)
			{
				comboCool();
			}
		}
	}

	var coolness:Int = 0;

	function doParticles()
	{
		if (!Config.comboParticles)
			return;

		switch (coolness)
		{
			case 0:
				goodParticle.stop();
				coolParticle.stop();
				powerupParticle.stop();
				coolParticle.time = 0;
				goodParticle.time = 0;
				powerupParticle.time = 0;
				camParticles.removeParticle(goodParticle);
				camParticles.removeParticle(coolParticle);
				camParticles.removeParticle(powerupParticle);
			case 1:
				goodParticle.start();
				powerupParticle.start();
				camParticles.addParticle(goodParticle);
				camParticles.removeParticle(powerupParticle);
				camParticles.addParticle(powerupParticle);
			case 2:
				coolParticle.start();
				powerupParticle.start();
				camParticles.addParticle(coolParticle);
				camParticles.removeParticle(powerupParticle);
				camParticles.addParticle(powerupParticle);
		}
	}

	function comboGood()
	{
		if (!Config.comboParticles)
			return;

		coolness = 1;
		doParticles();
		FlxG.sound.play(Paths.sound('combosuper'), Conductor.vocalVolume);
		playCoolnessSprite('supercombo');
	}

	function comboCool()
	{
		if (!Config.comboParticles)
			return;

		coolness = 2;
		doParticles();
		FlxG.sound.play(Paths.sound('comboultra'), Conductor.vocalVolume);
		playCoolnessSprite('ultracombo');
		if (useColorz)
		{
			outlineShader.enabled.value = [true];
		}
	}

	function playCoolnessSprite(name:String)
	{
		if (!Config.comboParticles)
			return;

		coolnessSprite.animation.play(name);
		coolnessSprite.updateHitbox();
		coolnessSprite.x = FlxG.width;
		coolnessSprite.y = (effectiveDownScroll ? healthBarBG.y + 20 : healthBarBG.y - coolnessSprite.height - 20);
		coolnessSprite.alpha = 0.8;
		if (coolnessTween != null && coolnessTween.active)
		{
			coolnessTween.cancel();
			coolnessTween.destroy();
		}
		coolnessTween = FlxTween.tween(coolnessSprite, {"x": FlxG.width * 0.75 - coolnessSprite.width / 2}, 0.4, {
			onComplete: function(twn)
			{
				FlxTween.tween(coolnessSprite, {"alpha": 0}, 1.2, {
					onComplete: function(twn)
					{
						twn.destroy();
					},
					ease: FlxEase.quadIn
				});
				twn.destroy();
			}
		});
	}

	function comboFail()
	{
		if (!Config.comboParticles)
			return;

		if (coolness > 0)
		{
			if (coolness >= 2 && useColorz)
			{
				// for (i in 0...4)
				// {
				// 	Note.colorzShaders[i].colorBase.value = originalNoteColors[i][0];
				// 	Note.colorzShaders[i].colorOuter.value = originalNoteColors[i][1];
				// 	Note.colorzShaders[i].colorInner.value = originalNoteColors[i][2];
				// }
				if (useColorz)
				{
					outlineShader.enabled.value = [false];
				}
			}
			coolness = 0;
			doParticles();
			healthBarP1.color = (Main.characterColors[SONG.player1] != null ? Main.characterColors[SONG.player1] : 0xFF66FF33);
			FlxG.sound.play(Paths.sound('combofail'), Conductor.vocalVolume);
		}
	}

	function noteSplasher(noteData)
	{
		if (!Config.noteSplash)
			return;

		var splash = noteSplash.members[noteData % 4];
		if (splashTweens[noteData % 4] != null && splashTweens[noteData % 4].active)
		{
			splashTweens[noteData % 4].cancel();
			splashTweens[noteData % 4] = FlxDestroyUtil.destroy(splashTweens[noteData % 4]);
		}
		if (splashTweens2[noteData % 4] != null && splashTweens2[noteData % 4].active)
		{
			splashTweens2[noteData % 4].cancel();
			splashTweens2[noteData % 4] = FlxDestroyUtil.destroy(splashTweens2[noteData % 4]);
		}
		splash.scale.set(0.33, 0.33);
		splash.alpha = 1;
		var strumNote = playerStrums.members[noteData % 4];
		// splash.setPosition(strumNote.x + strumNote.width / 2 - splash.width / 2, strumNote.y + strumNote.height / 2 - splash.height / 2);

		splashTweens[noteData % 4] = FlxTween.tween(splash, {"scale.x": 0.9, "scale.y": 0.9}, 0.25, {
			onComplete: function(twn)
			{
				twn.cancel();
				FlxDestroyUtil.destroy(twn);
			},
			onUpdate: function(_)
			{
				splash.updateHitbox();
				splash.setPosition(strumNote.x + strumNote.width / 2 - splash.width / 2, strumNote.y + strumNote.height / 2 - splash.height / 2);
			}
		});
		splashTweens2[noteData % 4] = FlxTween.tween(splash, {"alpha": 0}, 0.25, {
			ease: FlxEase.quadIn,
			onComplete: function(twn)
			{
				twn.cancel();
				FlxDestroyUtil.destroy(twn);
			}
		});
	}

	// public function keyDown(evt:KeyboardEvent):Void
	// {
	// 	if (skipListener)
	// 	{
	// 		return;
	// 	}
	// 	@:privateAccess
	// 	var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
	// 	var binds:Array<String> = [
	// 		FlxG.save.data.leftBind,
	// 		FlxG.save.data.downBind,
	// 		FlxG.save.data.upBind,
	// 		FlxG.save.data.rightBind
	// 	];
	// 	var data = -1;
	// 	switch (evt.keyCode) // arrow keys
	// 	{
	// 		case 37:
	// 			data = 0;
	// 		case 40:
	// 			data = 1;
	// 		case 38:
	// 			data = 2;
	// 		case 39:
	// 			data = 3;
	// 	}
	// 	for (i in 0...binds.length) // binds
	// 	{
	// 		if (binds[i].toLowerCase() == key.toLowerCase())
	// 			data = i;
	// 	}
	// 	if (data == -1)
	// 		return;
	// 	switch (data)
	// 	{
	// 		case 0:
	// 			if (leftHold)
	// 			{
	// 				return;
	// 			}
	// 			leftPress = true;
	// 			leftHold = true;
	// 		case 1:
	// 			if (downHold)
	// 			{
	// 				return;
	// 			}
	// 			downPress = true;
	// 			downHold = true;
	// 		case 2:
	// 			if (upHold)
	// 			{
	// 				return;
	// 			}
	// 			upPress = true;
	// 			upHold = true;
	// 		case 3:
	// 			if (rightHold)
	// 			{
	// 				return;
	// 			}
	// 			rightPress = true;
	// 			rightHold = true;
	// 	}
	// }
	// public function keyUp(evt:KeyboardEvent):Void
	// {
	// 	if (skipListener)
	// 	{
	// 		return;
	// 	}
	// 	@:privateAccess
	// 	var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
	// 	var binds:Array<String> = [
	// 		FlxG.save.data.leftBind,
	// 		FlxG.save.data.downBind,
	// 		FlxG.save.data.upBind,
	// 		FlxG.save.data.rightBind
	// 	];
	// 	var data = -1;
	// 	switch (evt.keyCode) // arrow keys
	// 	{
	// 		case 37:
	// 			data = 0;
	// 		case 40:
	// 			data = 1;
	// 		case 38:
	// 			data = 2;
	// 		case 39:
	// 			data = 3;
	// 	}
	// 	for (i in 0...binds.length) // binds
	// 	{
	// 		if (binds[i].toLowerCase() == key.toLowerCase())
	// 			data = i;
	// 	}
	// 	if (data == -1)
	// 		return;
	// 	switch (data)
	// 	{
	// 		case 0:
	// 			leftRelease = true;
	// 			leftHold = false;
	// 		case 1:
	// 			downRelease = true;
	// 			downHold = false;
	// 		case 2:
	// 			upRelease = true;
	// 			upHold = false;
	// 		case 3:
	// 			rightRelease = true;
	// 			rightHold = false;
	// 	}
	// }
	// private function keyCheck():Void
	// {
	// 	upTime = controls.UP ? upTime + 1 : 0;
	// 	downTime = controls.DOWN ? downTime + 1 : 0;
	// 	leftTime = controls.LEFT ? leftTime + 1 : 0;
	// 	rightTime = controls.RIGHT ? rightTime + 1 : 0;
	// 	upPress = upTime == 1;
	// 	downPress = downTime == 1;
	// 	leftPress = leftTime == 1;
	// 	rightPress = rightTime == 1;
	// 	upRelease = upHold && upTime == 0;
	// 	downRelease = downHold && downTime == 0;
	// 	leftRelease = leftHold && leftTime == 0;
	// 	rightRelease = rightHold && rightTime == 0;
	// 	upHold = upTime > 0;
	// 	downHold = downTime > 0;
	// 	leftHold = leftTime > 0;
	// 	rightHold = rightTime > 0;
	// 	/*THE FUNNY 4AM CODE!
	// 		trace((leftHold?(leftPress?"^":"|"):(leftRelease?"^":" "))+(downHold?(downPress?"^":"|"):(downRelease?"^":" "))+(upHold?(upPress?"^":"|"):(upRelease?"^":" "))+(rightHold?(rightPress?"^":"|"):(rightRelease?"^":" ")));
	// 		I should probably remove this from the code because it literally serves no purpose, but I'm gonna keep it in because I think it's funny.
	// 		It just sorta prints 4 lines in the console that look like the arrows being pressed. Looks something like this:
	// 		====
	// 		^  |
	// 		| ^|
	// 		| |^
	// 		^ |
	// 		==== */
	// }

	private function keyShit():Void
	{
		if (autoPlay)
			return;

		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		// var upP = controls.UP_P;
		// var rightP = controls.RIGHT_P;
		// var downP = controls.DOWN_P;
		// var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		// if ((upP || rightP || downP || leftP) && generatedMusic)
		// {
		// 	boyfriend.holdTimer = 0;
		// }

		// var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		var possibleNotes:Array<Note> = [];
		// var ignoreList:Array<Int> = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
			{
				// the sorting probably doesn't need to be in here? who cares lol
				possibleNotes.push(daNote);
				// possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				haxe.ds.ArraySort.sort(possibleNotes, (a, b) -> Std.int(a.strumTime - b.strumTime));
				// ignoreList.push(daNote.noteData);
			}
		});

		// var severIndex = -1;
		// var severArray = [2, 3, 1, 0];
		// for (checkThisChucklenuts in [upP, rightP, downP, leftP])
		// {
		// 	severIndex++;
		// 	if (severInputs[severArray[severIndex]])
		// 		continue;

		// 	if (frozenInput > 0)
		// 		continue;

		// 	if (checkThisChucklenuts /*&& !boyfriend.stunned*/ && generatedMusic)
		// 	{
		// 		boyfriend.holdTimer = 0;
		// 		if (possibleNotes.length > 0)
		// 		{
		// 			// var daNote = possibleNotes[0];
		// 			var goodEnough:Bool = false;
		// 			var goodEnoughIndex:Array<Int> = [];
		// 			for (i in 0...possibleNotes.length)
		// 			{
		// 				if (controlArray[possibleNotes[i].noteData])
		// 				{
		// 					if (!goodEnough || (goodEnough && possibleNotes[i].strumTime == possibleNotes[goodEnoughIndex[0]].strumTime))
		// 					{
		// 						goodEnoughIndex.push(i);
		// 						goodNoteHit(possibleNotes[i]);
		// 						goodEnough = true;
		// 					}
		// 				}
		// 			}
		// 			if (goodEnough)
		// 			{
		// 				for (i in goodEnoughIndex)
		// 				{
		// 					possibleNotes.remove(possibleNotes[i]);
		// 				}
		// 			}
		// 			else
		// 				badNoteCheck(leftP, upP, rightP, downP);
		// 		}
		// 		else
		// 		{
		// 			badNoteCheck(leftP, upP, rightP, downP);
		// 		}
		// 	}
		// }

		var severIndex = -1;
		var severArray = [2, 3, 1, 0];
		var keyLock = [false, false, false, false];
		for (checkThisChucklenuts in [up, right, down, left])
		{
			severIndex++;
			if (severInputs[severArray[severIndex]])
				continue;

			if (frozenInput > 0)
				continue;

			if (checkThisChucklenuts /*&& !boyfriend.stunned*/ && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0:
								if (left && !keyLock[0])
								{
									keyLock[0] = true;
									goodNoteHit(daNote);
								}
							case 1:
								if (down && !keyLock[1])
								{
									keyLock[1] = true;
									goodNoteHit(daNote);
								}
							case 2:
								if (up && !keyLock[2])
								{
									keyLock[2] = true;
									goodNoteHit(daNote);
								}
							case 3:
								if (right && !keyLock[3])
								{
									keyLock[3] = true;
									goodNoteHit(daNote);
								}
						}
					}
				});
			}
		}

		notes.forEachAlive(function(daNote:Note)
		{
			// Guitar Hero Type Held Notes
			if (daNote.isSustainNote && daNote.mustPress)
			{
				if (daNote.prevNote.tooLate && !daNote.prevNote.wasGoodHit)
				{
					daNote.tooLate = true;
					killNote(daNote);
				}

				if (daNote.prevNote.wasGoodHit && !daNote.wasGoodHit)
				{
					switch (daNote.noteData)
					{
						case 0:
							if (leftR)
							{
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								muteBF();
								daNote.tooLate = true;
								killNote(daNote);
								boyfriend.holdTimer = 0;
								updateAccuracy();
							}
						case 1:
							if (downR)
							{
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								muteBF();
								daNote.tooLate = true;
								killNote(daNote);
								boyfriend.holdTimer = 0;
								updateAccuracy();
							}
						case 2:
							if (upR)
							{
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								muteBF();
								daNote.tooLate = true;
								killNote(daNote);
								boyfriend.holdTimer = 0;
								updateAccuracy();
							}
						case 3:
							if (rightR)
							{
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								muteBF();
								daNote.tooLate = true;
								killNote(daNote);
								boyfriend.holdTimer = 0;
								updateAccuracy();
							}
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.getCurAnim().startsWith('sing') && !boyfriend.getCurAnim().endsWith('End'))
				boyfriend.idleEnd();
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 2:
					// if (upP && spr.animation.curAnim.name != 'confirm')
					// {
					// 	spr.animation.play('pressed');
					// 	doPressGlow(spr.ID);
					// }
					if (!up && spr.animation.curAnim.name != 'static')
					{
						spr.animation.play('static');
						resetGlows(spr.ID);
					}
				case 3:
					// if (rightP && spr.animation.curAnim.name != 'confirm')
					// {
					// 	spr.animation.play('pressed');
					// 	doPressGlow(spr.ID);
					// }
					if (!right && spr.animation.curAnim.name != 'static')
					{
						spr.animation.play('static');
						resetGlows(spr.ID);
					}
				case 1:
					// if (downP && spr.animation.curAnim.name != 'confirm')
					// {
					// 	spr.animation.play('pressed');
					// 	doPressGlow(spr.ID);
					// }
					if (!down && spr.animation.curAnim.name != 'static')
					{
						spr.animation.play('static');
						resetGlows(spr.ID);
					}
				case 0:
					// if (leftP && spr.animation.curAnim.name != 'confirm')
					// {
					// 	spr.animation.play('pressed');
					// 	doPressGlow(spr.ID);
					// }
					if (!left && spr.animation.curAnim.name != 'static')
					{
						spr.animation.play('static');
						resetGlows(spr.ID);
					}
			}

			switch (spr.animation.curAnim.name)
			{
				case "confirm":
					// spr.alpha = 1;
					// spr.updateHitbox();
					spr.centerOffsets();

				/*case "static":
					spr.alpha = 0.5; //Might mess around with strum transparency in the future or something.
					spr.centerOffsets(); */

				default:
					// spr.alpha = 1;
					spr.centerOffsets();
			}

			additionalOffset(spr);
		});
	}

	var alreadyTapped:Array<Bool> = [false, false, false, false];

	private function keyShitTap(event:KeyboardEvent):Void
	{
		if (inCutscene || paused || autoPlay)
			return;

		@:privateAccess
		var keyThing = FlxG.keys.getKey(event.keyCode);
		if (keyThing == null)
			return;
		var button = keyThing.ID.toString();
		var index:Int = -1;
		if (button == 'LEFT' || button == FlxG.save.data.leftBind)
			index = 0;
		else if (button == 'DOWN' || button == FlxG.save.data.downBind)
			index = 1;
		else if (button == 'UP' || button == FlxG.save.data.upBind)
			index = 2;
		else if (button == 'RIGHT' || button == FlxG.save.data.rightBind)
			index = 3;

		if (index == -1)
			return;

		if (alreadyTapped[index])
			return;

		alreadyTapped[index] = true;

		if (generatedMusic)
		{
			boyfriend.holdTimer = 0;
		}

		// FlxG.watch.addQuick('asdfa', upP);
		var possibleNotes:Array<Note> = [];
		// var ignoreList:Array<Int> = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
			{
				// the sorting probably doesn't need to be in here? who cares lol
				possibleNotes.push(daNote);
				// possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				haxe.ds.ArraySort.sort(possibleNotes, (a, b) -> Std.int(a.strumTime - b.strumTime));
				// ignoreList.push(daNote.noteData);
			}
		});

		if (severInputs[index])
			return;

		if (frozenInput > 0)
			return;

		if (/*!boyfriend.stunned &&*/ generatedMusic)
		{
			boyfriend.holdTimer = 0;
			if (possibleNotes.length > 0)
			{
				// var daNote = possibleNotes[0];
				var goodEnough:Bool = false;
				var goodEnoughIndex:Array<Int> = [];
				for (i in 0...possibleNotes.length)
				{
					if (possibleNotes[i].noteData == index)
					{
						if (!goodEnough || (goodEnough && possibleNotes[i].strumTime == possibleNotes[goodEnoughIndex[0]].strumTime))
						{
							goodEnoughIndex.push(i);
							goodNoteHit(possibleNotes[i]);
							goodEnough = true;
						}
					}
				}
				if (goodEnough)
				{
					for (i in goodEnoughIndex)
					{
						possibleNotes.remove(possibleNotes[i]);
					}
				}
				else
					badNoteCheck(index == 0, index == 1, index == 2, index == 3);
			}
			else
			{
				badNoteCheck(index == 0, index == 1, index == 2, index == 3);
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 2:
					if (spr.animation.curAnim.name != 'confirm')
					{
						spr.animation.play('pressed');
						doPressGlow(spr.ID);
					}
				case 3:
					if (spr.animation.curAnim.name != 'confirm')
					{
						spr.animation.play('pressed');
						doPressGlow(spr.ID);
					}
				case 1:
					if (spr.animation.curAnim.name != 'confirm')
					{
						spr.animation.play('pressed');
						doPressGlow(spr.ID);
					}
				case 0:
					if (spr.animation.curAnim.name != 'confirm')
					{
						spr.animation.play('pressed');
						doPressGlow(spr.ID);
					}
			}

			switch (spr.animation.curAnim.name)
			{
				case "confirm":
					// spr.alpha = 1;
					// spr.updateHitbox();
					spr.centerOffsets();

				/*case "static":
					spr.alpha = 0.5; //Might mess around with strum transparency in the future or something.
					spr.centerOffsets(); */

				default:
					// spr.alpha = 1;
					spr.centerOffsets();
			}

			additionalOffset(spr);
		});
	}

	private function keyShitRelease(event:KeyboardEvent):Void
	{
		if (inCutscene || paused || autoPlay)
			return;

		@:privateAccess
		var keyThing = FlxG.keys.getKey(event.keyCode);
		if (keyThing == null)
			return;
		var button = keyThing.ID.toString();
		var index:Int = -1;
		if (button == 'LEFT' || button == FlxG.save.data.leftBind)
			index = 0;
		else if (button == 'DOWN' || button == FlxG.save.data.downBind)
			index = 1;
		else if (button == 'UP' || button == FlxG.save.data.upBind)
			index = 2;
		else if (button == 'RIGHT' || button == FlxG.save.data.rightBind)
			index = 3;

		if (index == -1)
			return;

		alreadyTapped[index] = false;
	}

	function additionalOffset(spr:FlxSprite)
	{
		spr.offset.x += xWiggle[spr.ID % 4];
		spr.offset.y += yWiggle[spr.ID % 4];
	}

	// private function keyShitAuto():Void
	// {
	// 	var hitNotes:Array<Note> = [];
	// 	notes.forEachAlive(function(daNote:Note)
	// 	{
	// 		if (daNote.mustPress && daNote.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.125)
	// 		{
	// 			hitNotes.push(daNote);
	// 		}
	// 	});
	// 	if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !upHold && !downHold && !rightHold && !leftHold)
	// 	{
	// 		if (boyfriend.getCurAnim().startsWith('sing') && !boyfriend.getCurAnim().endsWith('End'))
	// 			boyfriend.idleEnd();
	// 	}
	// 	for (x in hitNotes)
	// 	{
	// 		boyfriend.holdTimer = 0;
	// 		goodNoteHit(x);
	// 		playerStrums.forEach(function(spr:FlxSprite)
	// 		{
	// 			if (Math.abs(x.noteData) == spr.ID)
	// 			{
	// 				spr.animation.play('confirm', true);
	// 				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
	// 				{
	// 					spr.centerOffsets();
	// 					spr.offset.x -= 14;
	// 					spr.offset.y -= 14;
	// 				}
	// 				else
	// 					spr.centerOffsets();
	// 				additionalOffset(spr);
	// 			}
	// 		});
	// 	}
	// }

	function noteMiss(direction:Int = 1, ?healthLoss:Float = 0.04, ?playAudio:Bool = true, ?skipInvCheck:Bool = false, isAlert:Bool = false):Void
	{
		if (!startingSong && (!invuln || skipInvCheck))
		{
			health -= healthLoss * Config.healthDrainMultiplier * dmgMultiplier;
			if (combo > minCombo)
			{
				if (boyfriend.curCharacter.startsWith('bf'))
					gf.playAnim('sad', true);
				else
					gf.playAnim('cheer', true);
				comboUI.breakPopup();
			}
			misses += 1;
			combo = 0;

			comboFail();

			songScore -= 100;

			if (playAudio)
			{
				FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), FlxG.random.float(0.1, 0.2));
			}

			if (isAlert)
			{
				// FlxG.sound.play('assets/sounds/warning' + ".ogg");
				// var fist:FlxSprite = new FlxSprite().loadGraphic("assets/images/thepunch.png");
				// fist.x = FlxG.width / camGame.zoom;
				// fist.y = boyfriend.y + boyfriend.height / 2 - fist.height / 2;
				// add(fist);
				// FlxTween.tween(fist, {x: boyfriend.x + boyfriend.frameWidth / 2}, 0.1, {
				// 	onComplete: function(tween)
				// 	{
				// 		if (tween.executions >= 2)
				// 		{
				// 			fist.kill();
				// 			FlxDestroyUtil.destroy(fist);
				// 			tween.cancel();
				// 			FlxDestroyUtil.destroy(tween);
				// 		}
				// 	},
				// 	type: PINGPONG
				// });
			}
			// FlxG.sound.play('assets/sounds/missnote1' + ".ogg", 1, false);
			// FlxG.log.add('played imss note');

			setBoyfriendInvuln(5 / 60);

			if (boyfriend.canAutoAnim)
			{
				if (isAlert && boyfriend.animExists('hit'))
				{
					boyfriend.playAnim('hit', true);
					boyfriend.canAutoIdle = false;
				}
				else
				{
					switch (direction)
					{
						case 2:
							boyfriend.playAnim('singUPmiss', true);
						case 3:
							boyfriend.playAnim('singRIGHTmiss', true);
						case 1:
							boyfriend.playAnim('singDOWNmiss', true);
						case 0:
							boyfriend.playAnim('singLEFTmiss', true);
					}
				}
			}

			updateAccuracy();
		}

		if (Main.flippymode)
		{
			System.exit(0);
		}
	}

	function noteMissWrongPress(direction:Int = 1, ?healthLoss:Float = 0.0475, dropCombo:Bool = false):Void
	{
		if (!startingSong && !invuln)
		{
			health -= healthLoss * Config.healthDrainMultiplier * dmgMultiplier;

			if (dropCombo)
			{
				if (combo > 5)
				{
					if (boyfriend.curCharacter.startsWith('bf'))
						gf.playAnim('sad', true);
					else
						gf.playAnim('cheer', true);
				}
				combo = 0;
			}

			misses += 1;

			songScore -= 25;

			FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + ".ogg", FlxG.random.float(0.1, 0.2));

			// FlxG.sound.play('assets/sounds/missnote1' + ".ogg", 1, false);
			// FlxG.log.add('played imss note');

			setBoyfriendInvuln(4 / 60);

			if (boyfriend.canAutoAnim)
			{
				switch (direction)
				{
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
				}
			}

			comboFail();
		}
	}

	function badNoteCheck(leftP:Bool, downP:Bool, upP:Bool, rightP:Bool)
	{
		if (Config.ghostTapType > 0 && !canHit)
		{
		}
		else
		{
			if (leftP)
				noteMissWrongPress(0, 0.0475, true);
			if (upP)
				noteMissWrongPress(2, 0.0475, true);
			if (rightP)
				noteMissWrongPress(3, 0.0475, true);
			if (downP)
				noteMissWrongPress(1, 0.0475, true);
		}
	}

	function setBoyfriendInvuln(time:Float = 5 / 60)
	{
		invulnCount++;
		var invulnCheck = invulnCount;

		invuln = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if (invulnCount == invulnCheck)
			{
				invuln = false;
			}
			FlxDestroyUtil.destroy(tmr);
		});
	}

	function setCanMiss(time:Float = 10 / 60)
	{
		noMissCount++;
		var noMissCheck = noMissCount;

		canHit = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if (noMissCheck == noMissCount)
			{
				canHit = false;
			}
			FlxDestroyUtil.destroy(tmr);
		});
	}

	/*function setBoyfriendStunned(time:Float = 5 / 60){

		boyfriend.stunned = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		});

	}*/
	function goodNoteHit(note:Note):Void
	{
		if (note.specialNote)
		{
			specialNoteHit(note);
			return;
		}

		// Guitar Hero Styled Hold Notes
		if (note.isSustainNote && !note.prevNote.wasGoodHit)
		{
			noteMiss(note.noteData, 0.04, true, true);
			note.prevNote.tooLate = true;
			killNote(note.prevNote);
			muteBF();
		}
		else if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note.noteData);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			// if (note.noteData >= 0)
			// {
			// 	health += 0.023 * Config.healthMultiplier;
			// }
			// else
			// {
			// 	health += 0.004 * Config.healthMultiplier;
			// }
			if (!note.isSustainNote)
			{
				health += 0.023 * Config.healthMultiplier;
			}
			else
			{
				health += 0.008 * Config.healthMultiplier;
			}

			if (boyfriend.canAutoAnim && (!boyfriend.isModel || !note.isSustainNote))
			{
				var altAnim:String = "";

				if (SONG.notes[Math.floor(curStep / 16)] != null)
				{
					if (SONG.notes[Math.floor(curStep / 16)].altAnim)
						altAnim = '-alt';
				}

				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP' + altAnim, true);
					case 3:
						boyfriend.playAnim('singRIGHT' + altAnim, true);
					case 1:
						boyfriend.playAnim('singDOWN' + altAnim, true);
					case 0:
						boyfriend.playAnim('singLEFT' + altAnim, true);
				}
			}

			if (!note.isSustainNote)
			{
				setBoyfriendInvuln(2.5 / 60);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					doConfirmGlow(spr.ID);
					// spr.updateHitbox();
				}
			});

			note.wasGoodHit = true;
			unmuteBF();

			if (!note.isSustainNote)
			{
				killNote(note);
			}

			updateAccuracy();
		}
	}

	function specialNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			var dontSing = false;
			var countCombo = false;

			if (note.isMine || note.isFakeHeal)
			{
				misses++;
				health -= FlxG.random.float(0.18, 0.25) * dmgMultiplier;
				if (note.isMine)
					FlxG.sound.play('assets/sounds/mine' + ".ogg");
				else if (note.isFakeHeal)
					FlxG.sound.play('assets/sounds/mine' + ".ogg");
				redCross(note);
				comboFail();
				combo = 0;
			}
			else if (note.isFreeze)
			{
				misses++;
				FlxG.sound.play('assets/sounds/freeze' + ".ogg");
				frozenInput++;
				playerStrums.forEach(function(sprite)
				{
					sprite.color = 0x0073b5;
				});
				new FlxTimer().start(2, function(timer)
				{
					frozenInput--;
					if (frozenInput <= 0)
					{
						playerStrums.forEach(function(sprite)
						{
							sprite.color = 0xffffff;
						});
					}
					FlxDestroyUtil.destroy(timer);
				});
				comboFail();
				combo = 0;
			}
			else if (note.isAlert)
			{
				// FlxG.sound.play('assets/sounds/dodge' + ".ogg");
				if (boyfriend.animExists('dodge'))
				{
					boyfriend.playAnim('dodge', true);
					boyfriend.canAutoIdle = false;
					dontSing = true;
				}
				countCombo = true;
			}
			else if (note.isHeal)
			{
				health += FlxG.random.float(0.3, 0.4);
				FlxG.sound.play('assets/sounds/heal' + ".ogg");
				if (boyfriend.animExists('hey'))
				{
					boyfriend.playAnim('hey', true);
					dontSing = true;
				}
				countCombo = true;
			}
			else if (note.isScribble)
			{
				misses++;
				FlxG.sound.play(Paths.sound("paper"), 0.6);
				redCross(note);
				scribbleCount++;
				refreshScribble();
				new FlxTimer().start(12, function(tmr)
				{
					scribbleCount--;
					refreshScribble();
					FlxDestroyUtil.destroy(tmr);
				});
				comboFail();
				combo = 0;
			}

			if (countCombo && !note.isSustainNote)
			{
				popUpScore(note.strumTime, note.noteData);
				combo += 1;
				updateAccuracy();
			}

			if (boyfriend.canAutoAnim && !dontSing)
			{
				var altAnim:String = "";

				if (SONG.notes[Math.floor(curStep / 16)] != null)
				{
					if (SONG.notes[Math.floor(curStep / 16)].altAnim)
						altAnim = '-alt';
				}
				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP' + altAnim, true);
					case 3:
						boyfriend.playAnim('singRIGHT' + altAnim, true);
					case 1:
						boyfriend.playAnim('singDOWN' + altAnim, true);
					case 0:
						boyfriend.playAnim('singLEFT' + altAnim, true);
				}
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					doConfirmGlow(spr.ID);
					// spr.updateHitbox();
				}
			});

			note.wasGoodHit = true;
			unmuteBF();

			if (!note.isSustainNote)
			{
				killNote(note);
			}
		}
	}

	function redCross(note:Note)
	{
		var nope:FlxSprite = new FlxSprite(0, 0);
		nope.loadGraphic("assets/images/cross.png");
		nope.setGraphicSize(Std.int(nope.width * 4));
		nope.angle = 45;
		nope.updateHitbox();
		nope.alpha = 0.8;
		nope.cameras = [camNotes];

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (Math.abs(note.noteData) == spr.ID)
			{
				nope.x = (spr.x + spr.width / 2) - nope.width / 2;
				nope.y = (spr.y + spr.height / 2) - nope.height / 2;
			}
		});

		add(nope);

		FlxTween.tween(nope, {alpha: 0}, 1, {
			onComplete: function(tween)
			{
				nope.kill();
				remove(nope);
				nope.destroy();
			}
		});
	}

	function refreshScribble()
	{
		if (scribbleCount < 0)
			scribbleCount = 0;
		else if (scribbleCount >= 5)
		{
			scribbleCount = 5;
			health = 0;
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.sound('carPass' + FlxG.random.int(0, 1)), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			FlxDestroyUtil.destroy(tmr);
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width / defaultCamZoom + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.sound('thunder_' + FlxG.random.int(1, 2)));
		// halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);

		halloweenRed = 255;
		halloweenGreen = 255;
		halloweenBlue = 255;

		lightningStuff([0, 0, 0, 1, 255, 255, 255], [0, 0, 0, 1, 255, 255, 255], [1, 1, 1, 1, 22, 22, 27], [0, 0, 0, 1, 12, 11, 30]);

		new FlxTimer().start(0.0416, function(tmr)
		{
			switch (tmr.elapsedLoops)
			{
				case 1:
					resetLightning();
					lightningStuff([0.5, 0.5, 0.5, 1, 0, 0, 0], [0, 0, 0, 1, 18, 18, 61], [0, 0, 0, 1, 18, 18, 61], [0, 0, 0, 1, 10, 9, 36]);
				case 2:
					resetLightning();
					FlxTween.color(halloweenOutline, 0.75, FlxColor.BLACK, FlxColor.WHITE, {
						ease: FlxEase.quadOut,
						onComplete: function(twn)
						{
							twn.destroy();
						}
					});
					FlxTween.color(halloweenBG, 0.75, 0x363636, FlxColor.WHITE, {
						ease: FlxEase.quadOut,
						onComplete: function(twn)
						{
							twn.destroy();
						}
					});
					halloweenColors = true;
					FlxTween.tween(this, {'halloweenRed': 0, 'halloweenGreen': 0, 'halloweenBlue': 0}, 0.75, {
						ease: FlxEase.quadOut,
						onComplete: function(twn)
						{
							halloweenColors = false;
							FlxDestroyUtil.destroy(twn);
						}
					});
					FlxDestroyUtil.destroy(tmr);
			}
		}, 2);
	}

	var halloweenRed:Int = 0;
	var halloweenGreen:Int = 0;
	var halloweenBlue:Int = 0;
	var halloweenColors:Bool = false;

	function lightningStuff(window:Array<Float>, floor:Array<Float>, outline:Array<Float>, bg:Array<Float>)
	{
		halloweenWindow.setColorTransform(window[0], window[1], window[3], window[4], Std.int(window[5]), Std.int(window[6]), Std.int(window[7]));
		halloweenFloor.setColorTransform(floor[0], floor[1], floor[3], floor[4], Std.int(floor[5]), Std.int(floor[6]), Std.int(floor[7]));
		halloweenOutline.setColorTransform(outline[0], outline[1], outline[3], outline[4], Std.int(outline[5]), Std.int(outline[6]), Std.int(outline[7]));
		halloweenBG.setColorTransform(bg[0], bg[1], bg[3], bg[4], Std.int(bg[5]), Std.int(bg[6]), Std.int(bg[7]));
	}

	function resetLightning()
	{
		halloweenWindow.setColorTransform();
		halloweenFloor.setColorTransform();
		halloweenOutline.setColorTransform();
		halloweenBG.setColorTransform();
	}

	override function stepHit()
	{
		if (!endingSong && !inCutscene)
		{
			// if (vocals.time > Conductor.songPosition + 20 + delayOffset || vocals.time < Conductor.songPosition - 20 - delayOffset)
			// {
			// 	resyncVocals();
			// }
			// voices.forEach(function(snd)
			// {
			// 	if (snd.time > Conductor.songPosition + 15 + delayOffset || snd.time < Conductor.songPosition - 15 - delayOffset)
			// 	{
			// 		resyncVocals();
			// 	}
			// });
			if (Math.abs(musicStream.time - Conductor.songPosition) > 20 + delayOffset)
			{
				trace("GOTTA RESYNC because " + Math.abs(musicStream.time - Conductor.songPosition) + " diff");
				resyncVocals();
			}
		}

		/*if (dad.curCharacter == 'spooky' && totalSteps % 4 == 2)
			{
				// dad.dance();
		}*/

		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		// wiggleShit.update(Conductor.crochet);
		super.beatHit();

		if (curBeat % 4 == 0)
		{
			var sec = Math.floor(curBeat / 4);
			if (sec >= sectionHaveNotes.length)
			{
				sec = -1;
			}

			sectionHasBFNotes = sec >= 0 ? sectionHaveNotes[sec][0] : false;
			sectionHasOppNotes = sec >= 0 ? sectionHaveNotes[sec][1] : false;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			else
				Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (!sectionHasOppNotes)
				if (dad.getCurAnim().contains("idle") || dad.getCurAnim().contains("dance"))
					if (dadBeats.contains(curBeat % 4) && dad.canAutoAnim && dad.canAutoIdle)
						dad.dance();
		}
		else
		{
			if (dadBeats.contains(curBeat % 4))
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat <= 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			uiBop(0.015, 0.03);
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 168)
		{
			dadBeats = [0, 1, 2, 3];
			bfBeats = [0, 1, 2, 3];
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 200)
		{
			dadBeats = [0, 2];
			bfBeats = [1, 3];
		}

		if (curBeat % (4 * bopSpeed) == 0 && camZooming)
		{
			uiBop();
		}

		if (curBeat % bopSpeed == 0)
		{
			iconP1.iconScale = iconP1.defualtIconScale * 1.25;
			iconP2.iconScale = iconP2.defualtIconScale * 1.25;

			iconP1.tweenToDefaultScale(0.2, FlxEase.quintOut);
			iconP2.tweenToDefaultScale(0.2, FlxEase.quintOut);

			gf.dance();
		}

		if (bfBeats.contains(curBeat % 4) && boyfriend.canAutoAnim && boyfriend.canAutoIdle)
			boyfriend.dance();

		if (totalBeats % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		switch (curStage)
		{
			case "school":
				bgGirls.dance();

			case "limo":
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();

			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (totalBeats % 4 == 0)
				{
					var curLight = FlxColor.fromHSB(FlxG.random.int(0, 360), FlxG.random.float(0.65, 1), FlxG.random.float(0.65, 1));
					phillyCityLights.color = curLight;
				}

				if (totalBeats % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		for (beatHitFunc in bopSprites)
		{
			if (beatHitFunc != null)
				beatHitFunc();
		}

		if (curStage == "spooky" && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;

	function sectionContainsBfNotes(section:Int):Bool
	{
		var notes = SONG.notes[section].sectionNotes;
		var mustHit = SONG.notes[section].mustHitSection;

		for (x in notes)
		{
			if (mustHit)
			{
				if (x[1] < 4)
				{
					return true;
				}
			}
			else
			{
				if (x[1] > 3 && x[1] < 8)
				{
					return true;
				}
			}
		}

		return false;
	}

	function sectionContainsOppNotes(section:Int):Bool
	{
		var notes = SONG.notes[section].sectionNotes;
		var mustHit = SONG.notes[section].mustHitSection;

		for (x in notes)
		{
			if (mustHit)
			{
				if (x[1] > 3 && x[1] < 8)
				{
					return true;
				}
			}
			else
			{
				if (x[1] < 4)
				{
					return true;
				}
			}
		}

		return false;
	}

	function camFocusOpponent()
	{
		// var followX = dad.getMidpoint().x + 150;
		// var followY = dad.getMidpoint().y - 100;
		// // camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

		// switch (dad.curCharacter)
		// {
		// 	case "spooky":
		// 		followY = dad.getMidpoint().y - 30;
		// 	case "mom" | "mom-car":
		// 		followY = dad.getMidpoint().y;
		// 	case 'senpai':
		// 		followY = dad.getMidpoint().y - 430;
		// 		followX = dad.getMidpoint().x - 100;
		// 	case 'senpai-angry':
		// 		followY = dad.getMidpoint().y - 430;
		// 		followX = dad.getMidpoint().x - 100;
		// 	case 'spirit':
		// 		followY = dad.getMidpoint().y;
		// }

		/*if (dad.curCharacter == 'mom')
			vocals.volume = 1; */

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		// camMove(followX, followY, 1.9, FlxEase.quintOut, "dad");

		var followX = 0.0;
		var followY = 0.0;

		if (dad.initWidth > -1)
		{
			followX = dad.x + dad.initWidth / 2 + 150 + (dad.facing == dad.initFacing ? 1 : -1) * dad.camOffsets[0] * dad.scale.x;
			followY = dad.y + dad.initHeight / 2 - 100 + dad.camOffsets[1] * dad.scale.y;
		}
		else
		{
			followX = dad.x + dad.width / 2 + 150;
			followY = dad.y + dad.height / 2 - 100;
		}

		camMove(followX, followY, 1.9, FlxEase.quintOut, "dad");
	}

	function camFocusBF()
	{
		// var followX = boyfriend.getMidpoint().x - 100;
		// var followY = boyfriend.getMidpoint().y - 100;

		// switch (curStage)
		// {
		// 	case 'spooky':
		// 		followY = boyfriend.getMidpoint().y - 125;
		// 	case 'limo':
		// 		followX = boyfriend.getMidpoint().x - 300;
		// 	case 'mall':
		// 		followY = boyfriend.getMidpoint().y - 200;
		// 	case 'school':
		// 		followX = boyfriend.getMidpoint().x - 200;
		// 		followY = boyfriend.getMidpoint().y - 225;
		// 	case 'schoolEvil':
		// 		followX = boyfriend.getMidpoint().x - 200;
		// 		followY = boyfriend.getMidpoint().y - 225;
		// }

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			camChangeZoom(1, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		// camMove(followX, followY, 1.9, FlxEase.quintOut, "bf");

		var followX = 0.0;
		var followY = 0.0;

		if (boyfriend.initWidth > -1)
		{
			followX = boyfriend.x
				+ boyfriend.initWidth / 2
				- 100
				+ (boyfriend.facing == boyfriend.initFacing ? 1 : -1) * boyfriend.camOffsets[0] * boyfriend.scale.x;
			followY = boyfriend.y + boyfriend.initHeight / 2 - 100 + boyfriend.camOffsets[1] * boyfriend.scale.y;
		}
		else
		{
			followX = boyfriend.x + boyfriend.width / 2 - 100;
			followY = boyfriend.y + boyfriend.height / 2 - 100;
		}

		camMove(followX, followY, 1.9, FlxEase.quintOut, "bf");
	}

	function camMove(_x:Float, _y:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_focus:String = "",
			?_onComplete:Null<TweenCallback> = null):Void
	{
		if (_onComplete == null)
		{
			_onComplete = function(tween:FlxTween)
			{
			};
		}

		camTween.cancel();
		camTween = FlxTween.tween(camFollow, {x: _x, y: _y}, _time, {ease: _ease, onComplete: _onComplete});
		camFocus = _focus;
	}

	function camChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void
	{
		if (_onComplete == null)
		{
			_onComplete = function(tween:FlxTween)
			{
			};
		}

		camZoomTween.cancel();
		camZoomTween = FlxTween.tween(FlxG.camera, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
	}

	function uiChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void
	{
		if (_onComplete == null)
		{
			_onComplete = function(tween:FlxTween)
			{
			};
		}

		uiZoomTween.cancel();
		uiZoomTween = FlxTween.tween(camHUD, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
	}

	function uiBop(?_camZoom:Float = 0.01, ?_uiZoom:Float = 0.02)
	{
		if (autoZoom)
		{
			camZoomTween.cancel();
			FlxG.camera.zoom = defaultCamZoom + _camZoom;
			camChangeZoom(defaultCamZoom, 0.6, FlxEase.quintOut);
		}

		if (autoUi)
		{
			uiZoomTween.cancel();
			camHUD.zoom = 1 + _uiZoom;
			uiChangeZoom(1, 0.6, FlxEase.quintOut);
		}
	}

	// function inRange(a:Float, b:Float, tolerance:Float)
	// {
	// 	return (a <= b + tolerance && a >= b - tolerance);
	// }
	// function pauseMP4s()
	// {
	// 	for (i in 0...addedMP4s.length)
	// 	{
	// 		if (addedMP4s[i] == null)
	// 			continue;
	// 		if (addedMP4s[i].vlcBitmap == null)
	// 			continue;
	// 		if (!addedMP4s[i].vlcBitmap.isPlaying)
	// 			continue;
	// 		addedMP4s[i].pause();
	// 	}
	// }
	// function resumeMP4s()
	// {
	// 	if (paused)
	// 		return;
	// 	for (i in 0...addedMP4s.length)
	// 	{
	// 		if (addedMP4s[i] == null)
	// 			continue;
	// 		if (addedMP4s[i].vlcBitmap == null)
	// 			continue;
	// 		if (addedMP4s[i].vlcBitmap.isPlaying)
	// 			continue;
	// 		addedMP4s[i].resume();
	// 	}
	// }

	function muteBF()
	{
		// vocals.volume = 0;
		bfVoice.volume = 0;
	}

	function unmuteBF()
	{
		// vocals.volume = 1 * volumeMultiplier;
		bfVoice.volume = 1 * volumeMultiplier;
	}

	function doPause()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		// pauseMP4s();
		noiseSound.pause();
		AudioStreamThing.pauseGroup();

		PlayerSettings.menuControls();

		openSubState(new PauseSubState());
	}

	function killNote(note:Note)
	{
		note.kill();
	}

	override public function destroy()
	{
		// for (func in onDestroy)
		// {
		// 	if (func != null)
		// 		func();
		// }
		// onDestroy.resize(0);
		// onDestroy = null;
		if (goodParticle != null)
		{
			goodParticle.stop();
			goodParticle.destroy();
		}
		goodParticle = null;
		if (coolParticle != null)
		{
			coolParticle.stop();
			coolParticle.destroy();
		}
		coolParticle = null;
		if (powerupParticle != null)
		{
			powerupParticle.stop();
			powerupParticle.destroy();
		}
		powerupParticle = null;
		frontSprites.resize(0);
		frontSprites = null;
		bopSprites.resize(0);
		bopSprites = null;
		for (array in allFX)
		{
			array.resize(0);
		}
		allFX.resize(0);
		allFX = null;
		donePreloads.resize(0);
		donePreloads = null;
		doneNotePreloads.resize(0);
		doneNotePreloads = null;
		strumTweens = FlxDestroyUtil.destroyArray(strumTweens);
		FlxDestroyUtil.destroyArray(xWiggleTween);
		FlxDestroyUtil.destroyArray(yWiggleTween);
		xWiggleTween = null;
		yWiggleTween = null;
		notePositions = null;
		// if (vocals != null)
		// {
		// 	vocals.destroy();
		// 	vocals = null;
		// }
		if (musicStream != null)
		{
			musicStream.destroy();
			musicStream = null;
		}
		voices.clear();
		voices = null;
		if (dadVoice != null)
		{
			dadVoice.destroy();
			dadVoice = null;
		}
		if (bfVoice != null)
		{
			bfVoice.destroy();
			bfVoice = null;
		}
		// AudioStreamThing.destroyEngine();
		if (healthBarBG != null && healthBarBG.graphic != null)
		{
			if (healthBarBG.graphic.bitmap != null)
			{
				healthBarBG.graphic.bitmap.disposeImage();
				healthBarBG.graphic.bitmap.dispose();
				healthBarBG.graphic.bitmap = null;
			}
			healthBarBG.graphic.destroy();
			healthBarBG.graphic = null;
		}
		healthBarBG = FlxDestroyUtil.destroy(healthBarBG);
		healthBarP1 = FlxDestroyUtil.destroy(healthBarP1);
		healthBarP2.clipRect = FlxDestroyUtil.put(healthBarP2.clipRect);
		healthBarP2 = FlxDestroyUtil.destroy(healthBarP2);
		drunkTween = FlxDestroyUtil.destroy(drunkTween);
		effectTimer = FlxDestroyUtil.destroy(effectTimer);
		camTween = FlxDestroyUtil.destroy(camTween);
		camZoomTween = FlxDestroyUtil.destroy(camZoomTween);
		uiZoomTween = FlxDestroyUtil.destroy(uiZoomTween);
		dad = FlxDestroyUtil.destroy(dad);
		gf = FlxDestroyUtil.destroy(gf);
		boyfriend = FlxDestroyUtil.destroy(boyfriend);
		notes = FlxDestroyUtil.destroy(notes);
		arrowNotes = FlxDestroyUtil.destroy(arrowNotes);
		sustainNotes = FlxDestroyUtil.destroy(sustainNotes);
		// if (unspawnNotes != null)
		// 	unspawnNotes.resize(0);
		// unspawnNotes = null;
		strumLine = FlxDestroyUtil.destroy(strumLine);
		playerStrums = FlxDestroyUtil.destroy(playerStrums);
		enemyStrums = FlxDestroyUtil.destroy(enemyStrums);
		splashTweens = FlxDestroyUtil.destroyArray(splashTweens);
		splashTweens2 = FlxDestroyUtil.destroyArray(splashTweens2);
		comboUI = FlxDestroyUtil.destroy(comboUI);
		trainSound = FlxDestroyUtil.destroy(trainSound);
		waterSprite = FlxDestroyUtil.destroy(waterSprite);
		waterTween1 = FlxDestroyUtil.destroy(waterTween1);
		waterTween2 = FlxDestroyUtil.destroy(waterTween2);
		waterTween3 = FlxDestroyUtil.destroy(waterTween3);
		horiBars = FlxDestroyUtil.destroy(horiBars);
		ghotis = FlxDestroyUtil.destroy(ghotis);
		fishBack = FlxDestroyUtil.destroy(fishBack);
		fishFront = FlxDestroyUtil.destroy(fishFront);
		for (item in filters)
		{
			item = null;
		}
		filters = null;
		for (item in filtersGame)
		{
			item = null;
		}
		filtersGame = null;
		for (item in filterMap)
		{
			item = null;
		}
		filterMap.clear();
		filterMap = null;
		// blurEffect = null;
		waterFilter2 = null;
		waterFilter = null;
		// errorMessages = FlxDestroyUtil.destroy(errorMessages);
		noiseSound = FlxDestroyUtil.destroy(noiseSound);
		spellPrompts = FlxDestroyUtil.destroyArray(spellPrompts);
		startTimer = FlxDestroyUtil.destroy(startTimer);
		// if (instance == this)
		// 	instance = null;
		FlxG.cameras.remove(camGame);
		FlxG.cameras.remove(camOverlay);
		FlxG.cameras.remove(camHUD);
		FlxG.cameras.remove(camNotes);
		FlxG.cameras.remove(camUnderTop);
		FlxG.cameras.remove(camSpellPrompts);
		FlxG.cameras.remove(camTop);
		camGame = FlxDestroyUtil.destroy(camGame);
		camOverlay = FlxDestroyUtil.destroy(camOverlay);
		camHUD = FlxDestroyUtil.destroy(camHUD);
		camNotes = FlxDestroyUtil.destroy(camNotes);
		camUnderTop = FlxDestroyUtil.destroy(camUnderTop);
		camSpellPrompts = FlxDestroyUtil.destroy(camSpellPrompts);
		camTop = FlxDestroyUtil.destroy(camTop);
		camParticles = FlxDestroyUtil.destroy(camParticles);
		if (validWords != null)
			validWords.resize(0);
		validWords = null;
		// FlxG.cameras.reset();
		if (pendingNotes != null)
		{
			for (note in pendingNotes)
			{
				note.destroy();
			}
			pendingNotes.resize(0);
		}
		pendingNotes = null;
		noteMap.clear();
		noteMap = null;
		Note.clearColorz();
		// originalNoteColors.clear();
		// originalNoteColors = null;
		super.destroy();
		// Cashew.destroyAll();
	}

	override public function onResize(newWidth:Int, newHeight:Int)
	{
		@:privateAccess
		if (waterFilter != null)
		{
			camNotes.setFilters(null);
			camGame.setFilters(null);
			camNotes.flashSprite.cacheAsBitmap = false;
			camGame.flashSprite.cacheAsBitmap = false;
			if (camNotes.flashSprite.__cacheBitmap != null)
			{
				camNotes.flashSprite.__cacheBitmap.__cleanup();
				camNotes.flashSprite.__cacheBitmap = null;
			}
			if (camNotes.flashSprite.__cacheBitmapData != null)
			{
				camNotes.flashSprite.__cacheBitmapData.dispose();
				camNotes.flashSprite.__cacheBitmapData = null;
			}
			if (camGame.flashSprite.__cacheBitmap != null)
			{
				camGame.flashSprite.__cacheBitmap.__cleanup();
				camGame.flashSprite.__cacheBitmap = null;
			}
			if (camGame.flashSprite.__cacheBitmapData != null)
			{
				camGame.flashSprite.__cacheBitmapData.dispose();
				camGame.flashSprite.__cacheBitmapData = null;
			}
		}
		super.onResize(newWidth, newHeight);
		if (waterFilter != null)
		{
			camNotes.setFilters(filters);
			camGame.setFilters(filtersGame);
		}
	}

	override public function onFocusLost():Void
	{
		if (canPause && !paused)
			doPause();
		super.onFocusLost();
	}

	override public function onFocus()
	{
		super.onFocus();
	}

	override public function switchState(_state:FlxState)
	{
		super.switchState(_state);
	}

	override public function switchTo(nextState:FlxState):Bool
	{
		// musicStream.pause();
		// // vocals.pause();
		// voices.forEach(function(snd)
		// {
		// 	snd.pause();
		// });
		// pauseMP4s();
		AudioStreamThing.pauseGroup();

		if (xWiggle != null && yWiggle != null && xWiggleTween != null && yWiggleTween != null)
		{
			xWiggle = [0, 0, 0, 0];
			yWiggle = [0, 0, 0, 0];
			for (i in [xWiggleTween, yWiggleTween])
			{
				for (j in i)
				{
					if (j != null && j.active)
						j.cancel();
				}
			}
		}

		if (drunkTween != null && drunkTween.active)
		{
			drunkTween.cancel();
		}

		if (effectTimer != null && effectTimer.active)
			effectTimer.cancel();

		if (startTimer != null && startTimer.active)
			startTimer.cancel();

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyShitTap);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyShitRelease);

		return super.switchTo(nextState);
	}

	inline function getSongPos()
	{
		if (useStreamPos)
			return (startingSong ? Conductor.songPosition : musicStream.time);
		else
			return Conductor.songPosition;
	}
}

class NotePool extends FlxTypedGroup<Note>
{
	override public function recycle(?ObjectClass:Class<Note>, ?ObjectFactory:Void->Note, Force:Bool = false, Revive:Bool = true):Note
	{
		var basic:FlxBasic = null;
		basic = getFirstAvailable(ObjectClass, Force);

		if (basic != null)
		{
			if (Revive)
				basic.revive();
			return cast basic;
		}

		return recycleCreateObject(ObjectClass, ObjectFactory);
	}

	override public function getFirstAvailable(?ObjectClass:Class<Note>, Force:Bool = false):Note
	{
		var i:Int = 0;
		var basic:Note = null;

		while (i < length)
		{
			basic = members[i++];

			if (basic != null && !basic.exists)
			{
				if (members[i - 1].isAvailable && (members[i - 1].onStrumTime == null || (members[i - 1].didSpecialStuff)))
				{
					members[i - 1].isAvailable = false;
					return members[i - 1];
				}
			}
		}
		return null;
	}
}

class PendingNote
{
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var prevNote:PendingNote;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var rootNote:PendingNote;
	public var noteType:Int;
	public var notePitch:Int;
	public var notePreset:Int;
	public var noteVolume:Float;
	public var noteLength:Float;
	public var isLeafNote:Bool;

	public function new(_strumTime:Float, _noteData:Int, ?_prevNote:PendingNote, _sustainNote:Bool, ?_sustainLength:Float, ?_rootNote:PendingNote,
			_noteType:Int, _mustHit:Bool, _pitch:Int, _preset:Int, _vol:Float, _length:Float)
	{
		strumTime = _strumTime;
		noteData = _noteData;
		prevNote = _prevNote;
		isSustainNote = _sustainNote;
		sustainLength = _sustainLength;
		rootNote = _rootNote;
		noteType = _noteType;
		mustPress = _mustHit;
		notePitch = _pitch;
		notePreset = _preset;
		noteVolume = _vol;
		noteLength = _length;
	}

	public function destroy()
	{
		prevNote = null;
		rootNote = null;
	}
}
