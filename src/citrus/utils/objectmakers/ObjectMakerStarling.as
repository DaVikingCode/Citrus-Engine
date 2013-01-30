package citrus.utils.objectmakers {

	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.objects.CitrusSprite;
	import citrus.utils.objectmakers.tmx.TmxMap;
	import citrus.utils.objectmakers.tmx.TmxObject;
	import citrus.utils.objectmakers.tmx.TmxObjectGroup;
	import citrus.utils.objectmakers.tmx.TmxPropertySet;
	import citrus.utils.objectmakers.tmx.TmxTileSet;

	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;

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
		 * You can pass a custom-created MovieClip object into this method to auto-create CitrusObjects.
		 * This method looks at all the children of the MovieClip you passed in, and creates a CitrusObject with the
		 * x, y, width, height, name, and rotation of the of MovieClip.
		 * 
		 * <p>You may use the powerful Inspectable metadata tag : in your fla file, add the path to the libraries and 
		 * the swcs. Then create your MovieClip, right click on it and convert as a component. Inform the package and class. 
		 * You will have access to all its properties.</p>
		 * 
		 * <p>You can also add properties directly in your MovieClips, follow this step :</p>
		 * 
		 * <p>In order for this to properly create a CitrusObject from a MovieClip, the MovieClip needs to have a variable
		 * called <code>classPath</code> on it, which will provide, in String form, the full
		 * package and class name of the Citrus Object that it is supposed to create (such as "myGame.MyHero"). You can specify
		 * this in frame 1 of the MovieClip asset in Flash.</p>
		 * 
		 * <p>You can also initialize your CitrusObject's parameters by creating a "params" variable (of type Object)
		 * on your MovieClip. The "params" object will be passed into the newly created CitrusObject.</p>
		 * 
		 * <p>So, within the first frame of each child-MovieClip of the "layout" MovieClip,
		 * you should specify something like the following:</p>
		 * 
		 * <p><code>var classPath="citrus.objects.platformer.Hero";</code></p>
		 * 
		 * <p><code>var params={view: "Patch.swf", jumpHeight: 14};</code></p>
		 * 
		 * <p>This Starling version enables you to use a String for the view which is a texture name coming from your texture atlas.</p>
		 * 
		 * @param textureAtlas A TextureAtlas containing textures which are used in your level maker.
		 */
		public static function FromMovieClip(mc:MovieClip, textureAtlas:TextureAtlas, addToCurrentState:Boolean = true):Array {
			var a:Array = [];
			var n:Number = mc.numChildren;
			var child:MovieClip;
			for (var i:uint = 0; i < n; ++i) {
				child = mc.getChildAt(i) as MovieClip;
				if (child) {
					if (!child.className)
						continue;

					var objectClass:Class = getDefinitionByName(child.className) as Class;
					var params:Object = {};

					if (child.params)
						params = child.params;

					params.x = child.x;
					params.y = child.y;

					// We need to unrotate the object to get its true width/height. Then rotate it back.
					var rotation:Number = child.rotation;
					child.rotation = 0;
					params.width = child.width;
					params.height = child.height;
					child.rotation = rotation;

					params.rotation = child.rotation;

					// Adding properties from the component inspector
					for (var metatags:String in child) {
						if (metatags != "componentInspectorSetting" && metatags != "className") {
							params[metatags] = child[metatags];
						}
					}
					
					if (params.view) {
					
						var suffix:String = params.view.substring(params.view.length - 4).toLowerCase();
						if (!(suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg"))
							params.view = new Image(textureAtlas.getTexture(params.view));
					}

					var object:CitrusObject = new objectClass(child.name, params);
					a.push(object);
				}
			}

			if (addToCurrentState) {
				var ce:CitrusEngine = CitrusEngine.getInstance();
				for each (object in a) ce.state.add(object);
			}

			return a;
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

			for (var layer_num:uint = 0; layer_num < tmx.layers_ordered.length; ++layer_num) {
				
				var layer:String = tmx.layers_ordered[layer_num];
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
					
					// Polygon/Polyline support
					if (objectTmx.shapeType != null) {
						//params.shapeType = objectTmx.shapeType;
						params.points = objectTmx.points;
					}

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
