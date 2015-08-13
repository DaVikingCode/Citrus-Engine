package dragonBones.objects 
{
	import dragonBones.core.DragonBones;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.DBDataUtil;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author sukui
	 */
	final public class XML3DataParser 
	{
		private static var tempDragonBonesData:DragonBonesData;
		
		use namespace dragonBones_internal;
		
		public function XML3DataParser() 
		{
			
		}
		
		/**
		 * Parse the SkeletonData.
		 * @param xml The SkeletonData xml to parse.
		 * @return A SkeletonData instance.
		 */
		public static function parseSkeletonData(rawData:XML, ifSkipAnimationData:Boolean = false, outputAnimationDictionary:Dictionary = null):DragonBonesData
		{
			if(!rawData)
			{
				throw new ArgumentError();
			}
			var version:String = rawData.@[ConstValues.A_VERSION];
			switch (version)
			{
				case "2.3":
					//Update2_3To3_0.format(rawData as XML);
					break;
				
				case "3.0":
					break;
				
				default:
					throw new Error("Nonsupport version!");
			}
			
			var frameRate:uint = int(rawData.@[ConstValues.A_FRAME_RATE]);
			
			var data:DragonBonesData = new DragonBonesData();
			tempDragonBonesData = data;
			data.name = rawData.@[ConstValues.A_NAME];
			var isGlobalData:Boolean = rawData.@[ConstValues.A_IS_GLOBAL] == "0" ? false : true;
			for each(var armatureXML:XML in rawData[ConstValues.ARMATURE])
			{
				data.addArmatureData(parseArmatureData(armatureXML, data, frameRate, isGlobalData, ifSkipAnimationData, outputAnimationDictionary));
			}
			
			return data;
		}
		
		private static function parseArmatureData(armatureXML:XML, data:DragonBonesData, frameRate:uint, isGlobalData:Boolean, ifSkipAnimationData:Boolean, outputAnimationDictionary:Dictionary):ArmatureData
		{
			var armatureData:ArmatureData = new ArmatureData();
			armatureData.name = armatureXML.@[ConstValues.A_NAME];
			
			for each(var boneXML:XML in armatureXML[ConstValues.BONE])
			{
				armatureData.addBoneData(parseBoneData(boneXML, isGlobalData));
			}
			
			for each( var skinXml:XML in armatureXML[ConstValues.SKIN])
			{
				for each(var slotXML:XML in skinXml[ConstValues.SLOT])
				{
					armatureData.addSlotData(parseSlotData(slotXML));
				}
			}
			for each(var skinXML:XML in armatureXML[ConstValues.SKIN])
			{
				armatureData.addSkinData(parseSkinData(skinXML, data));
			}
			
			if(isGlobalData)
			{
				DBDataUtil.transformArmatureData(armatureData);
			}
			armatureData.sortBoneDataList();
			
			var animationXML:XML;
			if(ifSkipAnimationData)
			{
				//if(outputAnimationDictionary!= null)
				//{
					//outputAnimationDictionary[armatureData.name] = new Dictionary();
				//}
				//
				//var index:int = 0;
				//for each(animationXML in armatureXML[ConstValues.ANIMATION])
				//{
					//if(index == 0)
					//{
						//armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate, isGlobalData));
					//}
					//else if(outputAnimationDictionary != null)
					//{
						//outputAnimationDictionary[armatureData.name][animationXML.@[ConstValues.A_NAME]] = animationXML;
					//}
					//index++;
				//}
			}
			else
			{
				for each(animationXML in armatureXML[ConstValues.ANIMATION])
				{
					//var animationData:AnimationData = parseAnimationData(animationXML, frameRate);
					//DBDataUtil.addHideTimeline(animationData, outputArmatureData);
					//DBDataUtil.transformAnimationData(animationData, outputArmatureData, tempDragonBonesData.isGlobalData);
					//outputArmatureData.addAnimationData(animationData);
					armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate, isGlobalData));
				}
			}
			
			//for each(var rectangleXML:XML in armatureXML[ConstValues.RECTANGLE])
			//{
				//armatureData.addAreaData(parseRectangleData(rectangleXML));
			//}
			//
			//for each(var ellipseXML:XML in armatureXML[ConstValues.ELLIPSE])
			//{
				//armatureData.addAreaData(parseEllipseData(ellipseXML));
			//}
			
			return armatureData;
		}
		
		private static function parseBoneData(boneXML:XML, isGlobalData:Boolean):BoneData
		{
			var boneData:BoneData = new BoneData();
			boneData.name = boneXML.@[ConstValues.A_NAME];
			boneData.parent = boneXML.@[ConstValues.A_PARENT];
			boneData.length = Number(boneXML.@[ConstValues.A_LENGTH]);
			boneData.inheritRotation = getBoolean(boneXML, ConstValues.A_INHERIT_ROTATION, true);
			boneData.inheritScale = getBoolean(boneXML, ConstValues.A_INHERIT_SCALE, true);
			
			parseTransform(boneXML[ConstValues.TRANSFORM][0], boneData.transform);
			if(isGlobalData)//绝对数据
			{
				boneData.global.copy(boneData.transform);
			}
			
			//for each(var rectangleXML:XML in boneXML[ConstValues.RECTANGLE])
			//{
				//boneData.addAreaData(parseRectangleData(rectangleXML));
			//}
			//
			//for each(var ellipseXML:XML in boneXML[ConstValues.ELLIPSE])
			//{
				//boneData.addAreaData(parseEllipseData(ellipseXML));
			//}
			
			return boneData;
		}
		
		private static function parseRectangleData(rectangleXML:XML):RectangleData
		{
			var rectangleData:RectangleData = new RectangleData();
			rectangleData.name = rectangleXML.@[ConstValues.A_NAME];
			rectangleData.width = Number(rectangleXML.@[ConstValues.A_WIDTH]);
			rectangleData.height = Number(rectangleXML.@[ConstValues.A_HEIGHT]);
			
			parseTransform(rectangleXML[ConstValues.TRANSFORM][0], rectangleData.transform, rectangleData.pivot);
			
			return rectangleData;
		}
		
		private static function parseEllipseData(ellipseXML:XML):EllipseData
		{
			var ellipseData:EllipseData = new EllipseData();
			ellipseData.name = ellipseXML.@[ConstValues.A_NAME];
			ellipseData.width = Number(ellipseXML.@[ConstValues.A_WIDTH]);
			ellipseData.height = Number(ellipseXML.@[ConstValues.A_HEIGHT]);
			
			parseTransform(ellipseXML[ConstValues.TRANSFORM][0], ellipseData.transform, ellipseData.pivot);
			
			return ellipseData;
		}
		
		private static function parseSlotData(slotXML:XML):SlotData
		{
			var slotData:SlotData = new SlotData();
			slotData.name = slotXML.@[ConstValues.A_NAME];
			slotData.parent = slotXML.@[ConstValues.A_PARENT];
			slotData.zOrder = getNumber(slotXML,ConstValues.A_Z_ORDER,0)||0;
			slotData.blendMode = slotXML.@[ConstValues.A_BLENDMODE];
			slotData.displayIndex = 0;
			return slotData;
		}
		
		private static function parseSkinData(skinXML:XML, data:DragonBonesData):SkinData
		{
			var skinData:SkinData = new SkinData();
			skinData.name = skinXML.@[ConstValues.A_NAME];
			
			for each(var slotXML:XML in skinXML[ConstValues.SLOT])
			{
				skinData.addSlotData(parseSkinSlotData(slotXML, data));
			}
			
			return skinData;
		}
		
		private static function parseSkinSlotData(slotXML:XML, data:DragonBonesData):SlotData
		{
			var slotData:SlotData = new SlotData();
			slotData.name = slotXML.@[ConstValues.A_NAME];
			slotData.parent = slotXML.@[ConstValues.A_PARENT];
			slotData.zOrder = getNumber(slotXML, ConstValues.A_Z_ORDER, 0) || 0;
			slotData.blendMode = slotXML.@[ConstValues.A_BLENDMODE];
			for each(var displayXML:XML in slotXML[ConstValues.DISPLAY])
			{
				slotData.addDisplayData(parseDisplayData(displayXML, data));
			}
			
			return slotData;
		}
		
		private static function parseDisplayData(displayXML:XML, data:DragonBonesData):DisplayData
		{
			var displayData:DisplayData = new DisplayData();
			displayData.name = displayXML.@[ConstValues.A_NAME];
			displayData.type = displayXML.@[ConstValues.A_TYPE];
			
			displayData.pivot = new Point();
			//displayData.pivot = data.addSubTexturePivot(
				//0, 
				//0, 
				//displayData.name
			//);
			
			parseTransform(displayXML[ConstValues.TRANSFORM][0], displayData.transform, displayData.pivot);
			
			if (tempDragonBonesData)
			{
				tempDragonBonesData.addDisplayData(displayData);
			}
			return displayData;
		}
		
		/** @private */
		dragonBones_internal static function parseAnimationData(animationXML:XML, armatureData:ArmatureData, frameRate:uint, isGlobalData:Boolean):AnimationData
		{
			var animationData:AnimationData = new AnimationData();
			animationData.name = animationXML.@[ConstValues.A_NAME];
			animationData.frameRate = frameRate;
			animationData.duration = Math.round((int(animationXML.@[ConstValues.A_DURATION]) || 1) * 1000 / frameRate);
			animationData.playTimes = int(getNumber(animationXML, ConstValues.A_LOOP, 1));
			animationData.fadeTime = getNumber(animationXML, ConstValues.A_FADE_IN_TIME, 0) || 0;
			animationData.scale = getNumber(animationXML, ConstValues.A_SCALE, 1) || 0;
			//use frame tweenEase, NaN
			//overwrite frame tweenEase, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			animationData.tweenEasing = getNumber(animationXML, ConstValues.A_TWEEN_EASING, NaN);
			animationData.autoTween = getBoolean(animationXML, ConstValues.A_AUTO_TWEEN, true);
			
			for each(var frameXML:XML in animationXML[ConstValues.FRAME])
			{
				var frame:Frame = parseTransformFrame(frameXML, frameRate, isGlobalData);
				animationData.addFrame(frame);
			}
			
			parseTimeline(animationXML, animationData);
			
			var lastFrameDuration:int = animationData.duration;
			for each(var timelineXML:XML in animationXML[ConstValues.TIMELINE])
			{
				var timeline:TransformTimeline = parseTransformTimeline(timelineXML, animationData.duration, frameRate, isGlobalData);
				lastFrameDuration = Math.min(lastFrameDuration, timeline.frameList[timeline.frameList.length - 1].duration);
				animationData.addTimeline(timeline);
				
				var slotTimeline:SlotTimeline = parseSlotTimeline(timelineXML, animationData.duration, frameRate, isGlobalData);
				if (slotTimeline.frameList.length > 0)
				{
					lastFrameDuration = Math.min(lastFrameDuration, slotTimeline.frameList[slotTimeline.frameList.length - 1].duration);
					animationData.addSlotTimeline(slotTimeline);
				}
			}
			
			if(animationData.frameList.length > 0)
			{
				lastFrameDuration = Math.min(lastFrameDuration, animationData.frameList[animationData.frameList.length - 1].duration);
			}
			animationData.lastFrameDuration = lastFrameDuration;
			
			DBDataUtil.addHideTimeline(animationData, armatureData);
			DBDataUtil.transformAnimationData(animationData, armatureData, isGlobalData);
			
			return animationData;
		}
		
		private static function parseSlotTimeline(timelineXML:XML, duration:int, frameRate:uint, isGlobalData:Boolean):SlotTimeline
		{
			var timeline:SlotTimeline = new SlotTimeline();
			timeline.name = timelineXML.@[ConstValues.A_NAME];
			timeline.scale = getNumber(timelineXML, ConstValues.A_SCALE, 1) || 0;
			timeline.offset = getNumber(timelineXML, ConstValues.A_OFFSET, 0) || 0;
			timeline.duration = duration;
			
			for each(var frameXML:XML in timelineXML[ConstValues.FRAME])
			{
				var frame:SlotFrame = parseSlotFrame(frameXML, frameRate, isGlobalData);
				timeline.addFrame(frame);
			}
			
			parseTimeline(timelineXML, timeline);
			
			return timeline;
		}
		
		private static function parseSlotFrame(frameXML:XML, frameRate:uint, isGlobalData:Boolean):SlotFrame
		{
			var frame:SlotFrame = new SlotFrame();
			parseFrame(frameXML, frame, frameRate);
			
			frame.visible = !getBoolean(frameXML, ConstValues.A_HIDE, false);
			
			//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			frame.tweenEasing = getNumber(frameXML, ConstValues.A_TWEEN_EASING, 10);
			frame.displayIndex = int(getNumber(frameXML,ConstValues.A_DISPLAY_INDEX,0));
			
			//如果为NaN，则说明没有改变过zOrder
			frame.zOrder = getNumber(frameXML, ConstValues.A_Z_ORDER, isGlobalData ? NaN:0);
				
			var colorTransformXML:XML = frameXML[ConstValues.COLOR_TRANSFORM][0];
			if(colorTransformXML)
			{
				frame.color = new ColorTransform();
				parseColorTransform(colorTransformXML, frame.color);
			}
			
			return frame;
		}
		
		private static function parseTransformTimeline(timelineXML:XML, duration:int, frameRate:uint, isGlobalData:Boolean):TransformTimeline
		{
			var timeline:TransformTimeline = new TransformTimeline();
			timeline.name = timelineXML.@[ConstValues.A_NAME];
			timeline.scale = getNumber(timelineXML, ConstValues.A_SCALE, 1) || 0;
			timeline.offset = getNumber(timelineXML, ConstValues.A_OFFSET, 0) || 0;
			timeline.originPivot.x = getNumber(timelineXML, ConstValues.A_PIVOT_X, 0) || 0;
			timeline.originPivot.y = getNumber(timelineXML, ConstValues.A_PIVOT_Y, 0) || 0;
			timeline.duration = duration;
			
			for each(var frameXML:XML in timelineXML[ConstValues.FRAME])
			{
				var frame:TransformFrame = parseTransformFrame(frameXML, frameRate, isGlobalData);
				timeline.addFrame(frame);
			}
			
			parseTimeline(timelineXML, timeline);
			
			return timeline;
		}
		
		private static function parseMainFrame(frameXML:XML, frameRate:uint):Frame
		{
			var frame:Frame = new Frame();
			parseFrame(frameXML, frame, frameRate);
			return frame;
		}
		
		private static function parseTransformFrame(frameXML:XML, frameRate:uint, isGlobalData:Boolean):TransformFrame
		{
			var frame:TransformFrame = new TransformFrame();
			parseFrame(frameXML, frame, frameRate);
			
			frame.visible = !getBoolean(frameXML, ConstValues.A_HIDE, false);
			
			//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
			frame.tweenEasing = getNumber(frameXML, ConstValues.A_TWEEN_EASING, 10);
			frame.tweenRotate = int(getNumber(frameXML, ConstValues.A_TWEEN_ROTATE,0));
			frame.tweenScale = getBoolean(frameXML, ConstValues.A_TWEEN_SCALE, true);
			//frame.displayIndex = int(getNumber(frameXML, ConstValues.A_DISPLAY_INDEX, 0));
			
			//如果为NaN，则说明没有改变过zOrder
			//frame.zOrder = getNumber(frameXML, ConstValues.A_Z_ORDER, isGlobalData ? NaN : 0);
			
			parseTransform(frameXML[ConstValues.TRANSFORM][0], frame.transform, frame.pivot);
			if(isGlobalData)//绝对数据
			{
				frame.global.copy(frame.transform);
			}
			
			frame.scaleOffset.x = getNumber(frameXML, ConstValues.A_SCALE_X_OFFSET, 0) || 0;
			frame.scaleOffset.y = getNumber(frameXML, ConstValues.A_SCALE_Y_OFFSET, 0) || 0;
			
			//var colorTransformXML:XML = frameXML[ConstValues.COLOR_TRANSFORM][0];
			//if(colorTransformXML)
			//{
				//frame.color = new ColorTransform();
				//parseColorTransform(colorTransformXML, frame.color);
			//}
			
			return frame;
		}
		
		private static function parseTimeline(timelineXML:XML, timeline:Timeline):void
		{
			var position:int = 0;
			var frame:Frame;
			for each(frame in timeline.frameList)
			{
				frame.position = position;
				position += frame.duration;
			}
			if(frame)
			{
				frame.duration = timeline.duration - frame.position;
			}
		}
		
		private static function parseFrame(frameXML:XML, frame:Frame, frameRate:uint):void
		{
			frame.duration = Math.round((int(frameXML.@[ConstValues.A_DURATION]) || 1) * 1000 / frameRate);
			frame.action = frameXML.@[ConstValues.A_ACTION];
			frame.event = frameXML.@[ConstValues.A_EVENT];
			frame.sound = frameXML.@[ConstValues.A_SOUND];
		}
		
		private static function parseTransform(transformXML:XML, transform:DBTransform, pivot:Point = null):void
		{
			if(transformXML)
			{
				if(transform)
				{
					transform.x = getNumber(transformXML, ConstValues.A_X, 0) || 0;
					transform.y = getNumber(transformXML, ConstValues.A_Y, 0) || 0;
					transform.skewX = getNumber(transformXML, ConstValues.A_SKEW_X, 0) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.skewY = getNumber(transformXML, ConstValues.A_SKEW_Y, 0) * ConstValues.ANGLE_TO_RADIAN || 0;
					transform.scaleX = getNumber(transformXML, ConstValues.A_SCALE_X, 1) || 0;
					transform.scaleY = getNumber(transformXML, ConstValues.A_SCALE_Y, 1) || 0;
				}
				if(pivot)
				{
					pivot.x = getNumber(transformXML, ConstValues.A_PIVOT_X, 0) || 0;
					pivot.y = getNumber(transformXML, ConstValues.A_PIVOT_Y, 0) || 0;
				}
			}
		}
		
		private static function parseColorTransform(colorTransformXML:XML, colorTransform:ColorTransform):void
		{
			if(colorTransformXML)
			{
				if(colorTransform)
				{
					colorTransform.alphaOffset = int(colorTransformXML.@[ConstValues.A_ALPHA_OFFSET]);
					colorTransform.redOffset = int(colorTransformXML.@[ConstValues.A_RED_OFFSET]);
					colorTransform.greenOffset = int(colorTransformXML.@[ConstValues.A_GREEN_OFFSET]);
					colorTransform.blueOffset = int(colorTransformXML.@[ConstValues.A_BLUE_OFFSET]);
					
					colorTransform.alphaMultiplier = int(getNumber(colorTransformXML, ConstValues.A_ALPHA_MULTIPLIER, 100) || 100) * 0.01;
					colorTransform.redMultiplier = int(getNumber(colorTransformXML, ConstValues.A_RED_MULTIPLIER, 100) || 100) * 0.01;
					colorTransform.greenMultiplier = int(getNumber(colorTransformXML, ConstValues.A_GREEN_MULTIPLIER, 100) || 100) * 0.01;
					colorTransform.blueMultiplier = int(getNumber(colorTransformXML, ConstValues.A_BLUE_MULTIPLIER, 100) || 100) * 0.01;
				}
			}
		}
		
		private static function getBoolean(data:XML, key:String, defaultValue:Boolean):Boolean
		{
			if(data && data.@[key].length() > 0)
			{
				switch(String(data.@[key]))
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
		
		private static function getNumber(data:XML, key:String, defaultValue:Number):Number
		{
			if(data && data.@[key].length() > 0)
			{
				switch(String(data.@[key]))
				{
					case "NaN":
					case "":
					case "false":
					case "null":
					case "undefined":
						return NaN;
						
					default:
						return Number(data.@[key]);
				}
			}
			return defaultValue;
		}
	}

}