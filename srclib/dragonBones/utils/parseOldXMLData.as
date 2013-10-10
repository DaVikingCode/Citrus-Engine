package dragonBones.utils
{
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.ArmatureData;

	public function parseOldXMLData(rawData:XML):SkeletonData
	{
		var frameRate:uint = int(rawData.@[A_FRAME_RATE]);
		
		var data:SkeletonData = new SkeletonData();
		data.name = rawData.@[A_NAME];
		
		for each(var armatureXML:XML in rawData[ARMATURES][ARMATURE])
		{
			data.addArmatureData(parseArmatureData(armatureXML, data));
		}
		
		for each(var animationsXML:XML in rawData[ANIMATIONS][ANIMATION])
		{
			var armatureData:ArmatureData = data.getArmatureData(animationsXML.@[A_NAME]);
			if(armatureData)
			{
				for each(var animationXML:XML in animationsXML[MOVEMENT])
				{
					armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate));
				}
			}
		}
		
		return data;
	}
}

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
import dragonBones.utils.ConstValues;
import dragonBones.utils.DBDataUtil;

import flash.geom.ColorTransform;
import flash.geom.Point;

const ARMATURES:String = "armatures";
const ANIMATIONS:String = "animations";
const ARMATURE:String = "armature";
const BONE:String = "b";
const DISPLAY:String = "d";
const ANIMATION:String = "animation";
const MOVEMENT:String = "mov";
const FRAME:String = "f";
const COLOR_TRANSFORM:String = "colorTransform";

const A_VERSION:String = "version";
const A_FRAME_RATE:String = "frameRate";
const A_NAME:String = "name";
const A_PARENT:String = "parent";
const A_TYPE:String = "isArmature";
const A_DURATION:String = "dr";
const A_FADE_IN_TIME:String = "to";
const A_DURATION_TWEEN:String = "drTW";
const A_LOOP:String = "lp";
const A_SCALE:String = "sc";
const A_OFFSET:String = "dl";
const A_EVENT:String = "evt";
const A_SOUND:String = "sd";
const A_TWEEN_EASING:String = "twE";
const A_TWEEN_ROTATE:String = "twR";
const A_ACTION:String = "mov";
const A_VISIBLE:String = "visible";
const A_DISPLAY_INDEX:String = "dI";
const A_Z_ORDER:String = "z";
const A_X:String = "x";
const A_Y:String = "y";
const A_SKEW_X:String = "kX";
const A_SKEW_Y:String = "kY";
const A_SCALE_X:String = "cX";
const A_SCALE_Y:String = "cY";
const A_PIVOT_X:String = "pX";
const A_PIVOT_Y:String = "pY";

const A_ALPHA_OFFSET:String = "a";
const A_RED_OFFSET:String = "r";
const A_GREEN_OFFSET:String = "g";
const A_BLUE_OFFSET:String = "b";
const A_ALPHA_MULTIPLIER:String = "aM";
const A_RED_MULTIPLIER:String = "rM";
const A_GREEN_MULTIPLIER:String = "gM";
const A_BLUE_MULTIPLIER:String = "bM";

function parseArmatureData(armatureXML:XML, data:SkeletonData):ArmatureData
{
	var armatureData:ArmatureData = new ArmatureData();
	armatureData.name = armatureXML.@[A_NAME];
	
	for each(var boneXML:XML in armatureXML[BONE])
	{
		armatureData.addBoneData(parseBoneData(boneXML));
	}
	
	armatureData.addSkinData(parseSkinData(armatureXML, data));
	
	DBDataUtil.transformArmatureData(armatureData);
	armatureData.sortBoneDataList();
	return armatureData;
}

function parseBoneData(boneXML:XML):BoneData
{
	var boneData:BoneData = new BoneData();
	boneData.name = boneXML.@[A_NAME];
	boneData.parent = boneXML.@[A_PARENT];
	
	parseTransform(boneXML, boneData.global);
	boneData.transform.copy(boneData.global);
	
	return boneData;
}

function parseSkinData(armatureXML:XML, data:SkeletonData):SkinData
{
	var skinData:SkinData = new SkinData();
	//skinData.name
	for each(var boneXML:XML in armatureXML[BONE])
	{
		skinData.addSlotData(parseSlotData(boneXML, data));
	}
	
	return skinData;
}

function parseSlotData(boneXML:XML, data:SkeletonData):SlotData
{
	var slotData:SlotData = new SlotData();
	slotData.name = boneXML.@[A_NAME];
	slotData.parent = slotData.name;
	slotData.zOrder = boneXML.@[A_Z_ORDER];
	
	for each(var displayXML:XML in boneXML[DISPLAY])
	{
		var displayData:DisplayData = parseDisplayData(displayXML, data);
		slotData.addDisplayData(displayData);
	}
	
	return slotData;
}

function parseDisplayData(displayXML:XML, data:SkeletonData):DisplayData
{
	var displayData:DisplayData = new DisplayData();
	displayData.name = displayXML.@[A_NAME];
	if(uint(displayXML.@[A_TYPE]) == 1)
	{
		displayData.type = DisplayData.ARMATURE;
	}
	else
	{
		displayData.type = DisplayData.IMAGE;
	}
	
	//
	//displayData.transform.x = -Number(frameXML.@[A_PIVOT_X]);
	//displayData.transform.y = -Number(frameXML.@[A_PIVOT_Y]);
	displayData.transform.x = NaN;
	displayData.transform.y = NaN;
	displayData.transform.skewX = 0;
	displayData.transform.skewY = 0;
	displayData.transform.scaleX = 1;
	displayData.transform.scaleY = 1;
	
	displayData.pivot = data.addSubTexturePivot(
		Number(displayXML.@[A_PIVOT_X]), 
		Number(displayXML.@[A_PIVOT_Y]), 
		displayData.name
	);
	
	return displayData;
}

function parseAnimationData(animationXML:XML, armatureData:ArmatureData, frameRate:uint):AnimationData
{
	var animationData:AnimationData = new AnimationData();
	animationData.name = animationXML.@[A_NAME];
	animationData.frameRate = frameRate;
	animationData.loop = uint(animationXML.@[A_LOOP]) == 1?0:1;
	animationData.fadeInTime = uint(animationXML.@[A_FADE_IN_TIME]) / frameRate;
	animationData.duration = uint(animationXML.@[A_DURATION]) / frameRate;
	var durationTween:Number = Number(animationXML.@[A_DURATION_TWEEN][0]);
	if(isNaN(durationTween))
	{
		animationData.scale = 1;
	}
	else
	{
		animationData.scale = durationTween / frameRate / animationData.duration;
	}
	animationData.tweenEasing = Number(animationXML.@[A_TWEEN_EASING][0]);
	
	parseTimeline(animationXML, animationData, parseMainFrame, frameRate);
	
	var skinData:SkinData = armatureData.skinDataList[0];
	var slotData:SlotData;
	
	var timeline:TransformTimeline;
	var timelineName:String;
	for each(var timelineXML:XML in animationXML[BONE])
	{
		timeline = parseTransformTimeline(timelineXML, animationData.duration, frameRate);
		timelineName = timelineXML.@[A_NAME];
		animationData.addTimeline(timeline, timelineName);
		if(skinData)
		{
			slotData = skinData.getSlotData(timelineName);
			formatDisplayTransformXYAndTimelinePivot(slotData, timeline);
		}
	}
	
	DBDataUtil.addHideTimeline(animationData, armatureData);
	DBDataUtil.transformAnimationData(animationData, armatureData);
	
	return animationData;
}


function parseTimeline(timelineXML:XML, timeline:Timeline, frameParser:Function, frameRate:uint):void
{
	var position:Number = 0;
	var frame:Frame;
	for each(var frameXML:XML in timelineXML[FRAME])
	{
		frame = frameParser(frameXML, frameRate);
		frame.position = position;
		timeline.addFrame(frame);
		position += frame.duration;
	}
	if(frame)
	{
		frame.duration = timeline.duration - frame.position;
	}
}

function parseTransformTimeline(timelineXML:XML, duration:Number, frameRate:uint):TransformTimeline
{
	var timeline:TransformTimeline = new TransformTimeline();
	timeline.duration = duration;
	
	parseTimeline(timelineXML, timeline, parseTransformFrame, frameRate);
	
	timeline.scale = Number(timelineXML.@[A_SCALE]);
	timeline.offset = (1 - Number(timelineXML.@[A_OFFSET])) % 1;
	
	return timeline;
}

function parseFrame(frameXML:XML, frame:Frame, frameRate:uint):void
{
	frame.duration = uint(frameXML.@[A_DURATION]) / frameRate;
	frame.action = frameXML.@[A_ACTION];
	frame.event = frameXML.@[A_EVENT];
	frame.sound = frameXML.@[A_SOUND];
}

function parseMainFrame(frameXML:XML, frameRate:uint):Frame
{
	var frame:Frame = new Frame();
	parseFrame(frameXML, frame, frameRate);
	return frame;
}

function parseTransformFrame(frameXML:XML, frameRate:uint):TransformFrame
{
	var frame:TransformFrame = new TransformFrame();
	parseFrame(frameXML, frame, frameRate);
	
	frame.visible = frameXML.@[A_VISIBLE][0]?uint(frameXML.@[A_VISIBLE]) == 1:true;
	frame.tweenEasing = Number(frameXML.@[A_TWEEN_EASING]);
	frame.tweenRotate = int(frameXML.@[A_TWEEN_ROTATE]);
	frame.displayIndex = int(frameXML.@[A_DISPLAY_INDEX]);
	frame.zOrder = int(frameXML.@[A_Z_ORDER]);
	
	parseTransform(frameXML, frame.global, frame.pivot);
	frame.transform.copy(frame.global);
	
	frame.pivot.x *= -1;
	frame.pivot.y *= -1;
	
	var colorTransformXML:XML = frameXML[COLOR_TRANSFORM][0];
	if(colorTransformXML)
	{
		frame.color = new ColorTransform();
		frame.color.alphaOffset = int(colorTransformXML.@[A_ALPHA_OFFSET]);
		frame.color.redOffset = int(colorTransformXML.@[A_RED_OFFSET]);
		frame.color.greenOffset = int(colorTransformXML.@[A_GREEN_OFFSET]);
		frame.color.blueOffset = int(colorTransformXML.@[A_BLUE_OFFSET]);
		
		frame.color.alphaMultiplier = int(colorTransformXML.@[A_ALPHA_MULTIPLIER]) * 0.01;
		frame.color.redMultiplier = int(colorTransformXML.@[A_RED_MULTIPLIER]) * 0.01;
		frame.color.greenMultiplier = int(colorTransformXML.@[A_GREEN_MULTIPLIER]) * 0.01;
		frame.color.blueMultiplier = int(colorTransformXML.@[A_BLUE_MULTIPLIER]) * 0.01;
	}
	
	return frame;
}

function parseTransform(transformXML:XML, transform:DBTransform, pivot:Point = null):void
{
	if(transformXML)
	{
		if(transform)
		{
			transform.x = Number(transformXML.@[A_X]);
			transform.y = Number(transformXML.@[A_Y]);
			transform.skewX = Number(transformXML.@[A_SKEW_X]) * ConstValues.ANGLE_TO_RADIAN;
			transform.skewY = Number(transformXML.@[A_SKEW_Y]) * ConstValues.ANGLE_TO_RADIAN;
			transform.scaleX = Number(transformXML.@[A_SCALE_X]);
			transform.scaleY = Number(transformXML.@[A_SCALE_Y]);
		}
		if(pivot)
		{
			pivot.x = Number(transformXML.@[A_PIVOT_X]);
			pivot.y = Number(transformXML.@[A_PIVOT_Y]);
		}
	}
}

function formatDisplayTransformXYAndTimelinePivot(slotData:SlotData, timeline:TransformTimeline):void
{
	if(!slotData)
	{
		return;
	}
	
	var displayData:DisplayData;
	for each(var frame:TransformFrame in timeline.frameList)
	{
		if(frame.displayIndex >= 0)
		{
			displayData = slotData.displayDataList[frame.displayIndex];
			if(isNaN(displayData.transform.x))
			{
				displayData.transform.x = frame.pivot.x;
				displayData.transform.y = frame.pivot.y;
			}
			frame.pivot.x -= displayData.transform.x;
			frame.pivot.y -= displayData.transform.y;
		}
	}
}