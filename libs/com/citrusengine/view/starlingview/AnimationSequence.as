package com.citrusengine.view.starlingview {

	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.textures.TextureAtlas;

	import flash.utils.Dictionary;

	/**
	 * The Animation Sequence class represents all object animations in one sprite sheet. You have to create your texture atlas in your state class.
	 * Example : var hero:Hero = new Hero("Hero", {x:400, width:60, height:130, view:new AnimationSequence(textureAtlas, ["walk", "duck", "idle", "jump"], "idle")});
	 * 
	 * @param textureAtlas : a TextureAtlas object with all your object's animations
	 * @param animations : an array with all your object's animations as a String
	 * @param firstAnimation : a string of your default animation at its creation
	 * @param animFps : a number which determines the animation MC's fps
	 * @param firstAnimLoop : a boolean, set it to true if you want your first animation to loop
	 */
	public class AnimationSequence extends Sprite {

		private var _textureAtlas:TextureAtlas;
		private var _animations:Array;
		private var _mcSequences:Dictionary;
		private var _previousAnimation:String;

		public function AnimationSequence(textureAtlas:TextureAtlas, animations:Array, firstAnimation:String, animFps:Number = 30, firstAnimLoop:Boolean = false) {

			super();

			_textureAtlas = textureAtlas;

			_animations = animations;

			_mcSequences = new Dictionary();

			for each (var animation:String in animations) {
				
				if (_textureAtlas.getTextures(animation).length == 0) {
					throw new Error("One object doesn't have the " + animation + " animation in its TextureAtlas");
				}
				
				_mcSequences[animation] = new MovieClip(_textureAtlas.getTextures(animation));
				_mcSequences[animation].fps = animFps;
			}
			
			addChild(_mcSequences[firstAnimation]);
			Starling.juggler.add(_mcSequences[firstAnimation]);
			_mcSequences[firstAnimation].loop = firstAnimLoop;
				
			_previousAnimation = firstAnimation;			
		}
		
		/**
		 * Called by StarlingArt, managed the MC's animations.
		 * @param animation : the MC's animation
		 * @param fps : the MC's fps
		 * @param animLoop : true if the MC is a loop
		 */
		public function changeAnimation(animation:String, animLoop:Boolean):void {
			
			if (!(_mcSequences[animation])) {
				throw new Error("One object doesn't have the " + animation + " animation set up in its initial array");
				return;
			}
			
			removeChild(_mcSequences[_previousAnimation]);
			Starling.juggler.remove(_mcSequences[_previousAnimation]);
			
			addChild(_mcSequences[animation]);
			Starling.juggler.add(_mcSequences[animation]);
			_mcSequences[animation].loop = animLoop;
			_mcSequences[animation].currentFrame = 0;
			
			_previousAnimation = animation;
		}
		
		/**
		 * Called by StarlingArt, remove or add to the Juggler if the Citrus Engine is playing or not
		 */
		public function pauseAnimation(value:Boolean):void {
			
			value ? Starling.juggler.add(_mcSequences[_previousAnimation]) : Starling.juggler.remove(_mcSequences[_previousAnimation]);
		}
		
		public function destroy():void {
			
			removeChild(_mcSequences[_previousAnimation]);
			Starling.juggler.remove(_mcSequences[_previousAnimation]);
			
			for each (var animation : String in _animations)
				_mcSequences[animation].dispose();
			
			_mcSequences = null;
		}
	}
}
