import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import openfl.particle.GPUParticleSprite;

class ParticleCam extends FlxCamera
{
	var particles:Array<ParticleThing> = [];

	public function addParticle(particle:ParticleThing)
	{
		particles.push(particle);
		_scrollRect.addChild(particle);
	}

	public function removeParticle(particle:ParticleThing)
	{
		particles.remove(particle);
		FlxDestroyUtil.removeChild(_scrollRect, particle);
	}

	override public function destroy()
	{
		if (particles != null)
		{
			for (particle in particles)
			{
				if (particle != null)
				{
					particle.stop();
					FlxDestroyUtil.removeChild(_scrollRect, particle);
					particle.destroy();
				}
			}
		}
		particles = null;
		super.destroy();
	}
}
