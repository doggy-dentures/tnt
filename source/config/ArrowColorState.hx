package config;

import flixel.FlxSubState;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class ArrowColorState extends MusicBeatState
{
	var arrows:FlxTypedGroup<FlxExtendedSprite>;

	override public function create()
	{
		persistentDraw = false;
		FlxG.mouse.visible = true;
		var bg = new FlxSprite(-80).loadGraphic(Paths.getImageFunk('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		var backText = new FlxTextThing(5, FlxG.height - 37, 0, "ESCAPE/BACKSPACE - Back to Menu\nDELETE - Reset to Defaults\n", 16);
		backText.scrollFactor.set();
		backText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(backText);

		Note.loadColorz("user");

		arrows = new FlxTypedGroup<FlxExtendedSprite>();
		for (i in 0...4)
		{
			var arrow = new ArrowSprite(i);
			arrow.x = (i + 1) / 5 * FlxG.width - arrow.width / 2;
			arrow.screenCenter(Y);
			arrow.ID = i;
			arrows.add(arrow);
		}
		add(arrows);

		var text:FlxTextThing = new FlxTextThing(0, 0, 0, "Click a note to change its colors\n", 64);
		text.setFormat(Paths.font("Funkin-Bold", "otf"), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		text.y = 10;
		text.antialiasing = true;
		text.disposeImage();
		add(text);
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if ((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE))
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			exit();
		}
		if (FlxG.keys.justPressed.DELETE)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Config.resetArrowColors();
			exit();
		}
		for (i in 0...arrows.length)
		{
			if (arrows.members[i].mouseOver && FlxG.mouse.justPressed)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				openSubState(new ArrowChanger(i));
				break;
			}
		}
	}

	override public function destroy()
	{
		arrows = FlxDestroyUtil.destroy(arrows);
		Note.clearColorz();
		super.destroy();
	}

	function exit():Void
	{
		FlxG.mouse.visible = false;
		Config.write(Config.offset, Config.accuracy, Config.healthMultiplier, Config.healthDrainMultiplier, Config.comboType, Config.downscroll,
			Config.noteGlow, Config.ghostTapType, Config.noFpsCap, Config.controllerScheme, Config.bgDim, Config.noteSplash, Config.fpsDisplayValue,
			Config.arrowColors, Config.comboParticles, Config.scrollSpeed);
		switchState(new ConfigMenu());
	}
}

class ArrowChanger extends FlxSubState
{
	var arrow:FlxExtendedSprite;
	var texts:FlxTypedGroup<FlxText>;
	var buttons:FlxTypedGroup<FlxExtendedSprite>;
	var buttons2:FlxTypedGroup<FlxExtendedSprite>;
	var colorPreviews:FlxTypedGroup<FlxSprite>;
	var arrowIndex:Int;
	var mode:Int = 0;
	var part:Int;
	var msg:FlxText;
	var picker:RGBPicker;
	var ok:FlxTextThing;
	var no:FlxTextThing;
	var backText:FlxTextThing;

	override public function new(arrowIndex:Int)
	{
		this.arrowIndex = arrowIndex;
		super();
	}

	override public function create()
	{
		var bg = new FlxSprite(-80).loadGraphic(Paths.getImageFunk('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		backText = new FlxTextThing(5, FlxG.height - 37, 0, "ESCAPE/BACKSPACE - Back\n", 16);
		backText.scrollFactor.set();
		backText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(backText);
		arrow = new ArrowSprite(arrowIndex);
		arrow.x = 50;
		arrow.screenCenter(Y);
		add(arrow);
		msg = new FlxTextThing(0, 0, 0, "Click which part of the note to change", 64);
		msg.setFormat(Paths.font("Funkin-Bold", "otf"), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msg.screenCenter(X);
		msg.y = 10;
		msg.antialiasing = true;
		add(msg);
		buttons = new FlxTypedGroup<FlxExtendedSprite>();
		texts = new FlxTypedGroup<FlxText>();
		colorPreviews = new FlxTypedGroup<FlxSprite>();
		for (i in 0...3)
		{
			var text:FlxTextThing = new FlxTextThing(0, 0, 256);
			switch (i)
			{
				case 0:
					text.text = "Outline";
				case 1:
					text.text = "Inside";
				case 2:
					text.text = "Base";
			}
			text.setFormat(Paths.font("Funkin-Bold", "otf"), 64, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.setPosition(arrow.x + arrow.width + 50, (i + 1) / 4 * (FlxG.height - msg.height) - text.height / 2 + msg.height);
			text.antialiasing = true;
			var button = new FlxExtendedSprite();
			button.makeGraphic(1, 1, FlxColor.TRANSPARENT);
			button.setGraphicSize(Math.ceil(text.width) + 64, Math.ceil(text.height));
			button.setPosition(text.x, text.y);
			button.updateHitbox();
			buttons.add(button);
			var spr = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
			spr.setGraphicSize(64, 64);
			spr.updateHitbox();
			spr.setPosition(text.x + text.width + 5, text.y + text.height / 2 - spr.height / 2);
			colorPreviews.add(spr);
			text.text += "\n";
			text.disposeImage();
			texts.add(text);
		}
		msg.text += "\n";
		add(texts);
		add(buttons);
		picker = new RGBPicker(Paths.getImagePNG("colorpicker1"), Paths.getImagePNG("colorpicker2"), 0.5);
		picker.setPosition(600, 200);
		picker.visible = false;
		add(picker);
		ok = new FlxTextThing(0, 0, 0, "Confirm");
		ok.setFormat(Paths.font("Funkin-Bold", "otf"), 64, 0x5fcc5a, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ok.antialiasing = true;
		no = new FlxTextThing(0, 0, 0, "Cancel");
		no.setFormat(Paths.font("Funkin-Bold", "otf"), 64, 0xc93838, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		no.antialiasing = true;
		ok.setPosition(picker.x + 400, picker.y);
		no.setPosition(picker.x + 400, picker.y + 200);
		add(ok);
		add(no);
		buttons2 = new FlxTypedGroup<FlxExtendedSprite>();
		for (i in [ok, no])
		{
			var button = new FlxExtendedSprite();
			button.makeGraphic(1, 1, FlxColor.TRANSPARENT);
			button.setGraphicSize(Math.ceil(i.width), Math.ceil(i.height));
			button.setPosition(i.x, i.y);
			button.updateHitbox();
			buttons2.add(button);
		}
		ok.visible = false;
		no.visible = false;
		ok.text += "\n";
		no.text += "\n";
		ok.disposeImage();
		no.disposeImage();
		add(buttons2);
		add(colorPreviews);
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		switch (mode)
		{
			case 0:
				for (i in 0...buttons.length)
				{
					var button = buttons.members[i];
					if (button.mouseOver && FlxG.mouse.justPressed)
					{
						part = i;
						mode = 1;
						picker.overrideColor = getPartColor(i);
						// picker.preset(getPartColor(i));
						FlxG.sound.play(Paths.sound('scrollMenu'));
						break;
					}
				}
				picker.visible = false;
				ok.visible = false;
				no.visible = false;
				colorPreviews.visible = true;
				texts.visible = true;
				backText.visible = true;
				for (i in 0...colorPreviews.length)
				{
					colorPreviews.members[i].color = getPartColor(i);
				}
				if ((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE))
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					close();
				}
				msg.text = "Click which part of the note to change\n";
				msg.screenCenter(X);
			case 1:
				texts.visible = false;
				picker.visible = true;
				ok.visible = true;
				no.visible = true;
				colorPreviews.visible = false;
				backText.visible = false;
				for (i in 0...buttons2.length)
				{
					var button = buttons2.members[i];
					if (button.mouseOver && FlxG.mouse.justPressed)
					{
						if (i == 0)
						{
							confirmColor();
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						else
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
						}
						updateShader(getPartColor(part));
						mode = 0;
						return;
					}
				}
				msg.text = "Choose a color\n";
				msg.screenCenter(X);
				updateShader(picker.pickedColor);
		}
	}

	function getPartColor(index:Int)
	{
		var arrow = getCurArrow();
		var str = switch (index)
		{
			case 0:
				arrow.outer;
			case 1:
				arrow.inner;
			default:
				arrow.base;
		}
		return FlxColor.fromString("0x" + str);
	}

	function getCurArrow()
	{
		return switch (arrowIndex)
		{
			case 0:
				Config.arrowColors.left;
			case 1:
				Config.arrowColors.down;
			case 2:
				Config.arrowColors.up;
			default:
				Config.arrowColors.right;
		}
	}

	function confirmColor()
	{
		var arrow = switch (arrowIndex)
		{
			case 0:
				Config.arrowColors.left;
			case 1:
				Config.arrowColors.down;
			case 2:
				Config.arrowColors.up;
			default:
				Config.arrowColors.right;
		}
		switch (part)
		{
			case 0:
				arrow.outer = picker.pickedColor.toHexString(false, false);
			case 1:
				arrow.inner = picker.pickedColor.toHexString(false, false);
			default:
				arrow.base = picker.pickedColor.toHexString(false, false);
		}
	}

	function updateShader(color:FlxColor)
	{
		switch (part)
		{
			case 0:
				cast(arrow.shader, Colorz).colorOuter.value = [color.redFloat, color.greenFloat, color.blueFloat];
			case 1:
				cast(arrow.shader, Colorz).colorInner.value = [color.redFloat, color.greenFloat, color.blueFloat];
			case 2:
				cast(arrow.shader, Colorz).colorBase.value = [color.redFloat, color.greenFloat, color.blueFloat];
		}
	}

	override public function close()
	{
		super.close();
	}

	override public function destroy()
	{
		arrow = FlxDestroyUtil.destroy(arrow);
		buttons = FlxDestroyUtil.destroy(buttons);
		msg = FlxDestroyUtil.destroy(msg);
		texts = FlxDestroyUtil.destroy(texts);
		picker = FlxDestroyUtil.destroy(picker);
		ok = FlxDestroyUtil.destroy(ok);
		no = FlxDestroyUtil.destroy(no);
		buttons2 = FlxDestroyUtil.destroy(buttons2);
		colorPreviews = FlxDestroyUtil.destroy(colorPreviews);
		backText = FlxDestroyUtil.destroy(backText);
		super.destroy();
	}
}

class ArrowSprite extends FlxExtendedSprite
{
	override public function new(index:Int)
	{
		super();
		frames = Paths.getSparrowAtlasFunk("notes/note");
		animation.addByPrefix('Scroll', 'scroll', 0, false);
		animation.play("Scroll");
		antialiasing = true;
		switch (index)
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
		shader = Note.getShader(index, true);
		updateHitbox();
	}
}
