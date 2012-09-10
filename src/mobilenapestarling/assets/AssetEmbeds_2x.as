package mobilenapestarling.assets {
	
	/**
	 * @author Aymeric
	 */
	public class AssetEmbeds_2x {
		
		// Bitmaps
		[Embed(source="/../embed/2x/yellowBackground.png")]
		public static const Background:Class;

		// Texture Atlas

		[Embed(source="/../embed/2x/heroMobile.xml", mimeType="application/octet-stream")]
		public static const HeroConfig:Class;

		[Embed(source="/../embed/2x/heroMobile.png")]
		public static const HeroPng:Class;

		[Embed(source="/../embed/2x/worldYellow.xml", mimeType="application/octet-stream")]
		public static const WorldYellowConfig:Class;
		
		[Embed(source="/../embed/2x/worldYellow.png")]
		public static const WorldYellowPng:Class;
	}
}
