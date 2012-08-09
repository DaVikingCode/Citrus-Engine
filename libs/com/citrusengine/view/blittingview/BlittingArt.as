package com.citrusengine.view.blittingview {

	import com.citrusengine.math.MathVector;
	
	public class BlittingArt
	{
		/**
		 * The animation that is currently playing for this character
		 */
		public var currAnimation:AnimationSequence;
		
		/**
		 * Values can be "center" or "topLeft". Specifies the registration point for your art. Often, static images such as backgrounds
		 * are easier to place with "topLeft" registration, while physics objects are commonly represented with "center" registration.
		 */
		public var registration:String = "center";
		
		/**
		 * The x and y offset distance that the art will sit from the registration.
		 */
		public var offset:MathVector = new MathVector();
		
		/**
		 * A list of AnimationSequence objects associated with this character. Use addAnimation() to add a sequence to this array.
		 */
		public var sequences:Array = [];
		
		/**
		 * The visual layering value. Lower numbers appear below higher numbers. The Citrus Engine sets this in BlittingView.
		 */
		public var group:Number = 0;
		
		/**
		 * Stores the rank in the graphics' add-order. This is used as a second sorting parameter if the group param is equal for two objects.
		 */
		public var addIndex:Number = 0;
		
		/**
		 * The CitrusObject associated with this art object.
		 */
		public var citrusObject:Object;
		
		/**
		 * This is the graphical representation of your CitrusObject when using the Blitting view. a BlittingArt object
		 * should contain one or more AnimationSequences. If your object is does not need to animate (such as a background),
		 * you can simply pass in a class that creates your graphic. The class that you pass in must create a BitmapData object.
		 * @param	defaultGraphic For objects without aimation, you can pass in a single BitmapData class. Useful for creating
		 * backgrounds.
		 */
		public function BlittingArt(defaultGraphic:Class = null) 
		{
			if (defaultGraphic)
				addAnimation(new AnimationSequence(defaultGraphic));
		}
		
		public function initialize(citrusObject:Object):void
		{
			this.citrusObject = citrusObject;
		}
		
		/**
		 * Called by the CitrusEngine to play a particular animation.
		 */
		public function play(animationName:String):void
		{
			var newAnimation:AnimationSequence = getAnimationByName(animationName);
			if (!newAnimation || newAnimation.name == currAnimation.name)
				return;
			currAnimation = newAnimation;
			currAnimation.currFrame = 0;
		}
		
		/**
		 * Call this to add a new animation sequence to this BlittingArt object.
		 * @param	animationSequence An animation sequence that your character will use.
		 */
		public function addAnimation(animationSequence:AnimationSequence):void
		{
			sequences.push(animationSequence);
			if (!currAnimation)
				currAnimation = animationSequence;
		}
		
		/**
		 * Returns an animation sequence object that has the name that you provided.
		 */
		public function getAnimationByName(name:String):AnimationSequence
		{
			for each (var sequence:AnimationSequence in sequences)
			{
				if (sequence.name == name)
					return sequence;
			}
			return null;
		}
	}

}