package;

import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.FlxState;
import transition.*;
import transition.data.*;
import flixel.addons.ui.FlxUIState;

class UIStateExt extends FlxUIState
{
	private var useDefaultTransIn:Bool = true;
	private var useDefaultTransOut:Bool = true;

	public static var defaultTransIn:Class<BasicTransition>;
	public static var defaultTransInArgs:Array<Dynamic>;
	public static var defaultTransOut:Class<BasicTransition>;
	public static var defaultTransOutArgs:Array<Dynamic>;

	private var customTransIn(get, set):BasicTransition;
	private var customTransOut(get, set):BasicTransition;

	private var _customTransIn:BasicTransition = null;
	private var _customTransOut:BasicTransition = null;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		super.create();
		if (customTransIn != null)
		{
			CustomTransition.transition(customTransIn, null);
		}
		else if (useDefaultTransIn)
			CustomTransition.transition(Type.createInstance(defaultTransIn, defaultTransInArgs), null);
	}

	public function switchState(_state:FlxState)
	{
		if (customTransOut != null)
		{
			CustomTransition.transition(customTransOut, _state);
		}
		else if (useDefaultTransOut)
		{
			CustomTransition.transition(Type.createInstance(defaultTransOut, defaultTransOutArgs), _state);
			return;
		}
		else
		{
			FlxG.switchState(_state);
			return;
		}
	}

	override public function destroy()
	{
		customTransIn = FlxDestroyUtil.destroy(customTransIn);
		customTransOut = FlxDestroyUtil.destroy(customTransOut);
		super.destroy();
		Cashew.destroyAll();
	}

	function set_customTransIn(trans:BasicTransition)
	{
		if (_customTransIn != null)
		{
			_customTransIn = FlxDestroyUtil.destroy(_customTransIn);
		}
		_customTransIn = trans;
		return trans;
	}

	function get_customTransIn()
	{
		return _customTransIn;
	}

	function set_customTransOut(trans:BasicTransition)
	{
		if (_customTransOut != null)
		{
			_customTransOut = FlxDestroyUtil.destroy(_customTransOut);
		}
		_customTransOut = trans;
		return trans;
	}

	function get_customTransOut()
	{
		return _customTransOut;
	}
}
