import cpp.Char;
import cpp.ConstCharStar;
import cpp.ConstPointer;
import cpp.Float32;
import cpp.Int16;
import cpp.NativeArray;
import cpp.Pointer;
import cpp.RawPointer;
import cpp.Star;
import cpp.UInt8;

@:buildXml('<include name="../../../../source/lz4/LZ4Build.xml" />')
@:include("lz4stuff.cpp")
@:keep
@:unreflective
@:noCompletion
extern class LZ4Raw
{
	@:native("decompressRaw") public static function decompressRaw(input:Pointer<UInt8>, compressedSize:Int, decompressedSize:Int):Pointer<UInt8>;
	@:native("allocateArrayRaw") public static function allocateArrayRaw(size:Int):Pointer<UInt8>;
}

class LZ4
{
	public static function decompress(input:Pointer<UInt8>, compressedSize:Int, decompressedSize:Int):Pointer<UInt8>
	{
		return LZ4Raw.decompressRaw(input, compressedSize, decompressedSize);
	}
	public static function allocateArray(size:Int)
	{
		return LZ4Raw.allocateArrayRaw(size);
	}
}
