package;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLFramebuffer;
import lime.utils.UInt8Array;
import openfl.display3D.textures.RectangleTexture;
import flixel.util.FlxDestroyUtil;
import sys.io.FileOutput;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import away3d.animators.*;
import away3d.containers.*;
import away3d.controllers.*;
import away3d.debug.*;
import away3d.entities.*;
import away3d.events.*;
import away3d.library.*;
import away3d.library.assets.*;
import away3d.lights.*;
import away3d.loaders.parsers.*;
import away3d.materials.*;
import away3d.materials.lightpickers.*;
import away3d.materials.methods.*;
import away3d.primitives.*;
import away3d.utils.Cast;
import openfl.display.*;
import openfl.events.*;
import openfl.filters.*;
import openfl.geom.*;
import openfl.text.*;
import openfl.ui.*;
import openfl.utils.ByteArray;
import openfl.Assets;
import openfl.Vector;

class ModelView
{
	public var view:View3D;
	public var cameraController:HoverController;

	private var _lookAtPosition:Vector3D = new Vector3D();

	public var light:DirectionalLight;

	public var lightPicker:StaticLightPicker;
	public var shadowMapMethod:FilteredShadowMapMethod;

	var thing:RectangleTexture;
	var fb:GLFramebuffer;

	public var sprite:FlxSprite = new FlxSprite();

	public function new(viewWidth:Float, viewHeight:Float, ambient:Float, specular:Float, diffuse:Float)
	{
		view = new View3D();
		view.width = viewWidth;
		view.height = viewHeight;
		view.backgroundAlpha = 0;

		FlxG.addChildBelowMouse(view);

		view.camera.lens.far = 5000;
		cameraController = new HoverController(view.camera, null, 90, 0, 300);
		cameraController.lookAtPosition = _lookAtPosition;

		light = new DirectionalLight(-0.5, -1, -1);
		lightPicker = new StaticLightPicker([light]);
		view.scene.addChild(light);
		light.ambient = ambient;
		light.specular = specular;
		light.diffuse = diffuse;

		shadowMapMethod = new FilteredShadowMapMethod(light);

		thing = FlxG.stage.context3D.createRectangleTexture(Std.int(viewWidth), Std.int(viewHeight), openfl.display3D.Context3DTextureFormat.COMPRESSED_ALPHA,
			true);
		sprite.loadGraphic(BitmapData.fromTexture(thing));
	}

	public function update()
	{
		view.render();
		tryStuff();
	}

	var madeBuffer = false;

	function tryStuff()
	{
		if (view.stage3DProxy != null && view.stage3DProxy.context3D != null)
		{
			@:privateAccess
			// var gl = view.stage3DProxy.context3D.gl;
			var gl = FlxG.stage.context3D.gl;
			if (!madeBuffer)
			{
				fb = gl.createFramebuffer();
				gl.bindFramebuffer(gl.FRAMEBUFFER, fb);
				madeBuffer = true;
			}
			@:privateAccess
			gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, thing.__textureID, 0);
		}
	}

	public function addModel(model:Mesh)
	{
		view.scene.addChild(model);
	}

	public function destroy()
	{
		cameraController = null;
		_lookAtPosition = null;
		if (view.camera != null)
		{
			view.camera.disposeWithChildren();
			view.camera.disposeAsset();
		}
		if (light != null)
			light.disposeWithChildren();
		light = null;
		if (lightPicker != null)
			lightPicker.dispose();
		lightPicker = null;
		if (shadowMapMethod != null)
			shadowMapMethod.dispose();
		shadowMapMethod = null;
		if (thing != null)
		{
			thing.dispose();
		}
		thing = null;
		if (sprite != null && sprite.graphic != null)
		{
			sprite.graphic.destroy();
		}
		sprite = FlxDestroyUtil.destroy(sprite);
		for (i in 0...view.scene.numChildren)
		{
			if (view.scene.getChildAt(i) != null)
			{
				view.scene.getChildAt(i).disposeWithChildren();
				view.scene.removeChildAt(i);
			}
		}
		FlxG.removeChild(view);
		view.dispose();
		@:privateAccess
		if (fb != null)
		{
			FlxG.stage.context3D.gl.deleteFramebuffer(fb);
			trace("DELETED");
		}
		fb = null;
		view = null;
	}
}
