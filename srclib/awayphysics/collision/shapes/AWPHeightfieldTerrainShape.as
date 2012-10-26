package awayphysics.collision.shapes {
	import away3d.core.base.Geometry;
	import awayphysics.extend.AWPTerrain;

	public class AWPHeightfieldTerrainShape extends AWPCollisionShape {
		private var dataPtr : uint;

		private var _geometry:Geometry;
		
		 /**
		  * create terrain with the heightmap data
		  */
		public function AWPHeightfieldTerrainShape(terrain : AWPTerrain) {
			_geometry = terrain.geometry;
			var dataLen : int = terrain.sw * terrain.sh;
			dataPtr = bullet.createHeightmapDataBufferMethod(dataLen);

			var data : Vector.<Number> = terrain.heights;
			alchemyMemory.position = dataPtr;
			for (var i : int = 0; i < dataLen; i++ ) {
				alchemyMemory.writeFloat(data[i] / _scaling);
			}

			pointer = bullet.createTerrainShapeMethod(dataPtr, terrain.sw, terrain.sh, terrain.lw / _scaling, terrain.lh / _scaling, 1, -terrain.maxHeight / _scaling, terrain.maxHeight / _scaling, 1);
			super(pointer, 10);
		}

		override public function dispose() : void {
			m_counter--;
			if (m_counter > 0) {
				return;
			}else {
				m_counter = 0;
			}
			if (!cleanup) {
				cleanup	= true;
				bullet.removeHeightmapDataBufferMethod(dataPtr);
				bullet.disposeCollisionShapeMethod(pointer);
			}
		}
		
		public function get geometry():Geometry {
			return _geometry;
		}
	}
}