package dragonBones.core
{
	import flash.geom.Matrix;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.objects.DBTransform;
	import dragonBones.utils.TransformUtil;
	
	use namespace dragonBones_internal;

	public class DBObject
	{
		public var name:String;
		
		/**
		 * An object that can contain any user extra data.
		 */
		public var userData:Object;
		
		/**
		 * 
		 */
		public var inheritRotation:Boolean;
		
		/**
		 * 
		 */
		public var inheritScale:Boolean;
		
		/**
		 * 
		 */
		public var inheritTranslation:Boolean;
		
		/** @private */
		dragonBones_internal var _global:DBTransform;
		/** @private */
		dragonBones_internal var _globalTransformMatrix:Matrix;
		
		dragonBones_internal static var _tempParentGlobalTransformMatrix:Matrix = new Matrix();
		dragonBones_internal static var _tempParentGlobalTransform:DBTransform = new DBTransform();
		
		
		/**
		 * This DBObject instance global transform instance.
		 * @see dragonBones.objects.DBTransform
		 */
		public function get global():DBTransform
		{
			return _global;
		}
		
		/** @private */
		protected var _origin:DBTransform;
		/**
		 * This DBObject instance related to parent transform instance.
		 * @see dragonBones.objects.DBTransform
		 */
		public function get origin():DBTransform
		{
			return _origin;
		}
		
		/** @private */
		protected var _offset:DBTransform;
		/**
		 * This DBObject instance offset transform instance (For manually control).
		 * @see dragonBones.objects.DBTransform
		 */
		public function get offset():DBTransform
		{
			return _offset;
		}
		
		/** @private */
		protected var _visible:Boolean;
		public function get visible():Boolean
		{
			return _visible;
		}
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		/** @private */
		protected var _armature:Armature;
		/**
		 * The armature this DBObject instance belongs to.
		 */
		public function get armature():Armature
		{
			return _armature;
		}
		/** @private */
		dragonBones_internal function setArmature(value:Armature):void
		{
			_armature = value;
		}
		
		/** @private */
		dragonBones_internal var _parent:Bone;
		/**
		 * Indicates the Bone instance that directly contains this DBObject instance if any.
		 */
		public function get parent():Bone
		{
			return _parent;
		}
		/** @private */
		dragonBones_internal function setParent(value:Bone):void
		{
			_parent = value;
		}
		
		public function DBObject()
		{
			_globalTransformMatrix = new Matrix();
			
			_global = new DBTransform();
			_origin = new DBTransform();
			_offset = new DBTransform();
			_offset.scaleX = _offset.scaleY = 1;
			
			_visible = true;
			
			_armature = null;
			_parent = null;
			
			userData = null;
			
			this.inheritRotation = true;
			this.inheritScale = true;
			this.inheritTranslation = true;
		}
		
		/**
		 * Cleans up any resources used by this DBObject instance.
		 */
		public function dispose():void
		{
			userData = null;
			
			_globalTransformMatrix = null;
			_global = null;
			_origin = null;
			_offset = null;
			
			_armature = null;
			_parent = null;
		}
		
		protected function calculateRelativeParentTransform():void
		{
		}
		
		protected function calculateParentTransform():Object
		{
			if(this.parent && (this.inheritTranslation || this.inheritRotation || this.inheritScale))
			{
				var parentGlobalTransform:DBTransform = this._parent._globalTransformForChild;
				var parentGlobalTransformMatrix:Matrix = this._parent._globalTransformMatrixForChild;
				
				if(!this.inheritTranslation || !this.inheritRotation || !this.inheritScale)
				{
					parentGlobalTransform = DBObject._tempParentGlobalTransform;
					parentGlobalTransform.copy(this._parent._globalTransformForChild);
					if(!this.inheritTranslation)
					{
						parentGlobalTransform.x = 0;
						parentGlobalTransform.y = 0;
					}
					if(!this.inheritScale)
					{
						parentGlobalTransform.scaleX = 1;
						parentGlobalTransform.scaleY = 1;
					}
					if(!this.inheritRotation)
					{
						parentGlobalTransform.skewX = 0;
						parentGlobalTransform.skewY = 0;
					}
					
					parentGlobalTransformMatrix = DBObject._tempParentGlobalTransformMatrix;
					TransformUtil.transformToMatrix(parentGlobalTransform, parentGlobalTransformMatrix);
				}
				
				return {parentGlobalTransform:parentGlobalTransform, parentGlobalTransformMatrix:parentGlobalTransformMatrix};
			}
			return null;
		}
		
		protected function updateGlobal():Object
		{
			calculateRelativeParentTransform();
			var output:Object = calculateParentTransform();
			if(output != null)
			{
				//计算父骨头绝对坐标
				var parentMatrix:Matrix = output.parentGlobalTransformMatrix;
				var parentGlobalTransform:DBTransform = output.parentGlobalTransform;
				//计算绝对坐标
				var x:Number = _global.x;
				var y:Number = _global.y;
				
				_global.x = parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx;
				_global.y = parentMatrix.d * y + parentMatrix.b * x + parentMatrix.ty;
				
				if(this.inheritRotation)
				{
					_global.skewX += parentGlobalTransform.skewX;
					_global.skewY += parentGlobalTransform.skewY;
				}
				
				if(this.inheritScale)
				{
					_global.scaleX *= parentGlobalTransform.scaleX;
					_global.scaleY *= parentGlobalTransform.scaleY;
				}
			}
			TransformUtil.transformToMatrix(_global, _globalTransformMatrix);
			return output;
		}
	}
}