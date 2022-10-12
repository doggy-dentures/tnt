package;

import config.Config;
import openfl.system.System;
import flixel.FlxG;
import flixel.util.FlxColor;
import sys.FileSystem;
import openfl.display3D.Context3DTextureFormat;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var fpsDisplay:FPS_Mem;

	// #if web
	// 	var vHandler:VideoHandler;
	// #elseif desktop
	// 	var webmHandle:WebmHandler;
	// #end
	// public static var novid:Bool = Sys.args().contains("-novid");
	public static var novid = true;
	public static var flippymode:Bool = Sys.args().contains("-flippymode");

	public static var characters:Array<String> = [];
	public static var characterNames:Array<String> = [];
	public static var characterQuotes:Array<String> = [];
	public static var characterDesc:Array<String> = [];
	public static var characterCredits:Array<String> = [];
	public static var characterCampaigns:Map<String, Array<Array<String>>> = [];
	public static var characterColors:Map<String, FlxColor> = [];
	public static var charToSong:Map<String, String> = [];

	public static var lol:AudioStreamThing;

	public static function addCharacter(who:String, name:String, quote:String, desc:String, song:String, color:FlxColor = FlxColor.WHITE, ?credit:String)
	{
		characters.push(who);
		characterNames.push(name);
		characterQuotes.push(quote);
		characterDesc.push(desc);
		characterCredits.push(credit);
		characterColors[who] = color;
		charToSong[who] = song;
	}

	public static function setCampaign(who:String, campaign:Array<String>, difficulties:Array<String>)
	{
		var songs:Array<String> = [];
		var diffs:Array<String> = [];
		for (char in campaign)
		{
			songs.push(charToSong[char]);
			if (char == 'prisma2')
				campaign[campaign.indexOf('prisma2')] = 'prisma';
		}
		for (diff in difficulties)
		{
			switch (diff)
			{
				case 'normal':
					diffs.push("");
				default:
					diffs.push("-" + diff);
			}
		}

		characterCampaigns[who] = [songs, diffs, campaign];
	}

	public static function music(path:String, vol:Float = 1, looping = true)
	{
		if (lol != null)
		{
			lol.stop();
			lol.destroy();
		}
		lol = new AudioStreamThing(path);
		lol.volume = vol;
		lol.looping = looping;
		lol.play();
	}

	public static function unmusic()
	{
		if (lol != null)
		{
			lol.stop();
			lol.destroy();
		}
		lol = null;
	}

	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, Startup, 1, 144, 144, true));

		openfl.Lib.current.stage.application.onExit.add(function(code)
		{
			AudioStreamThing.destroyEverything();
			deleteDirRecursively("assets/temp");
		});

		#if !mobile
		fpsDisplay = new FPS_Mem(10, 3, 0xFFFFFF);
		fpsDisplay.showFPS = true;
		addChild(fpsDisplay);
		switch (FlxG.save.data.fpsDisplayValue)
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
		#end

		// On web builds, video tends to lag quite a bit, so this just helps it run a bit faster.
		// #if web
		// VideoHandler.MAX_FPS = 30;
		// #end

		FlxG.signals.postStateSwitch.add(function()
		{
			System.gc();
			// cpp.vm.Gc.compact();
			// System.gc();
		});

		// FlxG.signals.preStateCreate.add(function(_)
		// {
		// 	Cashew.destroyAll();
		// });

		trace("-=Args=-");
		trace("novid: " + novid);
		trace("flippymode: " + flippymode);

		addCharacter("bf", "Boyfriend", "Beep.",
			"An up-and-coming singer trying to prove himself in front of his girlfriend and her parents. He may not be the sharpest tool in the shed, but he's got a knack for rap battles.",
			"Kickin", 0x31b0d1);
		addCharacter("dad", "Daddy Dearest", "Hands off my daughter.",
			"An ex-rockstar who has since settled down with Mommy Mearest. Currently spends his time trying to thwart the relationship between Boyfriend and his daughter.",
			"Demoniac", 0xaf66ce);
		addCharacter("spooky", "Skid & Pump", "It's spooky month!",
			"A pair of happy-go-lucky kids who love to celebrate the month of October. They tend to sing together. They also don't seem to ever take off their halloween costumes.",
			"Revenant", 0xffa245);
		addCharacter("pico", "Pico", "Don't worry, the safety's off.",
			"A crazed gunman or an assassin? Either way, he's got a firearm and he's not afraid to use it. Has a surprisingly deep voice despite his short stature.",
			"Trigger-Happy", 0xb7d855);
		addCharacter("mom", "Mommy Mearest", "Take care not to scratch the limo.",
			"A singer who's married to Daddy Dearest. She has a few henchman by her side and tends to cruise with them on her limo. Doesn't approve of the relationship between Boyfriend and her daughter.",
			"Playtime", 0xd8558e);
		addCharacter("lily", "Lily", "You're dinner tonight...literally.",
			"An amnesiac zombie who knows nothing but her name. In order to find her memory, she usually eats humans and travels around various towns.",
			"Zombie-Flower", 0xff99cc);
		addCharacter("atlanta", "Atlanta", "I'm pretty so-Fish-ticated myself!",
			"A literal fish out of water, she's trying her best to fit in with the land-dwellers. All while cracking fish puns in every sentence, she can be pretty obnoxious at times.",
			"Tune-A-Fish", 0x4c6b9b, "Ket Overkill");

		characterColors["gf"] = 0xa5004d;
		characterColors["prisma"] = 0x9fd5ed;
		characterColors["skid"] = 0xa2a2a2;
		characterColors["pump"] = 0xd57e00;
		characterColors["senpai"] = 0xfac146;
		characterColors["tankman"] = 0x383838;
		charToSong["prisma"] = "Fresnel";
		charToSong["prisma2"] = "SiO2";

		setCampaign("bf", ["spooky", "pico", "atlanta", "lily", "mom", "dad", "prisma2"], ["easy", "easy", "normal", "normal", "hard", "hard", "normal"]);
		setCampaign("dad", ["atlanta", "mom", "pico", "lily", "spooky", "bf", "prisma"], ["easy", "easy", "normal", "normal", "hard", "hard", "normal"]);
		setCampaign("spooky", ["lily", "bf", "pico", "mom", "dad", "atlanta", "prisma"], ["easy", "easy", "normal", "normal", "hard", "hard", "normal"]);
		setCampaign("pico", ["dad", "lily", "bf", "spooky", "atlanta", "mom", "prisma2"], ["easy", "easy", "normal", "normal", "hard", "hard", "normal"]);
		setCampaign("mom", ["pico", "dad", "spooky", "atlanta", "bf", "lily", "prisma"], ["easy", "easy", "normal", "normal", "hard", "hard", "normal"]);
		setCampaign("lily", ["bf", "atlanta", "dad", "mom", "pico", "spooky", "prisma2"], ["easy", "easy", "normal", "normal", "hard", "hard", "normal"]);
		setCampaign("atlanta", ["mom", "spooky", "bf", "dad", "lily", "pico", "prisma2"], ["easy", "easy", "normal", "normal", "hard", "hard", "normal"]);
	}

	public static function changeFramerate(newRate:Int)
	{
		FlxG.updateFramerate = FlxG.drawFramerate = newRate;
	}

	public static function fpsSwitch()
	{
		if (Config.noFpsCap)
		{
			changeFramerate(999);
		}
		else
			changeFramerate(144);
	}

	static function deleteDirRecursively(path:String):Void
	{
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			var entries = FileSystem.readDirectory(path);
			if (entries != null)
			{
				for (entry in entries)
				{
					if (FileSystem.isDirectory(path + '/' + entry))
					{
						deleteDirRecursively(path + '/' + entry);
						FileSystem.deleteDirectory(path + '/' + entry);
					}
					else
					{
						FileSystem.deleteFile(path + '/' + entry);
					}
				}
				FileSystem.deleteDirectory(path);
			}
		}
	}
}
