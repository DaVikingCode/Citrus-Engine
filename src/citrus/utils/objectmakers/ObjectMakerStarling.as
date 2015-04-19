package citrus.utils.objectmakers {
	
	import citrus.utils.objectmakers.tmx.TmxLayer;
	import flash.geom.Point;
	import flash.geom.Matrix;
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
	import starling.utils.Color;
	
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
		 * @param textureAtlas A TextureAtlas or an AssetManager object containing textures which are used in your level maker.
		 */
		public static function FromMovieClip(mc:MovieClip, textureAtlas:*, addToCurrentState:Boolean = true, forceFrame:uint = 1):Array {
		
			//force mc to given frame to avoid undefined properties defined in action frames.
			mc.gotoAndStop(forceFrame);
			
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
					
					if (params.view && !(params.view is Image)) {
						
						var suffix:String = params.view.substring(params.view.length - 4).toLowerCase();
						if (!(suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg")) {
							if (textureAtlas)
								params.view = new Image(textureAtlas.getTexture(params.view));
							else
								throw new Error("ObjectMakerStarling FromMovieClip function needs a TextureAtlas or a reference to an AssetManager!");
						}
					}
					
					var object:CitrusObject = new objectClass(child.name, params);
					a.push(object);
				}
			}
			
			if (addToCurrentState) {
				var ce:CitrusEngine = CitrusEngine.getInstance();
				for each (object in a)
					ce.state.add(object);
			}
			
			return a;
		}
		
		/**
		 * The Citrus Engine supports <a href="http://www.mapeditor.org/">the Tiled Map Editor</a>.
		 * <p>It supports different layers, objects creation and a Tilesets.</p>
		 *
		 * <p>You can add properties inside layers (group, parallax...), they are processed as Citrus Sprite.</p>
		 * <p>Polygons are supported but must be drawn clockwise in TiledMap editor to work correctly.</p>
		 *
		 * <p>For the objects, you can add their name and don't forget their types : package name + class name.
		 * It also supports properties.</p>
		 * @param levelXML the TMX provided by the Tiled Map Editor software, convert it into an xml before.
		 * @param atlas an atlas or a reference to an AssetManager which represent the different tiles, you must name each tile with the corresponding texture name.
		 */
		public static function FromTiledMap(levelXML:XML, atlas:*, addToCurrentState:Boolean = true):Array {
			var objects:Array = [];
			var tmx:TmxMap = new TmxMap(levelXML);
			
			for each (var layer:Object in tmx.layers_ordered) {
				if (layer is TmxLayer) {
					addTiledLayer(tmx, atlas, layer as TmxLayer, objects);
				} else if (layer is TmxObjectGroup) {
					addTiledObjectgroup(tmx, atlas, layer as TmxObjectGroup, objects);
				}
			}
			
			const ce:CitrusEngine = CitrusEngine.getInstance();
			if (addToCurrentState)
				for each (var object:CitrusObject in objects)
					ce.state.add(object);
			
			return objects;
		}
		
		static private function addTiledLayer(tmx:TmxMap, atlas:*, layer:TmxLayer, objects:Array):void {
			var mapTiles:Array = layer.tileGIDs;
			var mapTilesX:uint = mapTiles.length;
			var mapTilesY:uint;
			
			var tileSet:TmxTileSet;
			var tileProps:TmxPropertySet;
			var name:String;
			var texture:Texture;
			
			var qb:QuadBatch = new QuadBatch();
			
			for (var i:uint = 0; i < mapTilesX; ++i) {
				
				mapTilesY = mapTiles[i].length;
				
				for (var j:uint = 0; j < mapTilesY; ++j) {
					
					if (mapTiles[i][j] != 0) {
						
						var tileID:uint = mapTiles[i][j];
						
						for each (tileSet in tmx.tileSets) {
							tileProps = tileSet.getProperties(tileID - tileSet.firstGID);
							if (tileProps != null)
								break;
						}
						name = tileProps["name"];
						
						texture = atlas.getTexture(name);
						
						var image:Image = new Image(texture);
						image.x = j * tmx.tileWidth;
						image.y = i * tmx.tileHeight;
						
						qb.addImage(image);
					}
				}
			}
			
			var params:Object = {};
			params.view = qb;
			
			for (var param:String in layer.properties) {
				params[param] = layer.properties[param];
			}
			
			objects.push(new CitrusSprite(layer.name, params));
		}
		
		static private function addTiledObjectgroup(tmx:TmxMap, atlas:*, group:TmxObjectGroup, objects:Array):void {
			var objectClass:Class;
			var object:CitrusObject;
			
			var tileSet:TmxTileSet;
			var tileProps:TmxPropertySet;
			var name:String;
			
			var mtx:Matrix = new Matrix();
			var pt:Point = new Point();
			var newLoc:Point;
			var objectTmx:TmxObject;
			
			for each (objectTmx in group.objects) {
				
				objectClass = getDefinitionByName(objectTmx.type) as Class;
				var params:Object = {};
				
				for (var param:String in objectTmx.custom) {
					params[param] = objectTmx.custom[param];
				}
				
				params.x = objectTmx.x + objectTmx.width * 0.5;
				params.y = objectTmx.y + objectTmx.height * 0.5;
				params.width = objectTmx.width;
				params.height = objectTmx.height;
				params.rotation = objectTmx.rotation;
				
				if (params.rotation != 0) {
					mtx.identity();
					mtx.rotate(objectTmx.rotation * Math.PI / 180); 
					pt.setTo(objectTmx.width / 2, objectTmx.height / 2);
					newLoc = mtx.transformPoint(pt);
					params.x = objectTmx.x + newLoc.x;
					params.y = objectTmx.y + newLoc.y;
				}
				
				if (objectTmx.custom && objectTmx.custom["view"]) {
					params.view = atlas.getTexture(objectTmx.custom["view"]);
					
				} else if (objectTmx.gid != 0) { // for handling image objects in Tiled
					for each (tileSet in tmx.tileSets) {
						tileProps = tileSet.getProperties(objectTmx.gid - tileSet.firstGID);
						if (tileProps != null)
							break;
					}
					name = tileProps["name"];
					params.view = atlas.getTexture(name);
					params.width = Texture(params.view).frame.width;
					params.height = Texture(params.view).frame.height;
					params.x += params.width / 2;
					params.y -= params.height / 2;
				}
				
				// Polygon/Polyline support
				if (objectTmx.shapeType != null) {
					params.shapeType = objectTmx.shapeType;
					params.points = objectTmx.points;
				}
				
				object = new objectClass(objectTmx.name, params);
				objects.push(object);
			}
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
		 * @param textureAtlas An TextureAtlas that provides all texture within the level. (Note this function supports only single atlas)
		 * @param addToCurrentState Automatically adds all CitrusObjects that get created to the current state.
		 * @param layerIndexProperty Gleed's layer indexes will be assigned to the specified property.
		 * @param defaultClassName If a className custom property is not specified on a GLEED2D asset, this is the default CitrusObject class that gets created.
		 * @return An array of CitrusObjects. If the <code>addToCurrentState</code> property is false, you will still need to add these to the state.
		 *
		 */
		public static function FromGleed(levelXML:XML, textureAtlas:TextureAtlas, addToCurrentState:Boolean = true, layerIndexProperty:String = "group", defaultClassName:String = "citrus.objects.CitrusSprite"):Array {
			var objects:Array = [];
			var citrusObject:CitrusObject;
			var xsiNS:Namespace = new Namespace("xsi", "http://www.w3.org/2001/XMLSchema-instance");
			var ce:CitrusEngine = CitrusEngine.getInstance();
			
			for each (var layerXML:XML in levelXML.Layers.Layer) // Loop through all layers
			{
				var textureItems:Vector.<Image> = new Vector.<Image>;
				var layer:String = layerXML.@Name.toString();
				
				for each (var itemXML:XML in layerXML.Items.Item) // Loop through all items on a layer
				{
					var object:Object = {};
					var objectName:String = itemXML.@Name.toString();
					var x:Number = itemXML.Position.X.toString();
					var y:Number = itemXML.Position.Y.toString();
					var type:String = itemXML.@xsiNS::type.toString();
					var assetString:String = itemXML.asset_name.toString();
					var className:String = defaultClassName;
					
					// Let's add custom properties
					for each (var customPropXML:XML in itemXML.CustomProperties.Property) {
						if (customPropXML.@Name.toString() == "className")
						{
							className = customPropXML.string.toString();
						}
						else
						{
							object[customPropXML.@Name.toString()] = customPropXML.string.toString();
						}
					}
					
					// Let's strip the filename from the texturepath. This is going to be the atlas alias for this texture
					assetString = assetString.substr(assetString.lastIndexOf("\\") + 1, assetString.length);
					if (assetString)
						object.assetString = assetString;
					
					// If the item is just a TextureItem without any specified class, we will add it to the quadbatch which represents the layer
					if (className == defaultClassName && type == "TextureItem" && assetString != "") {
						var originX:Number = itemXML.Origin.X.toString();
						var originY:Number = itemXML.Origin.Y.toString();
						var scaleX:Number = itemXML.Scale.X.toString();
						var scaleY:Number = itemXML.Scale.Y.toString();
						var rotation:Number = Number(itemXML.Rotation.toString());
						
						// Flip
						var flipHorizontally:String = itemXML.FlipHorizontally.toString();
						var flipVertically:String = itemXML.FlipVertically.toString();
						if (flipHorizontally == "true")
							scaleX *= -1;
						if (flipVertically == "true")
							scaleY *= -1;
						
						// TintColor
						var r:int = itemXML.TintColor.R.toString();
						var g:int = itemXML.TintColor.G.toString();
						var b:int = itemXML.TintColor.B.toString();
						var a:int = itemXML.TintColor.A.toString();
						
						// Let's create the image that matches the asset string
						var image:Image = new Image(textureAtlas.getTexture(assetString));
						image.x = x;
						image.y = y;
						image.scaleX = scaleX;
						image.scaleY = scaleY;
						image.pivotX = originX;
						image.pivotY = originY;
						image.rotation = rotation;
						image.color = Color.argb(a, r, g, b);
						
						// And finally we collect these images for later batching
						textureItems.push(image);
					}
				}
				
				// We will bundle all TextureItems into single quadbatch
				if (textureItems.length > 0) {
					var qb:QuadBatch = new QuadBatch();
					
					for each (image in textureItems) {
						qb.addImage(image);
					}
					
					var citrusSprite:CitrusSprite = new CitrusSprite(layer, { view: qb });
					objects.push(citrusSprite);
				}
			}
			
			// Finally we will add everything to the state
			if (addToCurrentState) {
				for each (citrusObject in objects) {
					
					if (citrusObject is CitrusSprite) {
						citrusSprite = citrusObject as CitrusSprite;
					}
					
					ce.state.add(citrusObject);
				}
			}
			
			return objects;
		}
	}
}
