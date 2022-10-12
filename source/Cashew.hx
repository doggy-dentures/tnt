import openfl.display3D.textures.TextureBase;
import flixel.util.FlxDestroyUtil;
import away3d.library.Asset3DLibrary;
import openfl.utils.Assets;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.system.System;
import openfl.display3D.textures.Texture;

class Cashew
{
	public static var cached:Map<String, TextureCacheThing> = [];

	public static function cache(name:String, graphic:FlxGraphic, texture:TextureBase)
	{
		if (cached[name] == null)
		{
			cached[name] = new TextureCacheThing(graphic, texture);
		}
	}

	public static function exists(name:String)
	{
		return cached[name] != null;
	}

	public static function get(name:String)
	{
		return cached[name].graphic;
	}

	public static function destroyOne(key:String)
	{
		FlxG.bitmap.removeByKey(key);
		if (cached[key] != null)
		{
			cached[key].destroy();
			cached[key] = null;
			cached.remove(key);
		}
		else
			trace("KEY OF " + key + " TO DESTROY NOT FOUND");
	}

	public static function destroyAll()
	{
		Asset3DLibrary.removeAllAssets();
		for (name in cached.keys())
		{
			FlxG.bitmap.removeByKey(name);
			if (cached[name] != null)
			{
				cached[name].destroy();
				cached[name] = null;
			}
		}
		cached.clear();
		FlxG.bitmap.clearCache();
		Assets.cache.clear();
		System.gc();
	}
}

class TextureCacheThing
{
	public var graphic:FlxGraphic;
	public var texture:TextureBase;

	public function new(gfx:FlxGraphic, tex:TextureBase)
	{
		graphic = gfx;
		texture = tex;
	}

	public function destroy()
	{
		graphic = FlxDestroyUtil.destroy(graphic);
		if (texture != null)
			texture.dispose();
		texture = null;
	}
}
