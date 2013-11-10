package citrus.view.spriteview 
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	
	/**
	 * AnimationSequence.as wraps a flash MovieClip to manage different animations.
	 * The .fla used should have a specific format following the format of the "patch demo"
	 * https://github.com/alamboley/Citrus-Engine-Examples/blob/master/fla/patch_character-SpriteArt.fla
	 * 
	 * For each animation, have as many frames on the main timeline as needed for each.
	 * animations should be put in sequence on the same main timeline.
	 * to defin where each animation start and ends, spread a keyframe over each animation with a frame label.
	 * this label will be the animation name.
	 * 
	 * The MC already starts stopped (so you don't need to call stop() ).
	 * In fact you should not control the timeline yourself through actionscript in the fla, AnimationSequence will
	 * take care of looping animations that need looping, going back and force or stopping.
	 * 
	 * AnimationSequence adds scripts on frames.
	 * if all animations are correctly in sequence and all labeled keeframes are "connected" without gaps,
	 * AnimationSequence will make the MC dispatch a signal the frame before the main timeline should go to a different label
	 * so it automatically loops back or stops.
	 */
	public class AnimationSequence extends Sprite
	{
		protected var _mc:MovieClip;
		protected var anims:Dictionary;
		
		protected var _currentAnim:String;
		protected var _currentFrame:int = 0;
		protected var _looping:Boolean = false;
		
		public var onAnimationComplete:Signal;
		
		public function AnimationSequence(mc:MovieClip) 
		{
			_mc = mc;
			_mc["onAnimationComplete"] = new Signal();
			anims = new Dictionary();
			setupMCActions();
			_mc["onAnimationComplete"].add(handleAnimationComplete);
			_mc.stop();
			addChild(_mc);
			
			onAnimationComplete = new Signal(String);
		}
		
		protected function handleAddedToStage(e:Event):void
		{
			
		}
		
		protected function handleAnimationComplete():void
		{
			if (_currentAnim)
			{
				onAnimationComplete.dispatch(_currentAnim);
				if(_looping)
					changeAnimation(_currentAnim, _looping);
				else
					_mc.stop();
			}
		}
		
		protected function setupMCActions():void
		{
			var name:String;
			var frame:int;
			
			for each (var anim:FrameLabel in _mc.currentLabels)
			{
				name = anim.name;
				frame = anim.frame;
				
				if (!_currentAnim)
					_currentAnim = name;
				
				if (name in anim)
					continue;
					
				anims[name] = anim;
			}
			
			var previousAnimation:String;
			
			var f:Function = function():void
			{
				_mc.onAnimationComplete.dispatch();
			};
			
			for each (var anim:FrameLabel in _mc.currentLabels)
			{
				if (anim.frame != 1 && (anim.name != previousAnimation))
				{
					_mc.addFrameScript(anim.frame-1, f);
				}
				
				previousAnimation = anim.name;
			}
			
			_mc.addFrameScript(_mc.totalFrames,f);
		}
		
		public function pause():void
		{
			_currentFrame = _mc.currentFrame;
			_mc.stop();
		}
		
		public function resume():void
		{
			_mc.play();
		}
		
		public function changeAnimation(name:String, loop:Boolean  = false):void
		{
			_looping = loop;
		
			if (name in anims)
			{
				var frameLabel:FrameLabel = anims[name];
				_currentAnim = frameLabel.name;
				_mc.gotoAndPlay(frameLabel.frame);
				
			}
		}
		
		public function hasAnimation(animation:String):Boolean
		{
			for each (var anim:FrameLabel in _mc.currentLabels)
			{
				if (anim.name == animation)
					return true;
			}
			
			return false;
		}
		
		public function destroy():void
		{
			onAnimationComplete.removeAll();
			anims = null;
			removeChild(_mc);
		}
		
	}

}