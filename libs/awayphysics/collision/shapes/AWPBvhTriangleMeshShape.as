package awayphysics.collision.shapes {
	import away3d.core.base.Geometry;

	public class AWPBvhTriangleMeshShape extends AWPCollisionShape {
		private var indexDataPtr : uint;
		private var vertexDataPtr : uint;
		
		private var _geometry:Geometry;

		/**
		 *create a static triangle mesh shape with a 3D mesh object
		 */
		public function AWPBvhTriangleMeshShape(geometry : Geometry, useQuantizedAabbCompression : Boolean = true) {
			_geometry = geometry;
			var indexData : Vector.<uint> = geometry.subGeometries[0].indexData;
			var indexDataLen : int = indexData.length;
			indexDataPtr = bullet.createTriangleIndexDataBufferMethod(indexDataLen);

			alchemyMemory.position = indexDataPtr;
			for (var i : int = 0; i < indexDataLen; i++ ) {
				alchemyMemory.writeInt(indexData[i]);
			}

			var vertexData : Vector.<Number> = geometry.subGeometries[0].vertexData;
			var vertexDataLen : int = vertexData.length;
			vertexDataPtr = bullet.createTriangleVertexDataBufferMethod(vertexDataLen);

			alchemyMemory.position = vertexDataPtr;
			for (i = 0; i < vertexDataLen; i++ ) {
				alchemyMemory.writeFloat(vertexData[i] / _scaling);
			}

			var triangleIndexVertexArrayPtr : uint = bullet.createTriangleIndexVertexArrayMethod(int(indexDataLen / 3), indexDataPtr, int(vertexDataLen / 3), vertexDataPtr);

			pointer = bullet.createBvhTriangleMeshShapeMethod(triangleIndexVertexArrayPtr, useQuantizedAabbCompression ? 1 : 0, 1);
			super(pointer, 9);
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
				bullet.removeTriangleIndexDataBufferMethod(indexDataPtr);
				bullet.removeTriangleVertexDataBufferMethod(vertexDataPtr);
				bullet.disposeCollisionShapeMethod(pointer);
			}
		}
		
		public function get geometry():Geometry {
			return _geometry;
		}
	}
}