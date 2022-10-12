package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class ComboPopup extends FlxSpriteGroup
{
	public var ratingPosition:Array<Float> = [0.0, 0.0];
	public var numberPosition:Array<Float> = [0.0, 0.0];
	public var breakPosition:Array<Float> = [0.0, 0.0];

	public var ratingScale:Float = 0.7;
	public var numberScale:Float = 0.6;
	public var breakScale:Float = 0.6;

	public var accelScale:Float = 1;
	public var velocityScale:Float = 1;

	public var ratingInfo:ComboStuff;
	public var numberInfo:ComboStuff;
	public var comboBreakInfo:ComboStuff;

	var comboPool:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var ratingPool:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var breakPool:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	// @:noCompletion public static final GRAPHIC = 0;
	// @:noCompletion public static final WIDTH = 1;
	// @:noCompletion public static final HEIGHT = 2;
	// @:noCompletion public static final AA = 3;
	// @:noCompletion public static final X = 0;
	// @:noCompletion public static final Y = 1;
	@:noCompletion public static final ratingList = ["sick", "good", "bad", "shit"];

	/**
		The info arrays should be filled with [FlxGraphicAsset, Frame Width, Frame Height, Antialiasing]
		Scales go in order of [Ratings, Numbers, Combo Break]
	**/
	public function new(_x:Float, _y:Float, _ratingInfo:ComboStuff, _numberInfo:ComboStuff, _comboBreakInfo:ComboStuff, ?_scale:Array<Float>)
	{
		super(_x, _y);

		ratingInfo = _ratingInfo;
		numberInfo = _numberInfo;
		comboBreakInfo = _comboBreakInfo;

		if (_scale == null)
		{
			_scale = [0.7, 0.6, 0.6];
		}

		setScales(_scale, false);
	}

	/**
		Sets the scales for all the elements and re-aligns them.
	**/
	public function setScales(_scale:Array<Float>, ?positionReset:Bool = true):Void
	{
		if (positionReset)
		{
			numberPosition[1] -= (numberInfo.height * numberScale) * 1.6;
			breakPosition[1] += (comboBreakInfo.height * breakScale) / 2;
		}

		ratingScale = _scale[0];
		numberScale = _scale[1];
		breakScale = _scale[2];

		numberPosition[1] += (numberInfo.height * numberScale) * 1.6;
		breakPosition[1] -= (comboBreakInfo.height * breakScale) / 2;
	}

	/**
		Causes the combo count to pop up with the given integer. Returns without effect if the integer is less than 0.
	**/
	public function comboPopup(_combo:Int):Void
	{
		if (_combo < 0)
		{
			return;
		}

		var combo:String = Std.string(_combo);

		for (i in 0...combo.length)
		{
			// var digit = new FlxSprite(numberPosition[0] + (numberInfo.width * numberScale * i),
			// 	numberPosition[1]).loadGraphic(numberInfo.graphic, true, numberInfo.width, numberInfo.height);
			var digit = comboPool.recycle(FlxSprite, digitFactory);
			digit.setPosition(numberPosition[0] + (numberInfo.width * numberScale * i), numberPosition[1]);
			digit.setGraphicSize(Std.int(digit.width * numberScale));
			
			digit.animation.play(combo.charAt(i));

			add(digit);

			digit.alpha = 1;
			digit.acceleration.y = FlxG.random.int(150, 250) * accelScale;
			digit.velocity.y = -FlxG.random.int(100, 130) * velocityScale;
			digit.velocity.x = FlxG.random.int(-5, 5) * velocityScale;

			FlxTween.tween(digit, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					digit.kill();
					remove(digit);
					FlxDestroyUtil.destroy(tween);
				},
				startDelay: Conductor.crochet * 0.00075
			});
		}

		return;
	}

	function digitFactory()
	{
		var sprite = new FlxSprite().loadGraphic(Paths.getImageFunk(numberInfo.graphic), true, numberInfo.width, numberInfo.height);
		sprite.antialiasing = numberInfo.antialiasing;
		for (i in 0...10)
			sprite.animation.add(Std.string(i), [i], 0, false);
		return sprite;
	}

	/**
		Causes a note rating to pop up with the specified rating. Returns without effect if the rating isn't in `ratingList`.
	**/
	public function ratingPopup(_rating:String):Void
	{
		var rating = ratingList.indexOf(_rating);
		if (rating == -1)
		{
			return;
		}

		// var ratingSprite = new FlxSprite(ratingPosition[0], ratingPosition[1]).loadGraphic(ratingInfo.graphic, true, ratingInfo.width, ratingInfo.height);
		var ratingSprite = ratingPool.recycle(FlxSprite, ratingFactory);
		ratingSprite.setPosition(ratingPosition[0], ratingPosition[1]);
		ratingSprite.setGraphicSize(Std.int(ratingSprite.width * ratingScale));
		ratingSprite.animation.play(_rating);

		ratingSprite.alpha = 1;
		ratingSprite.acceleration.y = 250 * accelScale;
		ratingSprite.velocity.y = -FlxG.random.int(100, 130) * velocityScale;
		ratingSprite.velocity.x = -FlxG.random.int(-5, 5) * velocityScale;

		add(ratingSprite);

		FlxTween.tween(ratingSprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				ratingSprite.kill();
				remove(ratingSprite);
				FlxDestroyUtil.destroy(tween);
			},
			startDelay: Conductor.crochet * 0.00075
		});

		return;
	}

	function ratingFactory()
	{
		var sprite = new FlxSprite().loadGraphic(Paths.getImageFunk(ratingInfo.graphic), true, ratingInfo.width, ratingInfo.height);
		for (i in 0...ratingList.length)
			sprite.animation.add(ratingList[i], [i], 0, false);
		sprite.antialiasing = ratingInfo.antialiasing;
		return sprite;
	}

	/**
		Causes the combo broken text to pop up.
	**/
	public function breakPopup():Void
	{
		// var breakSprite = new FlxSprite(breakPosition[0], breakPosition[1]).loadGraphic(comboBreakInfo.graphic);
		var breakSprite = breakPool.recycle(FlxSprite, breakFactory);
		breakSprite.setPosition(breakPosition[0], breakPosition[1]);
		breakSprite.setGraphicSize(Std.int(breakSprite.width * breakScale));

		breakSprite.alpha = 1;
		breakSprite.acceleration.y = 300 * accelScale;
		breakSprite.velocity.y = -FlxG.random.int(80, 130) * velocityScale;
		breakSprite.velocity.x = -FlxG.random.int(-5, 5) * velocityScale;

		add(breakSprite);

		FlxTween.tween(breakSprite, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				breakSprite.kill();
				remove(breakSprite);
				FlxDestroyUtil.destroy(tween);
			},
			startDelay: Conductor.crochet * 0.0015
		});

		return;
	}

	function breakFactory()
	{
		var sprite = new FlxSprite().loadGraphic(Paths.getImageFunk(comboBreakInfo.graphic));
		sprite.antialiasing = comboBreakInfo.antialiasing;
		return sprite;
	}

	override public function destroy()
	{
		comboPool = FlxDestroyUtil.destroy(comboPool);
		ratingPool = FlxDestroyUtil.destroy(ratingPool);
		breakPool = FlxDestroyUtil.destroy(breakPool);
		super.destroy();
	}
}

typedef ComboStuff =
{
	var graphic:String;
	var width:Int;
	var height:Int;
	var antialiasing:Bool;
}
