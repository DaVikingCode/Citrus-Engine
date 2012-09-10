package games.live4sales.assets {
	
	/**
	 * @author Aymeric
	 */
	public class AssetEmbeds_2x {
		
		// Bitmaps

		// Texture Atlas

		[Embed(source="/../embed/games/live4sales/2x/objects.xml", mimeType="application/octet-stream")]
		public static const ObjectsConfig:Class;

		[Embed(source="/../embed/games/live4sales/2x/objects.png")]
		public static const ObjectsPng:Class;

		[Embed(source="/../embed/games/live4sales/2x/menu.xml", mimeType="application/octet-stream")]
		public static const MenuConfig:Class;
		
		[Embed(source="/../embed/games/live4sales/2x/menu.png")]
		public static const MenuPng:Class;
	}
}
