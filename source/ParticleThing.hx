import openfl.particle.events.ParticleEvent;
import openfl.shader.utils.ShaderBufferUtils;
import openfl.shader.utils.UpdateParams;
import flixel.FlxG;
import openfl.display.BlendMode;
import openfl.particle.data.GPUAttribute;
import openfl.particle.data.GPUOneAttribute;
import openfl.particle.data.GPURandomTwoAttribute;
import openfl.particle.data.GPUGroupFourAttribute;
import openfl.particle.data.GPUFourAttribute;
import openfl.particle.data.GPUGroupAttribute;
import openfl.particle.data.GPUTwoAttribute;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import openfl.display.BitmapData;
import openfl.particle.GPUJSONParticleSprite;
import openfl.events.Event;
import openfl.particle.GPUParticleSprite;

class ParticleThing extends GPUParticleSprite
{
	public var xPos:Int = 0;
	public var yPos:Int = 0;

	public static function fromJson(name:String):ParticleThing
	{
		var particle = new ParticleThing();
		if (!FileSystem.exists(Paths.json('_particles/' + name)))
		{
			trace("NO JSON FOUND");
			return particle;
		}
		var att:ParticleJSON = Json.parse(File.getContent(Paths.json('_particles/' + name)));
		particle.parse(att);
		return particle;
	}

	static function randomOne(item1:Float, item2:Float):GPUAttribute
	{
		if (item1 == item2)
		{
			return new GPUOneAttribute(item1);
		}
		return new GPURandomTwoAttribute(item1, item2);
	}

	static function randomXY(arr:Array<Float>)
	{
		var two = new GPUTwoAttribute();
		two.x = randomOne(arr[0], arr[1]);
		two.y = randomOne(arr[2], arr[3]);
		return two;
	}

	static function randomStartEnd(arr:Array<Float>)
	{
		var start = randomOne(arr[0], arr[1]);
		var end = randomOne(arr[2], arr[3]);
		return new GPUGroupAttribute(start, end);
	}

	public function parse(att:ParticleJSON)
	{
		texture = Paths.getImagePNG("particles/" + att.texture).bitmap;
		counts = att.counts;
		widthRange = att.widthRange;
		heightRange = att.heightRange;
		life = att.life;
		lifeVariance = att.lifeVariance;
		duration = att.duration;
		emitRotation = randomOne(att.emitRotation[0], att.emitRotation[1]);
		velocity = randomXY(att.velocity);
		gravity = randomXY(att.gravity);
		acceleration = randomXY(att.acceleration);
		tangential = randomXY(att.tangential);
		scaleXAttribute = randomStartEnd(att.scaleXAttribute);
		scaleYAttribute = randomStartEnd(att.scaleYAttribute);
		rotaionAttribute = randomStartEnd(att.rotationAttribute);
		colorAttribute.start.x = randomOne(att.colorAttribute[0], att.colorAttribute[1]);
		colorAttribute.start.y = randomOne(att.colorAttribute[2], att.colorAttribute[3]);
		colorAttribute.start.z = randomOne(att.colorAttribute[4], att.colorAttribute[5]);
		colorAttribute.start.w = randomOne(att.colorAttribute[6], att.colorAttribute[7]);
		colorAttribute.end.x = randomOne(att.colorAttribute[8], att.colorAttribute[9]);
		colorAttribute.end.y = randomOne(att.colorAttribute[10], att.colorAttribute[11]);
		colorAttribute.end.z = randomOne(att.colorAttribute[12], att.colorAttribute[13]);
		colorAttribute.end.w = randomOne(att.colorAttribute[14], att.colorAttribute[15]);
		blendMode = att.blendMode;
		forceReset = att.forcedReset;
		dynamicEmitPoint = att.dynamicEmitPoint;
		particleShader = new ParticleShader();
		xPos = att.xPos;
		yPos = att.yPos;
		x = xPos * scaleX;
		y = yPos * scaleY;
	}

	override public function onFrame(e:Event) {
		var curtime = time + FlxG.elapsed * 2.4;
		var lifetime = (life + lifeVariance);
		if (curtime > lifetime * 2 && loop) {
			curtime = lifetime + (curtime % lifetime);
		}
		this.time = curtime;
		particleLiveCounts = 0;
		var updateAttr:UpdateParams = new UpdateParams();
		for (index => value in childs) {
			if (!value.isDie()) {
				particleLiveCounts++;
			}
			if (value.onReset()) {
				if (forceReset || dynamicEmitPoint || colorAttribute.hasTween()) {
					value.reset();
					updateAttr.push(value);
				}
			} else {
				if (colorAttribute.hasTween()) {
					// 存在过渡
					if (value.updateTweenColor()) {
						updateAttr.push(value);
					}
				}
			}
		}
		_shader.u_stageSizeAlpha.value = [stage.stageWidth, stage.stageHeight, @:privateAccess __worldAlpha];
		_shader.u_loop.value = [duration == -1 ? 1 : 0];
		if (updateAttr != null)
			updateAttr.push(_shader.u_time.index);
		@:privateAccess for (index => value in this.graphics.__usedShaderBuffers) {
			ShaderBufferUtils.update(value, cast value.shader, updateAttr);
		}
		this.invalidate();
		if (this.duration != -1 && particleLiveCounts == 0) {
			this.time = 0;
			this.stop();
			this.dispatchEvent(new ParticleEvent(ParticleEvent.STOP));
		}
	}

	public function pause()
	{
		_isPlay = false;
		this.removeEventListener(Event.ENTER_FRAME, onFrame);
	}

	public function refresh(a:Int, b:Int)
	{
		var wasPlaying = isPlay;
		if (wasPlaying)
			stop();
		var newWidth = FlxG.scaleMode.gameSize.x / FlxG.width;
		var newHeight = FlxG.scaleMode.gameSize.y / FlxG.height;
		scaleX = newWidth;
		scaleY = newHeight;
		// trace("NEW: " + newWidth + " " + newHeight);
		x = xPos * scaleX;
		y = yPos * scaleY;
		for (index => value in childs)
		{
			value.reset();
		}
		if (wasPlaying)
			start();
	}

	override public function new()
	{
		super();
		FlxG.signals.gameResized.add(refresh);
		scaleX = FlxG.scaleMode.gameSize.x / FlxG.width;
		scaleY = FlxG.scaleMode.gameSize.y / FlxG.height;
	}

	public function destroy()
	{
		if (isPlay)
			stop();
		dispose();
		FlxG.signals.gameResized.remove(refresh);
	}
}

typedef ParticleJSON =
{
	var texture:String;
	var counts:Int;
	var widthRange:Float;
	var heightRange:Float;
	var life:Float;
	var lifeVariance:Float;
	var duration:Float;
	var emitRotation:Array<Float>;
	var velocity:Array<Float>;
	var gravity:Array<Float>;
	var acceleration:Array<Float>;
	var tangential:Array<Float>;
	var scaleXAttribute:Array<Float>;
	var scaleYAttribute:Array<Float>;
	var rotationAttribute:Array<Float>;
	var colorAttribute:Array<Float>;
	var blendMode:String;
	var dynamicEmitPoint:Bool;
	var forcedReset:Bool;
	var xPos:Int;
	var yPos:Int;
}
