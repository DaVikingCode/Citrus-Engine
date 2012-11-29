package dragonBones.objects
{
	import dragonBones.errors.UnknownDataError;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.TransfromUtils;
	import dragonBones.utils.dragonBones_internal;
	import dragonBones.utils.BytesType;
	
	import flash.utils.ByteArray;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.LoaderContext;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public class XMLDataParser
	{
		private static var helpNode:Node = new Node();
		
		private static function checkSkeletonXMLVersion(skeletonXML:XML):void
		{
			var version:String = skeletonXML.attribute(ConstValues.A_VERSION);
			switch(version){
				case ConstValues.VERSION:
					break;
				default:
					throw new Error("Nonsupport data version!");
			}
		}
		
		private static function getElementByAttribute(xmlList:XMLList, attribute:String, value:String):XMLList
		{
			var result:XMLList = new XMLList();
			var length:uint = xmlList.length();
			for (var i:int = 0; i < length; i++ )
			{
				var xml:XML = xmlList[i];
				if (xml["@" + attribute].toString() == value)
				{
					result[result.length()] = xmlList[i];
				}
			}
			return result;
		}
		
		public static function compressionData(skeletonXML:XML, textureAtlasXML:XML, byteArray:ByteArray):ByteArray {
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
		
		public static function parseXMLData(compressedByteArray:ByteArray):SkeletonAndTextureAtlasData
		{
			var dataType:String = BytesType.getType(compressedByteArray);
			switch(dataType)
			{
				case BytesType.SWF:
				case BytesType.PNG:
				case BytesType.JPG:
					try {
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
						throw new Error("Uncompression error!");
					}
					
					var sat:SkeletonAndTextureAtlasData = new SkeletonAndTextureAtlasData(skeletonXML, textureAtlasXML, compressedByteArray);
					return sat;
				case BytesType.ZIP:
					throw new Error("Can not uncompression zip!");
				default:
					throw new UnknownDataError();
			}
			return null;
		}
		
		public static function parseSkeletonData(skeletonXML:XML):SkeletonData
		{
			checkSkeletonXMLVersion(skeletonXML);
			
			var skeletonData:SkeletonData = new SkeletonData();
			skeletonData._name = skeletonXML.attribute(ConstValues.A_NAME);
			
			for each(var armatureXML:XML in skeletonXML.elements(ConstValues.ARMATURES).elements(ConstValues.ARMATURE))
			{
				var armatureData:ArmatureData = parseAramtureData(armatureXML);
				skeletonData.addArmatureData(armatureData);
			}
			
			for each(var animationXML:XML in skeletonXML.elements(ConstValues.ANIMATIONS).elements(ConstValues.ANIMATION))
			{
				var animationData:AnimationData = parseAnimationData(animationXML, skeletonData);
				skeletonData.addAnimationData(animationData);
			}
			return skeletonData;
		}
		
		private static function parseAramtureData(armatureXML:XML):ArmatureData
		{
			var aramtureData:ArmatureData = new ArmatureData();
			aramtureData._name = armatureXML.attribute(ConstValues.A_NAME);
			
			var boneXMLList:XMLList = armatureXML.elements(ConstValues.BONE);
			for each(var boneXML:XML in boneXMLList)
			{
				var boneName:String = boneXML.attribute(ConstValues.A_NAME);
				var parentName:String = boneXML.attribute(ConstValues.A_PARENT);
				var parentXML:XML = getElementByAttribute(boneXMLList, ConstValues.A_NAME, parentName)[0];
				var boneData:BoneData = aramtureData.getBoneData(boneName);
				boneData = parseBoneData(boneXML, parentXML, boneData);
				aramtureData.addBoneData(boneData);
			}
				
			aramtureData.updateBoneList();
			return aramtureData;
		}
		
		dragonBones_internal static function parseBoneData(boneXML:XML, parentXML:XML, boneData:BoneData = null):BoneData
		{
			if(!boneData){
				boneData = new BoneData();
			}
			boneData._name = boneXML.attribute(ConstValues.A_NAME);
			
			boneData.x = Number(boneXML.attribute(ConstValues.A_X));
			boneData.y = Number(boneXML.attribute(ConstValues.A_Y));
			boneData.skewX = Number(boneXML.attribute(ConstValues.A_SKEW_X)) * ConstValues.ANGLE_TO_RADIAN;
			boneData.skewY = Number(boneXML.attribute(ConstValues.A_SKEW_Y)) * ConstValues.ANGLE_TO_RADIAN;
			//boneData.scaleX = Number(boneXML.attribute(ConstValues.A_SCALE_X));
			//boneData.scaleY = Number(boneXML.attribute(ConstValues.A_SCALE_Y));
			boneData.z = int(boneXML.attribute(ConstValues.A_Z));
			
			var displayXMLList:XMLList = boneXML.elements(ConstValues.DISPLAY);
			var length:uint = displayXMLList.length();
			for(var i:int = 0;i < length;i ++)
			{
				var displayXML:XML = displayXMLList[i];
				var displayData:DisplayData = boneData.getDisplayDataAt(i);
				boneData._displayList[i] = parseDisplayData(displayXML, displayData);
			}
			
			if(parentXML)
			{
				boneData._parent = parentXML.attribute(ConstValues.A_NAME);
				helpNode.x = Number(parentXML.attribute(ConstValues.A_X));
				helpNode.y = Number(parentXML.attribute(ConstValues.A_Y));
				helpNode.skewX = Number(parentXML.attribute(ConstValues.A_SKEW_X)) * ConstValues.ANGLE_TO_RADIAN;
				helpNode.skewY = Number(parentXML.attribute(ConstValues.A_SKEW_Y)) * ConstValues.ANGLE_TO_RADIAN;
				//helpNode.scaleX = Number(parentXML.attribute(ConstValues.A_SCALE_X));
				//helpNode.scaleY = Number(parentXML.attribute(ConstValues.A_SCALE_Y));
				
				TransfromUtils.transfromPointWithParent(boneData, helpNode);
			}
			return boneData;
		}
		
		private static function parseDisplayData(displayXML:XML, displayData:DisplayData = null):DisplayData
		{
			if(!displayData)
			{
				displayData = new DisplayData();
			}
			displayData._name = displayXML.attribute(ConstValues.A_NAME);
			displayData._isArmature = Boolean(int(displayXML.attribute(ConstValues.A_IS_ARMATURE)));
			return displayData;
		}
		
		dragonBones_internal static function parseAnimationData(animationXML:XML, skeletonData:SkeletonData):AnimationData
		{
			var animationName:String = animationXML.attribute(ConstValues.A_NAME);
			var animationData:AnimationData = skeletonData.getAnimationData(animationName);
			if(!animationData)
			{
				animationData = new AnimationData();
				animationData._name = animationName;
			}
			
			var armatureData:ArmatureData = skeletonData.getArmatureData(animationData.name);
			for each(var movementXML:XML in animationXML.elements(ConstValues.MOVEMENT))
			{
				var movementName:String = movementXML.attribute(ConstValues.A_NAME);
				var movementData:MovementData = animationData.getMovementData(movementName);
				movementData = parseMovementData(movementXML, armatureData, movementData);
				animationData.addMovementData(movementData);
			}
			return animationData;
		}
		
		private static function parseMovementData(movementXML:XML, armatureData:ArmatureData, movementData:MovementData = null):MovementData
		{
			if(!movementData){
				movementData = new MovementData();
			}
			
			movementData._name = movementXML.attribute(ConstValues.A_NAME);
			
			movementData.setValues(
				int(movementXML.attribute(ConstValues.A_DURATION)),
				int(movementXML.attribute(ConstValues.A_DURATION_TO)),
				int(movementXML.attribute(ConstValues.A_DURATION_TWEEN)),
				Boolean(int(movementXML.attribute(ConstValues.A_LOOP)) == 1),
				Number(movementXML.attribute(ConstValues.A_TWEEN_EASING)[0])
			);
			
			var movementBoneXMLList:XMLList = movementXML.elements(ConstValues.BONE);
			for each(var movementBoneXML:XML in movementBoneXMLList)
			{
				var boneName:String = movementBoneXML.attribute(ConstValues.A_NAME);
				var boneData:BoneData = armatureData.getBoneData(boneName);
				var parentXML:XML = getElementByAttribute(movementBoneXMLList, ConstValues.A_NAME, boneData.parent)[0];
				var movementBoneData:MovementBoneData = movementData.getMovementBoneData(boneName);
				movementBoneData = parseMovementBoneData(movementBoneXML, parentXML, boneData, movementBoneData);
				movementData.addMovementBoneData(movementBoneData);
			}
			
			var movementFrameXMLList:XMLList = movementXML.elements(ConstValues.FRAME);
			var length:uint = movementFrameXMLList.length();
			for(var i:int = 0;i < length;i ++)
			{
				var movementFrameXML:XML = movementFrameXMLList[i];
				var movementFrameData:MovementFrameData = movementData._movementFrameList.length > i?movementData._movementFrameList[i]:null;
				movementFrameData = parseMovementFrameData(movementFrameXML, movementFrameData);
				movementData._movementFrameList[i] = movementFrameData;
			}
			return movementData;
		}
		
		private static function parseMovementBoneData(movementBoneXML:XML, parentXML:XML, boneData:BoneData, movementBoneData:MovementBoneData = null):MovementBoneData
		{
			if(!movementBoneData){
				movementBoneData = new MovementBoneData();
			}
			movementBoneData._name = movementBoneXML.attribute(ConstValues.A_NAME);
			
			movementBoneData._duration = 0;
			movementBoneData.setValues(
				Number(movementBoneXML.attribute(ConstValues.A_MOVEMENT_SCALE)),
				Number(movementBoneXML.attribute(ConstValues.A_MOVEMENT_DELAY))
			);
			
			if(parentXML){
				var xmlList:XMLList = parentXML.elements(ConstValues.FRAME);
				var parentFrameXML:XML;
				var parentLength:uint = xmlList.length();
				var i:uint = 0;
				var parentTotalDuration:uint = 0;
				var currentDuration:uint = 0;
			}
			
			var totalDuration:uint = 0;
			var frameXMLList:XMLList = movementBoneXML.elements(ConstValues.FRAME);
			var length:uint = frameXMLList.length();
			for(var j:int = 0;j < length;j ++)
			{
				var frameXML:XML = frameXMLList[j];
				if(parentXML){
					while(i < parentLength && (parentFrameXML?(totalDuration < parentTotalDuration || totalDuration >= parentTotalDuration + currentDuration):true))
					{
						parentFrameXML = xmlList[i];
						parentTotalDuration += currentDuration;
						currentDuration = int(parentFrameXML.attribute(ConstValues.A_DURATION));
						i++;
					}
				}
				var frameData:FrameData = movementBoneData._frameList.length > j?movementBoneData._frameList[j]:null;
				frameData = parseFrameData(frameXML, parentFrameXML, boneData, frameData);
				movementBoneData._frameList[j] = frameData;
				movementBoneData._duration += frameData.duration;
				totalDuration += frameData.duration;
			}
			return movementBoneData;
		}
		
		private static function parseMovementFrameData(movementFrameXML:XML, movementFrameData:MovementFrameData = null):MovementFrameData
		{
			if(!movementFrameData){
				movementFrameData = new MovementFrameData();
			}
			
			movementFrameData.setValues(
				int(movementFrameXML.attribute(ConstValues.A_START)),
				int(movementFrameXML.attribute(ConstValues.A_DURATION)),
				movementFrameXML.attribute(ConstValues.A_MOVEMENT),
				movementFrameXML.attribute(ConstValues.A_EVENT),
				movementFrameXML.attribute(ConstValues.A_SOUND)
			);
			return movementFrameData;
		}
	
		private static function parseFrameData(frameXML:XML, parentFrameXML:XML, boneData:BoneData, frameData:FrameData = null):FrameData
		{
			if(!frameData){
				frameData = new FrameData();
			}
				
			frameData.x = Number(frameXML.attribute(ConstValues.A_X));
			frameData.y = Number(frameXML.attribute(ConstValues.A_Y));
			frameData.skewX = Number(frameXML.attribute(ConstValues.A_SKEW_X)) * ConstValues.ANGLE_TO_RADIAN;
			frameData.skewY = Number(frameXML.attribute(ConstValues.A_SKEW_Y)) * ConstValues.ANGLE_TO_RADIAN;
			frameData.z = int(frameXML.attribute(ConstValues.A_Z));
			frameData.duration = int(frameXML.attribute(ConstValues.A_DURATION));
			frameData.tweenEasing = Number(frameXML.attribute(ConstValues.A_TWEEN_EASING));
			frameData.tweenRotate = int(frameXML.attribute(ConstValues.A_TWEEN_ROTATE));
			frameData.displayIndex = int(frameXML.attribute(ConstValues.A_DISPLAY_INDEX));
			frameData.movement = String(frameXML.attribute(ConstValues.A_MOVEMENT));
				
			frameData.event = String(frameXML.attribute(ConstValues.A_EVENT));
			frameData.sound = String(frameXML.attribute(ConstValues.A_SOUND));
			frameData.soundEffect = String(frameXML.attribute(ConstValues.A_SOUND_EFFECT));
				
				
			if(parentFrameXML){
				helpNode.x = Number(parentFrameXML.attribute(ConstValues.A_X));
				helpNode.y = Number(parentFrameXML.attribute(ConstValues.A_Y));
				helpNode.skewX = Number(parentFrameXML.attribute(ConstValues.A_SKEW_X)) * ConstValues.ANGLE_TO_RADIAN;
				helpNode.skewY = Number(parentFrameXML.attribute(ConstValues.A_SKEW_Y)) * ConstValues.ANGLE_TO_RADIAN;
				//helpNode.scaleX = Number(parentFrameXML.attribute(ConstValues.A_SCALE_X));
				//helpNode.scaleY = Number(parentFrameXML.attribute(ConstValues.A_SCALE_Y));
				
				TransfromUtils.transfromPointWithParent(frameData, helpNode);
			}
			
			frameData.x -=	boneData.x;
			frameData.y -=	boneData.y;
			frameData.skewX -=	boneData.skewX;
			frameData.skewY -=boneData.skewY;
			frameData.scaleX = Number(frameXML.attribute(ConstValues.A_SCALE_X));
			frameData.scaleY = Number(frameXML.attribute(ConstValues.A_SCALE_Y));
			//frameData.scaleX -= boneData.scaleX;
			//frameData.scaleY -= boneData.scaleY;
			
			return frameData;
		}
		
		public static function parseTextureAtlasData(textureAtlasXML:XML, textureBytes:ByteArray):TextureAtlasData
		{
			var textureAtlasData:TextureAtlasData = new TextureAtlasData();
			textureAtlasData._name = textureAtlasXML.attribute(ConstValues.A_NAME);
			textureAtlasData._width = int(textureAtlasXML.attribute(ConstValues.A_WIDTH));
			textureAtlasData._height = int(textureAtlasXML.attribute(ConstValues.A_HEIGHT));
			
			
			for each(var subTextureXML:XML in textureAtlasXML.elements(ConstValues.SUB_TEXTURE))
			{
				var subTextureData:SubTextureData = parseSubTextureData(subTextureXML);
				textureAtlasData.addSubTextureData(subTextureData);
			}
			
			var dataType:String = BytesType.getType(textureBytes);
			textureAtlasData._dataType = dataType;
			textureAtlasData._rawData = textureBytes;
			switch(dataType)
			{
				case BytesType.SWF:
				case BytesType.PNG:
				case BytesType.JPG:
					var loader:Loader = new Loader();
					var loaderContext:LoaderContext = new LoaderContext(false);
					loaderContext.allowCodeImport = true;
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureAtlasData.loaderCompleteHandler);
					loader.loadBytes(textureBytes, loaderContext);
					break;
				case BytesType.ATF:
					textureAtlasData.completeHandler();
					break;
				default:
					throw new UnknownDataError();
					break;
			}
			return textureAtlasData;
		}
		
		private static function parseSubTextureData(subTextureXML:XML):SubTextureData
		{
			var subTextureData:SubTextureData = new SubTextureData();
			subTextureData.name = subTextureXML.attribute(ConstValues.A_NAME);
			subTextureData.x = int(subTextureXML.attribute(ConstValues.A_X));
			subTextureData.y = int(subTextureXML.attribute(ConstValues.A_Y));
			subTextureData.width = int(subTextureXML.attribute(ConstValues.A_WIDTH));
			subTextureData.height = int(subTextureXML.attribute(ConstValues.A_HEIGHT));
			subTextureData.pivotX = int(subTextureXML.attribute(ConstValues.A_PIVOT_X));
			subTextureData.pivotY = int(subTextureXML.attribute(ConstValues.A_PIVOT_Y));
			return subTextureData;
		}
	}
	
}