package citrus.utils.objectmakers {

	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.core.IState;
	import citrus.objects.CitrusSprite;
	import citrus.utils.objectmakers.tmx.TmxMap;
	import citrus.utils.objectmakers.tmx.TmxObject;
	import citrus.utils.objectmakers.tmx.TmxObjectGroup;
	import citrus.utils.objectmakers.tmx.TmxTileSet;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
	public class ObjectMaker2D {

		public function ObjectMaker2D() {
		}

		/**
		 * You can pass a custom-created MovieClip object into this method to auto-create CitrusObjects.
		 * This method looks at all the children of the MovieClip you passed in, and creates a CitrusObject with the
		 * x, y, width, height, name, and rotation of the of MovieClip.
		 * 
		 * <p>You may use the powerful Inspectable metadata tag : in your fla file, add the path to the libraries and 
		 * the swcs. Then create your MovieClip, right click on it and convert as a component. Inform the package and class. 
		 * You will have access to all its properties. Don't forget to put the className with path!</p>
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
		 */
		public static function FromMovieClip(mc:MovieClip, addToCurrentState:Boolean = true):Array {
			var a:Array = [];
			var n:Number = mc.numChildren;
			var child:MovieClip;
			for (var i:int = 0; i < n; i++) {
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
					for (var metatags:Object in child) {
						if (metatags != "componentInspectorSetting" && metatags != "className") {
							params[metatags] = child[metatags];
						}
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
		 * @param images an array of bitmap used by tileSets. The name of the bitmap must correspond to the tileSet image source name.
		 */
		public static function FromTiledMap(levelXML:XML, images:Array, addToCurrentState:Boolean = true):Array {

			var ce:CitrusEngine = CitrusEngine.getInstance();
			var params:Object;

			var objects:Array = [];

			var tmx:TmxMap = new TmxMap(levelXML);

			var bmp:Bitmap;
			var bmpData:BitmapData;
			var citrusSprite:CitrusSprite;

			var mapTiles:Array;

			var rectangleSelection:Rectangle = new Rectangle();
			rectangleSelection.width = tmx.tileWidth;
			rectangleSelection.height = tmx.tileHeight;

			var pt:Point = new Point();

			var mapTilesX:uint, mapTilesY:uint;

			for (var layer:String in tmx.layers) {

				mapTiles = tmx.getLayer(layer).tileGIDs;

				mapTilesX = mapTiles.length;

				bmpData = new BitmapData(tmx.width * tmx.tileWidth, tmx.height * tmx.tileHeight, true, 0);
				bmpData.lock();

				for each (var tileSet:TmxTileSet in tmx.tileSets) {

					for each (var image:Bitmap in images) {
						if (tileSet.imageSource == image.name) {
							bmp = image;
							break;
						} else throw new Error("ObjectMaker didn't find an image name corresponding to the tileset imagesource name, add its name to your bitmap.");
					}

					tileSet.image = bmp.bitmapData;

					for (var i:uint = 0; i < mapTilesX; ++i) {

						mapTilesY = mapTiles[i].length;

						for (var j:uint = 0; j < mapTilesY; ++j) {

							if (mapTiles[i][j] != 0) {

								if (mapTiles[i][j] <= tileSet.numCols) {

									rectangleSelection.x = mapTiles[i][j] * tmx.tileWidth - tmx.tileWidth;
									rectangleSelection.y = 0;

								} else {

									var modulo:uint = mapTiles[i][j] % tileSet.numCols;

									rectangleSelection.x = modulo * tmx.tileWidth - tmx.tileWidth;

									rectangleSelection.y = Math.floor(mapTiles[i][j] / tileSet.numCols) * tmx.tileHeight;
								}

								pt.x = j * tmx.tileWidth;
								pt.y = i * tmx.tileHeight;

								bmpData.copyPixels(bmp.bitmapData, rectangleSelection, new Point(pt.x, pt.y));
							}
						}

						bmpData.unlock();
					}
				}

				params = {};

				params.view = new Bitmap(bmpData);

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

		/**
		 * This batch-creates CitrusObjects from an XML file generated by the level editor GLEED2D. If you would like to 
		 * use GLEED2D as a level editor for your Citrus Engine game, call this function to parse your GLEED2D level.
		 * 
		 * <p>When using GLEED2D, there are a few things to note:
		 * <ul>
		 * <li> You must add a custom property named 'className' for each object you make, unless it will be of the type
		 * specified in the <code>defaultClassName</code> parameter. Assign this property a value
		 * that represents the class that you want that object to be. For example, if you wanted to make a hero, you must
		 * give your GLEED2D Hero 'className' property the value 'citrus.objects.platformer.Hero'. Don't forget
		 * to include the package, or the Citrus Engine won't be able to make your object.</li>
		 * <li> You can shift-click and drag to duplicate GLEED2D objects. This is the easiest way to copy an entire object,
		 * custom-properties and all.</li>
		 * <li> Unfortunately, GLEED2D does not support rotating the Rectangle Primitive, this makes GLEED2D difficult to use
		 * if you plan on using it to layout levels for a platformer with hills. You can, however, specify a custom property
		 * named "rotation", which will work in Citrus Engine, but not be reflected in GLEED2D.</li>
		 * <li> GLEED2D does not support SWFs as textures, so any CitrusObjects that will use SWFs as their view should
		 * be created via a GLEED2D rectangle primitive, then specify the SWF path or MovieClip class name using a custom
		 * property named 'view'.
		 * </li>
		 * </ul>
		 * </p>
		 * 
		 * @param levelXML An XML level object created by GLEED2D.
		 * @param addToCurrentState Automatically adds all CitrusObjects that get created to the current state.
		 * @param layerIndexProperty Gleed's layer indexes will be assigned to the specified property.
		 * @param defaultClassName If a className custom property is not specified on a GLEED2D asset, this is the default CitrusObject class that gets created.
		 * @return An array of CitrusObjects. If the <code>addToCurrentState</code> property is false, you will still need to add these to the state.
		 * 
		 */
		public static function FromGleed(levelXML:XML, addToCurrentState:Boolean = true, layerIndexProperty:String = "group", defaultClassName:String = "citrus.objects.CitrusSprite"):Array {
			var layerIndex:uint = 0;
			var items:Array = [];
			var object:Object;
			var objectName:String;
			var ce:CitrusEngine = CitrusEngine.getInstance();
			for each (var layerXML:XML in levelXML.Layers.Layer) // Loop through all layers
			{
				for each (var itemXML:XML in layerXML.Items.Item) // Loop through all items on a layer
				{
					// Grab the XML properties we want off of the item node.
					objectName = itemXML.@Name.toString();
					var x:Number = itemXML.Position.X.toString();
					// Top for primitives, center for textures
					var y:Number = itemXML.Position.Y.toString();
					// Left for primitives, center for textures

					// See if this object has a texture
					var viewString:String = itemXML.texture_filename.toString();
					if (viewString != "") {
						// Create known params for a GLEED2D "texture"
						var originX:Number = itemXML.Origin.X.toString();
						var originY:Number = itemXML.Origin.Y.toString();
						var rotation:Number = Number(itemXML.Rotation.toString()) * 180 / Math.PI;
						object = {x:x, y:y, width:originX * 2, height:originY * 2, rotation:rotation, registration:"center"};
						viewString = Replace(viewString, "\\", "/");
						// covert backslashes to forward slashes
						object.view = viewString;
					} else {
						// Create known params for a GLEED2D "primitive"
						var width:Number = itemXML.Width.toString();
						var height:Number = itemXML.Height.toString();

						object = {x:x + (width / 2), y:y + (height / 2), width:width, height:height};
					}

					// Covert GLEED layer index to a property on the object.
					if (layerIndexProperty)
						object[layerIndexProperty] = layerIndex;

					// Add the custom properties
					var className:String = defaultClassName;
					for each (var customPropXML:XML in itemXML.CustomProperties.Property) {
						if (customPropXML.@Name.toString() == "className")
							className = customPropXML.string.toString();
						else
							object[customPropXML.@Name.toString()] = customPropXML.string.toString();
					}

					// Make the CitrusObject and add it to the current state.
					var citrusClass:Class = getDefinitionByName(className) as Class;
					var citrusObject:CitrusObject = new citrusClass(objectName, object);
					if (addToCurrentState)
						ce.state.add(citrusObject);

					items.push(citrusObject);
				}
				layerIndex++;
			}
			return items;
		}

		/**
		 * This function batch-creates Citrus Engine game objects from an XML file generated by the Level Architect.
		 * If you are using the Level Architect as your level editor, call this function to parse the objects in
		 * your Level Architect level.
		 * 
		 * @param	levelData The XML file (.lev) that the Level Architect generates.
		 * @param	addToCurrentState If true, the objects that are created will get added to the current state's object list.
		 * @return Returns an array containing all the objects that were created via this function.
		 */
		public static function FromLevelArchitect(levelData:XML, addToCurrentState:Boolean = true):Array {
			var array:Array = [];

			var state:IState = CitrusEngine.getInstance().state;
			for each (var objectXML:XML in levelData.CitrusObject) {
				var params:Object = {};
				for each (var paramXML:XML in objectXML.Property) {
					params[paramXML.@name] = paramXML.toString();
				}
				var className:String = objectXML.@className;
				try {
					var theClass:Class = getDefinitionByName(className) as Class;
				} catch (e:Error) {
					if (e.errorID == 1065) {
						throw new Error("You (yes, YOU) must import and create a reference to the " + className + " class somewhere in your code. The Level Architect cannot create objects unless they are compiled into the SWF.");
					} else {
						throw e;
					}
				}
				var theObject:CitrusObject = new theClass(objectXML.@name, params);
				array.push(theObject);
				if (addToCurrentState)
					state.add(theObject);
			}

			return array;
		}

		private static function Replace(str:String, fnd:String, rpl:String):String {
			return str.split(fnd).join(rpl);
		}
	}
}