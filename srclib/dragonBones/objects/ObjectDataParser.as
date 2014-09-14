package dragonBones.objects
{
	import dragonBones.core.DragonBones;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.DisplayData;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.SkinData;
	import dragonBones.objects.SlotData;
	import dragonBones.objects.Timeline;
	import dragonBones.objects.TransformFrame;
	import dragonBones.objects.TransformTimeline;
	import dragonBones.textures.TextureData;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.DBDataUtil;
	
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	use namespace dragonBones_internal;
	
	public final class ObjectDataParser
	{
		public static function parseTextureAtlasData(rawData:Object, scale:Number = 1):Object
		{
			var textureAtlasData:Object = {};
			textureAtlasData.__name = rawData[ConstValues.A_NAME];
			var subTextureFrame:Rectangle;
			for each (var subTextureObject:Object in rawData[ConstValues.SUB_TEXTURE])
			{
				var subTextureName:String = subTextureObject[ConstValues.A_NAME];
				var subTextureRegion:Rectangle = new Rectangle();
				subTextureRegion.x = int(subTextureObject[ConstValues.A_X]) / scale;
				subTextureRegion.y = int(subTextureObject[ConstValues.A_Y]) / scale;
				subTextureRegion.width = int(subTextureObject[ConstValues.A_WIDTH]) / scale;
				subTextureRegion.height = int(subTextureObject[ConstValues.A_HEIGHT]) / scale;
				
				var rotated:Boolean = subTextureObject[ConstValues.A_ROTATED] == "true";
				
				var frameWidth:Number = int(subTextureObject[ConstValues.A_FRAME_WIDTH]) / scale;
				var frameHeight:Number = int(subTextureObject[ConstValues.A_FRAME_HEIGHT]) / scale;
				
				if(frameWidth > 0 && frameHeight > 0)
				{
					subTextureFrame = new Rectangle();
					subTextureFrame.x = int(subTextureObject[ConstValues.A_FRAME_X]) / scale;
					subTextureFrame.y = int(subTextureObject[ConstValues.A_FRAME_Y]) / scale;
					subTextureFrame.width = frameWidth;
					subTextureFrame.height = frameHeight;
				}
				else
				{
					subTextureFrame = null;
				}
				
				textureAtlasData[subTextureName] = new TextureData(subTextureRegion, subTextureFrame, rotated);
			}
			
			return textureAtlasData;
		}
		
		public static function parseSkeletonData(rawData:Object, ifSkipAnimationData:Boolean=false, outputAnimationDictionary:Dictionary = null):SkeletonData
		{
			if(!rawData)
			{
				throw new ArgumentError();
			}
			
			var version:String = rawData[ConstValues.A_VERSION];
			switch (version)
			{
				case "2.3":
					//Update2_3To3_0.format(rawData);
					break;
				
				case DragonBones.DATA_VERSION:
					break;
				
				default:
					throw new Error("Nonsupport version!");
			}
			
			var frameRate:uint = int(rawData[ConstValues.A_FRAME_RATE]);
			
			var data:SkeletonData = new SkeletonData();
			data.name = rawData[ConstValues.A_NAME];
			
			for each(var armatureObject:Object in rawData[ConstValues.ARMATURE])
			{
				data.addArmatureData(parseArmatureData(armatureObject, data, frameRate, ifSkipAnimationData, outputAnimationDictionary));
			}
			
			return data;
		}
		
		private static function parseArmatureData(armatureObject:Object, data:SkeletonData, frameRate:uint, ifSkipAnimationData:Boolean, outputAnimationDictionary:Dictionary):ArmatureData
		{
			var armatureData:ArmatureData = new ArmatureData();
			armatureData.name = armatureObject[ConstValues.A_NAME];
			
			for each(var boneObject:Object in armatureObject[ConstValues.BONE])
			{
				armatureData.addBoneData(parseBoneData(boneObject));
			}
			
			for each(var skinObject:Object in armatureObject[ConstValues.SKIN])
			{
				armatureData.addSkinData(parseSkinData(skinObject, data));
			}
			
			DBDataUtil.transformArmatureData(armatureData);
			armatureData.sortBoneDataList();
			
			var animationObject:Object;
			if(ifSkipAnimationData)
			{
				if(outputAnimationDictionary!= null)
				{
					outputAnimationDictionary[armatureData.name] = new Dictionary();
				}
				
				var index:int = 0;
				for each(animationObject in armatureObject[ConstValues.ANIMATION])
				{
					if(index == 0)
					{
						armatureData.addAnimationData(parseAnimationData(animationObject, armatureData, frameRate));
					}
					else if(outputAnimationDictionary != null)
					{
						outputAnimationDictionary[armatureData.name][animationObject[ConstValues.A_NAME]] = animationObject;
					}
					index++;
				}
			}
			else
			{
				for each(animationObject in armatureObject[ConstValues.ANIMATION])
				{
					armatureData.addAnimationData(parseAnimationData(animationObject, armatureData, frameRate));
				}
			}
			
			for each(var rectangleObject:Object in armatureObject[ConstValues.RECTANGLE])
			{
				armatureData.addAreaData(parseRectangleData(rectangleObject));
			}
			
			for each(var ellipseObject:Object in armatureObject[ConstValues.ELLIPSE])
			{
				armatureData.addAreaData(parseEllipseData(ellipseObject));
			}
			
			return armatureData;
		}
		
		private static function parseBoneData(boneObject:Object):BoneData
		{
			var boneData:BoneData = new BoneData();
			boneData.name = boneObject[ConstValues.A_NAME];
			boneData.parent = boneObject[ConstValues.A_PARENT];
			boneData.length = Number(boneObject[ConstValues.A_LENGTH]);
			boneData.inheritRotation = getBoolean(boneObject, ConstValues.A_INHERIT_ROTATION, true);
			boneData.inheritScale = getBoolean(boneObject, ConstValues.A_SCALE_MODE, false);
			
			parseTransform(boneObject[ConstValues.TRANSFORM], boneData.global);
			boneData.transform.copy(boneData.global);
			
			for each(var rectangleObject:Object in boneObject[ConstValues.RECTANGLE])
			{
				boneObject.addAreaData(parseRectangleData(rectangleObject));
			}
			
			for each(var ellipseObject:Object in boneObject[ConstValues.ELLIPSE])
			{
				boneObject.addAreaData(parseEllipseData(ellipseObject));
			}
			
			return boneData;
		}
		
		private static function parseRectangleData(rectangleObject:Object):RectangleData
		{
			var rectangleData:RectangleData = new RectangleData();
			rectangleData.name = rectangleObject[ConstValues.A_NAME];
			rectangleData.width = Number(rectangleObject[ConstValues.A_WIDTH]);
			rectangleData.height = Number(rectangleObject[ConstValues.A_HEIGHT]);
			
			parseTransform(rectangleObject[ConstValues.TRANSFORM], rectangleData.transform, rectangleData.pivot);
			
			return rectangleData;
		}
		
		private static function parseEllipseData(ellipseObject:Object):EllipseData
		{
			var ellipseData:EllipseData = new EllipseData();
			ellipseData.name = ellipseObject[ConstValues.A_NAME];
			ellipseData.width = Number(ellipseObject[ConstValues.A_WIDTH]);
			ellipseData.height = Number(ellipseObject[ConstValues.A_HEIGHT]);
			
			parseTransform(ellipseObject[ConstValues.TRANSFORM], ellipseData.transform, ellipseData.pivot);
			
			return ellipseData;
		}
		
		private static function parseSkinData(skinObject:Object, data:SkeletonData):SkinData
		{
			var skinData:SkinData = new SkinData();
			skinData.name = skinObject[ConstValues.A_NAME];
			
			for each(var slotObject:Object in skinObject[ConstValues.SLOT])
			{
				skinData.addSlotData(parseSlotData(slotObject, data));
			}
			
			return skinData;
		}
		
		private static function parseSlotData(slotObject:Object, data:SkeletonData):SlotData
		{
			var slotData:SlotData = new SlotData();
			slotData.name = slotObject[ConstValues.A_NAME];
			slotData.parent = slotObject[ConstValues.A_PARENT];
			slotData.zOrder = Number(slotObject[ConstValues.A_Z_ORDER]);
			slotData.blendMode = slotObject[ConstValues.A_BLENDMODE];
			
			for each(var displayObject:Object in slotObject[ConstValues.DISPLAY])
			{
				slotData.addDisplayData(parseDisplayData(displayObject, data));
			}
			
			return slotData;
		}
		
		private static function parseDisplayData(displayObject:Object, data:SkeletonData):DisplayData
		{
			var displayData:DisplayData = new DisplayData();
			displayData.name = displayObject[ConstValues.A_NAME];
			displayData.type = displayObject[ConstValues.A_TYPE];
			
			displayData.pivot = data.addSubTexturePivot(
				0, 
				0, 
				displayData.name
			);
			
			parseTransform(displayObject[ConstValues.TRANSFORM], displayData.transform, displayData.pivot);
			
			return displayData;
		}
		
		/** @private */
		dragonBones_internal static function parseAnimationData(animationObject:Object, armatureData:ArmatureData, frameRate:uint):AnimationData
		{
			var animationData:AnimationData = new AnimationData();
			animationData.name = animationObject[ConstValues.A_NAME];
			animationData.frameRate = frameRate;
			animationData.playTimes = int(animationObject[ConstValues.A_LOOP]);
			animationData.fadeTime = Number(animationObject[ConstValues.A_FADE_IN_TIME]);
			animationData.duration = Math.round((Number(animationObject[ConstValues.A_DURATION]) || 1) / frameRate * 1000);
			animationData.scale = getNumber(animationObject, ConstValues.A_SCALE, 1) || 0;
			//use frame tweenEase, NaN
			//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			animationData.tweenEasing = getNumber(animationObject, ConstValues.A_TWEEN_EASING, NaN);
			animationData.autoTween = getBoolean(animationObject, ConstValues.A_AUTO_TWEEN, true);
			
			parseTimeline(animationObject, animationData, parseMainFrame, frameRate);
			
			var lastFrameDuration:int = animationData.duration;
			for each(var timelineObject:Object in animationObject[ConstValues.TIMELINE])
			{
				var timeline:TransformTimeline = parseTransformTimeline(timelineObject, animationData.duration, frameRate);
				lastFrameDuration = Math.min(lastFrameDuration, timeline.frameList[timeline.frameList.length - 1].duration);
				animationData.addTimeline(timeline);
			}
			
			if(animationData.frameList.length > 0)
			{
				lastFrameDuration = Math.min(lastFrameDuration, animationData.frameList[animationData.frameList.length - 1].duration);
			}
			animationData.lastFrameDuration = lastFrameDuration;
			
			DBDataUtil.addHideTimeline(animationData, armatureData);
			DBDataUtil.transformAnimationData(animationData, armatureData);
			
			return animationData;
		}
		
		private static function parseTimeline(timelineObject:Object, timeline:Timeline, frameParser:Function, frameRate:uint):void
		{
			var position:int = 0;
			var frame:Frame;
			for each(var frameObject:Object in timelineObject[ConstValues.FRAME])
			{
				frame = frameParser(frameObject, frameRate);
				frame.position = position;
				timeline.addFrame(frame);
				position += frame.duration;
			}
			if(frame)
			{
				frame.duration = timeline.duration - frame.position;
			}
		}
		
		private static function parseTransformTimeline(timelineObject:Object, duration:int, frameRate:uint):TransformTimeline
		{
			var timeline:TransformTimeline = new TransformTimeline();
			timeline.name = timelineObject[ConstValues.A_NAME];
			timeline.duration = duration;
			timeline.scale = getNumber(timelineObject, ConstValues.A_SCALE, 1) || 0;
			timeline.offset = getNumber(timelineObject, ConstValues.A_OFFSET, 0) || 0;
			
			parseTimeline(timelineObject, timeline, parseTransformFrame, frameRate);
			
			return timeline;
		}
		
		private static function parseFrame(frameObject:Object, frame:Frame, frameRate:uint):void
		{
			frame.duration = Math.round((Number(frameObject[ConstValues.A_DURATION]) || 1) / frameRate * 1000);
			frame.action = frameObject[ConstValues.A_ACTION];
			frame.event = frameObject[ConstValues.A_EVENT];
			frame.sound = frameObject[ConstValues.A_SOUND];
		}
		
		private static function parseMainFrame(frameObject:Object, frameRate:uint):Frame
		{
			var frame:Frame = new Frame();
			parseFrame(frameObject, frame, frameRate);
			return frame;
		}
		
		private static function parseTransformFrame(frameObject:Object, frameRate:uint):TransformFrame
		{
			var frame:TransformFrame = new TransformFrame();
			parseFrame(frameObject, frame, frameRate);
			
			frame.visible = !getBoolean(frameObject, ConstValues.A_HIDE, false);
			
			//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			frame.tweenEasing = getNumber(frameObject, ConstValues.A_TWEEN_EASING, 10);
			frame.tweenRotate = Number(frameObject[ConstValues.A_TWEEN_ROTATE]);
			frame.tweenScale = getBoolean(frameObject, ConstValues.A_TWEEN_SCALE, true);
			frame.displayIndex = Number(frameObject[ConstValues.A_DISPLAY_INDEX]);
			
			//如果为NaN，则说明没有改变过zOrder
			frame.zOrder = getNumber(frameObject, ConstValues.A_Z_ORDER, NaN);
			
			parseTransform(frameObject[ConstValues.TRANSFORM], frame.global, frame.pivot);
			frame.transform.copy(frame.global);
			
			frame.scaleOffset.x = getNumber(frameObject, ConstValues.A_SCALE_X_OFFSET, 0);
			frame.scaleOffset.y = getNumber(frameObject, ConstValues.A_SCALE_Y_OFFSET, 0);
			
			var colorTransformObject:Object = frameObject[ConstValues.COLOR_TRANSFORM];
			if(colorTransformObject)
			{
				frame.color = new ColorTransform();
				frame.color.alphaOffset = Number(colorTransformObject[ConstValues.A_ALPHA_OFFSET]);
				frame.color.redOffset = Number(colorTransformObject[ConstValues.A_RED_OFFSET]);
				frame.color.greenOffset = Number(colorTransformObject[ConstValues.A_GREEN_OFFSET]);
				frame.color.blueOffset = Number(colorTransformObject[ConstValues.A_BLUE_OFFSET]);
				
				frame.color.alphaMultiplier = Number(colorTransformObject[ConstValues.A_ALPHA_MULTIPLIER]) * 0.01;
				frame.color.redMultiplier = Number(colorTransformObject[ConstValues.A_RED_MULTIPLIER]) * 0.01;
				frame.color.greenMultiplier = Number(colorTransformObject[ConstValues.A_GREEN_MULTIPLIER]) * 0.01;
				frame.color.blueMultiplier = Number(colorTransformObject[ConstValues.A_BLUE_MULTIPLIER]) * 0.01;
			}
			
			return frame;
		}
		
		private static function parseTransform(transformObject:Object, transform:DBTransform, pivot:Point = null):void
		{
			if(transformObject)
			{
				if(transform)
				{
					transform.x = Number(transformObject[ConstValues.A_X]) || 0;
					transform.y = Number(transformObject[ConstValues.A_Y]) || 0;
					transform.skewX = Number(transformObject[ConstValues.A_SKEW_X]) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.skewY = Number(transformObject[ConstValues.A_SKEW_Y]) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.scaleX = getNumber(transformObject, ConstValues.A_SCALE_X, 1) || 0;
					transform.scaleY = getNumber(transformObject, ConstValues.A_SCALE_Y, 1) || 0;
				}
				if(pivot)
				{
					pivot.x = Number(transformObject[ConstValues.A_PIVOT_X]) || 0;
					pivot.y = Number(transformObject[ConstValues.A_PIVOT_Y]) || 0;
				}
			}
		}
		
		private static function getBoolean(data:Object, key:String, defaultValue:Boolean):Boolean
		{
			if(key in data)
			{
				switch(String(data[key]))
				{
					case "0":
					case "NaN":
					case "":
					case "false":
					case "null":
					case "undefined":
						return false;
						
					case "1":
					case "true":
					default:
						return true;
				}
			}
			return defaultValue;
		}
		
		private static function getNumber(data:Object, key:String, defaultValue:Number):Number
		{
			if(key in data)
			{
				switch(String(data[key]))
				{
					case "NaN":
					case "":
					case "false":
					case "null":
					case "undefined":
						return NaN;
						
					default:
						return Number(data[key]);
				}
			}
			return defaultValue;
		}
	}
}