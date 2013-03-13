package dragonBones
{
	import dragonBones.animation.Tween;
	import dragonBones.display.IDisplayBridge;
	import dragonBones.objects.Node;
	import dragonBones.utils.dragonBones_internal;
	
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	use namespace dragonBones_internal;
	
	/**
	 * A object representing a single joint in an armature. It controls the transform of displays in it.
	 *
	 * @see dragonBones.Armature
	 */
	public class Bone extends EventDispatcher
	{
		private static var _helpPoint:Point = new Point();
		/**
		 * The name of the Armature.
		 */
		public var name:String;
		/**
		 * An object that can contain any extra data.
		 */
		public var userData:Object;
		
		public var global:Node;
		public var origin:Node;
		public var node:Node;
		
		/** @private */
		dragonBones_internal var _tween:Tween;
		/** @private */
		dragonBones_internal var _tweenNode:Node;
		/** @private */
		dragonBones_internal var _tweenColorTransform:ColorTransform;
		/** @private */
		dragonBones_internal var _children:Vector.<Bone>;
		/** @private */
		dragonBones_internal var _displayBridge:IDisplayBridge;
		/** @private */
		dragonBones_internal var _isOnStage:Boolean;
		/** @private */
		dragonBones_internal var _visible:Boolean;
		/** @private */
		dragonBones_internal var _armature:Armature;
		
		private var _globalTransformMatrix:Matrix;
		private var _displayList:Array;
		private var _displayIndex:int;
		private var _parent:Bone;
		
		/**
		 * The armature holding this bone.
		 */
		public function get armature():Armature
		{
			return _armature;
		}
		
		/**
		 * The sub-armature of this bone.
		 */
		public function get childArmature():Armature
		{
			return _displayList[_displayIndex] as Armature;
		}
		
		/**
		 * Indicates the bone that contains this bone.
		 */
		public function get parent():Bone
		{
			return _parent;
		}
		
		/**
		 * Indicates the display object belonging to this bone.
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
		
		/** @private */
		dragonBones_internal function changeDisplay(displayIndex:int):void
		{
			if(displayIndex < 0)
			{
				if(_isOnStage)
				{
					_isOnStage = false;
					//removeFromStage
					_displayBridge.removeDisplay();
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
			}
		}
		
		/**
		 * Creates a new <code>Bone</code> object
		 * @param	displayBrideg
		 */
		public function Bone(displayBrideg:IDisplayBridge)
		{
			origin = new Node();
			global = new Node();
			node = new Node();
			
			_displayBridge = displayBrideg;
			
			_children = new Vector.<Bone>;
			
			_globalTransformMatrix = new Matrix();
			_displayList = [];
			_displayIndex = -1;
			_visible = true;
			
			_tweenNode = new Node();
			_tweenColorTransform = new ColorTransform();
			
			_tween = new Tween(this);
		}
		
		public function changeDisplayList(displayList:Array):void
		{
			var indexBackup:int = _displayIndex;
			
			var length:uint = Math.min(_displayList.length, displayList.length);
			for(var i:int = 0;i < length;i ++)
			{
				changeDisplay(i);
				display = displayList[i];
			}
			
			changeDisplay(indexBackup);
		}
		
		/**
		 * Cleans up any resources used by the current object.
		 */
		public function dispose():void
		{
			for each(var _child:Bone in _children)
			{
				_child.dispose();
			}
			
			_displayList.length = 0;
			_children.length = 0;
			//_displayBridge.display = null;
			
			_armature = null;
			_parent = null;
			
			//_tween.dispose();
			//_tween = null;
			
			userData = null;
		}
		
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
			//update node and matirx
			if (_children.length > 0 || _isOnStage)
			{
				//update global
				global.x = origin.x + node.x + _tweenNode.x;
				global.y = origin.y + node.y + _tweenNode.y;
				global.skewX = origin.skewX + node.skewX + _tweenNode.skewX;
				global.skewY = origin.skewY + node.skewY + _tweenNode.skewY;
				global.scaleX = origin.scaleX + node.scaleX + _tweenNode.scaleX;
				global.scaleY = origin.scaleY + node.scaleY + _tweenNode.scaleY;
				global.pivotX = origin.pivotX + node.pivotX + _tweenNode.pivotX;
				global.pivotY = origin.pivotY + node.pivotY + _tweenNode.pivotY;
				global.z = origin.z + node.z + _tweenNode.z;
				//transform
				if(_parent)
				{
					_helpPoint.x = global.x;
					_helpPoint.y = global.y;
					_helpPoint = _parent._globalTransformMatrix.transformPoint(_helpPoint);
					global.x = _helpPoint.x
					global.y = _helpPoint.y;
					global.skewX += _parent.global.skewX;
					global.skewY += _parent.global.skewY;
				}
				
				//Note: this formula of transform is defined by Flash pro
				_globalTransformMatrix.a = global.scaleX * Math.cos(global.skewY);
				_globalTransformMatrix.b = global.scaleX * Math.sin(global.skewY);
				_globalTransformMatrix.c = -global.scaleY * Math.sin(global.skewX);
				_globalTransformMatrix.d = global.scaleY * Math.cos(global.skewX);
				_globalTransformMatrix.tx = global.x;
				_globalTransformMatrix.ty = global.y;
				
				//update children
				if (_children.length > 0)
				{
					for each(var child:Bone in _children)
					{
						child.update();
					}
				}
				
				var childArmature:Armature = this.childArmature;
				if(childArmature)
				{
					childArmature.update();
				}
				
				var currentDisplay:Object = _displayBridge.display;
				//update display
				if(_isOnStage && currentDisplay)
				{
					//colorTransform
					var colorTransform:ColorTransform;
					
					if(_tween._differentColorTransform)
					{
						if(_armature.colorTransform)
						{
							_tweenColorTransform.concat(_armature.colorTransform);
						}
						colorTransform = _tweenColorTransform;
					}
					else if(_armature._colorTransformChange)
					{
						colorTransform = _armature.colorTransform;
						_armature._colorTransformChange = false;
					}
					
					_displayBridge.update(_globalTransformMatrix, global, colorTransform, _visible);
				}
			}
		}
		
		private function setParent(parent:Bone):void
		{
			if (parent && parent.contains(this, true))
			{
				throw new ArgumentError("An Bone cannot be added as a child to itself or one of its children (or children's children, etc.)");
			}
			_parent = parent;
		}
	}
}