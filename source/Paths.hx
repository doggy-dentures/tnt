package;

import cpp.Pointer;
import cpp.UInt8;
import openfl.display3D.textures.TextureBase;
import lime.utils.ArrayBufferView;
import openfl.display3D.Context3DTextureFormat;
import flixel.FlxG;
import lime.utils.UInt8Array;
import away3d.textures.Texture2DBase;
import sys.io.File;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import openfl.display3D.textures.Texture;
import openfl.Assets;
import openfl.system.System;
import openfl.utils.CompressionAlgorithm;
import lime.utils.Bytes;
import openfl.utils.ByteArray;
#if sys
import sys.FileSystem;
#end
import flixel.graphics.frames.FlxAtlasFrames;

class Paths
{
	static final audioExtension:String = "ogg";

	inline static public function file(key:String, location:String, extension:String):String
	{
		var data:String = 'assets/$location/$key.$extension';
		/*#if override
			if(FileSystem.exists('override/$location/$key.$extension')){
				data = 'override/$location/$key.$extension';
				//trace("OVERRIDE FOR " + key + " FOUND!");
			}
			#end */
		return data;
	}

	inline static public function image(key:String)
	{
		var data:String = file(key, "images", "png");

		// if (ImageCache.exists(data))
		// {
		// 	// trace(key + " is in the cache");
		// 	return ImageCache.get(data);
		// }
		// else
		// {
		// 	// trace(key + " loading from file");
		// 	return data;
		// }
		return data;
	}

	// inline static public function atf(key:String, ?location:String = "images")
	// {
	// 	return file(key, location, "atf");
	// }

	// inline static public function dds(key:String, ?location:String = "images")
	// {
	// 	return file(key, location, "dds");
	// }

	inline static public function funk(key:String, ?location:String = "images")
	{
		return file(key, location, "funk");
	}

	inline static public function xml(key:String, ?location:String = "images")
	{
		return file(key, location, "xml");
	}

	inline static public function text(key:String, ?location:String = "data")
	{
		return file(key, location, "txt");
	}

	inline static public function json(key:String, ?location:String = "data")
	{
		return file(key, location, "json");
	}

	inline static public function sound(key:String)
	{
		return file(key, "sounds", audioExtension);
	}

	static public function music(key:String)
	{
		if (FileSystem.exists(file(key, "music", "flac")))
			return file(key, "music", "flac");
		else if (FileSystem.exists(file(key, "music", "opus")))
			return file(key, "music", "opus");
		else
			return file(key, "music", audioExtension);
	}

	inline static public function getSparrowAtlas(key:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key), xml(key));
	}

	inline static public function getPackerAtlas(key:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), text(key, "images"));
	}

	// inline static public function video(key:String)
	// {
	// 	return file(key, "videos", "mp4");
	// }

	inline static public function font(key:String, ?extension:String = "ttf")
	{
		return file(key, "fonts", extension);
	}

	static var tmpPNGBytes:BitmapData = null;

	static public function getBitmapPNG(key:String)
	{
		tmpPNGBytes = BitmapData.fromFile(Paths.image(key));
		var texture = FlxG.stage.context3D.createTexture(tmpPNGBytes.width, tmpPNGBytes.height, Context3DTextureFormat.BGRA, false);
		texture.uploadFromBitmapData(tmpPNGBytes);
		tmpPNGBytes.dispose();
		tmpPNGBytes = null;
		return texture;
	}

	static public function getImagePNG(key:String)
	{
		if (!Cashew.exists(key))
		{
			var tex = getBitmapPNG(key);
			var gfx = FlxGraphic.fromBitmapData(BitmapData.fromTexture(tex), false, key, false);
			gfx.destroyOnNoUse = false;
			Cashew.cache(key, gfx, tex);
		}
		return Cashew.get(key);
	}

	static public function getSparrowAtlasPNG(key:String)
	{
		return FlxAtlasFrames.fromSparrow(getImagePNG(key), xml(key));
	}

	static public function getPackerAtlasPNG(key:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(getImagePNG(key), text(key, "images"));
	}

	static public function getTextureFunk(key:String)
	{
		var tmpComp = Bytes.fromFile(funk(key));
		if (tmpComp.getString(0, 4) != "FUNK")
			return null;
		var decompSize = tmpComp.getInt32(4);
		@:privateAccess
		var b:Array<UInt8> = tmpComp.b;
		var ptr:Pointer<UInt8> = Pointer.arrayElem(b, 8);
		var decompPtr = LZ4.decompress(ptr, b.length - 8, decompSize);
		var decompArray = decompPtr.toUnmanagedArray(decompSize);
		var tmpTexBytes = ByteArray.fromBytes(new lime.utils.Bytes(decompSize, decompArray));
		tmpComp = null;
		var fmt = tmpTexBytes.readInt();
		var height = tmpTexBytes.readInt();
		var width = tmpTexBytes.readInt();
		@:privateAccess
		var arraydata = new ArrayBufferView(null, 4);
		arraydata.buffer = tmpTexBytes;
		arraydata.byteLength = tmpTexBytes.length - 12;
		arraydata.length = tmpTexBytes.length - 12;
		arraydata.byteOffset = 12;
		var texture = new TextureThing(flixel.FlxG.stage.context3D, width, height, false, 0);
		switch (fmt)
		{
			case 0:
				texture.bc7(arraydata);
			case 1:
				texture.dxt1(arraydata);
			case 2:
				texture.rgba4(arraydata);
			case 3:
				texture.rgb5a1(arraydata);
			case 4:
				texture.dxt5(arraydata);
		}
		arraydata = null;
		tmpTexBytes.clear();
		tmpTexBytes = null;
		decompPtr.destroyArray();
		System.gc();
		return texture;
	}

	static public function getImageFunk(key:String)
	{
		if (!Cashew.exists(key))
		{
			var tex = getTextureFunk(key);
			var gfx = FlxGraphic.fromBitmapData(BitmapData.fromTexture(tex), false, key, false);
			gfx.destroyOnNoUse = false;
			Cashew.cache(key, gfx, tex);
		}
		return Cashew.get(key);
	}

	static public function getSparrowAtlasFunk(key:String)
	{
		return FlxAtlasFrames.fromSparrow(getImageFunk(key), xml(key));
	}
}
