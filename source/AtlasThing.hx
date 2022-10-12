package;

import flixel.graphics.frames.FlxFrame;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.animation.FlxAnimationController;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import haxe.Json;
import haxe.display.Display.Package;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.utils.Object;

class AtlasThing extends FlxNestedSkewSprite
{
	var pool:Map<String, FlxTypedGroup<FlxNestedSkewSprite>> = [];
	var cloneReference:FlxSprite;
	var curAnim:String = "";
	var curFramerate:Float = 24;
	var curAnimIndex:Int = 0;
	var animTimer:Float = 0;
	var timerMove:Bool = false;
	var prevAnim:String = "";
	var prevElementArray:Array<FlattenedElement> = null;
	var loopList:Map<String, Bool> = [];
	var mappyMap:Map<String, Map<Int, Array<FlattenedElement>>> = [];

	public var onlyTheseAnims:Array<String> = [];
	public var animWidths(default, null):Map<String, Float> = [];
	public var animHeights(default, null):Map<String, Float> = [];
	public var animList(default, null):Array<String> = [];
	public var maxIndex(default, null):Map<String, Int> = [];
	public var curAnimFinished(default, null):Bool = true;
	public var finishCallback:(name:String) -> Void;

	public function loadAtlas(spritemap:FlxGraphicAsset, spritemapJson:String, animationJson:String)
	{
		shouldPassDownAngle = false;
		shouldPassDownScale = false;
		var partsJson:PartsAtlas = Json.parse(StringTools.replace(Assets.getText(spritemapJson), "\uFEFF", ""));
		if (partsJson == null)
		{
			trace("OH NO");
			return;
		}

		cloneReference = new FlxNestedSkewSprite();
		cloneReference.antialiasing = true;
		cloneReference.frames = makeTheFramesOrSomething(spritemap, partsJson);
		// for (anonData in partsJson.ATLAS.SPRITES)
		// {
		// 	var spriteData = anonData.SPRITE;
		// 	cloneReference.animation.addByPrefix(spriteData.name, spriteData.name, 0, false);
		// }
		partsJson = null;

		loadGraphic(FlxGraphic.fromRectangle(1, 1, FlxColor.TRANSPARENT));

		var animJsonAnon = Json.parse(Assets.getText(animationJson));
		var animJson:AnimAtlas;
		if (animJsonAnon.AN != null)
		{
			var newjson = normalizeJson(animJsonAnon);
			animJson = cast newjson;
		}
		else
		{
			animJson = cast animJsonAnon;
			// animJson.ANIMATION = null;
		}
		animJsonAnon = null;

		if (animJson.metadata != null && animJson.metadata.framerate != null)
		{
			curFramerate = animJson.metadata.framerate;
		}

		var fullTimeline:Map<Layer, Array<Frame>> = [];
		for (data in animJson.SYMBOL_DICTIONARY.Symbols)
		{
			if (data.SYMBOL_name != null || data.SYMBOL_name != "")
			{
				animList.push(data.SYMBOL_name);
				for (layer in data.TIMELINE.LAYERS)
				{
					if (fullTimeline[layer] == null)
						fullTimeline[layer] = [];
					for (frame in layer.Frames)
					{
						for (i in 0...frame.duration)
						{
							fullTimeline[layer].push(frame);
						}
					}
					if (maxIndex[data.SYMBOL_name] == null || maxIndex[data.SYMBOL_name] < fullTimeline[layer].length - 1)
						maxIndex[data.SYMBOL_name] = fullTimeline[layer].length - 1;
				}
			}
		}
		prepareAnims(animJson, fullTimeline);
		animJson = null;
		fullTimeline.clear();
		fullTimeline = null;
	}

	public function playAtlasAnim(anim:String, force:Bool = false, index:Int = 0)
	{
		if (curAnimFinished || force)
		{
			if (!animList.contains(anim))
			{
				trace("NO ANIM " + anim + " FOUND");
				return;
			}
			animTimer = 0;
			curAnimFinished = false;
			timerMove = true;
			if (curAnim != "")
				prevElementArray = mappyMap[curAnim][curAnimIndex];
			curAnimIndex = index;
			prevAnim = curAnim;
			curAnim = anim;
			tryStuff(anim, index);
		}
	}

	public function setLooping(name:String, value:Bool)
	{
		loopList[name] = value;
	}

	override public function update(elapsed:Float)
	{
		animTimer += FlxG.elapsed;
		if (timerMove && animTimer * curFramerate > curAnimIndex)
		{
			var pendingIndex = Math.floor(animTimer * curFramerate);
			if (pendingIndex > maxIndex[curAnim])
			{
				if (loopList[curAnim])
				{
					pendingIndex = 0;
					if (curAnim != "")
						prevElementArray = mappyMap[curAnim][curAnimIndex];
					curAnimIndex = pendingIndex;
					tryStuff(curAnim, pendingIndex);
				}
				else
				{
					timerMove = false;
					curAnimFinished = true;
					if (finishCallback != null)
						finishCallback(curAnim);
				}
			}
			else
			{
				if (curAnim != "")
					prevElementArray = mappyMap[curAnim][curAnimIndex];
				curAnimIndex = pendingIndex;
				tryStuff(curAnim, pendingIndex);
			}
		}
		super.update(elapsed);
	}

	public function freezeFrame(anim:String, index:Int = 0)
	{
		if (!animList.contains(anim))
		{
			trace("NO ANIM " + anim + " FOUND");
			return;
		}
		animTimer = 0;
		timerMove = false;
		if (curAnim != "")
			prevElementArray = mappyMap[curAnim][curAnimIndex];
		curAnimIndex = index;
		prevAnim = curAnim;
		curAnim = anim;
		tryStuff(anim, index);
	}

	public function killEverything()
	{
		for (child in children)
		{
			child.killWithChildren();
			child.setRelativeColorTransform();
		}
		children.resize(0);
	}

	function tryStuff(anim:String, index:Int)
	{
		// killEverything();
		var stuffChanged = assembleStuff(anim, index);
		// refreshDimensions();
		if (stuffChanged)
		{
			updateBoundingBox();
		}
	}

	public function puzzlePiecePutTogether(animJson:AnimAtlas, fullTimeline:Map<Layer, Array<Frame>>, name:String, index:Int = 0, parentMatrix:Matrix = null,
			loopType:String = "loop", colorStuff:ColorStuff = null, parentName:String = null, firstFrame:Int = -1)
	{
		for (symbol in animJson.SYMBOL_DICTIONARY.Symbols)
		{
			if (symbol.SYMBOL_name == name)
			{
				for (i in 0...symbol.TIMELINE.LAYERS.length)
				{
					var layer = symbol.TIMELINE.LAYERS[symbol.TIMELINE.LAYERS.length - 1 - i];

					var indexToPlay = (firstFrame == -1 ? index : firstFrame);
					if (indexToPlay > maxIndex[name])
					{
						switch (loopType)
						{
							case 'loop' | "LP":
								indexToPlay = indexToPlay % (maxIndex[name] + 1);
							default:
								indexToPlay = maxIndex[name];
						}
					}

					var frame = fullTimeline[layer][indexToPlay];

					if (true) // lol
					{
						// var index = frame.index;
						// var duration = frame.duration;
						if (frame == null)
						{
							// trace("NULL FRAME FOUND FOR " + name + " WITH INDEX " + indexToPlay + " AT LAYER" + layer.Layer_name);
							continue;
						}

						var elements = frame.elements;
						if (elements != null)
						{
							for (element in elements)
							{
								var spriteInstance = element.ATLAS_SPRITE_instance;
								var symbolInstance = element.SYMBOL_Instance;

								if (spriteInstance != null)
								{
									// var name = spriteInstance.name;
									var newMatrix = new Matrix();

									// CC 2018 format
									if (spriteInstance.Position != null)
									{
										var xPos = spriteInstance.Position.x;
										var yPos = spriteInstance.Position.y;
										newMatrix.tx = xPos;
										newMatrix.ty = yPos;
									}
									// CC 2022 format
									else if (spriteInstance.Matrix3D != null)
									{
										newMatrix.a = spriteInstance.Matrix3D.m00;
										newMatrix.b = spriteInstance.Matrix3D.m01;
										newMatrix.c = spriteInstance.Matrix3D.m10;
										newMatrix.d = spriteInstance.Matrix3D.m11;
										newMatrix.tx = spriteInstance.Matrix3D.m30;
										newMatrix.ty = spriteInstance.Matrix3D.m31;
									}

									if (parentMatrix != null)
									{
										newMatrix.concat(parentMatrix);
									}

									var pName = (parentName == null ? name : parentName);

									if (mappyMap[pName] == null)
										mappyMap[pName] = new Map<Int, Array<FlattenedElement>>();
									if (mappyMap[pName][index] == null)
										mappyMap[pName][index] = [];

									mappyMap[pName][index].push({
										name: new String(spriteInstance.name),
										flattenedMatrix: newMatrix,
										flattenedColor: colorStuff
									});
								}
								// CC 2018 format
								else if (symbolInstance != null && symbolInstance.bitmap != null)
								{
									// var name = symbolInstance.bitmap.name;
									var xPos = symbolInstance.bitmap.Position.x * symbolInstance.Matrix3D.m00
										+ symbolInstance.bitmap.Position.y * symbolInstance.Matrix3D.m10;
									var yPos = symbolInstance.bitmap.Position.y * symbolInstance.Matrix3D.m11
										+ symbolInstance.bitmap.Position.x * symbolInstance.Matrix3D.m01;

									var newMatrix = new Matrix();

									newMatrix.a = symbolInstance.Matrix3D.m00;
									newMatrix.b = symbolInstance.Matrix3D.m01;
									newMatrix.c = symbolInstance.Matrix3D.m10;
									newMatrix.d = symbolInstance.Matrix3D.m11;
									newMatrix.tx = symbolInstance.Matrix3D.m30;
									newMatrix.ty = symbolInstance.Matrix3D.m31;

									newMatrix.translate(xPos, yPos);

									if (parentMatrix != null)
									{
										newMatrix.concat(parentMatrix);
									}

									var newColor:ColorStuff = null;
									if (colorStuff != null && symbolInstance.color != null)
									{
										var t = symbolInstance.color;
										newColor = {
											mode: "Advanced",
											AlphaOffset: colorStuff.AlphaOffset + t.AlphaOffset,
											RedMultiplier: colorStuff.RedMultiplier * t.RedMultiplier,
											alphaMultiplier: colorStuff.alphaMultiplier * t.alphaMultiplier,
											blueMultiplier: colorStuff.blueMultiplier * t.blueMultiplier,
											blueOffset: colorStuff.blueOffset + t.blueOffset,
											greenMultiplier: colorStuff.greenMultiplier * t.greenMultiplier,
											greenOffset: colorStuff.greenOffset + t.greenOffset,
											redOffset: colorStuff.redOffset + t.redOffset,
										};
									}
									else if (colorStuff != null)
									{
										newColor = colorStuff;
									}
									else
									{
										newColor = symbolInstance.color;
									}
									var pName = (parentName == null ? name : parentName);
									if (mappyMap[pName] == null)
										mappyMap[pName] = new Map<Int, Array<FlattenedElement>>();
									if (mappyMap[pName][index] == null)
										mappyMap[pName][index] = [];

									mappyMap[pName][index].push({
										name: new String(symbolInstance.bitmap.name),
										flattenedMatrix: newMatrix,
										flattenedColor: newColor
									});
								}
								else if (symbolInstance != null && symbolInstance.bitmap == null)
								{
									var newMatrix = new Matrix();
									newMatrix.a = symbolInstance.Matrix3D.m00;
									newMatrix.b = symbolInstance.Matrix3D.m01;
									newMatrix.c = symbolInstance.Matrix3D.m10;
									newMatrix.d = symbolInstance.Matrix3D.m11;
									newMatrix.tx = symbolInstance.Matrix3D.m30;
									newMatrix.ty = symbolInstance.Matrix3D.m31;
									if (parentMatrix != null)
									{
										newMatrix.concat(parentMatrix);
									}
									var loopThing = (symbolInstance.loop != null ? symbolInstance.loop : "loop");
									var newColor:ColorStuff = null;
									if (colorStuff != null && symbolInstance.color != null)
									{
										var t = symbolInstance.color;
										newColor = {
											mode: "Advanced",
											AlphaOffset: colorStuff.AlphaOffset + t.AlphaOffset,
											RedMultiplier: colorStuff.RedMultiplier * t.RedMultiplier,
											alphaMultiplier: colorStuff.alphaMultiplier * t.alphaMultiplier,
											blueMultiplier: colorStuff.blueMultiplier * t.blueMultiplier,
											blueOffset: colorStuff.blueOffset + t.blueOffset,
											greenMultiplier: colorStuff.greenMultiplier * t.greenMultiplier,
											greenOffset: colorStuff.greenOffset + t.greenOffset,
											redOffset: colorStuff.redOffset + t.redOffset,
										};
									}
									else if (colorStuff != null)
									{
										newColor = colorStuff;
									}
									else
									{
										newColor = symbolInstance.color;
									}
									var frameToGoto:Int = (symbolInstance.firstFrame == null ? -1 : symbolInstance.firstFrame);
									puzzlePiecePutTogether(animJson, fullTimeline, symbolInstance.SYMBOL_name, index, newMatrix, loopThing, newColor,
										parentName == null ? name : parentName, frameToGoto);
								}
							}
						}
					}
				}
			}
		}
	}

	function assembleStuff(name:String, index:Int = 0, raw:Bool = false):Bool
	{
		if (mappyMap[name] == null)
		{
			trace("MAP OF " + name + " NOT FOUND");
			return false;
		}

		var itsTheSame:Bool = true;
		if (name != prevAnim)
		{
			itsTheSame = false;
		}
		else
		{
			var elements = mappyMap[name][index];
			var ogelements = prevElementArray;
			if (elements != null && ogelements != null)
			{
				for (i in 0...elements.length)
				{
					if (elements[i] == null || ogelements[i] == null)
					{
						itsTheSame = false;
						break;
					}
					else if (elements[i].name != ogelements[i].name)
					{
						itsTheSame = false;
						break;
					}
					else if (elements[i].flattenedMatrix != ogelements[i].flattenedMatrix)
					{
						itsTheSame = false;
						break;
					}
					else if (elements[i].flattenedColor != ogelements[i].flattenedColor)
					{
						itsTheSame = false;
						break;
					}
				}
			}
			if (itsTheSame)
			{
				return false;
			}
		}

		killEverything();
		for (element in mappyMap[name][index])
		{
			var partName = element.name;
			var flattenedMatrix = element.flattenedMatrix;
			var flattenedColor = element.flattenedColor;

			createWithThisPart = partName;
			if (pool[partName] == null)
				pool[partName] = new FlxTypedGroup<FlxNestedSkewSprite>();
			var clone = pool[partName].recycle(FlxNestedSkewSprite, cloneCreator);
			clone.matrixExposed = true;
			// clone.animation.play(partName);
			clone.origin.set(0, 0);
			clone.setPosition(x, y);
			clone.transformMatrix.copyFrom(flattenedMatrix);
			if (!raw)
			{
				if (flipX)
				{
					clone.transformMatrix.scale(-1, 1);
					clone.transformMatrix.translate(animWidths[name], 0);
				}
				if (angle != 0)
				{
					var rad = angle * FlxAngle.TO_RAD;
					clone.transformMatrix.rotate(rad);
					var cos = Math.cos(rad);
					var sin = Math.sin(rad);
					var rotatedX = (animWidths[name] / 2 * cos - animHeights[name] / 2 * sin);
					var thingyX = rotatedX - animWidths[name] / 2;
					var rotatedY = (animWidths[name] / 2 * sin + animHeights[name] / 2 * cos);
					var thingyY = rotatedY - animHeights[name] / 2;
					clone.transformMatrix.translate(-thingyX, -thingyY);
				}
				clone.transformMatrix.scale(scale.x, scale.y);
				if (flattenedColor != null)
				{
					clone.setRelativeColorTransform(flattenedColor.RedMultiplier, flattenedColor.greenMultiplier, flattenedColor.blueMultiplier,
						flattenedColor.alphaMultiplier, flattenedColor.redOffset, flattenedColor.greenOffset, flattenedColor.blueOffset,
						flattenedColor.AlphaOffset);
				}
			}

			add(clone);
		}
		return true;
	}

	var createWithThisPart:String = "";
	function cloneCreator()
	{
		var clone = new FlxNestedSkewSprite();
		clone.loadGraphicFromSprite(cloneReference);
		clone.animation.addByNames(createWithThisPart, [createWithThisPart], 0, false);
		clone.animation.play(createWithThisPart, true);
		return clone;
	}

	function prepareAnims(animJson:AnimAtlas, fullTimeline:Map<Layer, Array<Frame>>)
	{
		for (anim in animList)
		{
			if (onlyTheseAnims.length != 0 && !onlyTheseAnims.contains(anim))
				continue;
			for (i in 0...maxIndex[anim] + 1)
			{
				killEverything();
				puzzlePiecePutTogether(animJson, fullTimeline, anim, i, null, "loop", null, null);
				assembleStuff(anim, i, true);
				refreshDimensions();
				if (animWidths[anim] == null || animWidths[anim] < width)
				{
					animWidths[anim] = width;
				}
				if (animHeights[anim] == null || animHeights[anim] < height)
				{
					animHeights[anim] = height;
				}
			}
		}
	}

	function updateBoundingBox()
	{
		frameWidth = Std.int(Math.ceil(animWidths[curAnim]));
		frameHeight = Std.int(Math.ceil(animHeights[curAnim]));
		width = animWidths[curAnim] * scale.x;
		height = animHeights[curAnim] * scale.y;
	}

	override public function destroy()
	{
		if (pool != null)
		{
			for (partPool in pool)
				partPool = FlxDestroyUtil.destroy(partPool);
			pool.clear();
		}
		pool = null;
		cloneReference = FlxDestroyUtil.destroy(cloneReference);
		if (prevElementArray != null)
		{
			prevElementArray.resize(0);
		}
		prevElementArray = null;
		if (animWidths != null)
		{
			animWidths.clear();
			animWidths = null;
		}
		if (animHeights != null)
		{
			animHeights.clear();
			animHeights = null;
		}
		if (animList != null)
		{
			animList.resize(0);
			animList = null;
		}
		if (maxIndex != null)
		{
			maxIndex.clear();
			maxIndex = null;
		}
		finishCallback = null;
		if (loopList != null)
		{
			loopList.clear();
			loopList = null;
		}
		if (onlyTheseAnims != null)
		{
			onlyTheseAnims.resize(0);
			onlyTheseAnims = null;
		}
		if (mappyMap != null)
		{
			for (nestedMap in mappyMap)
			{
				if (nestedMap != null)
					nestedMap.clear();
			}
			mappyMap.clear();
		}
		mappyMap = null;
		super.destroy();
	}

	static function makeTheFramesOrSomething(Source:FlxGraphicAsset, atlas:PartsAtlas):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)
			return null;

		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || atlas == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		for (anonData in atlas.ATLAS.SPRITES)
		{
			var spriteData = anonData.SPRITE;

			var name = spriteData.name;

			var rotated = spriteData.rotated;

			var rect = FlxRect.get(spriteData.x, spriteData.y, spriteData.w, spriteData.h);

			var size = new Rectangle(0, 0, rect.width, rect.height);

			var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

			var offset = FlxPoint.get(-size.left, -size.top);
			var sourceSize = FlxPoint.get(size.width, size.height);

			frames.addAtlasFrame(rect, sourceSize, offset, name, angle);
		}

		return frames;
	}

	private static function normalizeJson(data:Dynamic):Dynamic
	{
		if (data is Int || data is Float || data is String)
			return data;
		else if (data is Array)
		{
			var newArray = [];
			for (i in 0...data.length)
			{
				newArray[i] = normalizeJson(data[i]);
			}
			return newArray;
		}
		else
		{
			var newObj = {};
			var fields = Reflect.fields(data);
			for (i in 0...fields.length)
			{
				if (fields[i] == "M3D")
				{
					var arr = Reflect.getProperty(data, "M3D");
					var newMatrix:Matrix3DStuff = {
						m00: arr[0],
						m01: arr[1],
						m02: arr[2],
						m03: arr[3],
						m10: arr[4],
						m11: arr[5],
						m12: arr[6],
						m13: arr[7],
						m20: arr[8],
						m21: arr[9],
						m22: arr[10],
						m23: arr[11],
						m30: arr[12],
						m31: arr[13],
						m32: arr[14],
						m33: arr[15]
					};
					Reflect.setField(newObj, "Matrix3D", newMatrix);
				}
				else if (fields[i] == "BM")
				{
					if (Reflect.getProperty(data, "BM") is Float)
					{
						Reflect.setField(newObj, "blueMultiplier", normalizeJson(Reflect.getProperty(data, fields[i])));
					}
					else
					{
						Reflect.setField(newObj, convertKeys[fields[i]], normalizeJson(Reflect.getProperty(data, fields[i])));
					}
				}
				else if (fields[i] != "AN")
					Reflect.setField(newObj, convertKeys[fields[i]], normalizeJson(Reflect.getProperty(data, fields[i])));
			}
			return newObj;
		}
		return data;
	}

	static final convertKeys:Map<String, String> = [
		"AN" => "ANIMATION", "AM" => "alphaMultiplier", "ASI" => "ATLAS_SPRITE_instance", "BM" => "bitmap", "C" => "color", "DU" => "duration",
		"E" => "elements", "FF" => "firstFrame", "FR" => "Frames", "FRT" => "framerate", "I" => "index", "IN" => "Instance_Name", "L" => "LAYERS",
		"LN" => "Layer_name", "LP" => "loop", "M3D" => "Matrix3D", "MD" => "metadata", "M" => "mode", "N" => "name", "POS" => "Rotation", "S" => "Symbols",
		"SD" => "SYMBOL_DICTIONARY", "SI" => "SYMBOL_Instance", "SN" => "SYMBOL_name", "ST" => "symbolType", "TL" => "TIMELINE",
		"TRP" => "transformationPoint", "AD" => "Advanced", "RM" => "RedMultiplier", "GM" => "greenMultiplier", /*"BM" => "blueMultiplier",*/
		"RO" => "redOffset", "GO" => "greenOffset", "BO" => "blueOffset", "AO" => "AlphaOffset"
	];

	override function set_flipX(bool:Bool):Bool
	{
		flipX = bool;
		return bool;
	}

	override public function draw():Void
	{
		checkEmptyFrame();

		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		var shouldRenderChild = false;

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			shouldRenderChild = true;

			getScreenPosition(_point, camera).subtractPoint(offset);

			if (isSimpleRender(camera))
				drawSimple(camera);
			else
				drawComplex(camera);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end

		for (child in children)
		{
			if (child.exists && child.visible)
			{
				child.ignoreScreenBounds = shouldRenderChild;
				child.draw();
			}
		}
	}
}

typedef FlattenedElement =
{
	var name:String;
	var flattenedMatrix:Matrix;
	var flattenedColor:ColorStuff;
}

// spritemap.json stuff
typedef PartsAtlas =
{
	var ATLAS:PartsAtlasInner;
}

typedef PartsAtlasInner =
{
	var SPRITES:Array<PartsAtlasSpriteArray>;
}

typedef PartsAtlasSpriteArray =
{
	var SPRITE:AtlasSprite;
}

typedef AtlasSprite =
{
	var name:String;
	var x:Int;
	var y:Int;
	var w:Int;
	var h:Int;
	var rotated:Bool;
}

// Animation.json stuff
typedef AnimAtlas =
{
	var SYMBOL_DICTIONARY:SymbolDict;
	var metadata:MetaStuff;
	// var ANIMATION:Dynamic;
}

typedef MetaStuff =
{
	var ?framerate:Float;
}

typedef SymbolDict =
{
	var Symbols:Array<Symbol>;
}

typedef Symbol =
{
	var SYMBOL_name:String;
	var TIMELINE:Timeline;
}

typedef Timeline =
{
	var LAYERS:Array<Layer>;
}

typedef Layer =
{
	var Layer_name:String;
	var Frames:Array<Frame>;
}

typedef Frame =
{
	var duration:Int;
	var elements:Array<Elements>;
	var index:Int;
}

typedef Elements =
{
	var ATLAS_SPRITE_instance:SpriteInstance;
	var SYMBOL_Instance:SymbolInstance;
}

typedef SpriteInstance =
{
	var Position:XYStuff;
	var name:String;
	var DecomposedMatrix:DecomposedMatrix;
	var Matrix3D:Matrix3DStuff;
}

typedef XYStuff =
{
	var x:Float;
	var y:Float;
	var z:Float;
}

typedef SymbolInstance =
{
	var Instance_Name:String;
	var SYMBOL_name:String;
	var transformationPoint:XYStuff;
	var DecomposedMatrix:DecomposedMatrix;
	var Matrix3D:Matrix3DStuff;
	var bitmap:BitmapStuff;
	var loop:String;
	var color:ColorStuff;
	var ?firstFrame:Int;
}

typedef DecomposedMatrix =
{
	var Position:XYStuff;
	var Rotation:XYStuff;
	var Scaling:XYStuff;
}

typedef BitmapStuff =
{
	var Position:XYStuff;
	var name:String;
}

typedef ColorStuff =
{
	// only Advanced color mode for now
	var mode:String;
	var AlphaOffset:Int;
	var RedMultiplier:Float;
	var alphaMultiplier:Float;
	var blueMultiplier:Float;
	var blueOffset:Int;
	var greenMultiplier:Float;
	var greenOffset:Int;
	var redOffset:Int;
}

typedef Matrix3DStuff =
{
	var m00:Float;
	var m01:Float;
	var m02:Float;
	var m03:Float;
	var m10:Float;
	var m11:Float;
	var m12:Float;
	var m13:Float;
	var m20:Float;
	var m21:Float;
	var m22:Float;
	var m23:Float;
	var m30:Float;
	var m31:Float;
	var m32:Float;
	var m33:Float;
}
