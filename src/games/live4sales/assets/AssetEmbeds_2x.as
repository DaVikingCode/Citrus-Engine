package games.live4sales.assets {
	
	/**
	 * @author Aymeric
	 */
	public class AssetEmbeds_2x {
		
		// Bitmaps
		[Embed(source="../embed/2x/yellowBackground.png")]
		public static const Background:Class;

		// Texture Atlas

		[Embed(source="../embed/games/live4sales/1x/defenders.xml", mimeType="application/octet-stream")]
		public static const DefendersConfig:Class;

		[Embed(source="../embed/games/live4sales/1x/defenders.png")]
		public static const DefendersPng:Class;

		[Embed(source="../embed/2x/worldYellow.xml", mimeType="application/octet-stream")]
		public static const WorldYellowConfig:Class;
		
		[Embed(source="../embed/2x/worldYellow.png")]
		public static const WorldYellowPng:Class;
	}
}
