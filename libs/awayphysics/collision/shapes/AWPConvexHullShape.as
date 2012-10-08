package awayphysics.collision.shapes
{
	import away3d.core.base.Geometry;
	
	public class AWPConvexHullShape extends AWPCollisionShape
	{
		private var vertexDataPtr : uint;
		
		private var _geometry:Geometry;
		
		public function AWPConvexHullShape(geometry : Geometry)
		{
			_geometry = geometry;
			var vertexData : Vector.<Number> = geometry.subGeometries[0].vertexData;
			var vertexDataLen : int = vertexData.length;
			vertexDataPtr = bullet.createTriangleVertexDataBufferMethod(vertexDataLen);
			
			alchemyMemory.position = vertexDataPtr;
			for (var i:int = 0; i < vertexDataLen; i++ ) {
				alchemyMemory.writeFloat(vertexData[i] / _scaling);
			}
			
			pointer = bullet.createConvexHullShapeMethod(int(vertexDataLen / 3), vertexDataPtr);
			super(pointer, 5);
		}
		
		override public function dispose() : void
		{
			m_counter--;
			if (m_counter > 0) {
				return;
			}else {
				m_counter = 0;
			}
			if (!cleanup) {
				cleanup	= true;
				bullet.removeTriangleVertexDataBufferMethod(vertexDataPtr);
				bullet.disposeCollisionShapeMethod(pointer);
			}
		}
		
		public function get geometry():Geometry {
			return _geometry;
		}
	}
}