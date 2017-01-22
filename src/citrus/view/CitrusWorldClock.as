package citrus.view
{
	import dragonBones.Armature;
	import dragonBones.animation.WorldClock;
	
	import flash.display.DisplayObject;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public final class CitrusWorldClock implements ICitrusArt
	{
		private var _updateArtEnabled:Boolean = true;
		
		//private var _view:*;
		
		private static var _worldClock:WorldClock = WorldClock.clock;
		
		public function CitrusWorldClock()
		{
			
		}
		public static function destroyView(view:*):void   //,content:starling.display.DisplayObject
		{
			if (view is Armature) {
					WorldClock.clock.remove(view);
					(view as Armature).dispose();
					//content.dispose();
							//销毁骨架
					
			}
		}
		public static function setAnimation(_view:*,value:String,animLoop:Boolean):void
		{
			if (_view is Armature)
				(_view as Armature).animation.gotoAndPlay(value, -1, -1, animLoop ? 0 : 1);
		}
		public static function setView(view:*,_content:*):void
		{
			if(view is Armature)
			{
				if(_content == flash.display.DisplayObject)
				{
					_content = (view as Armature).display as flash.display.Sprite;//(_view as Armature).display as Sprite;
				}
				else if(_content == starling.display.DisplayObject)
				{
				_content = (view as Armature).display as starling.display.Sprite;//(_view as Armature).display as Sprite;
				}
				WorldClock.clock.add(view);
			}
		}
		public static function pauseAnimation(view:*,value:Boolean):void
		{
			if(view is Armature)
				value ? (view as Armature).animation.play() : (view as Armature).animation.stop(); 
		}
			
		public function get updateArtEnabled():Boolean
		{
			return _updateArtEnabled;
		}
		
		public function set updateArtEnabled(val:Boolean):void
		{
			_updateArtEnabled = val;
		}
		
		public function update(sceneView:ACitrusView):void
		{
		}
	}
}