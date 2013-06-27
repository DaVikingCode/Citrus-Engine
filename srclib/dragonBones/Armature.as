package dragonBones
{
	
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	
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
	 * Dispatched when the playback of a animation stops.
	 */
	[Event(name="complete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the playback of a animation completes a loop.
	 */
	[Event(name="loopComplete", type="dragonBones.events.AnimationEvent")]
	
	/**
	 * Dispatched when the animation of the armature enter a frame.
	 */
	[Event(name="movementFrameEvent", type="dragonBones.events.FrameEvent")]
	
	/**
	 * Dispatched when a bone of the armature enters a frame.
	 */
	[Event(name="boneFrameEvent", type="dragonBones.events.FrameEvent")]
	
	/**
	 * A Armature instance is the core of the skeleton animation system. It contains the object to display, all sub-bones and the object animation(s).
	 * @example
	 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
	 * <p>This example builds an Armature instance called "dragon" and stores it into the member varaible called 'armature'.</p>
	 * <listing>	
	 *	package  
	 *	{
	 *		import dragonBones.Armature;
	 *		import dragonBones.factorys.BaseFactory;
	 *  	import flash.display.Sprite;
	 *		import flash.events.Event;	
     *
	 *		public class DragonAnimation extends Sprite 
	 *		{		
	 *			[Embed(source = "Dragon1.swf", mimeType = "application/octet-stream")]  
	 *			private static const ResourcesData:Class;
	 *			
	 *			private var factory:BaseFactory;
	 *			private var armature:Armature;		
	 *			
	 *			public function DragonAnimation() 
	 *			{				
	 *				factory = new BaseFactory();
	 *				factory.addEventListener(Event.COMPLETE, handleParseData);
	 *				factory.parseData(new ResourcesData(), 'Dragon');
	 *			}
	 *			
	 *			private function handleParseData(e:Event):void 
	 *			{			
	 *				armature = factory.buildArmature('Dragon');
	 *				addChild(armature.display as Sprite); 			
	 *				armature.animation.play();
	 *				addEventListener(Event.ENTER_FRAME, updateAnimation);			
	 *			}
	 *			
	 *			private function updateAnimation(e:Event):void 
	 *			{
	 *				armature.advanceTime(1 / stage.frameRate);
	 *			}		
	 *		}
	 *	}
	 * </listing>
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
		 * An object containing user data.
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

		
		/** @private */
		public function set colorTransform(value:ColorTransform):void
		{
			_colorTransform = value;
			_colorTransformChange = true;
		}
		/**
		 * The ColorTransform instance assiociated with this instance.
		 * @param	The ColorTransform instance assiociated with this Armature instance.
		 */
		public function get colorTransform():ColorTransform
		{
			return _colorTransform;
		}
		
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
			super();
			_display = display;
			
			_boneDepthList = new Vector.<Bone>;
			_rootBoneList = new Vector.<Bone>;
			
			_animation = new Animation(this);
			_bonesIndexChanged = false;
		}
		
		/**
		 * Cleans up resources used by this Armature instance.
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
			
			userData = null;
			
			if(_colorTransform)
			{
				_colorTransform = null;
			}
		}
		

		/**
		 * Retreives a Bone by name
		 * @param	The name of the Bone to retreive.
		 * @return A Bone instance or null if no Bone with that name exist.
		 * @see dragonBones.Bone
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
		 * Gets the Bone assiociated with this DisplayObject.
		 * @param	Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 * @return A bone instance.
		 * @see dragonBones.Bone
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
		 * Get all Bone instance assiociated with this armature.
		 * @return A Vector.&lt;Bone&gt; instance.
		 * @see dragonBones.Bone
		 */
		public function getBones():Vector.<Bone>
		{
			return _boneDepthList.concat();
		}
		/**
		 * Add a Bone instance to this Armature instance.
		 * @param	A Bone instance
		 * @param	(optional) The parent's name of this Bone instance.
		 * @see dragonBones.Bone
		 */
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
		/**
		 * Remove a Bone instance from this Armature instance.
		 * @param	A Bone instance
		 * @see dragonBones.Bone
		 */
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
		/**
		 * Remove a Bone instance from this Armature instance.
		 * @param	The name of the Bone instance to remove.
		 * @see dragonBones.Bone
		 */
		public function removeBoneByName(boneName:String):void
		{
			var bone:Bone = getBone(boneName);
			removeBone(bone);
		}
		/**
		 * Update the animation using this method typically in an ENTERFRAME Event or with a Timer.
		 * @param	The amount of second to move the playhead ahead.
		 */
		public function advanceTime(passedTime:Number):void
		{
			var i:int = _boneDepthList.length;
			while(i --)
			{
				var bone:Bone = _boneDepthList[i];
				if(bone._isOnStage)
				{
					var childArmature:Armature = bone.childArmature;
					if(childArmature)
					{
						childArmature.advanceTime(passedTime);
					}
				}
			}
			animation.advanceTime(passedTime);
			update();
		}
		
		/**
		 * Update the z-order of the display. 
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
			var i:int = _rootBoneList.length;
			while(i --)
			{
				_rootBoneList[i].update();
			}
			
			_colorTransformChange = false;
			
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