import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class CrappyTile extends FlxTypedGroup<FlxSprite>
{
	var numWide:Int;
	var numTall:Int;
	var velX:Float = 1;
	var velY:Float = 1;

	override public function new(gfx:FlxGraphic, _velX:Float, _velY:Float)
	{
		super();
		velX = _velX;
		velY = _velY;
		newTile(gfx);
	}

	public function newTile(gfx:FlxGraphic)
	{
		destroyMembers();
		maxSize = 0;
		var tile = new FlxSprite(0, 0).loadGraphic(gfx);
        // this.add(tile);
		numWide = Math.ceil(FlxG.width / FlxG.camera.zoom / tile.width) + 4;
		numTall = Math.ceil(FlxG.height / FlxG.camera.zoom / tile.height) + 4;
		for (i in 0...numWide)
		{
			for (j in 0...numTall)
			{
				maxSize++;
				var xPos = tile.width * (numWide - 2) - (i * tile.width);
				var yPos = tile.height * (numTall - 2) - (j * tile.height);
				var moreTiles = new FlxSprite(xPos, yPos).loadGraphic(gfx);
				moreTiles.antialiasing = true;
				if (i == numWide - 1 && j == numTall - 1)
				{
					moreTiles.elasticity = 1;
					moreTiles.angularDrag = 1;
					moreTiles.collisonXDrag = true;
				}
				else if (i == numWide - 1)
				{
					moreTiles.elasticity = 0;
					moreTiles.angularDrag = 0;
					moreTiles.collisonXDrag = true;
				}
				else if (j == numTall - 1)
				{
					moreTiles.elasticity = 1;
					moreTiles.angularDrag = 0;
					moreTiles.collisonXDrag = false;
				}
				else
				{
					moreTiles.elasticity = 0;
					moreTiles.angularDrag = 0;
					moreTiles.collisonXDrag = false;
				}
				this.add(moreTiles);
			}
		}
		tile.destroy();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var reviveMe:Array<FlxSprite> = [];
		this.forEachAlive(function(sprite)
		{
			sprite.x += (velX * FlxG.elapsed);
			sprite.y += (velY * FlxG.elapsed);
			if (sprite.x > FlxG.width / FlxG.camera.zoom || sprite.y > FlxG.height / FlxG.camera.zoom)
			{
				sprite.kill();
			}
			else
			{
				if ((sprite.x > 0 || sprite.y > 0) && sprite.angularDrag == 1)
				{
					positionNew(sprite, reviveMe, "topleft");
					sprite.angularDrag = 0;
				}
				if (sprite.x > 0 && sprite.y < FlxG.height / FlxG.camera.zoom && sprite.collisonXDrag)
				{
					positionNew(sprite, reviveMe, "left");
					sprite.collisonXDrag = false;
				}
				if (sprite.y > 0 && sprite.x < FlxG.width / FlxG.camera.zoom && sprite.elasticity == 1)
				{
					positionNew(sprite, reviveMe, "top");
					sprite.elasticity = 0;
				}
			}
		});
		for (sprite in reviveMe)
		{
			sprite.revive();
		}
	}

	function positionNew(sprite:FlxSprite, reviveMe:Array<FlxSprite>, position:String)
	{
		switch (position)
		{
			case 'top':
				var newSprite = getFirstAvailable();
				reviveMe.push(newSprite);
				newSprite.elasticity = 1;
				newSprite.angularDrag = 0;
				newSprite.collisonXDrag = false;
				newSprite.setPosition(sprite.x, sprite.y - sprite.height);
			case 'left':
				var newSprite = getFirstAvailable();
				reviveMe.push(newSprite);
				newSprite.elasticity = 0;
				newSprite.angularDrag = 0;
				newSprite.collisonXDrag = true;
				newSprite.setPosition(sprite.x - sprite.width, sprite.y);
			case 'topleft':
				var newSprite = getFirstAvailable();
				reviveMe.push(newSprite);
				newSprite.angularDrag = 1;
				newSprite.elasticity = 1;
				newSprite.collisonXDrag = true;
				newSprite.setPosition(sprite.x - sprite.width, sprite.y - sprite.height);
		}
	}

	override public function getFirstAvailable(?ObjectClass:Class<Any>, Force:Bool = false)
	{
		var checkNull = super.getFirstAvailable();

		if (checkNull != null)
		{
			checkNull.exists = true;
			return checkNull;
		}
		else
			return recycle(FlxSprite, null, false, false);
	}

	function destroyMembers()
	{
		for (member in members)
		{
			member.dirty = false;
			member.active = false;
			member.kill();
			this.remove(member);
			FlxDestroyUtil.destroy(member);
		}
	}

}
