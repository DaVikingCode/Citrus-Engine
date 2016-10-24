package aze.motion.specials 
{
	import aze.motion.EazeTween;
	import aze.motion.specials.EazeSpecial;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	
	/**
	 * Frame tweening as a special property
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class PropertyFrame extends EazeSpecial
	{
		static public function register():void
		{
			EazeTween.specialProperties.frame = PropertyFrame;
		}
		
		private var start:int;
		private var delta:int;
		private var frameStart:*;
		private var frameEnd:*;
		
		public function PropertyFrame(target:Object, property:*, value:*, next:EazeSpecial)
		{
			super(target, property, value, next);
		
			var mc:MovieClip = MovieClip(target);
			
			var parts:Array;
			if (value is String) 
			{
				// smart frame label handling
				var label:String = value;
				if (label.indexOf("+") > 0) 
				{
					parts = label.split("+");
					frameStart = parts[0];
					frameEnd = label;
				}
				else if (label.indexOf(">") > 0) 
				{
					parts = label.split(">");
					frameStart = parts[0];
					frameEnd = parts[1];
				}
				else frameEnd = label;
			}
			else 
			{
				// numeric frame index
				var index:int = int(value);
				if (index <= 0) index += mc.totalFrames;
				frameEnd = Math.max(1, Math.min(mc.totalFrames, index));
			}
		}
		
		override public function init(reverse:Boolean):void 
		{
			var mc:MovieClip = MovieClip(target);
			
			// convert labels to num
			if (frameStart is String) frameStart = findLabel(mc, frameStart);
			else frameStart = mc.currentFrame;
			if (frameEnd is String) frameEnd = findLabel(mc, frameEnd);
			
			if (reverse) { start = frameEnd; delta = frameStart - start; }
			else { start = frameStart; delta = frameEnd - start; }
			
			mc.gotoAndStop(start);
		}
		
		private function findLabel(mc:MovieClip, name:String):int
		{
			for each(var label:FrameLabel in mc.currentLabels)
				if (label.name == name) return label.frame;
			return 1;
		}
		
		override public function update(ke:Number, isComplete:Boolean):void
		{
			var mc:MovieClip = MovieClip(target);
			
			mc.gotoAndStop(Math.round(start + delta * ke));
		}
		
		public function getPreferredDuration():Number
		{
			var mc:MovieClip = MovieClip(target);
			
			var fps:Number = mc.stage ? mc.stage.frameRate : 30;
			return Math.abs(Number(delta) / fps);
		}
	}

}