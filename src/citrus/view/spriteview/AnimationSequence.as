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
	 */
	public class AnimationSequence extends Sprite
	{
		protected var _ce:CitrusEngine;
		
		protected var _mc:MovieClip;
		protected var anims:Dictionary;
		
		protected var time:int = 0;
		
		protected var _currentAnim:AnimationSequenceData;
		protected var _currentFrame:int = 0;
		protected var _looping:Boolean = false;
		protected var _playing:Boolean = false;
		protected var _paused:Boolean = false;
		protected var _animChanged:Boolean = false;
		
		public var onAnimationComplete:Signal;
		
		/**
		 * if fpsRatio = .5, the animations will go 1/2 slower than the stage fps.
		 */
		public var fpsRatio:Number = 1;
		
		public function AnimationSequence(mc:MovieClip) 
		{
			_ce = CitrusEngine.getInstance();
			_mc = mc;
			anims = new Dictionary();
			
			if (_mc.totalFrames != 1)
			{
				onAnimationComplete = new Signal(String);
				setupMCActions();
				_mc.gotoAndStop(0);
				_ce.stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			
			addChild(_mc);
		}
		
		protected function handleEnterFrame(e:Event):void
		{
			if (_paused)
				return;
			
			if (_playing)
			{
				if(fpsRatio == 1 || (time%((1/fpsRatio)<<0) == 0))
					_mc.nextFrame();
				time++;
				
				if (_mc.currentFrame == _currentAnim.endFrame)
					handleAnimationComplete();	
			}
		}
		
		protected function handleAnimationComplete():void
		{
			onAnimationComplete.dispatch(_currentAnim.name);
			if (_looping && _playing)
				changeAnimation(_currentAnim.name, _looping);
			else
				_playing = false;
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
				
				if (name in anim)
					continue;
					
				anims[name] = new AnimationSequenceData(name, frame);
				
				if (!_currentAnim)
					_currentAnim = anims[name];
			}
			
			var previousAnimation:String;
			
			for each (anim in _mc.currentLabels)
			{
				if(previousAnimation)
					AnimationSequenceData(anims[previousAnimation]).endFrame = anim.frame-1;
				previousAnimation = anim.name;
			}
			AnimationSequenceData(anims[previousAnimation]).endFrame = _mc.totalFrames-1;
		}
		
		public function pause():void
		{
			_paused = true;
			_ce.stage.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		public function resume():void
		{
			_paused = false;
			_ce.stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		public function changeAnimation(name:String, loop:Boolean  = false):void
		{
			_looping = loop;
			if (name in anims)
			{
				_currentAnim = anims[name];
				_mc.gotoAndStop(_currentAnim.startFrame);
				_playing = true;
			}
		}
		
		public function hasAnimation(animation:String):Boolean
		{
			return anims[animation];
		}
		
		public function destroy():void
		{
			_ce.stage.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			onAnimationComplete.removeAll();
			anims = null;
			removeChild(_mc);
		}
		
		public function get mc():MovieClip {
			return _mc;
		}
		
	}

}

internal class AnimationSequenceData 
{
	internal var startFrame:int;
	internal var endFrame:int;
	internal var name:String;
	public function AnimationSequenceData(name:String,startFrame:int = -1,endFrame:int = -1)
	{
		this.name = name;
		this.startFrame = startFrame;
		this.endFrame = endFrame;
	}
}