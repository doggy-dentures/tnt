import flixel.FlxCamera;
import flixel.FlxSprite;
import openfl.particle.events.ParticleEvent;
import ParticleThing.ParticleJSON;
import openfl.display.BlendMode;
import lime.ui.FileDialog;
import haxe.io.Bytes;
import haxe.Json;
import flixel.group.FlxSpriteGroup;
import openfl.particle.data.GPUGroupFourAttribute;
import openfl.particle.data.GPUFourAttribute;
import openfl.particle.data.GPUGroupAttribute;
import openfl.particle.data.GPURandomTwoAttribute;
import flixel.input.FlxInput;
import flixel.addons.ui.FlxUIText;
import sys.FileSystem;
import openfl.particle.data.GPUTwoAttribute;
import openfl.particle.data.GPUOneAttribute;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import flixel.addons.ui.FlxUIButton;
import openfl.particle.GPUParticleSprite;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;

class ParticleState extends MusicBeatState
{
	var att:ParticleJSON;
	var camParticle = new ParticleCam();
	var particle:ParticleThing;
	var inputStuff:Map<String, TheInput> = [];
	var inputContainer:FlxSpriteGroup = new FlxSpriteGroup();
	var ok:FlxUIButton;
	var stop:FlxUIButton;
	var imp:FlxUIButton;
	var exp:FlxUIButton;
	var bgButton:FlxUIButton;
	var bgC:FlxSprite = new FlxSprite();
	var bg:FlxSprite = new FlxSprite();

	var list = [
		"texture", "xPos", "yPos", "blendMode", "dynamicEmitPoint", "forcedReset", "counts", "widthRange", "heightRange", "life", "lifeVariance", "duration",
		"emitRotation", "velocity1", "velocity2", "gravity1", "gravity2", "acceleration1", "acceleration2", "tangential1", "tangential2", "scaleXAttribute1",
		"scaleXAttribute2", "scaleYAttribute1", "scaleYAttribute2", "rotationAttribute1", "rotationAttribute2", "colorAttribute1", "colorAttribute2",
		"colorAttribute3", "colorAttribute4", "colorAttribute5", "colorAttribute6", "colorAttribute7", "colorAttribute8"
	];

	var singleOnly = [
		"texture", "counts", "widthRange", "heightRange", "life", "lifeVariance", "duration", "blendMode", "dynamicEmitPoint", "forcedReset", "xPos", "yPos"
	];

	override function create()
	{
		Main.unmusic();
		super.create();
		bgC.makeGraphic(1, 1);
		bgC.setGraphicSize(FlxG.width, FlxG.height);
		bgC.updateHitbox();
		bgC.color = 0xff0000;
		add(bgC);
		bg.loadGraphic(Paths.getImageFunk('stage/stageback2'));
		bg.screenCenter(XY);
		add(bg);
		FlxG.mouse.visible = true;
		FlxG.cameras.reset(camParticle);
		att = blank();

		var prevInput:TheInput = null;
		var regexp:EReg = ~/[0-9]/;

		for (i in 0...list.length)
		{
			var str = list[i];
			var onlyOne = singleOnly.contains(str);
			var hasNum = regexp.match(list[i]);
			var x:Float = 0;
			var y:Float = 100;
			if (prevInput != null)
			{
				if (hasNum && str.charAt(str.length - 1) != '1' && str.charAt(str.length - 1) != '5')
				{
					x = prevInput.x + 25 + 5;
					y = prevInput.y;
				}
				else
				{
					y = prevInput.y + 20;
				}
			}
			var name = (hasNum ? list[i].substring(0, list[i].length - 1) : list[i]);
			var input = new TheInput(x, y, (onlyOne ? 50 : 25));
			input.name = name;
			inputContainer.add(input);
			input.callback = callbackThing;

			if (prevInput != null)
			{
				if (prevInput.name != name)
				{
					inputContainer.add(new FlxUIText(prevInput.x + prevInput.width, prevInput.y, 0, prevInput.name));
				}
			}

			prevInput = input;
			if (onlyOne)
			{
				inputStuff[str] = input;
			}
			else
			{
				inputStuff[str + "A"] = input;
				inputStuff[str + "B"] = new TheInput(x + 25, y, 25);
				inputContainer.add(inputStuff[str + "B"]);
				inputStuff[str + "B"].name = name;
				inputStuff[str + "B"].callback = callbackThing;
				prevInput = inputStuff[str + "B"];
			}
		}
		var textStuff = new FlxTextThing(prevInput.x + prevInput.width, prevInput.y - prevInput.height / 2, 0, "color", 8);
		textStuff.disposeImage();
		textStuff.active = false;
		inputContainer.add(textStuff);

		add(inputContainer);

		syncInputText();

		ok = new FlxUIButton(0, 0, "Play", function()
		{
			if (!FileSystem.exists(Paths.image("particles/" + att.texture)))
			{
				trace("BAD");
				return;
			}
			reinitParticle();
			inputContainer.active = false;
			inputContainer.visible = false;
			setupParticle();
			particle.start();
			camParticle.addParticle(particle);
		});
		stop = new FlxUIButton(ok.x + ok.width + 5, 0, "Stop", function()
		{
			inputContainer.active = true;
			inputContainer.visible = true;
			stopParticle();
		});

		exp = new FlxUIButton(stop.x + stop.width + 5, 0, "Export", function()
		{
			var bytes = Bytes.ofString(Json.stringify(att));
			var byteFile = new FileDialog();
			byteFile.save(bytes, "json", att.texture + ".json", "Save your particle");
		});

		imp = new FlxUIButton(exp.x + exp.width + 5, 0, "Import", function()
		{
			var byteFile = new FileDialog();
			byteFile.onOpen.add(function(res)
			{
				byteFile.onOpen.removeAll();
				var bytes:Bytes = res;
				att = Json.parse(bytes.toString());
				syncInputText();
			});
			byteFile.open("json", null, "Import your particle");
		});

		bgButton = new FlxUIButton(imp.x + imp.width + 5, 0, "BG", function()
		{
			switch (bgC.color)
			{
				case 0x000000:
					bgC.color = 0xffffff;
				case 0xffffff:
					bgC.color = 0x888888;
				case 0x888888:
					bgC.color = 0xff0000;
					bg.visible = true;
				case 0xff0000:
					bgC.color = 0x000000;
					bg.visible = false;
			}
		});

		ok.y = stop.y = exp.y = imp.y = bgButton.y = FlxG.height - ok.height;

		add(ok);
		add(stop);
		inputContainer.add(exp);
		inputContainer.add(imp);
		add(bgButton);
	}

	function reinitParticle()
	{
		stopParticle();
		particle = new ParticleThing();
	}

	function stopParticle()
	{
		if (particle == null)
			return;
		particle.stop();
		camParticle.removeParticle(particle);
		particle.time = 0;
		// particle.dispose();
	}

	function callbackThing(text:String, name:String)
	{
		switch (name)
		{
			case 'texture':
				att.texture = text;
			case 'xPos':
				att.xPos = Std.parseInt(text);
			case 'yPos':
				att.yPos = Std.parseInt(text);
			case 'blendMode':
				att.blendMode = text;
			case 'dynamicEmitPoint':
				att.dynamicEmitPoint = (StringTools.trim(text.toLowerCase()) == 'true' ? true : false);
			case 'forcedReset':
				att.forcedReset = (StringTools.trim(text.toLowerCase()) == 'true' ? true : false);
			case 'counts':
				att.counts = Std.parseInt(text);
			case 'widthRange':
				att.widthRange = Std.parseFloat(text);
			case 'heightRange':
				att.heightRange = Std.parseFloat(text);
			case 'life':
				att.life = Std.parseFloat(text);
			case 'lifeVariance':
				att.lifeVariance = Std.parseFloat(text);
			case 'duration':
				att.duration = Std.parseFloat(text);
			case 'emitRotation':
				att.emitRotation = arrStuff2(name);
			case 'velocity':
				att.velocity = arrStuff(name, 4);
			case 'gravity':
				att.gravity = arrStuff(name, 4);
			case 'acceleration':
				att.acceleration = arrStuff(name, 4);
			case 'tangential':
				att.tangential = arrStuff(name, 4);
			case 'scaleXAttribute':
				att.scaleXAttribute = arrStuff(name, 4);
			case 'scaleYAttribute':
				att.scaleYAttribute = arrStuff(name, 4);
			case 'rotationAttribute':
				att.rotationAttribute = arrStuff(name, 4);
			case 'colorAttribute':
				att.colorAttribute = arrStuff(name, 16);
		}
	}

	function syncInputText()
	{
		for (str in list)
		{
			var oneOnly = singleOnly.contains(str);
			var regexp:EReg = ~/[0-9]/;
			var hasNum = regexp.match(str);
			if (oneOnly)
			{
				inputStuff[str].text = Std.string(Reflect.getProperty(att, str));
			}
			else if (hasNum)
			{
				var name:String = str.substring(0, str.length - 1);
				var offset:Int = Std.parseInt(str.charAt(str.length - 1)) * 2 - 2;
				inputStuff[str + "A"].text = Std.string(Reflect.getProperty(att, name)[offset]);
				inputStuff[str + "B"].text = Std.string(Reflect.getProperty(att, name)[offset + 1]);
			}
			else
			{
				inputStuff[str + "A"].text = Std.string(Reflect.getProperty(att, str)[0]);
				inputStuff[str + "B"].text = Std.string(Reflect.getProperty(att, str)[1]);
			}
		}
	}

	function setupParticle()
	{
		particle.parse(att);
	}

	function arrStuff2(name:String)
	{
		var arr:Array<Float> = [];
		arr.push(Std.parseFloat(inputStuff[name + "A"].text));
		arr.push(Std.parseFloat(inputStuff[name + "B"].text));
		return arr;
	}

	function arrStuff(name:String, count:Int)
	{
		var arr:Array<Float> = [];
		for (i in 1...(Std.int(count / 2) + 1))
		{
			arr.push(Std.parseFloat(inputStuff[name + i + "A"].text));
			arr.push(Std.parseFloat(inputStuff[name + i + "B"].text));
		}
		return arr;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			switchState(new MainMenuState());
		}
	}

	function blank():ParticleJSON
	{
		return {
			'texture': "",
			'counts': 1,
			'widthRange': 0,
			'heightRange': 0,
			'life': 1,
			'lifeVariance': 0,
			'duration': 0,
			'emitRotation': [0, 0],
			'velocity': [0, 0, 0, 0],
			'gravity': [0, 0, 0, 0],
			'acceleration': [0, 0, 0, 0],
			'tangential': [0, 0, 0, 0],
			'scaleXAttribute': [1, 1, 1, 1],
			'scaleYAttribute': [1, 1, 1, 1],
			'rotationAttribute': [0, 0, 0, 0],
			'colorAttribute': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			'blendMode': "normal",
			"dynamicEmitPoint": false,
			"forcedReset": false,
			"xPos": 640,
			"yPos": 360
		};
	}

	override public function destroy()
	{
		if (particle != null)
		{
			particle.stop();
			particle.destroy();
		}
		camParticle = FlxDestroyUtil.destroy(camParticle);
		super.destroy();
	}
}

class TheInput extends FlxInputText
{
	public var name:String;

	override private function onChange(action:String):Void
	{
		if (callback != null)
		{
			callback(text, name);
		}
	}

	override private function prepareCharBoundaries(numChars:Int):Void
	{
		if (_charBoundaries == null)
		{
			_charBoundaries = [];
		}

		if (_charBoundaries.length > numChars)
		{
			var diff:Int = _charBoundaries.length - numChars;
			for (i in 0...diff)
			{
				_charBoundaries[_charBoundaries.length - 1].put();
				_charBoundaries.pop();
			}
		}

		for (i in 0...numChars)
		{
			if (_charBoundaries.length - 1 < i)
			{
				_charBoundaries.push(flixel.math.FlxRect.get(0, 0, 0, 0));
			}
		}
	}

	override public function destroy():Void
	{
		#if sys
		if (_charBoundaries != null)
		{
			while (_charBoundaries.length > 0)
			{
				_charBoundaries[_charBoundaries.length - 1].put();
				_charBoundaries.pop();
			}
			_charBoundaries = null;
		}
		#end

		super.destroy();
	}
}
