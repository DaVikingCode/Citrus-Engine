package dragonBones.factorys
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.display.NativeDisplayBridge;
	import dragonBones.display.PivotBitmap;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.DisplayData;
	import dragonBones.objects.FrameData;
	import dragonBones.objects.Node;
	import dragonBones.objects.SkeletonAndTextureAtlasData;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.SubTextureData;
	import dragonBones.objects.TextureAtlasData;
	import dragonBones.objects.XMLDataParser;
	import dragonBones.utils.ConstValues;
	import dragonBones.utils.dragonBones_internal;
	import flash.events.EventDispatcher;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	use namespace dragonBones_internal;
	
	/** Dispatched when the textureData init completed. */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * A object managing the set of armature resources for the tranditional DisplayList. It parses the raw data, stores the armature resources and creates armature instrances.
	 * @see dragonBones.Armature
	 */
	public class BaseFactory extends EventDispatcher
	{
		/** @private */
		public static function getTextureDisplay(textureAtlasData:TextureAtlasData, fullName:String):Object
		{
			var clip:MovieClip = textureAtlasData.clip;
			if (clip)
			{
				clip.gotoAndStop(clip.totalFrames);
				clip.gotoAndStop(fullName);
				if (clip.numChildren > 0)
				{
					try
					{
						var displaySWF:Object = clip.getChildAt(0);
						displaySWF.x = 0;
						displaySWF.y = 0;
						return displaySWF;
					}
					catch(e:Error)
					{
						trace("can not get the clip, please make sure the version of the resource compatible with app version！");
					}
				}
			}
			else if(textureAtlasData.bitmap)
			{
				var subTextureData:SubTextureData = textureAtlasData.getSubTextureData(fullName);
				if (subTextureData)
				{
					var displayBitmap:PivotBitmap = new PivotBitmap(textureAtlasData.bitmap.bitmapData);
					displayBitmap.smoothing = true;
					displayBitmap.scrollRect = subTextureData;
					displayBitmap.pivotX = subTextureData.pivotX;
					displayBitmap.pivotY = subTextureData.pivotY;
					return displayBitmap;
				}
			}
			return null;
		}
		
		protected var _skeletonData:SkeletonData;
		
		/**
		 * A set of armature datas and animation datas
		 */
		public function get skeletonData():SkeletonData
		{
			return _skeletonData;
		}
		public function set skeletonData(value:SkeletonData):void
		{
			_skeletonData = value;
		}
		
		protected var _textureAtlasData:TextureAtlasData;
		
		/**
		 * A set of texture datas
		 */
		public function get textureAtlasData():TextureAtlasData
		{
			return _textureAtlasData;
		}
		public function set textureAtlasData(value:TextureAtlasData):void
		{
			if(_textureAtlasData)
			{
				_textureAtlasData.removeEventListener(Event.COMPLETE, textureCompleteHandler);
			}
			_textureAtlasData = value;
			if(_textureAtlasData)
			{
				_textureAtlasData.addEventListener(Event.COMPLETE, textureCompleteHandler);
			}
		}
		
		/**
		 * Creates a new <code>BaseFactory</code>
		 *
		 */
		public function BaseFactory()
		{
			super();
		}
		
		/**
		 * Pareses the raw data.
		 * @param	bytes Represents the raw data for the whole skeleton system.
		 */
		public function parseData(bytes:ByteArray):void
		{
			var sat:SkeletonAndTextureAtlasData = XMLDataParser.parseXMLData(bytes);
			skeletonData = sat.skeletonData;
			textureAtlasData = sat.textureAtlasData;
			sat.dispose();
		}
		
		/**
		 * Cleans up any resources used by the current object.
		 */
		public function dispose():void
		{
			skeletonData = null;
			textureAtlasData = null;
		}
		
		/**
		 * Builds a new armature by name
		 * @param	armatureName
		 * @return
		 */
		public function buildArmature(armatureName:String):Armature
		{
			var armatureData:ArmatureData = skeletonData.getArmatureData(armatureName);
			if(!armatureData)
			{
				return null;
			}
			var animationData:AnimationData = skeletonData.getAnimationData(armatureName);
			var armature:Armature = generateArmature();
			armature.name = armatureName;
			if (armature)
			{
				armature.animation.setData(animationData);
				var boneList:Array = armatureData.boneList;
				for each(var boneName:String in boneList)
				{
					var boneData:BoneData = armatureData.getBoneData(boneName);
					var bone:Bone = buildBone(boneData);
					if(bone)
					{
						armature.addBone(bone, boneData.parent);
					}
				}
			}
			armature.update();
			return armature;
		}
		
		protected function generateArmature():Armature
		{
			var display:Sprite = new Sprite();
			var armature:Armature = new Armature(display);
			return armature;
		}
		
		protected function buildBone(boneData:BoneData):Bone
		{
			var bone:Bone = generateBone();
			bone.origin.copy(boneData);
			bone.name = boneData.name;
			
			var length:uint = boneData.displayLength;
			var displayData:DisplayData;
			for(var i:int = length - 1;i >=0;i --)
			{
				displayData = boneData.getDisplayDataAt(i);
				bone.changeDisplay(i);
				if (displayData.isArmature)
				{
					var childArmature:Armature = buildArmature(displayData.name);
					childArmature.animation.play();
					bone.display = childArmature;
				}
				else
				{
					bone.display = getBoneTextureDisplay(displayData.name);
				}
			}
			return bone;
		}
		
		protected function getBoneTextureDisplay(textureName:String):Object
		{
			return getTextureDisplay(_textureAtlasData, textureName);
		}
		
		protected function generateBone():Bone
		{
			var bone:Bone = new Bone(new NativeDisplayBridge());
			return bone;
		}
		
		private function textureCompleteHandler(e:Event):void
		{
			dispatchEvent(e);
		}
	}
}