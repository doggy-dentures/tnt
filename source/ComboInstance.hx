import flixel.system.FlxAssets.FlxGraphicAsset;

@:keepInit
@:keep
class ComboInstance
{
	public var graphic:FlxGraphicAsset;
	public var width:Int;
	public var height:Int;
	public var antialias:Bool;
	public function new (_graphic:FlxGraphicAsset, _width:Int, _height:Int, _antialias:Bool)
	{
		this.graphic = _graphic;
		this.width = _width;
		this.height = _height;
		this.antialias = _antialias;
	}
}