package citrus.view.spriteview 
{
	import citrus.core.CitrusEngine;
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
	 * For each animation, have as many frames on the main timeline as needed for each:
	 * The animations should be playing along with the main timeline as AnimationSequence will control the playhead for pausing/resuming/looping.
	 * 
	 * animations should be put in sequence without any gaps.
	 * to define where each animation start and ends, spread a keyframe over each animation with a frame label.
	 * this label will be the animation name.
	 * 
	 * The MC already starts stopped (so you don't need to call stop() ).
	 * In fact you should not control the timeline yourself through actionscript in the fla, AnimationSequence will
	 * take care of looping animations that need looping, going back and forth or stopping as well as pause/resume.
	 * 
	 * AnimationSequence adds scripts on frames.
	 * if all animations are correctly in sequence and all labeled keeframes are "connected" without gaps,
	 * AnimationSequence will make the MC dispatch a signal the frame before the main timeline should go to a different label
	 * so it automatically loops back or stops.
	 */
	public class AnimationSequence extends Sprite
	{
		protected var _ce:CitrusEngine;
		
		protected var _mc:MovieClip;
		protected var anims:Dictionary;
		
		protected var _currentAnim:String;
		protected var _currentFrame:int = 0;
		protected var _looping:Boolean = false;
		protected var _playing:Boolean = false;
		protected var _paused:Boolean = false;
		protected var _animChanged:Boolean = false;
		
		public var onAnimationComplete:Signal;
		
		public function AnimationSequence(mc:MovieClip) 
		{
			_ce = CitrusEngine.getInstance();
			_mc = mc;
			_mc["onAnimationComplete"] = new Signal();
			anims = new Dictionary();
			setupMCActions();
			_mc["onAnimationComplete"].add(handleAnimationComplete);
			_mc.gotoAndStop(0);
			addChild(_mc);
			onAnimationComplete = new Signal(String);
			
			_ce.stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		protected function handleEnterFrame(e:Event):void
		{
			if (_paused)
				return;
			
			if (_playing)
			{
				_mc.gotoAndStop(_currentFrame);
				_currentFrame++;
			}
		}
		
		protected function handleAnimationComplete():void
		{
			if (_currentAnim)
			{
				onAnimationComplete.dispatch(_currentAnim);
				if (_looping)
					changeAnimation(_currentAnim, _looping);
				else
				{
					_playing = false;
				}
			}
		}
		
		protected function setupMCActions():void
		{
			var name:String;
			var frame:int;
			var anim:FrameLabel;
			
			for each (anim in _mc.currentLabels)
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
			
			for each (anim in _mc.currentLabels)
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
			_paused = true;
		}
		
		public function resume():void
		{
			_paused = false;
		}
		
		public function changeAnimation(name:String, loop:Boolean  = false):void
		{
			_looping = loop;
		
			if (name in anims)
			{
				var frameLabel:FrameLabel = anims[name];
				_currentAnim = frameLabel.name;
				_currentFrame = frameLabel.frame;
				_playing = true;
				_mc.gotoAndStop(_currentFrame);
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
			_ce.stage.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			onAnimationComplete.removeAll();
			anims = null;
			removeChild(_mc);
		}
		
	}

}