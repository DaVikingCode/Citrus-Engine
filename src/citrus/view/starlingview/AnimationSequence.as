package citrus.view.starlingview {

	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.textureAtlas.DynamicAtlas;
	import starling.textures.TextureAtlas;
	
	import flash.display.MovieClip;

	import org.osflash.signals.Signal;

	import flash.utils.Dictionary;

	/**
	 * The Animation Sequence class represents all object animations in one sprite sheet. You have to create your texture atlas in your state class.
	 * Example : <code>var hero:Hero = new Hero("Hero", {x:400, width:60, height:130, view:new AnimationSequence(textureAtlas, ["walk", "duck", "idle", "jump"], "idle")});</code>
	 * <b>Important:</b> for managing if an animation should loop, you've to set it up at <code>StarlingArt.setLoopAnimations(["fly", "fallen"])</code>. By default, the walk's 
	 * animation is the only one looping.
	 */
	public class AnimationSequence extends Sprite {

		/**
		 * The signal is dispatched each time an animation is completed, giving the animation name as argument.
		 */
		public var onAnimationComplete:Signal;

		private var _textureAtlas:*;
		private var _animations:Array;
		private var _firstAnimation:String;
		private var _animFps:Number;
		private var _firstAnimLoop:Boolean;
		private var _smoothing:String;

		private var _mcSequences:Dictionary;
		private var _previousAnimation:String;

		/**
		 * @param textureAtlas a TextureAtlas or an AssetManager object with your object's animations you would like to use.
		 * @param animations an array with the object's animations as a String you would like to pick up.
		 * @param firstAnimation a string of your default animation at its creation.
		 * @param animFps a number which determines the animation MC's fps.
		 * @param firstAnimLoop a boolean, set it to true if you want your first animation to loop.
		 * @param smoothing a string indicating the smoothing algorithms used for the AnimationSequence, default is bilinear.
		 */
		public function AnimationSequence(textureAtlas:*, animations:Array, firstAnimation:String, animFps:Number = 30, firstAnimLoop:Boolean = false, smoothing:String = "bilinear") {

			super();

			onAnimationComplete = new Signal(String);

			_textureAtlas = textureAtlas;
			_animations = animations;
			_firstAnimation = firstAnimation;
			_animFps = animFps;
			_firstAnimLoop = firstAnimLoop;
			_smoothing = smoothing;

			_mcSequences = new Dictionary();
			
			addTextureAtlasWithAnimations(_textureAtlas, _animations);

			addChild(_mcSequences[_firstAnimation]);
			Starling.juggler.add(_mcSequences[_firstAnimation]);
			_mcSequences[_firstAnimation].loop = _firstAnimLoop;

			_previousAnimation = _firstAnimation;
		}

		/**
		 * It may be useful to add directly a MovieClip instead of a Texture Atlas to enable its manipulation like an animation's reversion for example.
		 * Be careful, if you <code>clone</code> the AnimationSequence it's not taken into consideration.
		 * @param mc a MovieClip you would like to use.
		 * @param animation the object's animation name as a String you would like to pick up.
		 */
		public function addMovieClip(mc:starling.display.MovieClip, animation:String):void {

			if ((_mcSequences[animation]))
				throw new Error(this + " already have the " + animation + " animation set up in its animations' array");

			_mcSequences[animation] = mc;
			_mcSequences[animation].name = animation;
			_mcSequences[animation].addEventListener(Event.COMPLETE, _animationComplete);
			_mcSequences[animation].smoothing = _smoothing;
			_mcSequences[animation].fps = _animFps;
		}

		/**
		 * If you need more than one TextureAtlas for your character's animations, use this function. 
		 * Be careful, if you <code>clone</code> the AnimationSequence it's not taken into consideration.
		 * @param textureAtlas a TextureAtlas object with your object's animations you would like to use.
		 * @param animations an array with the object's animations as a String you would like to pick up.
		 */
		public function addTextureAtlasWithAnimations(textureAtlas:*, animations:Array):void {

			for each (var animation:String in animations) {

				if (textureAtlas.getTextures(animation).length == 0)
					throw new Error(textureAtlas + " doesn't have the " + animation + " animation in its TextureAtlas");

				_mcSequences[animation] = new starling.display.MovieClip(textureAtlas.getTextures(animation), _animFps);

				_mcSequences[animation].name = animation;
				_mcSequences[animation].addEventListener(Event.COMPLETE, _animationComplete);
				_mcSequences[animation].smoothing = _smoothing;
			}
		}

		/**
		 * You may want to remove animations from the AnimationSequence, use this function.
		 * Be careful, if you <code>clone</code> the AnimationSequence it's not taken into consideration.
		 * @param animations an array with the object's animations as a String you would like to remove.
		 */
		public function removeAnimations(animations:Array):void {

			for each (var animation:String in animations) {

				if (!(_mcSequences[animation]))
					throw new Error(this.parent.name + " doesn't have the " + animation + " animation set up in its animations' array");

				_mcSequences[animation].removeEventListener(Event.COMPLETE, _animationComplete);
				_mcSequences[animation].dispose();

				delete _mcSequences[animation];
			}
		}
		
		public function removeAllAnimations():void
		{
			removeAnimations(_animations);
		}

		/**
		 * Called by StarlingArt, managed the MC's animations.
		 * @param animation the MC's animation
		 * @param animLoop true if the MC is a loop
		 */
		public function changeAnimation(animation:String, animLoop:Boolean):void {

			if (!(_mcSequences[animation]))
				throw new Error(this.parent.name + " doesn't have the " + animation + " animation set up in its animations' array");

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

			removeAllAnimations();

			_mcSequences = null;
		}

		/**
		 * A dictionary containing all animations registered thanks to their string name.
		 */
		public function get mcSequences():Dictionary {
			return _mcSequences;
		}
		
		/**
		 * creates an AnimationSequence from a flash movie clip
		 * different animations should be in separate flash movie clips,
		 * each should have their name set to whatever animation they represent.
		 * all of those moviesclips should be added as children,in the first frame,
		 * to the movie clip provided as an argument to this function so that
		 * DynamicAtlas will run through each children, create animations for each
		 * with their name as animation names to be used in the AnimationSequence that gets returned.
		 * For more info, check out the Dynamic Texture Atlas Extension and how it renders texture atlases.
		 * @param	mc flash movie clip instance containing instances of movie clip animations
		 * @param	firstAnim the name of the first animation to be played
		 * @param	animFps fps of the AnimationSequence
		 * @param	firstAnimLoop should the first animation loop?
		 * @param	smoothing
		 * @return
		 */
		public static function fromMovieClip(mc:flash.display.Sprite,firstAnim:String = null,animFps:int = 30, firstAnimLoop:Boolean = true,smoothing:String = "bilinear"):AnimationSequence
		{
			var textureAtlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc, 1, 0, true, true);
			var textureAtlasNames:Vector.<String> = textureAtlas.getNames();
			
			var sorter:Object = { };
			
			for each (anim in textureAtlasNames)
			{
				anim = anim.split("_")[0];
				if (!(anim in sorter))
					sorter[anim+"_"] = true;
			}
			
			var anims:Array = [];
			var anim:String;
			
			for (anim in sorter)
				anims.push(anim.substring(0, anim.length - 1));
				
			return new AnimationSequence(textureAtlas, anims,(firstAnim in sorter)? firstAnim : anims[0], animFps, firstAnimLoop,smoothing);
		}
		
		/**
		 * returns a vector of all animation names in this AnimationSequence.
		 */
		public function getAnimationNames():Vector.<String>{
			var names:Vector.<String> = new Vector.<String>();
			var name:String;
			for (name in _mcSequences)
				names.push(name);
			return names;
		}

		/**
		 * Return a clone of the current AnimationSequence. Animations added via <code>addMovieClip</code> or <code>addTextureAtlasWithAnimations</code> aren't included.
		 */
		public function clone():AnimationSequence {
			return new AnimationSequence(_textureAtlas, _animations, _firstAnimation, _animFps, _firstAnimLoop, _smoothing);
		}

		private function _animationComplete(evt:Event):void {
			onAnimationComplete.dispatch((evt.target as starling.display.MovieClip).name);
		}
	}
}
