import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class FontAtlasThing extends FlxNestedSprite
{
	public var allCaps:Bool;

	var reference:FlxNestedSprite = new FlxNestedSprite();
	var _text:String;
	var cam:FlxCamera;

	public var text(get, set):String;

	var pool:FlxTypedGroup<FlxNestedSprite> = new FlxTypedGroup<FlxNestedSprite>();

	override public function new(atlas:FlxAtlasFrames, cam:FlxCamera, allCaps:Bool = false, ?X:Float, ?Y:Float)
	{
		super(X, Y);
		this.allCaps = allCaps;
		this.cam = cam;
		reference.frames = atlas;
		var normalizeMap:Map<String, String> = [];
		var readyChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890&[]=;!~`.-";
		if (!allCaps)
			readyChars += "abcdefghijklmnopqrstuvwxyz";
		for (char in readyChars.split(""))
			normalizeMap.set(char, char);

		var realNames = ["?", "*", "<", ">", "/", "\\", " ", '"', "'", "_", ":", "&"];
		var xmlNames = [
			"_question", "_asterisk", "_less", "_greater", "_slash", "_backslash", "_space", "_quotedbl", "_quotesingle", "_underscore", "_colon", "_ampersand"
		];

		for (i in 0...xmlNames.length)
			normalizeMap.set(xmlNames[i], realNames[i]);
		for (name in normalizeMap.keys())
			reference.animation.addByPrefix(normalizeMap[name], name, 0, false);
		reference.updateHitbox();
		reference.antialiasing = true;
		reference.cameras = [cam];
		loadGraphic(FlxGraphic.fromRectangle(1, 1, FlxColor.TRANSPARENT));
	}

	function cloneCreator():FlxNestedSprite
	{
		var sprite:FlxNestedSprite = new FlxNestedSprite();
		sprite.loadGraphicFromSprite(reference);
		sprite.cameras = [cam];
		return sprite;
	}

	public function setText(text:String)
	{
		if (_text != text)
		{
			_text = text;
			refreshSprite();
		}
	}

	public function setScale(scaleFactor:Float = 1.0)
	{
		scale.x = scale.y = scaleFactor;
		refreshSprite();
	}

	public function refreshSprite()
	{
		killEverything();
		var prevChar:FlxNestedSprite = null;
		var yOffset:Float = 0;
		var newLine:Bool = false;

		var maxX:Float = -999999;
		var maxY:Float = -999999;
		for (char in _text.split(""))
		{
			switch (char)
			{
				case "\n":
					yOffset += reference.frameHeight;
					newLine = true;
				case "\r":
					continue;
				default:
					var charToPlay = (allCaps ? char.toUpperCase() : char);
					var sprite = pool.recycle(FlxNestedSprite, cloneCreator);
					if (sprite.animation.getNameList().contains(charToPlay))
						sprite.animation.play(charToPlay, true);
					else
						sprite.animation.play("?", true);
					sprite.updateHitbox();
					if (prevChar == null)
						sprite.relativeX = sprite.relativeY = 0;
					else
					{
						if (newLine)
							sprite.relativeX = 0;
						else
							sprite.relativeX = prevChar.relativeX + prevChar.frameWidth;
						sprite.relativeY = yOffset;
					}
					maxX = Math.max(maxX, sprite.relativeX + sprite.frameWidth);
					maxY = Math.max(maxY, sprite.relativeY + sprite.frameHeight);
					add(sprite);
					prevChar = sprite;
					newLine = false;
			}
		}
		frameWidth = Std.int(Math.ceil(maxX));
		frameHeight = Std.int(Math.ceil(maxY));
		updateHitbox();
	}

	function killEverything()
	{
		for (child in children)
		{
			child.kill();
			child.scale.x = child.scale.y = 1;
			child.relativeScale.x = child.relativeScale.y = 1;
			child.color = FlxColor.WHITE;
		}
		children.resize(0);
	}

	override public function updateHitbox()
	{
		width = Math.abs(scale.x) * frameWidth;
		height = Math.abs(scale.y) * frameHeight;
		offset.set(-scale.x / 2 * (width - frameWidth), -scale.y / 2 * (height - frameHeight));
		centerOrigin();
	}

	override public function destroy()
	{
		reference = FlxDestroyUtil.destroy(reference);
		pool = FlxDestroyUtil.destroy(pool);
		_text = null;
		super.destroy();
	}

	public function get_text()
	{
		return _text;
	}

	public function set_text(text:String)
	{
		setText(text);
		return text;
	}
}
