package;

import flixel.math.FlxMath;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class RGBPicker extends FlxTypedSpriteGroup<FlxSprite>
{
	public var pickedColor(default, null):FlxColor;

	var box:SBPicker;
	var slider:HSlider;
	var boxIcon:FlxSprite;
	var sliderIcon:FlxSprite;
	var preview:FlxSprite;
	var redText:FlxTextThing;
	var greenText:FlxTextThing;
	var blueText:FlxTextThing;
	var redInput:FlxInputText;
	var greenInput:FlxInputText;
	var blueInput:FlxInputText;

	public var overrideColor:Null<FlxColor> = null;

	override public function new(boxAsset:FlxGraphicAsset, sliderAsset:FlxGraphicAsset, scale:Float = 1.0, X:Float = 0, Y:Float = 0, MaxSize:Int = 0)
	{
		super(X, Y, MaxSize);
		box = new SBPicker(0, 0, boxAsset);
		box.scale.set(scale, scale);
		box.updateHitbox();
		add(box);
		slider = new HSlider(0, 0, sliderAsset);
		slider.scale.set(scale, scale);
		slider.updateHitbox();
		slider.setPosition(box.width*1.05 + 10, 0);
		add(slider);
		preview = new FlxSprite();
		preview.makeGraphic(1, 1, FlxColor.WHITE);
		preview.scale.set(256 * scale, 256 * scale);
		preview.updateHitbox();
		preview.setPosition(0, box.y + box.height*1.05 + 10);
		add(preview);
		boxIcon = new FlxSprite();
		add(boxIcon);
		sliderIcon = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		sliderIcon.setGraphicSize(Math.ceil(slider.width), 3);
		add(sliderIcon);
		redText = new FlxTextThing(0, 0, 0, "R: ");
		redText.setFormat(null, Math.floor(60 * scale), FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		redText.setPosition(preview.x + preview.width, preview.y + preview.height);
		greenText = new FlxTextThing(0, 0, 0, "G: ");
		greenText.setFormat(null, Math.floor(60 * scale), FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		greenText.setPosition(preview.x + preview.width, redText.y + redText.height);
		blueText = new FlxTextThing(0, 0, 0, "B: ");
		blueText.setFormat(null, Math.floor(60 * scale), FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		blueText.setPosition(preview.x + preview.width, greenText.y + greenText.height);
		add(redText);
		add(greenText);
		add(blueText);
		redInput = new FlxInputText(0, 0, Math.floor(170 * scale), null, Math.floor(28 * scale));
		greenInput = new FlxInputText(0, 0, Math.floor(170 * scale), null, Math.floor(28 * scale));
		blueInput = new FlxInputText(0, 0, Math.floor(170 * scale), null, Math.floor(28 * scale));
		for (input in [redInput, greenInput, blueInput])
		{
			input.filterMode = FlxInputText.ONLY_NUMERIC;
			input.lines = 1;
			input.maxLength = 4;
			input.focusLost = function()
			{
				var num = Std.parseInt(input.text);
				if (num > 255)
				{
					input.text = "255";
				}
				if (num < 0 || input.text.length == 0)
				{
					input.text = "0";
				}
			};
			add(input);
		}
	}

	public function preset(color:FlxColor)
	{
		slider.setHue(Math.round(color.hue * 1000) / 1000);
		box.setSat(Math.round(color.saturation * 1000) / 1000);
		box.setBri(Math.round(color.brightness * 1000) / 1000);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Std.parseInt(redInput.text) != pickedColor.red
			|| Std.parseInt(greenInput.text) != pickedColor.green
			|| Std.parseInt(blueInput.text) != pickedColor.blue)
		{
			overrideColor = FlxColor.fromRGB(Std.parseInt(redInput.text), Std.parseInt(greenInput.text), Std.parseInt(blueInput.text));
		}
		else if (slider.wasTouched || box.wasTouched)
		{
			overrideColor = null;
		}

		if (overrideColor != null)
		{
			if (pickedColor != overrideColor)
			{
				preset(overrideColor);
				box.setBoxHue(slider.hue);
			}
			pickedColor = overrideColor;
		}
		else
		{
			box.setBoxHue(slider.hue);
			pickedColor = FlxColor.fromHSB(slider.hue, box.saturation, box.brightness);
		}
		preview.color = pickedColor;
		boxIcon.setPosition(box.x + box.xCoord - boxIcon.width / 2, box.y + box.yCoord - boxIcon.height / 2);
		sliderIcon.setPosition(slider.x + slider.width / 2 - sliderIcon.width / 2, slider.y + slider.yCoord - sliderIcon.height / 2);
		redText.setPosition(preview.x + preview.width, preview.y);
		greenText.setPosition(preview.x + preview.width, redText.y + redText.height);
		blueText.setPosition(preview.x + preview.width, greenText.y + greenText.height);
		if (!redInput.hasFocus && !greenInput.hasFocus && !blueInput.hasFocus)
		{
			redInput.text = Std.string(pickedColor.red);
			greenInput.text = Std.string(pickedColor.green);
			blueInput.text = Std.string(pickedColor.blue);
		}
		redInput.setPosition(redText.x + redText.width, redText.y + redText.height / 2 - redInput.height / 2);
		greenInput.setPosition(greenText.x + greenText.width, greenText.y + greenText.height / 2 - greenInput.height / 2);
		blueInput.setPosition(blueText.x + blueText.width, blueText.y + blueText.height / 2 - blueInput.height / 2);
	}

	override public function destroy()
	{
		box = FlxDestroyUtil.destroy(box);
		slider = FlxDestroyUtil.destroy(slider);
		boxIcon = FlxDestroyUtil.destroy(boxIcon);
		sliderIcon = FlxDestroyUtil.destroy(sliderIcon);
		preview = FlxDestroyUtil.destroy(preview);
		redText = FlxDestroyUtil.destroy(redText);
		greenText = FlxDestroyUtil.destroy(greenText);
		blueText = FlxDestroyUtil.destroy(blueText);
		redInput = FlxDestroyUtil.destroy(redInput);
		greenInput = FlxDestroyUtil.destroy(greenInput);
		blueInput = FlxDestroyUtil.destroy(blueInput);
		super.destroy();
	}
}

class SBPicker extends FlxSprite
{
	public var brightness(default, null):Float;
	public var saturation(default, null):Float;
	public var xCoord(default, null):Float;
	public var yCoord(default, null):Float;
	public var wasTouched(default, null):Bool;

	var theShader:Colorz;

	public function setBoxHue(hue:Float)
	{
		var shaderColor = FlxColor.fromHSB(hue, 1, 1);
		theShader.colorInner.value = [shaderColor.redFloat, shaderColor.greenFloat, shaderColor.blueFloat];
	}

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):FlxSprite
	{
		super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		theShader = new Colorz(0xff0000, FlxColor.BLACK, FlxColor.WHITE);
		shader = theShader;
		return this;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.pressed && FlxG.mouse.x >= (x - width * 0.05) && FlxG.mouse.y >= (y - height * 0.05) && FlxG.mouse.x <= x + width * 1.05
			&& FlxG.mouse.y <= y + height * 1.05)
		{
			var mouseX = FlxMath.bound(FlxG.mouse.x, x, x + width);
			var mouseY = FlxMath.bound(FlxG.mouse.y, y, y + height);
			saturation = (mouseX - x) / width;
			brightness = 1 - ((mouseY - y) / width);
			wasTouched = true;
		}
		else
		{
			wasTouched = false;
		}
		xCoord = saturation * width;
		yCoord = (brightness - 1) * width * -1;
	}

	override public function destroy()
	{
		theShader = null;
		super.destroy();
	}

	public function setSat(newSat:Float)
	{
		// xCoord = newSat * width;
		saturation = newSat;
	}

	public function setBri(newB:Float)
	{
		// yCoord = (newB - 1) * width * -1;
		brightness = newB;
	}
}

class HSlider extends FlxSprite
{
	public var hue(default, null):Float;
	public var yCoord(default, null):Float;
	public var wasTouched(default, null):Bool;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.pressed && FlxG.mouse.x >= (x - width * 0.05) && FlxG.mouse.y >= (y - height * 0.05) && FlxG.mouse.x <= x + width * 1.05
			&& FlxG.mouse.y <= y + height * 1.05)
		{
			var mouseY = FlxMath.bound(FlxG.mouse.y, y, y + height);
			hue = (1 - (mouseY - y) / height) * 360;
			wasTouched = true;
		}
		else
		{
			wasTouched = false;
		}
		yCoord = (hue / 360 - 1) * height * -1;
	}

	public function setHue(newHue:Float)
	{
		hue = newHue;
	}
}
