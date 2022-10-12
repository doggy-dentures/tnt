package transition.data;

import cpp.vm.Gc;
import flixel.util.FlxDestroyUtil;
import flixel.FlxCamera;
import openfl.system.System;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
	The base class for state transitions.
**/
class BasicTransition extends FlxSpriteGroup
{
	public var state:FlxState = null;
	public var transitionCamera:FlxCamera = null;

	/**
		Just a standard constructor.

		For custom animations, `super()` should be called at the top of the constructor.
	**/
	override public function new()
	{
		super();
	}

	/**
		Override this function to create the actual animated parts.
			
		For custom animations, a `super()` call is not needed.
	**/
	public function play()
	{
		end();
	}

	/**
		Function that should be called after the animation is done. 

		This shouldn't need to be overrided, but you can for whatever edge case you might have.
	**/
	public function end()
	{
		if (state != null)
		{
			FlxG.switchState(state);
			// System.gc();
		}
		else
		{
			this.destroy();
		}
	}

	override public function destroy()
	{
		state = null;
		cameras = [];
		if (transitionCamera != null)
		{
			// FlxG.game.removeChild(transitionCamera.flashSprite);
			FlxG.cameras.remove(transitionCamera);
		}
		transitionCamera = FlxDestroyUtil.destroy(transitionCamera);
		super.destroy();
	}
}
