package citrus.view.starlingview {

	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureAtlas;

	import org.osflash.signals.Signal;

	import flash.utils.Dictionary;

	/**
	 * The Animation Sequence class represents all object animations in one sprite sheet. You have to create your texture atlas in your state class.
	 * Example : <code>var hero:Hero = new Hero("Hero", {x:400, width:60, height:130, view:new AnimationSequence(textureAtlas, ["walk", "duck", "idle", "jump"], "idle")});</code>
	 */
	public class AnimationSequence extends Sprite {
		
		/**
		 * The signal is dispatched each time an animation is completed, giving the animation name as argument.
		 */
		public var onAnimationComplete:Signal;

		private var _textureAtlas:TextureAtlas;
		private var _animations:Array;
		private var _firstAnimation:String;
		private var _animFps:Number;
		private var _firstAnimLoop:Boolean;
		private var _smoothing:String;
		
		private var _mcSequences:Dictionary;
		private var _previousAnimation:String;
		
		/**
		 * @param textureAtlas a TextureAtlas object with all your object's animations.
	 	 * @param animations an array with all your object's animations as a String.
	 	 * @param firstAnimation a string of your default animation at its creation.
	 	 * @param animFps a number which determines the animation MC's fps.
	 	 * @param firstAnimLoop a boolean, set it to true if you want your first animation to loop.
	 	 * @param smoothing a string indicating the smoothing algorithms used for the AnimationSequence, default is bilinear.
		 */
		public function AnimationSequence(textureAtlas:TextureAtlas, animations:Array, firstAnimation:String, animFps:Number = 30, firstAnimLoop:Boolean = false, smoothing:String = "bilinear") {

			super();
			
			onAnimationComplete = new Signal(String);

			_textureAtlas = textureAtlas;
			_animations = animations;
			_firstAnimation = firstAnimation;
			_animFps = animFps;
			_firstAnimLoop = firstAnimLoop;
			_smoothing = smoothing;
			
			_mcSequences = new Dictionary();

			for each (var animation:String in _animations) {
				
				if (_textureAtlas.getTextures(animation).length == 0)
					throw new Error("One object doesn't have the " + animation + " animation in its TextureAtlas");
				
				_mcSequences[animation] = new MovieClip(_textureAtlas.getTextures(animation), _animFps);
				
				_mcSequences[animation].name = animation;
				_mcSequences[animation].addEventListener(Event.COMPLETE, _animationComplete);
				_mcSequences[animation].smoothing = _smoothing;
			}
			
			addChild(_mcSequences[_firstAnimation]);
			Starling.juggler.add(_mcSequences[_firstAnimation]);
			_mcSequences[_firstAnimation].loop = _firstAnimLoop;
				
			_previousAnimation = _firstAnimation;			
		}
		
		/**
		 * Called by StarlingArt, managed the MC's animations.
		 * @param animation the MC's animation
		 * @param animLoop true if the MC is a loop
		 */
		public function changeAnimation(animation:String, animLoop:Boolean):void {
			
			if (!(_mcSequences[animation]))
				throw new Error("One object doesn't have the " + animation + " animation set up in its initial array");
			
			removeChild(_mcSequences[_previousAnimation]);
			Starling.juggler.remove(_mcSequences[_previousAnimation]);
			
			addChild(_mcSequences[animation]);
			Starling.juggler.add(_mcSequences[animation]);
			_mcSequences[animation].loop = animLoop;
			_mcSequences[animation].currentFrame = 0;
			
			_previousAnimation = animation;
		}
		
		/**
		 * Called by StarlingArt, remove or add to the Juggler if the Citrus Engine is playing or not.
		 */
		public function pauseAnimation(value:Boolean):void {
			
			value ? Starling.juggler.add(_mcSequences[_previousAnimation]) : Starling.juggler.remove(_mcSequences[_previousAnimation]);
		}
		
		public function destroy():void {
			
			onAnimationComplete.removeAll();
			
			removeChild(_mcSequences[_previousAnimation]);
			Starling.juggler.remove(_mcSequences[_previousAnimation]);
			
			for each (var animation:String in _animations) {
				_mcSequences[animation].removeEventListener(Event.COMPLETE, _animationComplete);
				_mcSequences[animation].dispose();
			}
			
			_mcSequences = null;
		}
		
		/**
		 * A dictionary containing all animations registered thanks to their string name.
		 */
		public function get mcSequences():Dictionary {
			return _mcSequences;
		}
		
		/**
		 * Return a clone of the current AnimationSequence.
		 */
		public function clone():AnimationSequence {	
			return new AnimationSequence(_textureAtlas, _animations, _firstAnimation, _animFps, _firstAnimLoop, _smoothing);
		}
		
		private function _animationComplete(evt:Event):void {
			onAnimationComplete.dispatch((evt.target as MovieClip).name);
		}
	}
}
