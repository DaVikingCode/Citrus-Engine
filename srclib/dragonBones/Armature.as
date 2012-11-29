package dragonBones
{
	import dragonBones.animation.Animation;
	import dragonBones.utils.dragonBones_internal;
	import flash.events.EventDispatcher;
	
	use namespace dragonBones_internal;
	/**
	 * Dispatched when the movement of animation is changed.
	 */
	[Event(name="movementChange", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the playback of a animation starts.
	 */
	[Event(name="animationStart", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the playback of a movement stops.
	 */
	[Event(name="movementComplete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the playback of a movement completes a loop.
	 */
	[Event(name="movementLoopComplete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the animation of the armatrue enter a frame.
	 */
	[Event(name="movementFrameEvent", type="dragonBones.events.FrameEvent")]
	
	/**
	 * Dispatched when a bone of the armatrue enter a frame.
	 */
	[Event(name="boneFrameEvent", type="dragonBones.events.FrameEvent")]
	
	/**
	 * The core object of a skeleton animation system. It contains the root display object, the animation which can the change playback state and all sub-bones.
	 *
	 * @see dragonBones.Bone
	 * @see dragonBones.animation.Animation
	 */
	public class Armature extends EventDispatcher
	{
		/**
		 * The name of the Armature.
		 */
		public var name:String;
		/**
		 * An object that can contain any extra data.
		 */
		public var userData:Object;
		/**
		 * An object can change the playback state of the armature.
		 */
		public var animation:Animation;
		
		dragonBones_internal var _bonesIndexChanged:Boolean;
		dragonBones_internal var _boneDepthList:Vector.<Bone>;
		
		private var _rootBoneList:Vector.<Bone>;
		
		/** @private */
		protected var _display:Object;
		
		/**
		 * An display object which is dependent on specific display engine.
		 */
		public function get display():Object{
			return _display;
		}
		
		/**
		 * Creates a new <code>Armature</code>
		 *
		 * @param	display	Represents the root display object for all sub-bones.
		 */
		public function Armature(display:Object)
		{
			super();
			_display = display;
			
			_boneDepthList = new Vector.<Bone>;
			_rootBoneList = new Vector.<Bone>;
			
			animation = new Animation(this);
			_bonesIndexChanged = false;
		}
		
		/**
		 * Cleans up any resources used by the current object.
		 */
		public function dispose():void
		{
			for each(var bone:Bone in _rootBoneList)
			{
				bone.dispose();
			}
			
			animation.dispose();
			animation = null;
			//_display = null;
			
			_boneDepthList = null;
			_rootBoneList = null;
		}
		
		/**
		 * Updates the state of the armature. Should be called every frame manually.
		 */
		public function update():void
		{
			for each(var bone:Bone in _rootBoneList)
			{
				bone.update();
			}
			animation.update();
			
			if(_bonesIndexChanged)
			{
				updateBonesZ();
			}
		}
		
		/**
		 * Gets a bone by name.
		 * @param	name
		 * @return
		 */
		public function getBone(name:String):Bone
		{
			if(name)
			{
				for each(var bone:Bone in _boneDepthList)
				{
					if(bone.name == name)
					{
						return bone;
					}
				}
			}
			return null;
		}
		
		/**
		 * Gets a bone by display.
		 * @param	display
		 * @return
		 */
		public function getBoneByDisplay(display:Object):Bone
		{
			for each(var eachBone:Bone in _boneDepthList)
			{
				if(eachBone.display == display)
				{
					return eachBone;
				}
			}
			return null;
		}
		
		/** @private */
		public function addBone(bone:Bone, parentName:String = null):void
		{
			var boneParent:Bone = getBone(parentName);
			if (boneParent)
			{
				boneParent.addChild(bone);
			}
			else
			{
				bone.removeFromParent();
				addToBones(bone, true);
			}
		}
		
		/** @private */
		public function removeBone(boneName:String):void
		{
			var bone:Bone = getBone(boneName);
			if (bone)
			{
				if(bone.parent)
				{
					bone.removeFromParent();
				}
				else
				{
					removeFromBones(bone);
				}
			}
		}
		/** @private */
		dragonBones_internal function addToBones(bone:Bone, _root:Boolean = false):void
		{
			var boneIndex:int = _boneDepthList.indexOf(bone);
			if(boneIndex < 0)
			{
				_boneDepthList.push(bone);
			}
			
			boneIndex = _rootBoneList.indexOf(bone);
			if(_root)
			{
				if(boneIndex < 0)
				{
					_rootBoneList.push(bone);
				}
			}else if(boneIndex >= 0)
			{
				_rootBoneList.splice(boneIndex, 1);
			}
			
			bone._armature = this;
			bone._displayBridge.addDisplay(_display, bone.global.z);
			for each(var child:Bone in bone._children)
			{
				addToBones(child);
			}
		}
		
		/** @private */
		dragonBones_internal function removeFromBones(bone:Bone):void
		{
			var boneIndex:int = _boneDepthList.indexOf(bone);
			if(boneIndex >= 0)
			{
				_boneDepthList.splice(boneIndex, 1);
			}
			
			boneIndex = _rootBoneList.indexOf(bone);
			if(boneIndex >= 0)
			{
				_rootBoneList.splice(boneIndex, 1);
			}
			
			bone._armature = null;
			bone._displayBridge.removeDisplay();
			for each(var child:Bone in bone._children)
			{
				removeFromBones(child);
			}
		}
		
		/**
		 * Sorts the display objects by z value.
		 */
		public function updateBonesZ():void
		{
			_boneDepthList.sort(sortBoneZIndex);
			for each(var bone:Bone in _boneDepthList)
			{
				if(bone._displayVisible)
				{
					bone._displayBridge.addDisplay(_display);
				}
			}
			_bonesIndexChanged = false;
		}
		
		private function sortBoneZIndex(bone1:Bone, bone2:Bone):int
		{
			return bone1.global.z >= bone2.global.z?1: -1;
		}
	}
}