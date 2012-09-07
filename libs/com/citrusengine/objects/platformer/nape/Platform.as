package com.citrusengine.objects.platformer.nape {

	import nape.callbacks.CbType;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.geom.Vec2;
	import nape.phys.BodyType;

	import com.citrusengine.objects.NapePhysicsObject;

	/**
	 * A Platform is a rectangular object that is meant to be stood on. It can be given any position, width, height, or rotation to suit your level's needs.
	 * You can make your platform a "one-way" or "cloud" platform so that you can jump on from underneath (collision is only applied when coming from above it).
	 * 
	 * There are two ways of adding graphics for your platform. You can give your platform a graphic just like you would any other object (by passing a graphical
	 * class into the view property) or you can leave your platform invisible and line it up with your backgrounds for a more custom look.
	 * 
	 * Properties:
	 * oneWay - Makes the platform only collidable when falling from above it.
	 */
	public class Platform extends NapePhysicsObject {
		
		public static const ONEWAY_PLATFORM:CbType = new CbType();
		
		private var _oneWay:Boolean = false;
		private var _preListener:PreListener;

		public function Platform(name:String, params:Object = null) {
			
			super(name, params);
		}
		
		override public function destroy():void {
			
			if (_preListener)
				_body.space.listeners.remove(_preListener);
			
			super.destroy();
		}
		
		public function get oneWay():Boolean
		{
			return _oneWay;
		}
		
		[Inspectable(defaultValue="false")]
		public function set oneWay(value:Boolean):void
		{
			if (_oneWay == value)
				return;
			
			_oneWay = value;
			
			if (_oneWay)
			{
				_preListener = new PreListener(InteractionType.ANY, Platform.ONEWAY_PLATFORM, CbType.ANY_BODY, handlePreContact);
				_body.space.listeners.add(_preListener);
				_body.cbTypes.add(ONEWAY_PLATFORM);
			}
			else
			{
				if (_preListener) {
					_preListener.space = null;
					_preListener = null;
				}
				_body.cbTypes.clear();
			}
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
		}
		
		override protected function defineBody():void {
			
			_bodyType = BodyType.STATIC;
		}
		
		override protected function createConstraint():void {
			
			super.createConstraint();
			
			if (_oneWay) {
				_preListener = new PreListener(InteractionType.COLLISION, ONEWAY_PLATFORM, CbType.ANY_BODY, this.handlePreContact);
				_body.cbTypes.add(ONEWAY_PLATFORM);
				_body.space.listeners.add(_preListener);
			}
		}
		
		override public function handlePreContact(callback:PreCallback):PreFlag
		{
			var dir:Vec2 = new Vec2(0, callback.swapped ? 1 : -1);
			
			if (dir.dot(callback.arbiter.collisionArbiter.normal) <= 0) {
				return PreFlag.IGNORE;
			} else {
				return null;
			}
		}
	}
}
