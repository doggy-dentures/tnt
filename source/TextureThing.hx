import openfl.display3D.Context3D;
import haxe.io.Bytes;
import lime.utils.UInt8Array;
import openfl.utils.ByteArray;
import openfl.display3D.textures.TextureBase;

class TextureThing extends TextureBase
{
	public function new(context:Context3D, width:Int, height:Int, optimizeForRenderToTexture:Bool, streamingLevels:Int)
	{
		super(context);

		__width = width;
		__height = height;
		// __format = format;
		__optimizeForRenderToTexture = optimizeForRenderToTexture;
		__streamingLevels = streamingLevels;

		@:privateAccess
		var gl = __context.gl;

		__textureTarget = gl.TEXTURE_2D;

		@:privateAccess
		__context.__bindGLTexture2D(__textureID);
		gl.texImage2D(__textureTarget, 0, __internalFormat, __width, __height, 0, __format, gl.UNSIGNED_BYTE, null);
		@:privateAccess
		__context.__bindGLTexture2D(null);

		if (optimizeForRenderToTexture)
			__getGLFramebuffer(true, 0, 0);
	}

	public function bc7(bytes:UInt8Array):Void
	{
		var context = __context;
		@:privateAccess
		var gl = context.gl;

		@:privateAccess
		__context.__bindGLTexture2D(__textureID);

		gl.compressedTexImage2D(__textureTarget, 0, 0x8E8C, __width, __height, 0, bytes);

		@:privateAccess
		__context.__bindGLTexture2D(null);
	}

	public function dxt1(bytes:UInt8Array):Void
	{
		var context = __context;
		@:privateAccess
		var gl = context.gl;

		@:privateAccess
		__context.__bindGLTexture2D(__textureID);
		@:privateAccess
		gl.compressedTexImage2D(__textureTarget, 0, TextureBase.__compressedFormats[0], __width, __height, 0, bytes);

		@:privateAccess
		__context.__bindGLTexture2D(null);
	}

	public function dxt5(bytes:UInt8Array):Void
	{
		var context = __context;
		@:privateAccess
		var gl = context.gl;

		@:privateAccess
		__context.__bindGLTexture2D(__textureID);
		@:privateAccess
		gl.compressedTexImage2D(__textureTarget, 0, TextureBase.__compressedFormatsAlpha[0], __width, __height, 0, bytes);

		@:privateAccess
		__context.__bindGLTexture2D(null);
	}

	public function rgba4(bytes:UInt8Array):Void
	{
		var context = __context;
		@:privateAccess
		var gl = context.gl;

		@:privateAccess
		__context.__bindGLTexture2D(__textureID);

		gl.texImage2D(__textureTarget, 0, gl.RGBA4, __width, __height, 0, gl.RGBA, gl.UNSIGNED_SHORT_4_4_4_4, bytes);

		@:privateAccess
		__context.__bindGLTexture2D(null);
	}

	public function rgb5a1(bytes:UInt8Array):Void
	{
		var context = __context;
		@:privateAccess
		var gl = context.gl;

		@:privateAccess
		__context.__bindGLTexture2D(__textureID);

		gl.texImage2D(__textureTarget, 0, gl.RGB5_A1, __width, __height, 0, gl.RGBA, gl.UNSIGNED_SHORT_5_5_5_1, bytes);

		@:privateAccess
		__context.__bindGLTexture2D(null);
	}
}
