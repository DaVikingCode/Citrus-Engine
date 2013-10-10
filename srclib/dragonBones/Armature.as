package dragonBones
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	
	import dragonBones.animation.Animation;
	import dragonBones.animation.AnimationState;
	import dragonBones.animation.IAnimatable;
	import dragonBones.animation.TimelineState;
	import dragonBones.core.DBObject;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.events.ArmatureEvent;
	import dragonBones.events.FrameEvent;
	import dragonBones.events.SoundEvent;
	import dragonBones.events.SoundEventManager;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.Frame;
	
	use namespace dragonBones_internal;
	
	/**
	 * Dispatched when a bone of the armature enters a frame.
	 */
	[Event(name="zOrderUpdated", type="dragonBones.events.ArmatureEvent")]
	/**
	 * Dispatched when an animation state of the animation begins fade in.
	 */
	[Event(name="fadeIn", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when an animation state of the animation begins fade out.
	 */
	[Event(name="fadeOut", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when an animation state of the animation starts.
	 */
	[Event(name="start", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when an animation state of the animation completes.
	 */
	[Event(name="complete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when an animation state of the animation completes a loop.
	 */
	[Event(name="loopComplete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when an animation state of the animation completes fade in.
	 */
	[Event(name="fadeInComplete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when an animation state of the animation completes fade out.
	 */
	[Event(name="fadeOutComplete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when an animation state of the animation enters a frame.
	 */
	[Event(name="animationFrameEvent", type="dragonBones.events.FrameEvent")]
	
	/**
	 * Dispatched when a bone of the armature enters a frame.
	 */
	[Event(name="boneFrameEvent", type="dragonBones.events.FrameEvent")]

	public class Armature extends EventDispatcher implements IAnimatable
	{
		private static const _soundManager:SoundEventManager = SoundEventManager.getInstance();
		
		private const _helpArray:Array = [];
		
		/**
		 * The name of this DBObject instance's Armature instance.
		 */
		public var name:String;
		
		/**
		 * An object that can contain any user extra data.
		 */
		public var userData:Object;
		
		/** @private */
		dragonBones_internal var _slotsZOrderChanged:Boolean;
		/** @private */
		dragonBones_internal var _slotList:Vector.<Slot>;
		/** @private */
		dragonBones_internal var _boneList:Vector.<Bone>;
		/** @private */
		dragonBones_internal var _eventList:Vector.<Event>;
		
		/** @private */
		protected var _needUpdate:Boolean;
		
		/** @private */
		protected var _display:Object;
		/**
		 * Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 */
		public function get display():Object
		{
			return _display;
		}
		
		/** @private */
		protected var _animation:Animation;
		/**
		 * An Animation instance
		 * @see dragonBones.animation.Animation
		 */
		public function get animation():Animation
		{
			return _animation;
		}

		/**
		 * Creates a Armature blank instance.
		 * @param	Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 */
		public function Armature(display:Object)
		{
			super(this);
			_display = display;
			
			_animation = new Animation(this);
			_slotsZOrderChanged = false;
			
			_slotList = new Vector.<Slot>;
			_slotList.fixed = true;
			_boneList = new Vector.<Bone>;
			_boneList.fixed = true;
			_eventList = new Vector.<Event>;
			
			_needUpdate = false;
		}
		
		/**
		 * Cleans up any resources used by this DBObject instance.
		 */
		public function dispose():void
		{
			if(!_animation)
			{
				return;
			}
			
			userData = null;
			
			_animation.dispose();
			
			for each(var slot:Slot in _slotList)
			{
				slot.dispose();
			}
			
			for each(var bone:Bone in _boneList)
			{
				bone.dispose();
			}
			
			_slotList.fixed = false;
			_slotList.length = 0;
			_boneList.fixed = false;
			_boneList.length = 0;
			_eventList.length = 0;
			
			_animation = null;
			_slotList = null;
			_boneList = null;
			_eventList = null;
			
			//_display = null;
		}
		
		public function invalidUpdate():void
		{
			_needUpdate = true;
		}
		
		/**
		 * Update the animation using this method typically in an ENTERFRAME Event or with a Timer.
		 * @param	The amount of second to move the playhead ahead.
		 */
		public function advanceTime(passedTime:Number):void
		{
			var i:int;
			var slot:Slot;
			var childArmature:Armature;
			if(_animation.isPlaying || _needUpdate)
			{	
				_needUpdate = false;
				_animation.advanceTime(passedTime)
				passedTime *= _animation.timeScale;
				
				i = _boneList.length;
				while(i --)
				{
					_boneList[i].update();
				}
				
				i = _slotList.length;
				while(i --)
				{
					slot = _slotList[i];
					slot.update();
					if(slot._isDisplayOnStage)
					{
						childArmature = slot.childArmature;
						if(childArmature)
						{
							childArmature.advanceTime(passedTime);
						}
					}
				}
				
				if(_slotsZOrderChanged)
				{
					updateSlotsZOrder();
					
					if(this.hasEventListener(ArmatureEvent.Z_ORDER_UPDATED))
					{
						this.dispatchEvent(new ArmatureEvent(ArmatureEvent.Z_ORDER_UPDATED));
					}
				}
				
				if(_eventList.length)
				{
					for each(var event:Event in _eventList)
					{
						this.dispatchEvent(event);
					}
					_eventList.length = 0;
				}
			}
			else
			{
				passedTime *= _animation.timeScale;
				i = _slotList.length;
				while(i --)
				{
					slot = _slotList[i];
					if(slot._isDisplayOnStage)
					{
						childArmature = slot.childArmature;
						if(childArmature)
						{
							childArmature.advanceTime(passedTime);
						}
					}
				}
			}
		}
		
		
		/**
		 * Get all Slot instance associated with this armature.
		 * @return A Vector.&lt;Slot&gt; instance.
		 * @see dragonBones.Slot
		 */
		public function getSlots(returnCopy:Boolean = true):Vector.<Slot>
		{
			return returnCopy?_slotList.concat():_slotList;
		}
		
		/**
		 * Get all Bone instance associated with this armature.
		 * @return A Vector.&lt;Bone&gt; instance.
		 * @see dragonBones.Bone
		 */
		public function getBones(returnCopy:Boolean = true):Vector.<Bone>
		{
			return returnCopy?_boneList.concat():_boneList;
		}
		
		/**
		 * Retrieves a Slot by name
		 * @param	The name of the Bone to retrieve.
		 * @return A Slot instance or null if no Slot with that name exist.
		 * @see dragonBones.Slot
		 */
		public function getSlot(slotName:String):Slot
		{
			var i:int = _slotList.length;
			while(i --)
			{
				if(_slotList[i].name == slotName)
				{
					return _slotList[i];
				}
			}
			return null;
		}
		
		/**
		 * Gets the Slot associated with this DisplayObject.
		 * @param	Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 * @return A Slot instance.
		 * @see dragonBones.Slot
		 */
		public function getSlotByDisplay(display:Object):Slot
		{
			if(display)
			{
				var i:int = _slotList.length;
				while(i --)
				{
					if(_slotList[i].display == display)
					{
						return _slotList[i];
					}
				}
			}
			return null;
		}
		
		/**
		 * Remove a Slot instance from this Armature instance.
		 * @param	The Slot instance to remove.
		 * @see dragonBones.Slot
		 */
		public function removeSlot(slot:Slot):void
		{
			if(!slot)
			{
				throw new ArgumentError();
			}
			
			if(_slotList.indexOf(slot) >= 0)
			{
				slot.parent.removeChild(slot);
			}
			else
			{
				throw new ArgumentError();
			}
		}
		
		/**
		 * Remove a Slot instance from this Armature instance.
		 * @param	The name of the Slot instance to remove.
		 * @see dragonBones.Slot
		 */
		public function removeSlotByName(slotName:String):void
		{
			if(!slotName)
			{
				return;
			}
			
			var slot:Slot = getSlot(slotName);
			if(slot)
			{
				removeSlot(slot);
			}
		}
		
		/**
		 * Retrieves a Bone by name
		 * @param	The name of the Bone to retrieve.
		 * @return A Bone instance or null if no Bone with that name exist.
		 * @see dragonBones.Bone
		 */
		public function getBone(boneName:String):Bone
		{
			var i:int = _boneList.length;
			while(i --)
			{
				if(_boneList[i].name == boneName)
				{
					return _boneList[i];
				}
			}
			return null;
		}
		
		/**
		 * Gets the Bone associated with this DisplayObject.
		 * @param	Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 * @return A Bone instance.
		 * @see dragonBones.Bone
		 */
		public function getBoneByDisplay(display:Object):Bone
		{
			var slot:Slot = getSlotByDisplay(display);
			return slot?slot.parent:null;
		}
		
		/**
		 * Remove a Bone instance from this Armature instance.
		 * @param	The Bone instance to remove.
		 * @see	dragonBones.Bone
		 */
		public function removeBone(bone:Bone):void
		{
			if(!bone)
			{
				throw new ArgumentError();
			}
			
			if(_boneList.indexOf(bone) >= 0)
			{
				if(bone.parent)
				{
					bone.parent.removeChild(bone);
				}
				else
				{
					bone.setArmature(null);
				}
			}
			else
			{
				throw new ArgumentError();
			}
		}
		
		/**
		 * Remove a Bone instance from this Armature instance.
		 * @param	The name of the Bone instance to remove.
		 * @see dragonBones.Bone
		 */
		public function removeBoneByName(boneName:String):void
		{
			if(!boneName)
			{
				return;
			}
			
			var bone:Bone = getBone(boneName);
			if(bone)
			{
				removeBone(bone);
			}
		}
		
		
		/**
		 * Add a DBObject instance to this Armature instance.
		 * @param	A DBObject instance
		 * @param	(optional) The parent's name of this DBObject instance.
		 * @see dragonBones.core.DBObject
		 */
		public function addChild(object:DBObject, parentName:String = null):void
		{
			if(!object)
			{
				throw new ArgumentError();
			}
			
			if(parentName)
			{
				var boneParent:Bone = getBone(parentName);
				if (boneParent)
				{
					boneParent.addChild(object);
				}
				else
				{
					throw new ArgumentError();
				}
			}
			else
			{
				if(object.parent)
				{
					object.parent.removeChild(object);
				}
				object.setArmature(this);
			}
		}
		
		/**
		 * Add a Bone instance to this Armature instance.
		 * @param	A Bone instance
		 * @param	(optional) The parent's name of this Bone instance.
		 * @see dragonBones.Bone
		 */
		public function addBone(bone:Bone, parentName:String = null):void
		{
			addChild(bone, parentName);
		}
		
		/**
		 * Update the z-order of the display. 
		 */
		public function updateSlotsZOrder():void
		{
			_slotList.fixed = false;
			_slotList.sort(sortSlot);
			_slotList.fixed = true;
			var i:int = _slotList.length;
			var slot:Slot;
			while(i --)
			{
				slot = _slotList[i];
				if(slot._isDisplayOnStage)
				{
					slot._displayBridge.addDisplay(display);
				}
			}
			
			_slotsZOrderChanged = false;
		}
		
		/** @private */
		dragonBones_internal function addDBObject(object:DBObject):void
		{
			if(object is Slot)
			{
				var slot:Slot = object as Slot;
				if(_slotList.indexOf(slot) < 0)
				{
					_slotList.fixed = false;
					_slotList[_slotList.length] = slot;
					_slotList.fixed = true;
				}
			}
			else if(object is Bone)
			{
				var bone:Bone = object as Bone;
				if(_boneList.indexOf(bone) < 0)
				{
					_boneList.fixed = false;
					_boneList[_boneList.length] = bone;
					sortBoneList();
					_boneList.fixed = true;
				}
			}
		}
		
		/** @private */
		dragonBones_internal function removeDBObject(object:DBObject):void
		{
			if(object is Slot)
			{
				var slot:Slot = object as Slot;
				var index:int = _slotList.indexOf(slot);
				if(index >= 0)
				{
					_slotList.fixed = false;
					_slotList.splice(index, 1);
					_slotList.fixed = true;
				}
			}
			else if(object is Bone)
			{
				var bone:Bone = object as Bone;
				index = _boneList.indexOf(bone);
				if(index >= 0)
				{
					_boneList.fixed = false;
					_boneList.splice(index, 1);
					_boneList.fixed = true;
				}
			}
		}
		
		/** @private */
		dragonBones_internal function sortBoneList():void
		{
			var i:int = _boneList.length;
			if(i == 0)
			{
				return;
			}
			_helpArray.length = 0;
			var level:int;
			var bone:Bone;
			var boneParent:Bone;
			while(i --)
			{
				level = 0;
				bone = _boneList[i];
				boneParent = bone;
				while(boneParent)
				{
					level ++;
					boneParent = boneParent.parent;
				}
				_helpArray[i] = {level:level, bone:bone};
			}
			
			_helpArray.sortOn("level", Array.NUMERIC|Array.DESCENDING);
			
			i = _helpArray.length;
			while(i --)
			{
				_boneList[i] = _helpArray[i].bone;
			}
			_helpArray.length = 0;
		}
		
		/** @private */
		dragonBones_internal function arriveAtFrame(frame:Frame, timelineState:TimelineState, animationState:AnimationState, isCross:Boolean):void
		{
			if(frame.event && this.hasEventListener(FrameEvent.ANIMATION_FRAME_EVENT))
			{
				var frameEvent:FrameEvent = new FrameEvent(FrameEvent.ANIMATION_FRAME_EVENT);
				frameEvent.animationState = animationState;
				frameEvent.frameLabel = frame.event;
				_eventList.push(frameEvent);
			}
			
			if(frame.sound && _soundManager.hasEventListener(SoundEvent.SOUND))
			{
				var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
				soundEvent.armature = this;
				soundEvent.animationState = animationState;
				soundEvent.sound = frame.sound;
				_soundManager.dispatchEvent(soundEvent);
			}
			
			if(frame.action)
			{
				if(animationState.isPlaying)
				{
					animation.gotoAndPlay(frame.action);
				}
			}
		}
		
		private function sortSlot(slot1:Slot, slot2:Slot):int
		{
			return slot1.zOrder < slot2.zOrder?1: -1;
		}
		
	}
}