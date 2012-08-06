package com.citrusengine.view
{
	/**
	 * The ISpriteView interface provides a common interface between a CitrusObject and the SpriteView view manager.
	 * All objects that need to have graphical representations on screen need to implement this, if your
	 * objects are in a state that uses the CitrusView as its view (most common). Often, especially
	 * when working with Box2D, game object units will be different than than view object units.
	 * In Box2D, units are in meters, but graphics are rendered in pixels.
	 * Citrus Engine does not put a requirement on whether the game logic or the view manager should
	 * perform the conversion. 
	 * If you desire the game logic to perform the unit conversion, the values should be multiplied by
	 * [commonly] 30 before being returned in order to convert the meter values to pixel values.
	 */	
	public interface ISpriteView
	{
		/**
		 * The x position of the object. 
		 */	
		function get x():Number;
		
		/**
		 * The y position of the object. 
		 */
		function get y():Number;
		
		/**
		 * The ratio at which the object scrolls in relation to the camera.
		 */
		function get parallax():Number;
		
		/**
		 * The rotation value of the object.
		 * <p>Commonly, flash uses degrees to display art rotation, but game logic is usually in radians.
		 * If a conversion is necessary and you choose the game object to perform the conversion rather than
		 * the view manager, then you will want to perform your conversion here.</p>
		 */
		function get rotation():Number;
		
		/**
		 * The group property specifies the depth sorting. Objects placed in group 1 will be behind objects placed in group 2.
		 * Note that groups and parallax are unrelated, so be careful not to have an object have a lower parallax value than an object 
		 * in a group below it.
		 */
		function get group():Number;
		
		/**
		 * The visibility of the object. 
		 */
		function get visible():Boolean;
		
		/**
		 * This is where you specify what your graphical representation of your CitrusObject will be.
		 * 
		 * <p>You can specify your <code>view</code> value in multiple ways:</p>
		 * 
		 * <p>If you want your graphic to be a SWF, PNG, or JPG that
		 * is loaded at runtime, then assign <code>view</code> a String URL relative to your game's SWF, just like you would
		 * if you were loading any file in Flash. (graphic = "graphics/Hero.swf")
		 * 
		 * <p>If your graphic is embeddeded into the SWF, you can assign the <code>view</code> property in two ways: Either by package string
		 * notation (view = "com.myGame.MyHero"), or by using a direct class reference (graphic = MyHero). The first method, String notation, is useful
		 * when you are using a level editor such as the Flash IDE or GLEED2D because all data must come through in String form. However, if you
		 * are hardcoding your graphic class, you can simply pass a direct reference to the class.
		 * Whichever way you specify your class, your class must be (on some level) a <code>DisplayObject</code>.</p>
		 * 
		 * <p>Also note that you CANNOT assign the <code>view</code> property to a display object that you made. You must specify either an 
		 * external URL or a Class.
		 * 
		 * <p>If you are using a level editor and using the ObjectMaker to batch-create your
		 * CitrusObjects, you will need to specify the entire classpath in string form and let the factory turn your string
		 * into an actual class. Also, the class definition (MyHeroGraphic, for example) will need to be compiled into your code
		 * somewhere, otherwise the game will not be able to get the class definition from a String.</p>
		 * 
		 * <p>If your graphic is an external file such as a PNG, JPG, or SWF, you can provide the path to the file (either an absolute path,
		 * or a relative path from your HTML file or SWF). The SpriteView will detect that it is an external file and
		 * load the file using the ExternalArt class.</p>
		 */
		function get view():*;
		
		/**
		 * A string representing the current animation state that your object is in, such as "run", "jump", "attack", etc.
		 * The SpriteView checks this property every frame and, if your graphic is a SWF, attemps to "gotoAndPlay()" to a
		 * label with the name of the <code>animation</code> property.
		 * 
		 * If you want your graphic to not loop, you should call stop() on the last frame of your animation from within your SWF file.
		 */
		function get animation():String;
		
		/**
		 * If true, the view will invert your graphic. This is common in side-scrolling games so that you don't have to draw
		 * right-facing and left-facing versions of all your graphics. If you are using the inverted property to invert your
		 * graphics, make sure you set your registration to "center" or the graphic will flip like a page turning instead of a card
		 * flipping. 
		 */
		function get inverted():Boolean;
		
		/**
		 * The x offset from the graphic's registration point.
		 */
		function get offsetX():Number;
		
		/**
		 * The y offset from the graphic's registration point.
		 */
		function get offsetY():Number;
		
		/**
		 * Specify either "topLeft" or "center" to position your graphic's registration. Please note that this is
		 * only useful for graphics that are loaded dynamically at runtime (PNGs, SWFs, and JPGs). If you are embedding
		 * your art, you should handle the registration in your embedded class.
		 */
		function get registration():String;
	}
}