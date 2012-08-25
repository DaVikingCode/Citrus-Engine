package games.live4sales.assets {

	/**
	 * @author Aymeric
	 */
	public class AssetEmbeds_1x {

		// Bitmaps
		[Embed(source="../embed/1x/yellowBackground.png")]
		public static const Background:Class;

		// Texture Atlas

		[Embed(source="../embed/games/live4sales/1x/defenders.xml", mimeType="application/octet-stream")]
		//[Embed(source="../embed/Hero.xml", mimeType="application/octet-stream")]
		public static const DefendersConfig:Class;

		[Embed(source="../embed/games/live4sales/1x/defenders.png")]
		//[Embed(source="../embed/Hero.png")]
		public static const DefendersPng:Class;

		[Embed(source="../embed/1x/worldYellow.xml", mimeType="application/octet-stream")]
		public static const WorldYellowConfig:Class;
		
		[Embed(source="../embed/1x/worldYellow.png")]
		public static const WorldYellowPng:Class;

		// Bitmap Fonts
        
		/*[Embed(source="../media/fonts/1x/desyrel.fnt", mimeType="application/octet-stream")]
		public static const DesyrelXml:Class;
        
		[Embed(source = "../media/fonts/1x/desyrel.png")]
		public static const DesyrelTexture:Class;*/
	}
}
