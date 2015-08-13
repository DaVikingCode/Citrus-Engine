package dragonBones.factories
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.fast.FastArmature;
	import dragonBones.fast.FastBone;
	import dragonBones.fast.FastSlot;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.DataParser;
	import dragonBones.objects.DataSerializer;
	import dragonBones.objects.DecompressedData;
	import dragonBones.objects.DisplayData;
	import dragonBones.objects.DragonBonesData;
	import dragonBones.objects.SkinData;
	import dragonBones.objects.SlotData;
	import dragonBones.textures.ITextureAtlas;

	use namespace dragonBones_internal;
	
	public class BaseFactory  extends EventDispatcher
	{
		protected static const _helpMatrix:Matrix = new Matrix();
		
		/** @private */
		protected var dragonBonesDataDic:Dictionary = new Dictionary();
		
		/** @private */
		protected var textureAtlasDic:Dictionary = new Dictionary();
		public function BaseFactory(self:BaseFactory)
		{
			super(this);
			
			if(self != this)
			{ 
				throw new IllegalOperationError("Abstract class can not be instantiated!");
			}
		}
		
		/**
		 * Cleans up resources used by this BaseFactory instance.
		 * @param (optional) Destroy all internal references.
		 */
		public function dispose(disposeData:Boolean = true):void
		{
			if(disposeData)
			{
				for(var skeletonName:String in dragonBonesDataDic)
				{ 
					(dragonBonesDataDic[skeletonName] as DragonBonesData).dispose();
					delete dragonBonesDataDic[skeletonName];
				}
				
				for(var textureAtlasName:String in textureAtlasDic)
				{
					(textureAtlasDic[textureAtlasName] as ITextureAtlas).dispose();
					delete textureAtlasDic[textureAtlasName];
				}
			}
			
			dragonBonesDataDic = null;
			textureAtlasDic = null;
			//_currentDataName = null;
			//_currentTextureAtlasName = null;
		}
		
		/**
		 * Returns a SkeletonData instance.
		 * @param The name of an existing SkeletonData instance.
		 * @return A SkeletonData instance with given name (if exist).
		 */
		public function getSkeletonData(name:String):DragonBonesData
		{
			return dragonBonesDataDic[name];
		}
		
		/**
		 * Add a SkeletonData instance to this BaseFactory instance.
		 * @param A SkeletonData instance.
		 * @param (optional) A name for this SkeletonData instance.
		 */
		public function addSkeletonData(data:DragonBonesData, name:String = null):void
		{
			if(!data)
			{
				throw new ArgumentError();
			}
			name = name || data.name;
			if(!name)
			{
				throw new ArgumentError("Unnamed data!");
			}
			if(dragonBonesDataDic[name])
			{
				throw new ArgumentError();
			}
			dragonBonesDataDic[name] = data;
		}
		
		/**
		 * Remove a SkeletonData instance from this BaseFactory instance.
		 * @param The name for the SkeletonData instance to remove.
		 */
		public function removeSkeletonData(name:String):void
		{
			delete dragonBonesDataDic[name];
		}
		
		/**
		 * Return the TextureAtlas by name.
		 * @param The name of the TextureAtlas to return.
		 * @return A textureAtlas.
		 */
		public function getTextureAtlas(name:String):Object
		{
			return textureAtlasDic[name];
		}
		
		/**
		 * Add a textureAtlas to this BaseFactory instance.
		 * @param A textureAtlas to add to this BaseFactory instance.
		 * @param (optional) A name for this TextureAtlas.
		 */
		public function addTextureAtlas(textureAtlas:Object, name:String = null):void
		{
			if(!textureAtlas)
			{
				throw new ArgumentError();
			}
			if(!name && textureAtlas is ITextureAtlas)
			{
				name = textureAtlas.name;
			}
			if(!name)
			{
				throw new ArgumentError("Unnamed data!");
			}
			if(textureAtlasDic[name])
			{
				throw new ArgumentError();
			}
			textureAtlasDic[name] = textureAtlas;
		}
		
		/**
		 * Remove a textureAtlas from this baseFactory instance.
		 * @param The name of the TextureAtlas to remove.
		 */
		public function removeTextureAtlas(name:String):void
		{
			delete textureAtlasDic[name];
		}
		
		/**
		 * Return the TextureDisplay.
		 * @param The name of this Texture.
		 * @param The name of the TextureAtlas.
		 * @param The registration pivotX position.
		 * @param The registration pivotY position.
		 * @return An Object.
		 */
		public function getTextureDisplay(textureName:String, textureAtlasName:String = null, pivotX:Number = NaN, pivotY:Number = NaN):Object
		{
			var targetTextureAtlas:Object;
			if(textureAtlasName)
			{
				targetTextureAtlas = textureAtlasDic[textureAtlasName];
			}
			else
			{
				for (textureAtlasName in textureAtlasDic)
				{
					targetTextureAtlas = textureAtlasDic[textureAtlasName];
					if(targetTextureAtlas.getRegion(textureName))
					{
						break;
					}
					targetTextureAtlas = null;
				}
			}
			
			if(!targetTextureAtlas)
			{
				return null;
			}
			
			if(isNaN(pivotX) || isNaN(pivotY))
			{
				//默认dragonBonesData的名字和和纹理集的名字是一致的
				var data:DragonBonesData = dragonBonesDataDic[textureAtlasName];
				data = data ? data : findFirstDragonBonesData();
				if(data)
				{
					var displayData:DisplayData = data.getDisplayDataByName(textureName);
					if(displayData)
					{
						pivotX = displayData.pivot.x;
						pivotY = displayData.pivot.y;
					}
				}
			}
			
			return generateDisplay(targetTextureAtlas, textureName, pivotX, pivotY);
		}
		
		//一般情况下dragonBonesData和textureAtlas是一对一的，通过相同的key对应。
		//TO DO 以后会支持一对多的情况
		public function buildArmature(armatureName:String, fromDragonBonesDataName:String = null, fromTextureAtlasName:String = null, skinName:String = null):Armature
		{
			var buildArmatureDataPackage:BuildArmatureDataPackage = new BuildArmatureDataPackage();
			if(fillBuildArmatureDataPackageArmatureInfo(armatureName, fromDragonBonesDataName, buildArmatureDataPackage))
			{
				fillBuildArmatureDataPackageTextureInfo(fromTextureAtlasName, buildArmatureDataPackage);
			}
			
			var dragonBonesData:DragonBonesData = buildArmatureDataPackage.dragonBonesData;
			var armatureData:ArmatureData = buildArmatureDataPackage.armatureData;
			var textureAtlas:Object = buildArmatureDataPackage.textureAtlas;
			
			if(!armatureData || !textureAtlas)
			{
				return null;
			}
			
			return buildArmatureUsingArmatureDataFromTextureAtlas(dragonBonesData, armatureData, textureAtlas, skinName);
		}
		
		public function buildFastArmature(armatureName:String, fromDragonBonesDataName:String = null, fromTextureAtlasName:String = null, skinName:String = null):FastArmature
		{
			var buildArmatureDataPackage:BuildArmatureDataPackage = new BuildArmatureDataPackage();
			if(fillBuildArmatureDataPackageArmatureInfo(armatureName, fromDragonBonesDataName, buildArmatureDataPackage))
			{
				fillBuildArmatureDataPackageTextureInfo(fromTextureAtlasName, buildArmatureDataPackage);
			}
			
			var dragonBonesData:DragonBonesData = buildArmatureDataPackage.dragonBonesData;
			var armatureData:ArmatureData = buildArmatureDataPackage.armatureData;
			var textureAtlas:Object = buildArmatureDataPackage.textureAtlas;
			
			if(!armatureData || !textureAtlas)
			{
				return null;
			}
			
			return buildFastArmatureUsingArmatureDataFromTextureAtlas(dragonBonesData, armatureData, textureAtlas, skinName);
		}
		
		protected function buildArmatureUsingArmatureDataFromTextureAtlas(dragonBonesData:DragonBonesData, armatureData:ArmatureData, textureAtlas:Object, skinName:String = null):Armature
		{
			var outputArmature:Armature = generateArmature();
			outputArmature.name = armatureData.name;
			outputArmature.__dragonBonesData = dragonBonesData;
			outputArmature._armatureData = armatureData;
			outputArmature.animation.animationDataList = armatureData.animationDataList;
			
			buildBones(outputArmature);
			//TO DO: Support multi textureAtlas case in future
			buildSlots(outputArmature, skinName, textureAtlas);
			
			outputArmature.advanceTime(0);
			return outputArmature;
		}
		
		protected function buildFastArmatureUsingArmatureDataFromTextureAtlas(dragonBonesData:DragonBonesData, armatureData:ArmatureData, textureAtlas:Object, skinName:String = null):FastArmature
		{
			var outputArmature:FastArmature = generateFastArmature();
			outputArmature.name = armatureData.name;
			outputArmature.__dragonBonesData = dragonBonesData;
			outputArmature._armatureData = armatureData;
			outputArmature.animation.animationDataList = armatureData.animationDataList;
			
			buildFastBones(outputArmature);
			//TO DO: Support multi textureAtlas case in future
			buildFastSlots(outputArmature, skinName, textureAtlas);
			
			outputArmature.advanceTime(0);
			
			return outputArmature;
		}
		
		//暂时不支持ifRemoveOriginalAnimationList为false的情况
		public function copyAnimationsToArmature(toArmature:Armature, fromArmatreName:String, fromDragonBonesDataName:String = null, ifRemoveOriginalAnimationList:Boolean = true):Boolean
		{
			var buildArmatureDataPackage:BuildArmatureDataPackage = new BuildArmatureDataPackage();
			if(!fillBuildArmatureDataPackageArmatureInfo(fromArmatreName, fromDragonBonesDataName, buildArmatureDataPackage))
			{
				return false;
			}
			
			var fromArmatureData:ArmatureData = buildArmatureDataPackage.armatureData;
			toArmature.animation.animationDataList = fromArmatureData.animationDataList;
			
		//处理子骨架的复制
			var fromSkinData:SkinData = fromArmatureData.getSkinData("");
			var fromSlotData:SlotData;
			var fromDisplayData:DisplayData;
			
			var toSlotList:Vector.<Slot> = toArmature.getSlots(false); 
			var toSlot:Slot;
			var toSlotDisplayList:Array;
			var toSlotDisplayListLength:uint;
			var toDisplayObject:Object;
			var toChildArmature:Armature;
			
			for each(toSlot in toSlotList)
			{
				toSlotDisplayList = toSlot.displayList;
				toSlotDisplayListLength = toSlotDisplayList.length
				for(var i:int = 0; i < toSlotDisplayListLength; i++)
				{
					toDisplayObject = toSlotDisplayList[i];
					
					if(toDisplayObject is Armature)
					{
						toChildArmature = toDisplayObject as Armature;
						
						fromSlotData = fromSkinData.getSlotData(toSlot.name);
						fromDisplayData = fromSlotData.displayDataList[i];
						if(fromDisplayData.type == DisplayData.ARMATURE)
						{
							copyAnimationsToArmature(toChildArmature, fromDisplayData.name, buildArmatureDataPackage.dragonBonesDataName, ifRemoveOriginalAnimationList);
						}
					}
				}
			}
			
			return true;
		}
		
		private function fillBuildArmatureDataPackageArmatureInfo(armatureName:String, dragonBonesDataName:String, outputBuildArmatureDataPackage:BuildArmatureDataPackage):Boolean
		{
			if(dragonBonesDataName)
			{
				outputBuildArmatureDataPackage.dragonBonesDataName = dragonBonesDataName;
				outputBuildArmatureDataPackage.dragonBonesData = dragonBonesDataDic[dragonBonesDataName];
				outputBuildArmatureDataPackage.armatureData = outputBuildArmatureDataPackage.dragonBonesData.getArmatureDataByName(armatureName);
			}
			else
			{
				for(dragonBonesDataName in dragonBonesDataDic)
				{
					outputBuildArmatureDataPackage.dragonBonesData = dragonBonesDataDic[dragonBonesDataName];
					outputBuildArmatureDataPackage.armatureData = outputBuildArmatureDataPackage.dragonBonesData.getArmatureDataByName(armatureName);
					if(outputBuildArmatureDataPackage.armatureData)
					{
						outputBuildArmatureDataPackage.dragonBonesDataName = dragonBonesDataName;
						return true;
					}
				}
			}
			return false;
		}
		
		private function fillBuildArmatureDataPackageTextureInfo(fromTextureAtlasName:String, outputBuildArmatureDataPackage:BuildArmatureDataPackage):void
		{
			outputBuildArmatureDataPackage.textureAtlas = textureAtlasDic[fromTextureAtlasName ? fromTextureAtlasName : outputBuildArmatureDataPackage.dragonBonesDataName];
		}
		
		protected function findFirstDragonBonesData():DragonBonesData
		{
			for each(var outputDragonBonesData:DragonBonesData in dragonBonesDataDic)
			{
				if(outputDragonBonesData)
				{
					return outputDragonBonesData;
				}
			}
			return null;
		}
		
		protected function findFirstTextureAtlas():Object
		{
			for each(var outputTextureAtlas:Object in textureAtlasDic)
			{
				if(outputTextureAtlas)
				{
					return outputTextureAtlas;
				}
			}
			return null;
		}
		
		protected function buildBones(armature:Armature):void
		{
			//按照从属关系的顺序建立
			var boneDataList:Vector.<BoneData> = armature.armatureData.boneDataList;
			
			var boneData:BoneData;
			var bone:Bone;
			var parent:String;
			for(var i:int = 0;i < boneDataList.length;i ++)
			{
				boneData = boneDataList[i];
				bone = Bone.initWithBoneData(boneData);
				parent = boneData.parent;
				if(	parent && armature.armatureData.getBoneData(parent) == null)
				{
					parent = null;
				}
				armature.addBone(bone, parent, true);
			}
			armature.updateAnimationAfterBoneListChanged();
		}
		
		protected function buildFastBones(armature:FastArmature):void
		{
			//按照从属关系的顺序建立
			var boneDataList:Vector.<BoneData> = armature.armatureData.boneDataList;
			
			var boneData:BoneData;
			var bone:FastBone;
			for(var i:int = 0;i < boneDataList.length;i ++)
			{
				boneData = boneDataList[i];
				bone = FastBone.initWithBoneData(boneData);
				armature.addBone(bone, boneData.parent);
			}
		}
		
		protected function buildFastSlots(armature:FastArmature, skinName:String, textureAtlas:Object):void
		{
		//根据皮肤初始化SlotData的DisplayDataList
			var skinData:SkinData = armature.armatureData.getSkinData(skinName);
			if(!skinData)
			{
				return;
			}
			armature.armatureData.setSkinData(skinName);
			
			var displayList:Array = [];
			var slotDataList:Vector.<SlotData> = armature.armatureData.slotDataList;
			var slotData:SlotData;
			var slot:FastSlot;
			for(var i:int = 0; i < slotDataList.length; i++)
			{
				displayList.length = 0;
				slotData = slotDataList[i];
				slot = generateFastSlot();
				slot.initWithSlotData(slotData);
				
				var l:int = slotData.displayDataList.length;
				while(l--)
				{
					var displayData:DisplayData = slotData.displayDataList[l];
					
					switch(displayData.type)
					{
						case DisplayData.ARMATURE:
							var childArmature:FastArmature = buildFastArmatureUsingArmatureDataFromTextureAtlas(armature.__dragonBonesData, armature.__dragonBonesData.getArmatureDataByName(displayData.name), textureAtlas, skinName);
							displayList[l] = childArmature;
							slot.hasChildArmature = true;
							break;
						
						case DisplayData.IMAGE:
						default:
							displayList[l] = generateDisplay(textureAtlas, displayData.name, displayData.pivot.x, displayData.pivot.y);
							break;
						
					}
				}
				//==================================================
				//如果显示对象有name属性并且name属性可以设置的话，将name设置为与slot同名，dragonBones并不依赖这些属性，只是方便开发者
				for each(var displayObject:Object in displayList)
				{
					if(displayObject is FastArmature)
					{
						displayObject = (displayObject as FastArmature).display;
					}
					
					if(displayObject.hasOwnProperty("name"))
					{
						try
						{
							displayObject["name"] = slot.name;
						}
						catch(err:Error)
						{
						}
					}
				}
				//==================================================
				slot.initDisplayList(displayList.concat());
				armature.addSlot(slot, slotData.parent);
				slot.changeDisplayIndex(slotData.displayIndex);
			}
		}
		
		protected function buildSlots(armature:Armature, skinName:String, textureAtlas:Object):void
		{
			var skinData:SkinData = armature.armatureData.getSkinData(skinName);
			if(!skinData)
			{
				return;
			}
			armature.armatureData.setSkinData(skinName);
			var displayList:Array = [];
			var slotDataList:Vector.<SlotData> = armature.armatureData.slotDataList;
			var slotData:SlotData;
			var slot:Slot;
			var bone:Bone;
			var skinListObject:Object = { };
			for(var i:int = 0; i < slotDataList.length; i++)
			{
				displayList.length = 0;
				slotData = slotDataList[i];
				bone = armature.getBone(slotData.parent);
				if(!bone)
				{
					continue;
				}
				
				slot = generateSlot();
				slot.initWithSlotData(slotData);
				bone.addSlot(slot);
				
				var l:int = slotData.displayDataList.length;
				while(l--)
				{
					var displayData:DisplayData = slotData.displayDataList[l];
					
					switch(displayData.type)
					{
						case DisplayData.ARMATURE:
							var childArmature:Armature = buildArmatureUsingArmatureDataFromTextureAtlas(armature.__dragonBonesData, armature.__dragonBonesData.getArmatureDataByName(displayData.name), textureAtlas, skinName);
							displayList[l] = childArmature;
							break;
						
						case DisplayData.IMAGE:
						default:
							displayList[l] = generateDisplay(textureAtlas, displayData.name, displayData.pivot.x, displayData.pivot.y);
							break;
						
					}
				}
				//==================================================
				//如果显示对象有name属性并且name属性可以设置的话，将name设置为与slot同名，dragonBones并不依赖这些属性，只是方便开发者
				for each(var displayObject:Object in displayList)
				{
					if(displayObject is Armature)
					{
						displayObject = (displayObject as Armature).display;
					}
					
					if(displayObject.hasOwnProperty("name"))
					{
						try
						{
							displayObject["name"] = slot.name;
						}
						catch(err:Error)
						{
						}
					}
				}
				//==================================================
				skinListObject[slotData.name] = displayList.concat();
				slot.displayList = displayList;
				slot.changeDisplay(slotData.displayIndex);
			}
			armature.addSkinList(skinName, skinListObject);
		}
		
		
		public function addSkinToArmature(armature:Armature, skinName:String, textureAtlasName:String):void
		{
			var textureAtlas:Object = textureAtlasDic[textureAtlasName]
			var skinData:SkinData = armature.armatureData.getSkinData(skinName);
			if(!skinData || !textureAtlas)
			{
				return;
			}
			var displayList:Array = [];
			var slotDataList:Vector.<SlotData> = armature.armatureData.slotDataList;
			var slotData:SlotData;
			var slot:Slot;
			var bone:Bone;
			var skinListData:Object = { };
			var displayDataList:Vector.<DisplayData>
			
			for(var i:int = 0; i < slotDataList.length; i++)
			{
				displayList.length = 0;
				slotData = slotDataList[i];
				bone = armature.getBone(slotData.parent);
				if(!bone)
				{
					continue;
				}
				
				var l:int = 0;
				if (i >= skinData.slotDataList.length)
				{
					l = 0;
				}
				else
				{
					displayDataList = skinData.slotDataList[i].displayDataList;
					l = displayDataList.length;
				}
				while(l--)
				{
					var displayData:DisplayData = displayDataList[l];
					
					switch(displayData.type)
					{
						case DisplayData.ARMATURE:
							var childArmature:Armature = buildArmatureUsingArmatureDataFromTextureAtlas(armature.__dragonBonesData, armature.__dragonBonesData.getArmatureDataByName(displayData.name), textureAtlas, skinName);
							displayList[l] = childArmature;
							break;
						
						case DisplayData.IMAGE:
						default:
							displayList[l] = generateDisplay(textureAtlas, displayData.name, displayData.pivot.x, displayData.pivot.y);
							break;
						
					}
				}
				//==================================================
				//如果显示对象有name属性并且name属性可以设置的话，将name设置为与slot同名，dragonBones并不依赖这些属性，只是方便开发者
				for each(var displayObject:Object in displayList)
				{
					if(displayObject is Armature)
					{
						displayObject = (displayObject as Armature).display;
					}
					
					if(displayObject.hasOwnProperty("name"))
					{
						try
						{
							displayObject["name"] = slot.name;
						}
						catch(err:Error)
						{
						}
					}
				}
				//==================================================
				skinListData[slotData.name] = displayList.concat();
			}
			armature.addSkinList(skinName, skinListData);
		}
		
		/**
		 * Parses the raw data and returns a SkeletonData instance.	
		 * @example 
		 * <listing>
		 * import flash.events.Event; 
		 * import dragonBones.factorys.NativeFactory;
		 * 
		 * [Embed(source = "../assets/Dragon1.swf", mimeType = "application/octet-stream")]
		 *	private static const ResourcesData:Class;
		 * var factory:NativeFactory = new NativeFactory(); 
		 * factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
		 * factory.parseData(new ResourcesData());
		 * </listing>
		 * @param ByteArray. Represents the raw data for the whole DragonBones system.
		 * @param String. (optional) The SkeletonData instance name.
		 * @param Boolean. (optional) flag if delay animation data parsing. Delay animation data parsing can reduce the data paring time to improve loading performance.
		 * @param Dictionary. (optional) output parameter. If it is not null, and ifSkipAnimationData is true, it will be fulfilled animationData, so that developers can parse it later.
		 * @return A SkeletonData instance.
		 */
		public function parseData(bytes:ByteArray, dataName:String = null):void
		{
			if(!bytes)
			{
				throw new ArgumentError();
			}
			
			var decompressedData:DecompressedData = DataSerializer.decompressData(bytes);
			
			var dragonBonesData:DragonBonesData = DataParser.parseData(decompressedData.dragonBonesData);
			decompressedData.name = dataName || dragonBonesData.name;
			decompressedData.addEventListener(Event.COMPLETE, parseCompleteHandler);
			decompressedData.parseTextureAtlasBytes();
			
			addSkeletonData(dragonBonesData, dataName);
		}
		
		/** @private */
		protected function parseCompleteHandler(event:Event):void
		{
			var decompressedData:DecompressedData = event.target as DecompressedData;
			decompressedData.removeEventListener(Event.COMPLETE, parseCompleteHandler);
			
			var textureAtlas:Object = generateTextureAtlas(decompressedData.textureAtlas, decompressedData.textureAtlasData);
			addTextureAtlas(textureAtlas, decompressedData.name);
			
			decompressedData.dispose();
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		/** @private */
		protected function generateTextureAtlas(content:Object, textureAtlasRawData:Object):ITextureAtlas
		{
			return null;
		}
		
		/**
		 * @private
		 * Generates an Armature instance.
		 * @return Armature An Armature instance.
		 */
		protected function generateArmature():Armature
		{
			return null;
		}
		
		/**
		 * @private
		 * Generates an Armature instance.
		 * @return Armature An Armature instance.
		 */
		protected function generateFastArmature():FastArmature
		{
			return null;
		}
		
		/**
		 * @private
		 * Generates an Slot instance.
		 * @return Slot An Slot instance.
		 */
		protected function generateSlot():Slot
		{
			return null;
		}
		
		/**
		 * @private
		 * Generates an Slot instance.
		 * @return Slot An Slot instance.
		 */
		protected function generateFastSlot():FastSlot
		{
			return null;
		}
		
		/**
		 * @private
		 * Generates a DisplayObject
		 * @param textureAtlas The TextureAtlas.
		 * @param fullName A qualified name.
		 * @param pivotX A pivot x based value.
		 * @param pivotY A pivot y based value.
		 * @return
		 */
		protected function generateDisplay(textureAtlas:Object, fullName:String, pivotX:Number, pivotY:Number):Object
		{
			return null;
		}
		
	}
}
import dragonBones.objects.ArmatureData;
import dragonBones.objects.DragonBonesData;

class BuildArmatureDataPackage
{
	public var dragonBonesDataName:String;
	public var dragonBonesData:DragonBonesData;
	public var armatureData:ArmatureData;
	public var textureAtlas:Object;
}