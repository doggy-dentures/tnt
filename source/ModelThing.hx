package;

import openfl.system.System;
import away3d.textures.BitmapTexture;
import away3d.textures.BitmapCubeTexture;
import sys.FileSystem;
import away3d.animators.nodes.SkeletonClipNode;
import away3d.animators.data.Skeleton;
import away3d.animators.transitions.CrossfadeTransition;
import away3d.tools.commands.Explode;
import away3d.animators.nodes.VertexClipNode;
import away3d.tools.utils.Bounds;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
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

class ModelThing
{
	private var modelBytes:ByteArray;
	private var modelMaterial:TextureMaterial;

	public var mesh:Mesh;

	private var scale:Float;

	public var animationSet:VertexAnimationSet;

	private var vertexAnimator:VertexAnimator;

	public var modelType:String;

	public var modelView:ModelView;

	public var fullyLoaded:Bool = false;
	public var animSpeed:Map<String, Float>;
	public var noLoopList:Array<String>;

	public var currentAnim:String = "";

	public var initYaw:Float;
	public var initPitch:Float;
	public var initRoll:Float;

	public var xOffset:Float = 0;
	public var yOffset:Float = 0;
	public var zOffset:Float = 0;

	var flipSingAnims:Bool = false;

	var reflectionTexture:BitmapCubeTexture;
	var envMapMethod:EnvMapMethod;
	var maskMethod:AlphaMaskMethod;

	var bitmapTexture:BitmapTexture;
	var bitmapTextureReflect:Array<BitmapData> = [];
	var bitmapTextureCubeMask:BitmapTexture;
	var bitmapTextureAlphaMask:BitmapTexture;

	public function new(character:Character)
	{
		modelType = character.modelType;
		animSpeed = character.animSpeed;
		noLoopList = character.noLoopList;
		scale = character.modelScale;
		initYaw = character.initYaw;
		initPitch = character.initPitch;
		initRoll = character.initRoll;
		xOffset = character.xOffset;
		yOffset = character.yOffset;
		zOffset = character.zOffset;
		flipSingAnims = character.isPlayer;

		if (!FileSystem.exists('assets/models/' + character.modelName + '/' + character.modelName + '.md2'))
		{
			trace("ERROR: MODEL OF NAME '" + character.modelName + ".md2' CAN'T BE FOUND!");
			return;
		}

		modelBytes = ByteArray.fromFile('assets/models/' + character.modelName + '/' + character.modelName + '.md2');
		Asset3DLibrary.loadData(modelBytes, null, null, new MD2Parser());

		if (!FileSystem.exists('assets/models/' + character.modelName + '/' + character.modelName + '.png'))
		{
			trace("ERROR: TEXTURE OF NAME '" + character.modelName + "'.png CAN'T BE FOUND!");
			return;
		}
		bitmapTexture = Cast.bitmapTexture('assets/models/' + character.modelName + '/' + character.modelName + '.png');
		modelMaterial = new TextureMaterial(bitmapTexture);

		Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
		Asset3DLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);

		modelView = character.modelView;

		modelMaterial.lightPicker = modelView.lightPicker;
		modelMaterial.gloss = 30;
		// modelMaterial.specularMethod = new BasicSpecularMethod();
		modelMaterial.ambient = 1.0;
		// modelMaterial.shadowMethod = modelView.shadowMapMethod;
		modelMaterial.alpha = 1.0;
		if (character.isGlass)
		{
			// modelMaterial.alpha = 0.85;
			modelMaterial.gloss = 0.2;
			modelMaterial.specular = 0.2;
			modelMaterial.ambient = 1.0;

			bitmapTextureReflect = [
				Cast.bitmapData("assets/models/cubemap/px.png"), Cast.bitmapData("assets/models/cubemap/nx.png"),
				Cast.bitmapData("assets/models/cubemap/py.png"), Cast.bitmapData("assets/models/cubemap/ny.png"),
				Cast.bitmapData("assets/models/cubemap/pz.png"), Cast.bitmapData("assets/models/cubemap/nz.png")
			];

			reflectionTexture = new BitmapCubeTexture(bitmapTextureReflect[0], bitmapTextureReflect[1], bitmapTextureReflect[2], bitmapTextureReflect[3],
				bitmapTextureReflect[4], bitmapTextureReflect[5]);

			envMapMethod = new EnvMapMethod(reflectionTexture);
			envMapMethod.alpha = 0.8;
			if (!FileSystem.exists('assets/models/' + character.modelName + '/cubemask.png'))
				trace("ERROR: MASK OF MODEL '" + character.modelName + "' CAN'T BE FOUND!");
			else
			{
				bitmapTextureCubeMask = Cast.bitmapTexture('assets/models/' + character.modelName + '/cubemask.png');
				envMapMethod.mask = bitmapTextureCubeMask;
			}
			modelMaterial.addMethod(envMapMethod);

			if (!FileSystem.exists('assets/models/' + character.modelName + '/alphamask.png'))
				trace("ERROR: MASK OF MODEL '" + character.modelName + "' CAN'T BE FOUND!");
			else
			{
				bitmapTextureAlphaMask = Cast.bitmapTexture('assets/models/' + character.modelName + '/alphamask.png');
				maskMethod = new AlphaMaskMethod(bitmapTextureAlphaMask);
				modelMaterial.addMethod(maskMethod);
			}
		}

		modelView.cameraController.panAngle = 90;
		modelView.cameraController.tiltAngle = 0;
	}

	private function onAssetComplete(event:Asset3DEvent):Void
	{
		if (event.asset.assetType == Asset3DType.MESH)
		{
			mesh = cast(event.asset, Mesh);
			mesh.scaleX = scale;
			mesh.scaleY = scale;
			mesh.scaleZ = scale;
			mesh.yaw(initYaw);
			mesh.pitch(initPitch);
			mesh.roll(initRoll);
		}
		else if (event.asset.assetType == Asset3DType.ANIMATION_NODE)
		{
			var node:VertexClipNode = cast(event.asset, VertexClipNode);
			if (noLoopList.contains(node.name))
				node.looping = false;
		}
		else if (event.asset.assetType == Asset3DType.ANIMATION_SET)
		{
			animationSet = cast(event.asset, VertexAnimationSet);
		}
	}

	private function onResourceComplete(event:LoaderEvent):Void
	{
		if (vertexAnimator == null)
			vertexAnimator = new VertexAnimator(animationSet);
		// vertexAnimator.playbackSpeed = animSpeed["default"];
		mesh.animator = vertexAnimator;
		render(xOffset, yOffset, zOffset);
		modelBytes.clear();
		modelBytes = null;

		if (Character.modelMutex && Character.modelMutexThing == this)
		{
			Character.modelMutex = false;
			Character.modelMutexThing = null;
			begoneEventListeners();
		}
	}

	public function render(xPos:Float = 0, yPos:Float = 0, zPos:Float = 0):Void
	{
		mesh.y = yPos;
		mesh.x = xPos;
		mesh.z = zPos;
		if (modelType == 'md2')
		{
			mesh.castsShadows = false;
			mesh.material = modelMaterial;
		}
		modelView.addModel(mesh);
		fullyLoaded = true;
		begoneEventListeners();

		if (flipSingAnims)
		{
			var lefts = ['singLEFT', 'singLEFTmiss', 'singLEFTEnd', 'singLEFTmissEnd'];
			var rights = ['singRIGHT', 'singRIGHTmiss', 'singRIGHTEnd', 'singRIGHTmissEnd'];
			for (i in 0...rights.length)
			{
				if (animationSet.hasAnimation(rights[i]) && animationSet.hasAnimation(lefts[i]))
				{
					var right = animationSet.getAnimation(rights[i]);
					var left = animationSet.getAnimation(lefts[i]);
					@:privateAccess
					animationSet._animationDictionary[rights[i]] = left;
					@:privateAccess
					animationSet._animationDictionary[lefts[i]] = right;
				}
			}
		}

		playAnim("idle");
	}

	public function update()
	{
	}

	public function playAnim(anim:String = "", force:Bool = false, offset:Int = 0)
	{
		if (fullyLoaded)
		{
			if (animationSet.animationNames.indexOf(anim) != -1)
			{
				if (force || currentAnim != anim)
				{
					var newSpeed:Float = 1.0;
					if (animSpeed.exists(anim))
						newSpeed = animSpeed[anim];
					else
						newSpeed = animSpeed["default"];
					// trace("ya new speed: " + newSpeed);
					vertexAnimator.playbackSpeed = newSpeed;
					vertexAnimator.play(anim, null, null);
					currentAnim = anim;
				}
			}
			else
				trace("ANIMATION NAME " + anim + " NOT FOUND.");
		}
		else
			trace("MODEL NOT FULLY LOADED. NO ANIMATION WILL PLAY.");
	}

	public function destroy()
	{
		if (mesh != null)
		{
			if (mesh.geometry != null)
				mesh.geometry.dispose();
			mesh.geometry = null;
			mesh.material = null;
			mesh.disposeWithChildren();
		}
		mesh = null;
		if (modelBytes != null)
			modelBytes.clear();
		modelBytes = null;
		if (bitmapTexture != null)
		{
			if (bitmapTexture.bitmapData != null)
			{
				bitmapTexture.bitmapData.disposeImage();
				bitmapTexture.bitmapData.dispose();
			}
			bitmapTexture.dispose();
			bitmapTexture = null;
		}
		if (bitmapTextureCubeMask != null)
		{
			if (bitmapTextureCubeMask.bitmapData != null)
			{
				bitmapTextureCubeMask.bitmapData.disposeImage();
				bitmapTextureCubeMask.bitmapData.dispose();
			}
			bitmapTextureCubeMask.dispose();
			bitmapTextureCubeMask = null;
		}
		if (bitmapTextureAlphaMask != null)
		{
			if (bitmapTextureAlphaMask.bitmapData != null)
			{
				bitmapTextureAlphaMask.bitmapData.disposeImage();
				bitmapTextureAlphaMask.bitmapData.dispose();
			}
			bitmapTextureAlphaMask.dispose();
			bitmapTextureAlphaMask = null;
		}
		for (texture in bitmapTextureReflect)
		{
			if (texture != null)
			{
				texture.disposeImage();
				texture.dispose();
				texture = null;
			}
		}
		bitmapTextureReflect.resize(0);
		bitmapTextureReflect = null;
		if (modelMaterial != null)
		{
			if (modelMaterial.texture != null)
			{
				modelMaterial.texture.dispose();
			}
			if (modelMaterial.ambientTexture != null)
				modelMaterial.ambientTexture.dispose();
			modelMaterial.texture = null;
			modelMaterial.ambientTexture = null;
			if (modelMaterial.hasMethod(envMapMethod))
				modelMaterial.removeMethod(envMapMethod);
			if (modelMaterial.hasMethod(maskMethod))
				modelMaterial.removeMethod(maskMethod);
			modelMaterial.dispose();
		}
		modelMaterial = null;
		if (animationSet != null)
			animationSet.dispose();
		animationSet = null;
		if (vertexAnimator != null)
		{
			vertexAnimator.stop();
			vertexAnimator.dispose();
		}
		vertexAnimator = null;
		modelView = null;
		if (noLoopList != null)
			noLoopList.resize(0);
		noLoopList = null;
		if (reflectionTexture != null)
		{
			reflectionTexture.negativeX.disposeImage();
			reflectionTexture.negativeX.dispose();
			reflectionTexture.negativeY.disposeImage();
			reflectionTexture.negativeY.dispose();
			reflectionTexture.negativeZ.disposeImage();
			reflectionTexture.negativeZ.dispose();
			reflectionTexture.positiveX.disposeImage();
			reflectionTexture.positiveX.dispose();
			reflectionTexture.positiveY.disposeImage();
			reflectionTexture.positiveY.dispose();
			reflectionTexture.positiveZ.disposeImage();
			reflectionTexture.positiveZ.dispose();
			reflectionTexture.dispose();
		}
		reflectionTexture = null;
		if (envMapMethod != null)
		{
			envMapMethod.mask.dispose();
			envMapMethod.envMap.dispose();
			envMapMethod.dispose();
		}
		envMapMethod = null;
		if (maskMethod != null)
		{
			maskMethod.texture.dispose();
			maskMethod.dispose();
		}
		maskMethod = null;
		animSpeed.clear();
		animSpeed = null;
		begoneEventListeners();
		System.gc();
	}

	public function begoneEventListeners()
	{
		Asset3DLibrary.stopLoad();
		Asset3DLibrary.removeEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
		Asset3DLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
	}

	public function addYaw(angle:Float)
	{
		mesh.yaw(angle);
	}

	public function addPitch(angle:Float)
	{
		mesh.pitch(angle);
	}

	public function addRoll(angle:Float)
	{
		mesh.roll(angle);
	}
}
