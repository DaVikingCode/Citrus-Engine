package dragonBones.core
{
	import flash.geom.Matrix;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.DBTransform;
	
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
		
		/** @private */
		dragonBones_internal var _globalTransformMatrix:Matrix;
		
		/** @private */
		dragonBones_internal var _global:DBTransform;
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
		 * This Bone instance origin transform instance.
		 * @see dragonBones.objects.DBTransform
		 */
		public function get origin():DBTransform
		{
			return _origin;
		}
		
		/** @private */
		protected var _offset:DBTransform;
		/**
		 * This Bone instance offset transform instance.
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
			if(_armature)
			{
				_armature.removeDBObject(this);
			}
			_armature = value;
			if(_armature)
			{
				_armature.addDBObject(this);
			}
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
	}
}