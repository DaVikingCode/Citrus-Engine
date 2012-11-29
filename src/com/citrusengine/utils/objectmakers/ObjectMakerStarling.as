package com.citrusengine.utils.objectmakers {

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.utils.objectmakers.tmx.TmxMap;
	import com.citrusengine.utils.objectmakers.tmx.TmxObject;
	import com.citrusengine.utils.objectmakers.tmx.TmxObjectGroup;
	import com.citrusengine.utils.objectmakers.tmx.TmxPropertySet;
	import com.citrusengine.utils.objectmakers.tmx.TmxTileSet;

	import flash.utils.getDefinitionByName;

	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/**
	 * The ObjectMaker is a factory utility class for quickly and easily batch-creating a bunch of CitrusObjects.
	 * Usually the ObjectMaker is used if you laid out your level in a level editor or an XML file.
	 * Pass in your layout object (SWF, XML, or whatever else is supported in the future) to the appropriate method,
	 * and the method will return an array of created CitrusObjects.
	 * 
	 * <p>The methods within the ObjectMaker should be called according to what kind of layout file that was created
	 * by your level editor.</p>
	 */
	public class ObjectMakerStarling {

		public function ObjectMakerStarling() {
		}

		/**
		 * The Citrus Engine supports <a href="http://www.mapeditor.org/">the Tiled Map Editor</a>.
		 * <p>It supports different layers, objects creation and a Tilesets.</p>
		 * 
		 * <p>You can add properties inside layers (group, parallax...), they are processed as Citrus Sprite.</p>
		 * 
		 * <p>For the objects, you can add their name and don't forget their types : package name + class name. 
		 * It also supports properties.</p>
		 * @param levelXML the TMX provided by the Tiled Map Editor software, convert it into an xml before.
		 * @param atlas an atlas which represent the different tiles, you must name each tile with the corresponding texture name.
		 */
		public static function FromTiledMap(levelXML:XML, atlas:TextureAtlas, addToCurrentState:Boolean = true):Array {

			var ce:CitrusEngine = CitrusEngine.getInstance();
			var params:Object;

			var objects:Array = [];

			var tmx:TmxMap = new TmxMap(levelXML);

			var citrusSprite:CitrusSprite;

			var mapTiles:Array;
			var mapTilesX:uint, mapTilesY:uint;

			for (var layer:String in tmx.layers) {

				mapTiles = tmx.getLayer(layer).tileGIDs;

				mapTilesX = mapTiles.length;

				var qb:QuadBatch = new QuadBatch();

				for each (var tileSet:TmxTileSet in tmx.tileSets) {

					for (var i:uint = 0; i < mapTilesX; ++i) {

						mapTilesY = mapTiles[i].length;

						for (var j:uint = 0; j < mapTilesY; ++j) {

							if (mapTiles[i][j] != 0) {

								var tileID:uint = mapTiles[i][j];
								var tileProps:TmxPropertySet = tileSet.getProperties(tileID - 1);
								var name:String = tileProps["name"];
								// TODO : look into an other atlas if the texture isn't found.
								var texture:Texture = atlas.getTexture(name);

								var image:Image = new Image(texture);
								image.x = j * tmx.tileWidth;
								image.y = i * tmx.tileWidth;

								qb.addImage(image);
							}
						}
					}
				}

				params = {};

				params.view = qb;

				for (var param:String in tmx.getLayer(layer).properties)
					params[param] = tmx.getLayer(layer).properties[param];

				citrusSprite = new CitrusSprite(layer, params);
				objects.push(citrusSprite);
			}

			var objectClass:Class;
			var object:CitrusObject;

			for each (var group:TmxObjectGroup in tmx.objectGroups) {

				for each (var objectTmx:TmxObject in group.objects) {

					objectClass = getDefinitionByName(objectTmx.type) as Class;

					params = {};

					for (param in objectTmx.custom)
						params[param] = objectTmx.custom[param];

					params.x = objectTmx.x + objectTmx.width * 0.5;
					params.y = objectTmx.y + objectTmx.height * 0.5;
					params.width = objectTmx.width;
					params.height = objectTmx.height;

					object = new objectClass(objectTmx.name, params);
					objects.push(object);
				}
			}

			if (addToCurrentState)
				for each (object in objects) ce.state.add(object);

			return objects;
		}
	}
}
