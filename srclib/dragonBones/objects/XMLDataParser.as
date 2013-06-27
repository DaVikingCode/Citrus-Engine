package dragonBones.objects
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.animation.Tween;
	import dragonBones.errors.UnknownDataError;
	import dragonBones.utils.BytesType;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.TransformUtils;
	import dragonBones.utils.dragonBones_internal;
	import flash.geom.ColorTransform;
	import flash.utils.ByteArray;
	use namespace dragonBones_internal;
	/**
	 * The XMLDataParser xlass creates and parses xml data from dragonBones generated maps.
	 */
	public class XMLDataParser
	{
		private static const ANGLE_TO_RADIAN:Number = Math.PI / 180;
		private static const HALF_PI:Number = Math.PI * 0.5;
		private static var _currentSkeletonData:SkeletonData;
		private static var _helpNode:BoneTransform = new BoneTransform();
		private static var _helpFrameData:FrameData = new FrameData();
		
		private static function checkSkeletonXMLVersion(skeletonXML:XML):void
		{
			var version:String = skeletonXML.attribute(ConstValues.A_VERSION);
			switch (version)
			{
				case "1.4":
				case "1.5":
				case "2.0":
				case "2.1":
				case "2.1.1":
				case "2.1.2":
				case ConstValues.VERSION:
					break;
				default: 
					throw new Error("Nonsupport data version!");
			}
		}
		
		/** @private */
		public static function getElementsByAttribute(xmlList:XMLList, attribute:String, value:String):XMLList
		{
			var result:XMLList = new XMLList();
			var length:uint = xmlList.length();
			for (var i:int = 0; i < length; i++)
			{
				var xml:XML = xmlList[i];
				if (xml.@[attribute].toString() == value)
				{
					result[result.length()] = xmlList[i];
				}
			}
			return result;
		}
		/**
		 * Compress all data into a ByteArray for serialization.
		 * @param	skeletonXML The Skeleton data.
		 * @param	textureAtlasXML The TextureAtlas data.
		 * @param	byteArray The ByteArray representing the map.
		 * @return ByteArray. A DragonBones compatible ByteArray.
		 */
		public static function compressData(skeletonXML:XML, textureAtlasXML:XML, byteArray:ByteArray):ByteArray
		{
			var byteArrayCopy:ByteArray = new ByteArray();
			byteArrayCopy.writeBytes(byteArray);
			var xmlBytes:ByteArray = new ByteArray();
			xmlBytes.writeUTFBytes(textureAtlasXML.toXMLString());
			xmlBytes.compress();
			byteArrayCopy.position = byteArrayCopy.length;
			byteArrayCopy.writeBytes(xmlBytes);
			byteArrayCopy.writeInt(xmlBytes.length);
			xmlBytes.length = 0;
			xmlBytes.writeUTFBytes(skeletonXML.toXMLString());
			xmlBytes.compress();
			byteArrayCopy.position = byteArrayCopy.length;
			byteArrayCopy.writeBytes(xmlBytes);
			byteArrayCopy.writeInt(xmlBytes.length);
			return byteArrayCopy;
		}
		/**
		 * Decompress a compatible DragonBones data.
		 * @param	compressedByteArray The ByteArray to decompress.
		 * @return A DecompressedData instance.
		 */
		public static function decompressData(compressedByteArray:ByteArray):DecompressedData
		{
			var dataType:String = BytesType.getType(compressedByteArray);
			switch (dataType)
			{
				case BytesType.SWF: 
				case BytesType.PNG: 
				case BytesType.JPG: 
					try
					{
						compressedByteArray.position = compressedByteArray.length - 4;
						var strSize:int = compressedByteArray.readInt();
						var position:uint = compressedByteArray.length - 4 - strSize;
						var xmlBytes:ByteArray = new ByteArray();
						xmlBytes.writeBytes(compressedByteArray, position, strSize);
						xmlBytes.uncompress();
						compressedByteArray.length = position;
						var skeletonXML:XML = XML(xmlBytes.readUTFBytes(xmlBytes.length));
						compressedByteArray.position = compressedByteArray.length - 4;
						strSize = compressedByteArray.readInt();
						position = compressedByteArray.length - 4 - strSize;
						xmlBytes.length = 0;
						xmlBytes.writeBytes(compressedByteArray, position, strSize);
						xmlBytes.uncompress();
						compressedByteArray.length = position;
						var textureAtlasXML:XML = XML(xmlBytes.readUTFBytes(xmlBytes.length));
					}
					catch (e:Error)
					{
						throw new Error("Decompress error!");
					}
					var decompressedData:DecompressedData = new DecompressedData(skeletonXML, textureAtlasXML, compressedByteArray);
					return decompressedData;
				case BytesType.ZIP: 
					throw new Error("Can not decompress zip!");
				default: 
					throw new UnknownDataError();
			}
			return null;
		}
		/**
		 * Parse the SkeletonData.
		 * @param	skeletonXML The Skeleton xml to parse.
		 * @return A SkeletonData instance.
		 */
		public static function parseSkeletonData(skeletonXML:XML):SkeletonData
		{
			checkSkeletonXMLVersion(skeletonXML);
			var skeletonData:SkeletonData = new SkeletonData();
			skeletonData._name = skeletonXML.attribute(ConstValues.A_NAME);
			skeletonData._frameRate = int(skeletonXML.attribute(ConstValues.A_FRAME_RATE));
			_currentSkeletonData = skeletonData;
			for each (var armatureXML:XML in skeletonXML.elements(ConstValues.ARMATURES).elements(ConstValues.ARMATURE))
			{
				var armatureName:String = armatureXML.attribute(ConstValues.A_NAME);
				var armatureData:ArmatureData = skeletonData.getArmatureData(armatureName);
				if (armatureData)
				{
					parseArmatureData(armatureXML, armatureData);
				}
				else
				{
					armatureData = new ArmatureData();
					parseArmatureData(armatureXML, armatureData);
					skeletonData._armatureDataList.addData(armatureData, armatureName);
				}
			}
			
			for each (var animationXML:XML in skeletonXML.elements(ConstValues.ANIMATIONS).elements(ConstValues.ANIMATION))
			{
				var animationName:String = animationXML.attribute(ConstValues.A_NAME);
				armatureData = skeletonData.getArmatureData(animationName);
				var animationData:AnimationData = skeletonData.getAnimationData(animationName);
				if (animationData)
				{
					parseAnimationData(animationXML, animationData, armatureData);
				}
				else
				{
					animationData = new AnimationData();
					parseAnimationData(animationXML, animationData, armatureData);
					skeletonData._animationDataList.addData(animationData, animationName);
				}
			}
			_currentSkeletonData = null;
			return skeletonData;
		}
		
		private static function parseArmatureData(armatureXML:XML, armatureData:ArmatureData):void
		{
			var boneXMLList:XMLList = armatureXML.elements(ConstValues.BONE);
			for each (var boneXML:XML in boneXMLList)
			{
				var boneName:String = boneXML.attribute(ConstValues.A_NAME);
				var parentName:String = boneXML.attribute(ConstValues.A_PARENT);
				var parentXML:XML = getElementsByAttribute(boneXMLList, ConstValues.A_NAME, parentName)[0];
				var boneData:BoneData = armatureData.getBoneData(boneName);
				if (boneData)
				{
					parseBoneData(boneXML, parentXML, boneData);
				}
				else
				{
					boneData = new BoneData();
					parseBoneData(boneXML, parentXML, boneData);
					armatureData._boneDataList.addData(boneData, boneName);
				}
			}
			
			armatureData.updateBoneList();
		}
		
		/** @private */
		dragonBones_internal static function parseBoneData(boneXML:XML, parentXML:XML, boneData:BoneData):void
		{
			parseNode(boneXML, boneData.node);
			if (parentXML)
			{
				boneData._parent = parentXML.attribute(ConstValues.A_NAME);
				parseNode(parentXML, _helpNode);
				TransformUtils.transformPointWithParent(boneData.node, _helpNode);
			}
			else
			{
				boneData._parent = null;
			}
			if (_currentSkeletonData)
			{
				var displayXMLList:XMLList = boneXML.elements(ConstValues.DISPLAY);
				var length:uint = displayXMLList.length();
				for (var i:int = 0; i < length; i++)
				{
					var displayXML:XML = displayXMLList[i];
					var displayName:String = displayXML.attribute(ConstValues.A_NAME);
					boneData._displayNames[i] = displayName;
					var displayData:DisplayData = _currentSkeletonData.getDisplayData(displayName);
					if (displayData)
					{
						parseDisplayData(displayXML, displayData);
					}
					else
					{
						displayData = new DisplayData();
						parseDisplayData(displayXML, displayData);
						_currentSkeletonData._displayDataList.addData(displayData, displayName);
					}
				}
			}
		}
		
		private static function parseDisplayData(displayXML:XML, displayData:DisplayData):void
		{
			displayData._isArmature = Boolean(int(displayXML.attribute(ConstValues.A_IS_ARMATURE)));
			displayData.pivotX = Number(displayXML.attribute(ConstValues.A_PIVOT_X));
			displayData.pivotY = Number(displayXML.attribute(ConstValues.A_PIVOT_Y));
		}
		
		/** @private */
		dragonBones_internal static function parseAnimationData(animationXML:XML, animationData:AnimationData, armatureData:ArmatureData):void
		{
			for each (var movementXML:XML in animationXML.elements(ConstValues.MOVEMENT))
			{
				var movementName:String = movementXML.attribute(ConstValues.A_NAME);
				var movementData:MovementData = animationData.getMovementData(movementName);
				if (movementData)
				{
					parseMovementData(movementXML, armatureData, movementData);
				}
				else
				{
					movementData = new MovementData();
					parseMovementData(movementXML, armatureData, movementData);
					animationData._movementDataList.addData(movementData, movementName);
				}
			}
		}
		
		private static function parseMovementData(movementXML:XML, armatureData:ArmatureData, movementData:MovementData):void
		{
			if (_currentSkeletonData)
			{
				var frameRate:uint = _currentSkeletonData._frameRate;
				var duration:int = int(movementXML.attribute(ConstValues.A_DURATION));
				movementData.duration = (duration > 1) ? (duration / frameRate) : 0;
				movementData.durationTo = int(movementXML.attribute(ConstValues.A_DURATION_TO)) / frameRate;
				movementData.durationTween = int(movementXML.attribute(ConstValues.A_DURATION_TWEEN)) / frameRate;
				movementData.loop = Boolean(int(movementXML.attribute(ConstValues.A_LOOP)) == 1);
				movementData.tweenEasing = Number(movementXML.attribute(ConstValues.A_TWEEN_EASING)[0]);
			}
			var boneNames:Vector.<String> = armatureData.boneNames;
			var movementBoneXMLList:XMLList = movementXML.elements(ConstValues.BONE);
			for each (var movementBoneXML:XML in movementBoneXMLList)
			{
				var boneName:String = movementBoneXML.attribute(ConstValues.A_NAME);
				var boneData:BoneData = armatureData.getBoneData(boneName);
				var parentMovementBoneXML:XML = getElementsByAttribute(movementBoneXMLList, ConstValues.A_NAME, boneData.parent)[0];
				var movementBoneData:MovementBoneData = movementData.getMovementBoneData(boneName);
				if (movementBoneXML)
				{
					if (movementBoneData)
					{
						parseMovementBoneData(movementBoneXML, parentMovementBoneXML, boneData, movementBoneData);
					}
					else
					{
						movementBoneData = new MovementBoneData();
						parseMovementBoneData(movementBoneXML, parentMovementBoneXML, boneData, movementBoneData);
						movementData._movementBoneDataList.addData(movementBoneData, boneName);
					}
				}
				var index:int = boneNames.indexOf(boneName);
				if (index >= 0)
				{
					boneNames.splice(index, 1);
				}
			}
			for each (boneName in boneNames)
			{
				movementData._movementBoneDataList.addData(MovementBoneData.HIDE_DATA, boneName);
			}
			var movementFrameXMLList:XMLList = movementXML.elements(ConstValues.FRAME);
			var length:uint = movementFrameXMLList.length();
			var movementFrameList:Vector.<MovementFrameData> = movementData._movementFrameList;
			for (var i:int = 0; i < length; i++)
			{
				var movementFrameXML:XML = movementFrameXMLList[i];
				var movementFrameData:MovementFrameData = movementFrameList.length > i ? movementFrameList[i] : null;
				if (movementFrameData)
				{
					parseMovementFrameData(movementFrameXML, movementFrameData);
				}
				else
				{
					movementFrameData = new MovementFrameData();
					parseMovementFrameData(movementFrameXML, movementFrameData)
					if (movementFrameList.indexOf(movementFrameData) < 0)
					{
						movementFrameList.push(movementFrameData);
					}
				}
			}
		}
		
		private static function parseMovementBoneData(movementBoneXML:XML, parentMovementBoneXML:XML, boneData:BoneData, movementBoneData:MovementBoneData):void
		{
			movementBoneData.setValues(
				Number(movementBoneXML.attribute(ConstValues.A_MOVEMENT_SCALE)),
				Number(movementBoneXML.attribute(ConstValues.A_MOVEMENT_DELAY))
			);
			
			var i:uint = 0;
			var parentTotalDuration:uint = 0;
			var totalDuration:uint = 0;
			var currentDuration:uint = 0;
			if (parentMovementBoneXML)
			{
				var parentFrameXMLList:XMLList = parentMovementBoneXML.elements(ConstValues.FRAME);
				var parentFrameCount:uint = parentFrameXMLList.length();
				var parentFrameXML:XML;
			}
			var frameXMLList:XMLList = movementBoneXML.elements(ConstValues.FRAME);
			var frameCount:uint = frameXMLList.length();
			var frameList:Vector.<FrameData> = movementBoneData._frameList;
			for (var j:int = 0; j < frameCount; j++)
			{
				var frameXML:XML = frameXMLList[j];
				var frameData:FrameData = frameList.length > j ? frameList[j] : null;
				
				if (frameData)
				{
					parseFrameData(frameXML, frameData);
				}
				else
				{
					frameData = new FrameData();
					parseFrameData(frameXML, frameData);
					if (frameList.indexOf(frameData) < 0)
					{
						frameList.push(frameData);
					}
				}
				if (parentMovementBoneXML)
				{
					while (i < parentFrameCount && (parentFrameXML ? (totalDuration < parentTotalDuration || totalDuration >= parentTotalDuration + currentDuration) : true))
					{
						parentFrameXML = parentFrameXMLList[i];
						parentTotalDuration += currentDuration;
						currentDuration = int(parentFrameXML.attribute(ConstValues.A_DURATION));
						i++;
					}
					parseFrameData(parentFrameXML, _helpFrameData);
					var tweenFrameXML:XML = parentFrameXMLList[i];
					var progress:Number;
					if (tweenFrameXML)
					{
						progress = (totalDuration - parentTotalDuration) / currentDuration;
					}
					else
					{
						tweenFrameXML = parentFrameXML;
						progress = 0;
					}
					if (isNaN(_helpFrameData.tweenEasing))
					{
						progress = 0;
					}
					else
					{
						progress = Tween.getEaseValue(progress, _helpFrameData.tweenEasing);
					}
					parseNode(tweenFrameXML, _helpNode);
					TransformUtils.setOffSetNode(_helpFrameData.node, _helpNode, _helpNode, _helpFrameData.tweenRotate);
					
					_helpNode.setValues(
						_helpFrameData.node.x + progress * _helpNode.x,
						_helpFrameData.node.y + progress * _helpNode.y,
						_helpFrameData.node.skewX + progress * _helpNode.skewX,
						_helpFrameData.node.skewY + progress * _helpNode.skewY,
						_helpFrameData.node.scaleX + progress * _helpNode.scaleX,
						_helpFrameData.node.scaleY + progress * _helpNode.scaleY,
						_helpFrameData.node.pivotX + progress * _helpNode.pivotX,
						_helpFrameData.node.pivotY + progress * _helpNode.pivotY
					);
					
					TransformUtils.transformPointWithParent(frameData.node, _helpNode);
				}
				totalDuration += int(frameXML.attribute(ConstValues.A_DURATION));
				frameData.node.x -= boneData.node.x;
				frameData.node.y -= boneData.node.y;
				frameData.node.skewX -= boneData.node.skewX;
				frameData.node.skewY -= boneData.node.skewY;
				frameData.node.scaleX -= boneData.node.scaleX;
				frameData.node.scaleY -= boneData.node.scaleY;
				frameData.node.pivotX -= boneData.node.pivotX;
				frameData.node.pivotY -= boneData.node.pivotY;
				frameData.node.z -= boneData.node.z;
			}
		}
		
		private static function parseMovementFrameData(movementFrameXML:XML, movementFrameData:MovementFrameData):void
		{
			if(_currentSkeletonData)
			{
				movementFrameData.setValues(
					Number(movementFrameXML.attribute(ConstValues.A_DURATION)) / _currentSkeletonData._frameRate,
					movementFrameXML.attribute(ConstValues.A_MOVEMENT),
					movementFrameXML.attribute(ConstValues.A_EVENT),
					movementFrameXML.attribute(ConstValues.A_SOUND)
				);
			}
		}
		
		/** @private */
		dragonBones_internal static function parseFrameData(frameXML:XML, frameData:FrameData):void
		{
			parseNode(frameXML, frameData.node);
			if (_currentSkeletonData)
			{
				var colorTransformXML:XML = frameXML.elements(ConstValues.COLOR_TRANSFORM)[0];
				if (colorTransformXML)
				{
					parseColorTransform(colorTransformXML, frameData.colorTransform);
				}
				frameData.duration = int(frameXML.attribute(ConstValues.A_DURATION)) / _currentSkeletonData._frameRate;
				frameData.tweenEasing = Number(frameXML.attribute(ConstValues.A_TWEEN_EASING));
				frameData.tweenRotate = int(frameXML.attribute(ConstValues.A_TWEEN_ROTATE));
				frameData.displayIndex = int(frameXML.attribute(ConstValues.A_DISPLAY_INDEX));
				frameData.movement = String(frameXML.attribute(ConstValues.A_MOVEMENT));
				frameData.event = String(frameXML.attribute(ConstValues.A_EVENT));
				frameData.sound = String(frameXML.attribute(ConstValues.A_SOUND));
				frameData.soundEffect = String(frameXML.attribute(ConstValues.A_SOUND_EFFECT));
				var visibleStr:String = String(frameXML.attribute(ConstValues.A_VISIBLE));
				frameData.visible = (visibleStr == "1" || visibleStr == "");
			}
		}
		
		private static function parseNode(xml:XML, node:BoneTransform):void
		{
			node.x = Number(xml.attribute(ConstValues.A_X));
			node.y = Number(xml.attribute(ConstValues.A_Y));
			node.skewX = Number(xml.attribute(ConstValues.A_SKEW_X)) * ANGLE_TO_RADIAN;
			node.skewY = Number(xml.attribute(ConstValues.A_SKEW_Y)) * ANGLE_TO_RADIAN;
			node.scaleX = Number(xml.attribute(ConstValues.A_SCALE_X));
			node.scaleY = Number(xml.attribute(ConstValues.A_SCALE_Y));
			node.pivotX =  Number(xml.attribute(ConstValues.A_PIVOT_X));
			node.pivotY =  Number(xml.attribute(ConstValues.A_PIVOT_Y));
			node.z = int(xml.attribute(ConstValues.A_Z));
		}
		
		private static function parseColorTransform(xml:XML, colorTransform:ColorTransform):void
		{
			colorTransform.alphaOffset = int(xml.attribute(ConstValues.A_ALPHA));
			colorTransform.redOffset = int(xml.attribute(ConstValues.A_RED));
			colorTransform.greenOffset = int(xml.attribute(ConstValues.A_GREEN));
			colorTransform.blueOffset = int(xml.attribute(ConstValues.A_BLUE));
			colorTransform.alphaMultiplier = int(xml.attribute(ConstValues.A_ALPHA_MULTIPLIER)) * 0.01;
			colorTransform.redMultiplier = int(xml.attribute(ConstValues.A_RED_MULTIPLIER)) * 0.01;
			colorTransform.greenMultiplier = int(xml.attribute(ConstValues.A_GREEN_MULTIPLIER)) * 0.01;
			colorTransform.blueMultiplier = int(xml.attribute(ConstValues.A_BLUE_MULTIPLIER)) * 0.01;
		}
	}
}
