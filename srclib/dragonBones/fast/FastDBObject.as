package dragonBones.fast
{
	import flash.geom.Matrix;
	
	import dragonBones.cache.FrameCache;
	import dragonBones.core.DBObject;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.DBTransform;
	import dragonBones.utils.TransformUtil;
	
	use namespace dragonBones_internal;

	
	public class FastDBObject
	{
		private var _name:String;
		
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
		
		/** @private */
		dragonBones_internal var _globalBackup:DBTransform;
		/** @private */
		dragonBones_internal var _globalTransformMatrixBackup:Matrix;
		
		dragonBones_internal static var _tempParentGlobalTransform:DBTransform = new DBTransform();
		
		dragonBones_internal var _frameCache:FrameCache;
		
		/** @private */
		dragonBones_internal function updateByCache():void
		{
			_global = _frameCache.globalTransform;
			_globalTransformMatrix = _frameCache.globalTransformMatrix;
		}
		
		/** @private */
		dragonBones_internal function switchTransformToBackup():void
		{
			if(!_globalBackup)
			{
				_globalBackup = new DBTransform();
				_globalTransformMatrixBackup = new Matrix();
			}
			_global = _globalBackup;
			_globalTransformMatrix = _globalTransformMatrixBackup;
		}
		
		/**
		 * The armature this DBObject instance belongs to.
		 */
		public var armature:FastArmature;
		
		/** @private */
		protected var _origin:DBTransform;
		
		/** @private */
		protected var _visible:Boolean;
		
		/** @private */
		dragonBones_internal var _parent:FastBone;
		
		/** @private */
		dragonBones_internal function setParent(value:FastBone):void
		{
			_parent = value;
		}
		
		public function FastDBObject()
		{
			_globalTransformMatrix = new Matrix();
			
			_global = new DBTransform();
			_origin = new DBTransform();
			
			_visible = true;
			
			armature = null;
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
			
			armature = null;
			_parent = null;
		}
		
		static private var tempOutputObj:Object = {};
		protected function calculateParentTransform():Object
		{
			if(this.parent && (this.inheritTranslation || this.inheritRotation || this.inheritScale))
			{
				var parentGlobalTransform:DBTransform = this._parent._global;
				var parentGlobalTransformMatrix:Matrix = this._parent._globalTransformMatrix;
				
				if(	!this.inheritTranslation && (parentGlobalTransform.x != 0 || parentGlobalTransform.y != 0) ||
					!this.inheritRotation && (parentGlobalTransform.skewX != 0 || parentGlobalTransform.skewY != 0) ||
					!this.inheritScale && (parentGlobalTransform.scaleX != 1 || parentGlobalTransform.scaleY != 1))
				{
					parentGlobalTransform = FastDBObject._tempParentGlobalTransform;
					parentGlobalTransform.copy(this._parent._global);
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
				tempOutputObj.parentGlobalTransform = parentGlobalTransform;
				tempOutputObj.parentGlobalTransformMatrix = parentGlobalTransformMatrix;
				return tempOutputObj;
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
		
		protected function calculateRelativeParentTransform():void
		{
		}
		
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name = value;
		}
		
		/**
		 * This DBObject instance global transform instance.
		 * @see dragonBones.objects.DBTransform
		 */
		public function get global():DBTransform
		{
			return _global;
		}
		
		
		public function get globalTransformMatrix():Matrix
		{
			return _globalTransformMatrix;
		}
		
		/**
		 * This DBObject instance related to parent transform instance.
		 * @see dragonBones.objects.DBTransform
		 */
		public function get origin():DBTransform
		{
			return _origin;
		}
		
		/**
		 * Indicates the Bone instance that directly contains this DBObject instance if any.
		 */
		public function get parent():FastBone
		{
			return _parent;
		}
		
		/** @private */
		
		public function get visible():Boolean
		{
			return _visible;
		}
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		public function set frameCache(cache:FrameCache):void
		{
			_frameCache = cache;
		}
	}
}