package;

import cpp.Pointer;
import cpp.Native;
import haxe.io.BytesData;
import cpp.UInt8;
import cpp.Star;
import haxe.io.Bytes;

class BytesThing extends Bytes
{
    var star:Star<UInt8>;

    function setStar(str:Star<UInt8>):BytesThing
    {
        star = str;
        return this;
    }

    public function destroy()
    {
        if (star != null)
            Native.free(star);
        star = null;
        b = null;
        length = 0;
    }

    public static function alloc(length:Int):BytesThing
    {
        // var a = new BytesData();
        var star:Star<UInt8> = Native.malloc(length);
        var a = Pointer.fromStar(star).toUnmanagedArray(length);
		return new BytesThing(length, a).setStar(star);
    }
    
}