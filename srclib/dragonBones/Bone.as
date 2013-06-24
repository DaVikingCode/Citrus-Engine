package dragonBones
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
	
	import dragonBones.animation.Tween;
	import dragonBones.display.IDisplayBridge;
	import dragonBones.objects.BoneTransform;
	import dragonBones.utils.dragonBones_internal;
	
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	use namespace dragonBones_internal;

	/**
	 * A Bone instance represents a single joint in an Armature instance. An Armature instance can be made up of many Bone instances.
	 * @example
	 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
	 * <p>This example retrieves the Bone instance assiociated with the character's head and apply to its Display property an 0.5 alpha.</p>
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
	 * 				var bone:Bone = armature.getBone("head");
	 * 				bone.display.alpha = 0.5;//make the DisplayObject belonging to this bone semi transparent.
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
	public class Bone extends EventDispatcher
	{
		/**
		 * The name of this Bone instance's Armature instance.
		 */
		public var name:String;
		/**
		 * An object that can contain any user extra data.
		 */
		public var userData:Object;
		/**
		 * This Bone instance global Node instance.
		 * @see dragonBones.objects.Node
		 */
		public var global:BoneTransform;
		/**
		 * This Bone instance origin Node Instance.
		 * @see dragonBones.objects.Node
		 */
		public var origin:BoneTransform;
		/**
		 * This Bone instance Node Instance.
		 * @see dragonBones.objects.Node
		 */
		public var node:BoneTransform;
		
		/** @private */
		dragonBones_internal var _tween:Tween;
		/** @private */
		dragonBones_internal var _tweenNode:BoneTransform;
		/** @private */
		dragonBones_internal var _tweenColorTransform:ColorTransform;
		/** @private */
		dragonBones_internal var _visible:Boolean;
		/** @private */
		dragonBones_internal var _children:Vector.<Bone>;
		/** @private */
		dragonBones_internal var _displayBridge:IDisplayBridge;
		/** @private */
		dragonBones_internal var _isOnStage:Boolean;
		/** @private */
		dragonBones_internal var _armature:Armature;
		
		private var _globalTransformMatrix:Matrix;
		private var _displayList:Array;
		private var _displayIndex:int;
		private var _parent:Bone;
		
		private var _colorTransformChange:Boolean;
		private var _colorTransform:ColorTransform;
		private var _boneVisible:Object;
		
		/**
		 * @private
		 */
		public function set visible(value:Object):void
		{
			if(value == null)
			{
				_boneVisible = value;
			}
			else
			{
				_boneVisible = Boolean(value);
			}
		}
		
		/**
		 * Whether this Bone instance and its associated DisplayObject are visible or not (true/false/null). null means that the visible will be controled by animation data.
		 * 
		 */
		public function get visible():Object
		{
			return _boneVisible;
		}
		
		/**
		 * @private
		 */
		public function set colorTransform(value:ColorTransform):void
		{
			_colorTransform = value;
			_colorTransformChange = true;
		}
		
		/**
		 * The ColorTransform instance assiociated with this Bone instance. null means that the ColorTransform will be controled by animation data.
		 */
		public function get colorTransform():ColorTransform
		{
			return _colorTransform;
		}
		
		/**
		 * The armature this Bone instance belongs to.
		 */
		public function get armature():Armature
		{
			return _armature;
		}
		
		/**
		 * The sub-armature of this Bone instance.
		 */
		public function get childArmature():Armature
		{
			return _displayList[_displayIndex] as Armature;
		}
		
		/**
		 * Indicates the Bone instance that directly contains this Bone instance if any.
		 */
		public function get parent():Bone
		{
			return _parent;
		}
		
		/**
		 * The DisplayObject belonging to this Bone instance. Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 */
		public function get display():Object
		{
			return _displayBridge.display;
		}
		public function set display(value:Object):void
		{
			if(_displayBridge.display == value)
			{
				return;
			}
			_displayList[_displayIndex] = value;
			if(value is Armature)
			{
				value = (value as Armature).display;
			}
			_displayBridge.display = value;
		}
		
		
		/**
		 * The DisplayObject list belonging to this Bone instance.
		 */
		public function get displayList():Array
		{
			return _displayList;
		}
		
		/** @private */
		dragonBones_internal function changeDisplay(displayIndex:int):void
		{
			var childArmature:Armature = this.childArmature;
			if(displayIndex < 0)
			{
				if(_isOnStage)
				{
					_isOnStage = false;
					//removeFromStage
					_displayBridge.removeDisplay();
					
					if(childArmature)
					{
						childArmature.animation.stop();
						childArmature.animation.clearMovement();
					}
				}
			}
			else
			{
				if(!_isOnStage)
				{
					_isOnStage = true;
					//addToStage
					if(_armature)
					{
						_displayBridge.addDisplay(_armature.display, global.z);
						_armature._bonesIndexChanged = true;
					}
				}
				if(_displayIndex != displayIndex)
				{
					var length:uint = _displayList.length;
					if(displayIndex >= length && length > 0)
					{
						displayIndex = length - 1;
					}
					_displayIndex = displayIndex;
					
					//change
					display = _displayList[_displayIndex];
				}
				
				if(childArmature)
				{
					childArmature.animation.play();
				}
			}
		}
		
		/**
		 * Creates a new Bone instance and attaches to it a IDisplayBridge instance. 
		 * @param	dragonBones.display.IDisplayBridge
		 */
		public function Bone(displayBrideg:IDisplayBridge)
		{
			origin = new BoneTransform();
			origin.scaleX = 1;
			origin.scaleY = 1;
			global = new BoneTransform();
			node = new BoneTransform();			
			_displayBridge = displayBrideg;			
			_children = new Vector.<Bone>;			
			_globalTransformMatrix = new Matrix();
			_displayList = [];
			_displayIndex = -1;
			_visible = true;			
			_tweenNode = new BoneTransform();
			_tweenColorTransform = new ColorTransform();			
			_tween = new Tween(this);
		}
		/**
		 * Change all DisplayObject attached to this Bone instance.
		 * @param	displayList An array of valid DisplayObject to attach to this Bone.
		 */
		public function changeDisplayList(displayList:Array):void
		{
			var indexBackup:int = _displayIndex;
			var length:uint = displayList.length;
			_displayList.length = length;
			for(var i:int = 0;i < length;i ++)
			{
				changeDisplay(i);
				display = displayList[i];
			}			
			changeDisplay(indexBackup);
		}
		
		/**
		 * Cleans up any resources used by this Bone instance.
		 */
		public function dispose():void
		{
			for each(var _child:Bone in _children)
			{
				_child.dispose();
			}			
			_displayList.length = 0;
			_children.length = 0;			
			_armature = null;
			_parent = null;			
			userData = null;
		}
		/**
		 * Returns true if the passed Bone Instance is a child of this Bone instance (deepLevel false) or true if the passed Bone instance is in the child hierarchy of this Bone instance (deepLevel true) false otherwise.
		 * @param	deepLevel Check against child heirarchy.
		 * @return
		 */
		public function contains(bone:Bone, deepLevel:Boolean = false):Boolean
		{
			if(deepLevel)
			{
				var ancestor:Bone = this;
				while (ancestor != bone && ancestor != null)
				{
					ancestor = ancestor.parent;
				}
				if (ancestor == bone)
				{
					return true;
				}
				return false;
			}			
			return bone.parent == this;
		}
		
		/** @private */
		public function addChild(child:Bone):void
		{
			if (_children.length > 0?(_children.indexOf(child) < 0):true)
			{
				child.removeFromParent();
				
				_children.push(child);
				child.setParent(this);
				
				if (_armature)
				{
					_armature.addToBones(child);
				}
			}
		}
		
		/** @private */
		public function removeChild(child:Bone):void
		{
			var index:int = _children.indexOf(child);
			if (index >= 0)
			{
				if (_armature)
				{
					_armature.removeFromBones(child);
				}
				child.setParent(null);
				_children.splice(index, 1);
			}
		}
		
		/** @private */
		public function removeFromParent():void
		{
			if(_parent)
			{
				_parent.removeChild(this);
			}
		}
		
		/** @private */
		dragonBones_internal function update():void
		{
			//transform
			if(_parent)
			{
				var x:Number = origin.x + node.x + _tweenNode.x;
				var y:Number = origin.y + node.y + _tweenNode.y;
				var parentMatrix:Matrix = _parent._globalTransformMatrix;
				_globalTransformMatrix.tx = global.x = parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx;
				_globalTransformMatrix.ty = global.y = parentMatrix.d * y + parentMatrix.b * x + parentMatrix.ty;
				global.skewX = _parent.global.skewX + origin.skewX + node.skewX + _tweenNode.skewX;
				global.skewY = _parent.global.skewY + origin.skewY + node.skewY + _tweenNode.skewY;
			}
			else
			{
				_globalTransformMatrix.tx = global.x = origin.x + node.x + _tweenNode.x;
				_globalTransformMatrix.ty = global.y = origin.y + node.y + _tweenNode.y;
				global.skewX = origin.skewX + node.skewX + _tweenNode.skewX;
				global.skewY = origin.skewY + node.skewY + _tweenNode.skewY;
			}
			
			//update global
			global.scaleX = origin.scaleX + node.scaleX + _tweenNode.scaleX;
			global.scaleY = origin.scaleY + node.scaleY + _tweenNode.scaleY;
			global.pivotX = origin.pivotX + node.pivotX + _tweenNode.pivotX;
			global.pivotY = origin.pivotY + node.pivotY + _tweenNode.pivotY;
			global.z = origin.z + node.z + _tweenNode.z;
			
			//Note: this formula of transform is defined by Flash pro
			_globalTransformMatrix.a = global.scaleX * Math.cos(global.skewY);
			_globalTransformMatrix.b = global.scaleX * Math.sin(global.skewY);
			_globalTransformMatrix.c = -global.scaleY * Math.sin(global.skewX);
			_globalTransformMatrix.d = global.scaleY * Math.cos(global.skewX);
			
			//update children
			if (_children.length > 0)
			{
				var i:int = _children.length;
				while(i --)
				{
					_children[i].update();
				}
			}
			
			var childArmature:Armature = this.childArmature;
			if(childArmature)
			{
				childArmature.update();
			}
			
			var currentDisplay:Object = _displayBridge.display;
			//update display
			if(currentDisplay)
			{
				//currentColorTransform
				var currentColorTransform:ColorTransform;
				
				if(_tween._differentColorTransform)
				{
					if(_colorTransform)
					{
						_tweenColorTransform.concat(_colorTransform);
					}
					if(_armature.colorTransform)
					{
						_tweenColorTransform.concat(_armature.colorTransform);
					}
					currentColorTransform = _tweenColorTransform;
				}
				else if(_armature._colorTransformChange || _colorTransformChange)
				{
					currentColorTransform = _colorTransform || _armature.colorTransform;
					_colorTransformChange = false;
				}
				_displayBridge.update(_globalTransformMatrix, global, currentColorTransform, (_boneVisible != null)?_boneVisible:_visible);
			}
		}
		
		private function setParent(parent:Bone):void
		{
			if (parent && parent.contains(this, true))
			{
				throw new ArgumentError("An Bone cannot be added as a child to itself or one of its children (or children's children, etc.)");
			}
			_parent = parent;
			
			if(_parent)
			{
				_isOnStage = _parent._isOnStage;
			}			
		}
	}
}
