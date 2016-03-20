package citrus.core.starling 
{
	public class ViewportMode 
	{
		/**
		 * The viewport will fit the screen as best as it can, keeping the original aspect ratio, thus leaving horizontal or vertical borders 
		 * where nothing will be rendered.
		 */
		public static const LETTERBOX:String = "LETTERBOX";
		
		/**
		 * The viewport will be centered, with the game's base dimensions.
		 */
		public static const NO_SCALE:String = "NO_SCALE";
		
		/**
		 * The viewport will be as wide and tall as the screen, but the stage will be the base width and height dimensions, extended
		 * horizontally or vertically to keep the aspect ratio. This mode corresponds to Strategy 3 on the multiresolution wiki article for starling.
		 */
		public static const FULLSCREEN:String = "FULLSCREEN";
		
		/**
		 * Legacy mode will make the viewport fill the screen as well as set the starling stage dimensions to the flash stage dimensions
		 * as what used to happen by default in CE prior to 3.1.8.
		 */
		public static const LEGACY:String = "LEGACY";
		
		/**
		 * Manual mode :
		 * if the StarlingCitrusEngine.viewport rectangle is not defined, it will be defined as the flash stageWidth/stageHeight.
		 * if you have defined it in your StarlingCitrusEngine, it will be used as the starling viewport and you are in charge of defining its position or the starling stage dimensions.
		 */
		public static const MANUAL:String = "MANUAL";
	}

}