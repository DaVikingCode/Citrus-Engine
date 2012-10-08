package awayphysics.collision.shapes {
	import awayphysics.math.AWPMath;
	import awayphysics.math.AWPTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class AWPCompoundShape extends AWPCollisionShape {
		private var _children : Vector.<AWPCollisionShape>;
		private var _allChildren:Vector.<AWPCollisionShape>;
		private var _transforms:Vector.<AWPTransform>;
		private var _childTransform:AWPTransform;

		/**
		 *create a compound shape use the other primitive shapes
		 */
		public function AWPCompoundShape() {
			pointer = bullet.createCompoundShapeMethod();
			super(pointer, 7);
			_children = new Vector.<AWPCollisionShape>();
			_allChildren = new Vector.<AWPCollisionShape>();
			_transforms = new Vector.<AWPTransform>();
			
			_childTransform = new AWPTransform();
		}

		/**
		 *add a child shape and set its position and rotation in local coordinates
		 */
		public function addChildShape(child : AWPCollisionShape, localPos : Vector3D = null, localRot : Vector3D = null) : void {
			
			if ( localPos == null )
			localPos = new Vector3D();
			
			if ( localRot == null )
			localRot = new Vector3D();
			
			var tr:AWPTransform = new AWPTransform();
			tr.position = localPos;
			tr.rotation = AWPMath.degrees2radiansV3D(localRot);
			_transforms.push(tr);
			
			var rot:Matrix3D = AWPMath.euler2matrix(AWPMath.degrees2radiansV3D(localRot));
			var rotArr : Vector.<Number> = rot.rawData;
			bullet.addCompoundChildMethod(pointer, child.pointer, localPos.x / _scaling, localPos.y / _scaling, localPos.z / _scaling, rotArr[0], rotArr[4], rotArr[8], rotArr[1], rotArr[5], rotArr[9], rotArr[2], rotArr[6], rotArr[10]);

			_children.push(child);
			_allChildren.push(child);
		}

		/**
		 *remove a child shape from compound shape
		 */
		public function removeChildShapeByIndex(childShapeindex : int) : void {
			bullet.removeCompoundChildMethod(pointer, childShapeindex);

			_children.splice(childShapeindex, 1);
			_transforms.splice(childShapeindex, 1);
		}
		
		/**
		 *remove all children shape from compound shape
		 */
		public function removeAllChildren() : void {
			while (_children.length > 0){
				removeChildShapeByIndex(0);
			}
			_children.length = 0;
			_transforms.length = 0;
		}

		/**
		 *get the children list
		 */
		public function get children() : Vector.<AWPCollisionShape> {
			return _children;
		}
		
		public function getChildTransform(index:int):AWPTransform {
			_childTransform.position=AWPMath.vectorMultiply(_transforms[index].position, m_localScaling);
			_childTransform.rotation=_transforms[index].rotation;
			return _childTransform;
		}
		
		override public function set localScaling(scale:Vector3D):void {
			m_localScaling.setTo(scale.x, scale.y, scale.z);
			bullet.setShapeScalingMethod(pointer, scale.x, scale.y, scale.z);
			for each(var shape:AWPCollisionShape in _children) {
				shape.localScaling = new Vector3D(scale.x, scale.y, scale.z, 1);
			}
		}
		
		override public function dispose():void {
			m_counter--;
			if (m_counter > 0) {
				return;
			}else {
				m_counter = 0;
			}
			if (!cleanup) {
				cleanup	= true;
				removeAllChildren();
				for each(var shape:AWPCollisionShape in _allChildren) {
					shape.dispose();
				}
				_allChildren.length = 0;
				bullet.disposeCollisionShapeMethod(pointer);
			}
		}
	}
}