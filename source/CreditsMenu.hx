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

class CreditsMenu extends MusicBeatState
{
	var names:Array<FlxTextThing> = [];
	var selected:Int = 0;
	var selectedName:FlxTextThing;
	var selectedDesc:FlxTextThing;
    var pressEnter:FlxTextThing;

	var creditStuff:Array<Array<String>> = [
		[
			"DoggyDentures",
			"Director\n\nProgrammer\n\nLead Composer"
		],
		[
			"Ket Overkill",
			"Lead Artist\n\nCreator of Atlanta and Related Assets\n\nSelect Screen Portrait Artist\n\nDialogue Portrait Artist\n\nBackground Artist of BF's Stage\n\nCreator of PRIS-ma\n\nCreated the Logo",
			"https://twitter.com/ket_overkill"
		],
        [
			"Kanpei",
			"Creator of Lily and Related Assets\n\nComposer of Reunited Flower\n\nDialogue Portait Artist\n\nSelect Screen Portrait Artist",
			"https://twitter.com/kanpei_kankitu"
		],
        [
			"Kitikusan",
			"Dialogue Portait Artist",
			"https://gamebanana.com/members/1779935"
		],
		[
			"TheMaurii",
			"Created the Title Screen BF Art",
			"https://gamebanana.com/members/1726911"
		]
	];

	override function create()
	{
		// openfl.Lib.current.stage.frameRate = 144;
		Main.changeFramerate(144);
		var backdrop = new CrappyTile(Paths.getImagePNG('tile3'), 50, 50);
		add(backdrop);

		var smallbox = new FlxSprite(12, 15).loadGraphic(Paths.image('credits/smallbox'));
		var bigbox = new FlxSprite(431, 15).loadGraphic(Paths.image('credits/bigbox'));
		add(smallbox);
		add(bigbox);

		for (i in 0...creditStuff.length)
		{
			var person = new FlxTextThing(0, 0);
			person.setFormat(Paths.font("Funkin-Bold", "otf"), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
			person.text = creditStuff[i][0] + "\n\n";
			person.setPosition(smallbox.x + smallbox.width / 2 - person.width / 2, 32 + 48 * i);
			person.antialiasing = true;

			names.push(person);
		}

		selectedName = new FlxTextThing(0, 0, bigbox.width * 0.8);
		selectedName.setFormat(Paths.font("Funkin-Bold", "otf"), 84, FlxColor.WHITE, FlxTextAlign.CENTER);
		selectedName.setPosition(bigbox.x + bigbox.width / 2 - selectedName.width / 2, 32);
		selectedName.antialiasing = true;

		selectedDesc = new FlxTextThing(0, 0, bigbox.width * 0.8);
		selectedDesc.setFormat(Paths.font("Funkin-Bold", "otf"), 40, FlxColor.WHITE, FlxTextAlign.CENTER);
		selectedDesc.setPosition(bigbox.x + bigbox.width / 2 - selectedDesc.width / 2, selectedName.y + selectedName.height + 48);
		selectedDesc.antialiasing = true;

        pressEnter = new FlxTextThing(0, 0, bigbox.width * 0.8);
        pressEnter.text = "Press ENTER to open website";
        pressEnter.setFormat(Paths.font("Funkin-Bold", "otf"), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
        pressEnter.setPosition(bigbox.x + bigbox.width / 2 - selectedDesc.width / 2, bigbox.y + bigbox.height - pressEnter.height - 16);
		pressEnter.antialiasing = true;

		changeSelection();

		for (name in names)
			add(name);

		add(selectedName);
		add(selectedDesc);
        add(pressEnter);

		super.create();
	}

	function changeSelection(dir:Int = 0)
	{
		selected += dir;
		if (selected >= names.length)
			selected = 0;
		if (selected < 0)
			selected = names.length - 1;

		for (i in 0...names.length)
		{
			if (i == selected)
				names[i].color = FlxColor.ORANGE;
			else
				names[i].color = FlxColor.WHITE;
		}

		if (creditStuff[selected] != null)
		{
			if (creditStuff[selected][0] != null)
				selectedName.text = creditStuff[selected][0] + "\n\n";
			if (creditStuff[selected][1] != null)
				selectedDesc.text = creditStuff[selected][1] + "\n\n";
			if (creditStuff[selected][2] != null)
				pressEnter.visible = true;
            else
                pressEnter.visible = false;
		}

		if (dir != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			switchState(new MainMenuState());
		}

		if (accepted)
		{
			if (creditStuff[selected] != null && creditStuff[selected][2] != null)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.openURL(creditStuff[selected][2]);
			}
		}
	}
}
