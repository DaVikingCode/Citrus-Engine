package com.citrusengine.utils {

	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.SphereGeometry;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.objects.AwayPhysicsObject;
	import com.citrusengine.objects.platformer.awayphysics.Platform;

	/**
	 * The ObjectMaker is a factory utility class for quickly and easily batch-creating a bunch of CitrusObjects.
	 * Usually the ObjectMaker is used if you laid out your level in a level editor or an XML file.
	 * Pass in your layout object (SWF, XML, or whatever else is supported in the future) to the appropriate method,
	 * and the method will return an array of created CitrusObjects.
	 * 
	 * <p>The methods within the ObjectMaker3D should be called according to what kind of layout file that was created
	 * by your level editor.</p>
	 */
	public class ObjectMaker3D {

		public function ObjectMaker3D() {
		}
		
		/**
		 * The Citrus Engine supports <a href="http://unwrong.com/cadet">the Cadet Editor 3D</a>.
		 * <p>It supports physics objects creation (Plane, Cube, Sphere).</p>
		 */
		public static function FromCadetEditor3D(levelData:XML, addToCurrentState:Boolean = true):Array {
		
			var ce:CitrusEngine = CitrusEngine.getInstance();
		
			var params:Object;
		
			var objects:Array = [];
		
			var type:String;
			var radius:Number;
		
			var object:AwayPhysicsObject;
		
			for each (var root:XML in levelData.children()) {
				for each (var parent:XML in root.children()) {
		
					type = parent.@name;
		
					if (type == "Cube" || type == "Plane" || type == "Sphere") {
		
						var transform:Array = parent.@transform.split(",");
		
						params = {};
						params.x = transform[12];
						params.y = transform[13];
						params.z = transform[14];
		
						for each (var child:XML in parent.children()) {
		
							for each (var finalElement:XML in child.children()) {
								
								params.width = finalElement.@width;
								params.height = finalElement.@height;
								params.depth = finalElement.@depth;
								radius = finalElement.@radius;
		
								if (radius)
									params.radius = finalElement.@radius;
		
								if (type == "Plane") {
									
									// the plane seems to use the height as the depth
									params.depth = params.height;
									params.height = 0;
									params.view = new Mesh(new CubeGeometry(params.width, params.height, params.depth), new ColorMaterial(0xFF0000));
									object = new Platform("plane", params);
		
								} else {
		
									if (params.radius) {
		
										params.view = new Mesh(new SphereGeometry(params.radius), new ColorMaterial(0x00FF00));
										object = new AwayPhysicsObject("sphere", params);
		
									} else {
		
										params.view = new Mesh(new CubeGeometry(params.width, params.height, params.depth), new ColorMaterial(0x0000FF));
										object = new AwayPhysicsObject("cube", params);
									}
								}
		
								objects.push(object);
							}
						}
		
					}
				}
			}
		
			if (addToCurrentState)
				for each (object in objects) ce.state.add(object);
		
			return objects;
		}

		private static function Replace(str:String, fnd:String, rpl:String):String {
			return str.split(fnd).join(rpl);
		}
	}
}