package dragonBones
{
	import dragonBones.animation.Animation;
	import dragonBones.animation.IAnimatable;
	import dragonBones.events.ArmatureEvent;
	import dragonBones.utils.dragonBones_internal;
	
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	
	use namespace dragonBones_internal;
	/**
	 * Dispatched when the movement of animation is changed.
	 */
	[Event(name="movementChange", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the playback of a animation starts.
	 */
	[Event(name="start", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the playback of a movement stops.
	 */
	[Event(name="complete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the playback of a movement completes a loop.
	 */
	[Event(name="loopComplete", type="dragonBones.events.AnimationEvent")]
	
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
	public class Armature extends EventDispatcher implements IAnimatable
	{
		/**
		 * The name of the Armature.
		 */
		public var name:String;
		
		/**
		 * An object that can contain any extra data.
		 */
		public var userData:Object;
		
		/** @private */
		dragonBones_internal var _bonesIndexChanged:Boolean;
		
		/** @private */
		dragonBones_internal var _boneDepthList:Vector.<Bone>;
		/** @private */
		protected var _rootBoneList:Vector.<Bone>;
		
		
		/** @private */
		dragonBones_internal var _colorTransformChange:Boolean;
		/** @private */
		protected var _colorTransform:ColorTransform;
		
		public function get colorTransform():ColorTransform
		{
			return _colorTransform;
		}
		public function set colorTransfrom(value:ColorTransform):void
		{
			_colorTransform = value;
			_colorTransformChange = true;
		}
		
		/** @private */
		protected var _display:Object;
		/**
		 * An display object which is dependent on specific display engine.
		 */
		public function get display():Object
		{
			return _display;
		}
		
		/** @private */
		protected var _animation:Animation;
		/**
		 * An object can change the playback state of the armature.
		 */
		public function get animation():Animation
		{
			return _animation;
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
			
			_animation = new Animation(this);
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
			
			_boneDepthList.length = 0;
			_rootBoneList.length = 0;
			
			_animation.dispose();
			_animation = null;
			
			//_display = null;
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
			if(display)
			{
				for each(var bone:Bone in _boneDepthList)
				{
					if(bone.display == display)
					{
						return bone;
					}
				}
			}
			return null;
		}
		
		/**
		 * Gets bones.
		 * @return
		 */
		public function getBones():Vector.<Bone>
		{
			return _boneDepthList.concat();
		}
		
		public function addBone(bone:Bone, parentName:String = null):void
		{
			if (bone)
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
		}
		
		public function removeBone(bone:Bone):void
		{
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
		
		public function removeBoneByName(boneName:String):void
		{
			var bone:Bone = getBone(boneName);
			removeBone(bone);
		}
		
		public function advanceTime(passedTime:Number):void
		{
			animation.advanceTime(passedTime);
			update();
		}
		
		/**
		 * Sorts the display objects by z value.
		 */
		public function updateBonesZ():void
		{
			_boneDepthList.sort(sortBoneZIndex);
			for each(var bone:Bone in _boneDepthList)
			{
				if(bone._isOnStage)
				{
					bone._displayBridge.addDisplay(_display);
				}
			}
			_bonesIndexChanged = false;
			
			if(hasEventListener(ArmatureEvent.Z_ORDER_UPDATED))
			{
				dispatchEvent(new ArmatureEvent(ArmatureEvent.Z_ORDER_UPDATED));
			}
		}
		
		/** @private */
		dragonBones_internal function update():void
		{
			for each(var bone:Bone in _rootBoneList)
			{
				bone.update();
			}
			
			if(_bonesIndexChanged)
			{
				updateBonesZ();
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
			}
			else if(boneIndex >= 0)
			{
				_rootBoneList.splice(boneIndex, 1);
			}
			
			bone._armature = this;
			bone._displayBridge.addDisplay(_display, bone.global.z);
			for each(var child:Bone in bone._children)
			{
				addToBones(child);
			}
			_bonesIndexChanged = true;
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
			_bonesIndexChanged = true;
		}
		
		private function sortBoneZIndex(bone1:Bone, bone2:Bone):int
		{
			return bone1.global.z >= bone2.global.z?1: -1;
		}
	}
}