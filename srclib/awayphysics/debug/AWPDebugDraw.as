package awayphysics.debug 
{
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.entities.SegmentSet;
	import away3d.primitives.LineSegment;
	
	import awayphysics.collision.dispatch.AWPRay;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.*;
	import awayphysics.data.AWPCollisionShapeType;
	import awayphysics.data.AWPTypedConstraintType;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.constraintsolver.*;
	import awayphysics.math.AWPTransform;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class AWPDebugDraw 
	{
		public static const DBG_NoDebug : int = 0;
		public static const DBG_DrawCollisionShapes : int = 1;
		public static const DBG_DrawConstraints : int = 2;
		public static const DBG_DrawConstraintLimits : int =4;
		public static const DBG_DrawTransform:int = 8;
		public static const DBG_DrawRay : int = 16;
		
		private var _view:View3D;
		private var _physicsWorld:AWPDynamicsWorld;
		private var _segmentSet:SegmentSet;
		
		private var m_debugMode:int;
		
		public function AWPDebugDraw(view:View3D, physicsWorld:AWPDynamicsWorld)
		{
			_segmentSet = new SegmentSet();
			view.scene.addChild(_segmentSet);
			
			_view = view;
			_physicsWorld = physicsWorld;
			m_debugMode = 1;
		}
		
		public function get debugMode():int {
			return m_debugMode;
		}
		public function set debugMode(mode:int):void {
			m_debugMode = mode;
		}
		
		private function drawLine(from:Vector3D, to:Vector3D, color:uint):void {
			var line:LineSegment = new LineSegment(from.subtract(_segmentSet.position), to.subtract(_segmentSet.position), color, color, 2);
			_segmentSet.addSegment(line);
		}
		
		private function drawSphere(radius:Number, transform:AWPTransform, color:uint):void {
			var pos:Vector3D = transform.position;
			var rot:Matrix3D = transform.rotationWithMatrix;
			
			var xoffs:Vector3D = rot.transformVector(new Vector3D(radius, 0, 0));
			var yoffs:Vector3D = rot.transformVector(new Vector3D(0, radius, 0));
			var zoffs:Vector3D = rot.transformVector(new Vector3D(0, 0, radius));
			
			drawLine(pos.subtract(xoffs), pos.add(yoffs), color);
			drawLine(pos.add(yoffs), pos.add(xoffs), color);
			drawLine(pos.add(xoffs), pos.subtract(yoffs), color);
			drawLine(pos.subtract(yoffs), pos.subtract(xoffs), color);

			drawLine(pos.subtract(xoffs), pos.add(zoffs), color);
			drawLine(pos.add(zoffs), pos.add(xoffs), color);
			drawLine(pos.add(xoffs), pos.subtract(zoffs), color);
			drawLine(pos.subtract(zoffs), pos.subtract(xoffs), color);

			drawLine(pos.subtract(yoffs), pos.add(zoffs), color);
			drawLine(pos.add(zoffs), pos.add(yoffs), color);
			drawLine(pos.add(yoffs), pos.subtract(zoffs), color);
			drawLine(pos.subtract(zoffs), pos.subtract(yoffs), color);
		}
		
		private function drawTriangle(v0:Vector3D, v1:Vector3D, v2:Vector3D, color:uint):void {
			drawLine(v0, v1, color);
			drawLine(v1, v2, color);
			drawLine(v2, v0, color);
		}
		
		private function drawAabb(from:Vector3D, to:Vector3D, color:uint):void {
			var halfExtents:Vector3D = to.subtract(from);
			halfExtents.scaleBy(0.5);
			var center:Vector3D = to.subtract(from);
			center.scaleBy(0.5);
			var i:int, j:int, othercoord:int;

			var edgecoord:Vector.<Number> = new Vector.<Number>(3, true);
			edgecoord[0] = 1;
			edgecoord[1] = 1;
			edgecoord[2] = 1;
			
			var pa:Vector3D = new Vector3D();
			var pb:Vector3D = new Vector3D();
			for (i = 0; i < 4; i++)
			{
				for (j = 0; j < 3; j++)
				{
					pa.setTo(edgecoord[0] * halfExtents.x, edgecoord[1] * halfExtents.y, edgecoord[2] * halfExtents.z);
					pa = pa.add(center);
					
					othercoord = j % 3;
					edgecoord[othercoord] *= -1;
					pb.setTo(edgecoord[0] * halfExtents.x, edgecoord[1] * halfExtents.y, edgecoord[2] * halfExtents.z);
					pb += center;
					
					drawLine(pa,pb,color);
				}
				edgecoord[0] = -1;
				edgecoord[1] = -1;
				edgecoord[2] = -1;
				if (i<3)
					edgecoord[i] *= -1;
			}
		}
		
		private function drawTransform(transform:AWPTransform, orthoLen:Number):void {
			var pos:Vector3D = transform.position;
			var rot:Matrix3D = transform.rotationWithMatrix;
			
			drawLine(pos, pos.add(rot.transformVector(new Vector3D(orthoLen, 0, 0))), 0xff0000);
			drawLine(pos, pos.add(rot.transformVector(new Vector3D(0, orthoLen, 0))), 0x00ff00);
			drawLine(pos, pos.add(rot.transformVector(new Vector3D(0, 0, orthoLen))), 0x0000ff);
		}
		
		private function drawArc(center:Vector3D, normal:Vector3D, axis:Vector3D, radiusA:Number, radiusB:Number, minAngle:Number, maxAngle:Number, color:uint, drawSect:Boolean, stepDegrees:Number = 10):void {
			var vx:Vector3D = axis;
			var vy:Vector3D = normal.crossProduct(axis);
			var step:Number = stepDegrees * 2 * Math.PI / 360;
			var nSteps:int = int((maxAngle - minAngle) / step);
			if (!nSteps) nSteps = 1;
			
			var temp:Vector3D;
			temp = vx.clone();
			temp.scaleBy(radiusA * Math.cos(minAngle));
			var prev:Vector3D = center.add(temp);
			temp = vy.clone();
			temp.scaleBy(radiusB * Math.sin(minAngle));
			prev = prev.add(temp);
			if(drawSect)
			{
				drawLine(center, prev, color);
			}
			
			var angle:Number;
			var next:Vector3D;
			for(var i:int = 1; i <= nSteps; i++)
			{
				angle = minAngle + (maxAngle - minAngle) * i / nSteps;
				temp = vx.clone();
				temp.scaleBy(radiusA * Math.cos(angle));
				next = center.add(temp);
				temp = vy.clone();
				temp.scaleBy(radiusB * Math.sin(angle));
				next = next.add(temp);
				drawLine(prev, next, color);
				prev = next;
			}
			if(drawSect)
			{
				drawLine(center, prev, color);
			}
		}
		/*
		private function drawSpherePatch(center:Vector3D, up:Vector3D, axis:Vector3D, radius:Number, minTh:Number, maxTh:Number, minPs:Number, maxPs:Number, color:uint, stepDegrees:Number = 10):void {
			
		}*/
		
		
		private function drawBox(bbMin:Vector3D, bbMax:Vector3D, transform:AWPTransform, color:uint):void {
			var from:Vector3D = new Vector3D();
			var to:Vector3D = new Vector3D();
			
			var pos:Vector3D = transform.position;
			var rot:Matrix3D = transform.rotationWithMatrix;
			
			from.setTo(bbMin.x, bbMin.y, bbMin.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMax.x, bbMin.y, bbMin.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMax.x, bbMin.y, bbMin.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMax.x, bbMax.y, bbMin.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMax.x, bbMax.y, bbMin.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMin.x, bbMax.y, bbMin.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMin.x, bbMax.y, bbMin.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMin.x, bbMin.y, bbMin.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMin.x, bbMin.y, bbMin.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMin.x, bbMin.y, bbMax.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMax.x, bbMin.y, bbMin.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMax.x, bbMin.y, bbMax.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMax.x, bbMax.y, bbMin.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMax.x, bbMax.y, bbMax.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMin.x, bbMax.y, bbMin.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMin.x, bbMax.y, bbMax.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMin.x, bbMin.y, bbMax.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMax.x, bbMin.y, bbMax.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMax.x, bbMin.y, bbMax.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMax.x, bbMax.y, bbMax.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMax.x, bbMax.y, bbMax.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMin.x, bbMax.y, bbMax.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
			
			from.setTo(bbMin.x, bbMax.y, bbMax.z);
			from = rot.transformVector(from);
			from = from.add(pos);
			to.setTo(bbMin.x, bbMin.y, bbMax.z);
			to = rot.transformVector(to);
			to = to.add(pos);
			drawLine(from, to, color);
		}
		
		private function drawCapsule(radius:Number, halfHeight:Number, transform:AWPTransform, color:uint):void {
			var pos:Vector3D = transform.position;
			var rot:Matrix3D = transform.rotationWithMatrix;
			
			var capStart:Vector3D = new Vector3D();
			capStart.y = -halfHeight;

			var capEnd:Vector3D = new Vector3D();
			capEnd.y = halfHeight;

			var tr:AWPTransform = transform.clone();
			tr.position = transform.transform.transformVector(capStart);
			drawSphere(radius, tr, color);
			tr.position = transform.transform.transformVector(capEnd);
			drawSphere(radius, tr, color);

			// Draw some additional lines
			capStart.z = radius;
			capEnd.z = radius;
			drawLine(pos.add(rot.transformVector(capStart)), pos.add(rot.transformVector(capEnd)), color);
			capStart.z = -radius;
			capEnd.z = -radius;
			drawLine(pos.add(rot.transformVector(capStart)), pos.add(rot.transformVector(capEnd)), color);

			capStart.z = 0;
			capEnd.z = 0;

			capStart.x = radius;
			capEnd.x = radius;
			drawLine(pos.add(rot.transformVector(capStart)), pos.add(rot.transformVector(capEnd)), color);
			capStart.x = -radius;
			capEnd.x = -radius;
			drawLine(pos.add(rot.transformVector(capStart)), pos.add(rot.transformVector(capEnd)), color);
		}
		
		private function drawCylinder(radius:Number, halfHeight:Number, transform:AWPTransform, color:uint):void {
			var pos:Vector3D = transform.position;
			var rot:Matrix3D = transform.rotationWithMatrix;
			
			var	offsetHeight:Vector3D = new Vector3D(0, halfHeight, 0);
			var	offsetRadius:Vector3D = new Vector3D(0, 0, radius);
			drawLine(pos.add(rot.transformVector(offsetHeight.add(offsetRadius))), pos.add(rot.transformVector(offsetRadius.subtract(offsetHeight))), color);
			
			var vec:Vector3D = offsetHeight.add(offsetRadius);
			vec.scaleBy(-1);
			drawLine(pos.add(rot.transformVector(offsetHeight.subtract(offsetRadius))), pos.add(rot.transformVector(vec)), color);

			// Drawing top and bottom caps of the cylinder
			var yaxis:Vector3D = new Vector3D(0, 1, 0);
			var xaxis:Vector3D = new Vector3D(0, 0, 1);
			drawArc(pos.subtract(rot.transformVector(offsetHeight)), rot.transformVector(yaxis), rot.transformVector(xaxis), radius, radius, 0, 2 * Math.PI, color, false, 10);
			drawArc(pos.add(rot.transformVector(offsetHeight)), rot.transformVector(yaxis), rot.transformVector(xaxis), radius, radius, 0, 2 * Math.PI, color, false, 10);
		}
		
		private function drawCone(radius:Number, height:Number, transform:AWPTransform, color:uint):void {
			var pos:Vector3D = transform.position;
			var rot:Matrix3D = transform.rotationWithMatrix;

			var	offsetHeight:Vector3D = new Vector3D(0, 0.5 * height, 0);
			var	offsetRadius:Vector3D = new Vector3D(0, 0, radius);
			var	offset2Radius:Vector3D = new Vector3D(radius, 0, 0);

			var vec:Vector3D;
			drawLine(pos.add(rot.transformVector(offsetHeight)), pos.add(rot.transformVector(offsetRadius.subtract(offsetHeight))), color);
			vec = offsetHeight.add(offsetRadius);
			vec.scaleBy(-1);
			drawLine(pos.add(rot.transformVector(offsetHeight)), pos.add(rot.transformVector(vec)), color);
			drawLine(pos.add(rot.transformVector(offsetHeight)), pos.add(rot.transformVector(offset2Radius.subtract(offsetHeight))), color);
			vec = offsetHeight.add(offset2Radius);
			vec.scaleBy(-1);
			drawLine(pos.add(rot.transformVector(offsetHeight)), pos.add(rot.transformVector(vec)), color);

			// Drawing the base of the cone
			var yaxis:Vector3D = new Vector3D(0, 1, 0);
			var xaxis:Vector3D = new Vector3D(0, 0, 1);
			drawArc(pos.subtract(rot.transformVector(offsetHeight)), rot.transformVector(yaxis), rot.transformVector(xaxis), radius, radius, 0, 2 * Math.PI, color, false, 10);
		}
		
		private function drawPlane(planeNormal:Vector3D, planeConst:Number, transform:AWPTransform, color:uint):void {
			var pos:Vector3D = transform.position;
			var rot:Matrix3D = transform.rotationWithMatrix;
			
			var planeOrigin:Vector3D = planeNormal.clone();
			planeOrigin.scaleBy(planeConst);
			var vec0:Vector3D = new Vector3D();
			var vec1:Vector3D = new Vector3D();
			btPlaneSpace1(planeNormal, vec0, vec1);
			var vecLen:Number = 100*_physicsWorld.scaling;
			vec0.scaleBy(vecLen);
			vec1.scaleBy(vecLen);
			var pt0:Vector3D = planeOrigin.add(vec0);
			var pt1:Vector3D = planeOrigin.subtract(vec0);
			var pt2:Vector3D = planeOrigin.add(vec1);
			var pt3:Vector3D = planeOrigin.subtract(vec1);
			
			pt0 = rot.transformVector(pt0);
			pt0 = pt0.add(pos);
			pt1 = rot.transformVector(pt1);
			pt1 = pt1.add(pos);
			drawLine(pt0, pt1, color);
			
			pt2 = rot.transformVector(pt2);
			pt2 = pt2.add(pos);
			pt3 = rot.transformVector(pt3);
			pt3 = pt3.add(pos);
			drawLine(pt2, pt3, color);
		}
		 
		private function btPlaneSpace1(n:Vector3D, p:Vector3D, q:Vector3D):void {
			if (Math.abs(n.z) > 0.707) {
				var a:Number = n.y * n.y + n.z * n.z;
				var k:Number = 1 / Math.sqrt(a);
				p.x = 0;
				p.y = -n.z * k;
				p.z = n.y * k;
				// set q = n x p
				q.x = a*k;
				q.y = -n.x * p.z;
				q.z = n.x * p.y;
			} else {
				a = n.x * n.x + n.y * n.y;
				k = 1 / Math.sqrt(a);
				p.x = -n.y * k;
				p.y = n.x * k;
				p.z = 0;
				q.x = -n.z * p.y;
				q.y = n.z * p.x;
				q.z = a * k;
		    }
		}
		
		private function drawTriangles(geometry:Geometry, scale:Vector3D, transform:AWPTransform, color:uint):void {
			var indexData:Vector.<uint> = geometry.subGeometries[0].indexData;
			var vertexData:Vector.<Number> = geometry.subGeometries[0].vertexData;
			var indexDataLen:int = indexData.length;
			
			var m:int = 0;
			var v0:Vector3D = new Vector3D();
			var v1:Vector3D = new Vector3D();
			var v2:Vector3D = new Vector3D();
			for (var i:int = 0; i < indexDataLen; i += 3 ) {
				v0.setTo(vertexData[3*indexData[m]] * scale.x, vertexData[3*indexData[m]+1] * scale.y, vertexData[3*indexData[m]+2] * scale.z);
				m++;
				v1.setTo(vertexData[3*indexData[m]] * scale.x, vertexData[3*indexData[m]+1] * scale.y, vertexData[3*indexData[m]+2] * scale.z);
				m++;
				v2.setTo(vertexData[3*indexData[m]] * scale.x, vertexData[3*indexData[m]+1] * scale.y, vertexData[3*indexData[m]+2] * scale.z);
				m++;
				drawTriangle(transform.transform.transformVector(v0), transform.transform.transformVector(v1), transform.transform.transformVector(v2), color);
			}
		}
		
		private function debugDrawObject(transform:AWPTransform, shape:AWPCollisionShape, color:uint):void {
			if (m_debugMode & AWPDebugDraw.DBG_DrawTransform) {
				drawTransform(transform, 200);
			}
			
			if (shape.shapeType == AWPCollisionShapeType.COMPOUND_SHAPE) {
				var i:int = 0;
				var childTrans:AWPTransform;
				var compoundShape:AWPCompoundShape = shape as AWPCompoundShape;
				for each (var sp:AWPCollisionShape in compoundShape.children) {
					childTrans = compoundShape.getChildTransform(i).clone();
					childTrans.appendTransform(transform);
					debugDrawObject(childTrans, sp, color);
					i++;
				}
			}else if (shape.shapeType == AWPCollisionShapeType.BOX_SHAPE) {
				var boxShape:AWPBoxShape = shape as AWPBoxShape;
				var halfExtents:Vector3D = boxShape.dimensions;
				halfExtents.scaleBy(0.5);
				drawBox(new Vector3D( -halfExtents.x, -halfExtents.y, -halfExtents.z), halfExtents, transform, color);
			}else if (shape.shapeType == AWPCollisionShapeType.SPHERE_SHAPE) {
				var sphereShape:AWPSphereShape = shape as AWPSphereShape;
				drawSphere(sphereShape.radius, transform, color);
			}else if (shape.shapeType == AWPCollisionShapeType.CAPSULE_SHAPE) {
				var capsuleShape:AWPCapsuleShape = shape as AWPCapsuleShape;
				drawCapsule(capsuleShape.radius, capsuleShape.height / 2, transform, color);
			}else if (shape.shapeType == AWPCollisionShapeType.CONE_SHAPE) {
				var coneShape:AWPConeShape = shape as AWPConeShape;
				drawCone(coneShape.radius, coneShape.height, transform, color);
			}else if (shape.shapeType == AWPCollisionShapeType.CYLINDER_SHAPE) {
				var cylinder:AWPCylinderShape = shape as AWPCylinderShape;
				drawCylinder(cylinder.radius, cylinder.height / 2, transform, color);
			}else if (shape.shapeType == AWPCollisionShapeType.STATIC_PLANE) {
				var staticPlaneShape:AWPStaticPlaneShape = shape as AWPStaticPlaneShape;
				drawPlane(staticPlaneShape.normal, staticPlaneShape.constant, transform, color);
			}else if (shape.shapeType == AWPCollisionShapeType.CONVEX_HULL_SHAPE) {
				var convex:AWPConvexHullShape = shape as AWPConvexHullShape;
				drawTriangles(convex.geometry, convex.localScaling, transform, color);
			}else if (shape.shapeType == AWPCollisionShapeType.TRIANGLE_MESH_SHAPE) {
				var triangleMesh:AWPBvhTriangleMeshShape = shape as AWPBvhTriangleMeshShape;
				drawTriangles(triangleMesh.geometry, triangleMesh.localScaling, transform, color);
			}else if (shape.shapeType == AWPCollisionShapeType.HEIGHT_FIELD_TERRAIN) {
				//var terrain:AWPHeightfieldTerrainShape = shape as AWPHeightfieldTerrainShape;
				//drawTriangles(terrain.geometry, terrain.localScaling, transform, color);
			}
		}
		
		private function debugDrawConstraint(constraint:AWPTypedConstraint):void {
			var drawFrames:Boolean = ((m_debugMode & AWPDebugDraw.DBG_DrawConstraints) != 0);
			var drawLimits:Boolean = ((m_debugMode & AWPDebugDraw.DBG_DrawConstraintLimits) != 0);
			if (constraint.constraintType == AWPTypedConstraintType.POINT2POINT_CONSTRAINT_TYPE) {
				var p2pC:AWPPoint2PointConstraint = constraint as AWPPoint2PointConstraint;
				var tr:AWPTransform = new AWPTransform();
				var pivot:Vector3D = p2pC.pivotInA.clone();
				pivot = p2pC.rigidBodyA.transform.transformVector(pivot);
				tr.position = pivot;
				if (drawFrames) drawTransform(tr, 200);
				if (p2pC.rigidBodyB) {
					pivot = p2pC.pivotInB.clone();
					pivot = p2pC.rigidBodyB.transform.transformVector(pivot);
					tr.position = pivot;
					if (drawFrames) drawTransform(tr, 200);
				}
			}else if (constraint.constraintType == AWPTypedConstraintType.HINGE_CONSTRAINT_TYPE) {
				var pHinge:AWPHingeConstraint = constraint as AWPHingeConstraint;
				var pos:Vector3D = pHinge.rigidBodyA.worldTransform.position;
				var rot:Matrix3D = pHinge.rigidBodyA.worldTransform.rotationWithMatrix;
				var from:Vector3D = rot.transformVector(pHinge.pivotInA);
				from = from.add(pos);
				var to:Vector3D = rot.transformVector(pHinge.axisInA);
				to.scaleBy(200);
				to = from.add(to);
				if (drawFrames) drawLine(from,to,0xff0000);
				if (pHinge.rigidBodyB) {
					pos = pHinge.rigidBodyB.worldTransform.position;
					rot = pHinge.rigidBodyB.worldTransform.rotationWithMatrix;
					from = rot.transformVector(pHinge.pivotInB);
					from = from.add(pos);
					to = rot.transformVector(pHinge.axisInB);
					to.scaleBy(200);
					to = from.add(to);
					if (drawFrames) drawLine(from,to,0xff0000);
				}
				
				var minAng:Number = pHinge.limit.low;
				var maxAng:Number = pHinge.limit.high;
				if (minAng != maxAng) {
					var drawSect:Boolean = true;
					if(minAng > maxAng) {
						minAng = 0;
						maxAng = 2 * Math.PI;
						drawSect = false;
					}
					if (drawLimits) {
						var normal:Vector3D = to.subtract(from);
						normal.normalize();
						var axis:Vector3D = normal.crossProduct(new Vector3D(0, 0, 1));
						if (axis.length > -0.01 && axis.length < 0.01) {
							axis = normal.crossProduct(new Vector3D(0, -1, 0));
						}
						axis.normalize();
						to = rot.transformVector(axis);
						to.scaleBy(200);
						to = from.add(to);
						drawLine(from,to,0x00ff00);
						drawArc(from, normal, axis, 200, 200, minAng, maxAng, 0xffff00, drawSect);
					}
				}
			}else if (constraint.constraintType == AWPTypedConstraintType.CONETWIST_CONSTRAINT_TYPE) {
				var pCT:AWPConeTwistConstraint = constraint as AWPConeTwistConstraint;
				var trA:AWPTransform = pCT.rbAFrame.clone();
				trA.appendTransform(pCT.rigidBodyA.worldTransform);
				if (drawFrames) drawTransform(trA, 200);
				if (pCT.rigidBodyB) {
					var trB:AWPTransform = pCT.rbBFrame.clone();
					trB.appendTransform(pCT.rigidBodyB.worldTransform);
					if (drawFrames) drawTransform(trB, 200);
				}
				if (drawLimits) {
					rot = pCT.rigidBodyA.worldTransform.rotationWithMatrix;
					normal = rot.transformVector(pCT.rbAFrame.axisZ);
					axis = rot.transformVector(pCT.rbAFrame.axisY);
					minAng = -pCT.swingSpan1;
					maxAng = pCT.swingSpan1;
					drawArc(trA.position, normal, axis, 200, 200, minAng, maxAng, 0xffff00, true);
					
					normal = rot.transformVector(pCT.rbAFrame.axisX);
					axis = rot.transformVector(pCT.rbAFrame.axisY);
					minAng = -pCT.twistSpan;
					maxAng = pCT.twistSpan;
					drawArc(trA.position, normal, axis, 200, 200, minAng, maxAng, 0xffff00, true);
					
					normal = rot.transformVector(pCT.rbAFrame.axisY);
					axis = rot.transformVector(pCT.rbAFrame.axisX);
					minAng = -pCT.swingSpan2;
					maxAng = pCT.swingSpan2;
					drawArc(trA.position, normal, axis, 200, 200, minAng, maxAng, 0xffff00, true);
				}
			}else if (constraint.constraintType == AWPTypedConstraintType.D6_CONSTRAINT_TYPE) {
				var p6DOF:AWPGeneric6DofConstraint = constraint as AWPGeneric6DofConstraint;
				trA = p6DOF.rbAFrame.clone();
				trA.appendTransform(p6DOF.rigidBodyA.worldTransform);
				if (drawFrames) drawTransform(trA, 200);
				if (p6DOF.rigidBodyB) {
					trB = p6DOF.rbBFrame.clone();
					trB.appendTransform(p6DOF.rigidBodyB.worldTransform);
					if (drawFrames) drawTransform(trB, 200);
				}
				if (drawLimits) {
					rot = p6DOF.rigidBodyA.worldTransform.rotationWithMatrix;
					normal = rot.transformVector(p6DOF.rbAFrame.axisX);
					axis = rot.transformVector(p6DOF.rbAFrame.axisY);
					minAng = p6DOF.getRotationalLimitMotor(0).loLimit;
					maxAng = p6DOF.getRotationalLimitMotor(0).hiLimit;
					drawArc(trA.position, normal, axis, 200, 200, minAng, maxAng, 0xffff00, true);
					
					rot = p6DOF.rigidBodyA.worldTransform.rotationWithMatrix;
					normal = rot.transformVector(p6DOF.rbAFrame.axisY);
					axis = rot.transformVector(p6DOF.rbAFrame.axisX);
					minAng = p6DOF.getRotationalLimitMotor(1).loLimit;
					maxAng = p6DOF.getRotationalLimitMotor(1).hiLimit;
					drawArc(trA.position, normal, axis, 200, 200, minAng, maxAng, 0xffff00, true);
					
					rot = p6DOF.rigidBodyA.worldTransform.rotationWithMatrix;
					normal = rot.transformVector(p6DOF.rbAFrame.axisZ);
					axis = rot.transformVector(p6DOF.rbAFrame.axisY);
					minAng = p6DOF.getRotationalLimitMotor(2).loLimit;
					maxAng = p6DOF.getRotationalLimitMotor(2).hiLimit;
					drawArc(trA.position, normal, axis, 200, 200, minAng, maxAng, 0xffff00, true);
					
					var bbMin:Vector3D = p6DOF.getTranslationalLimitMotor().lowerLimit;
					var bbMax:Vector3D = p6DOF.getTranslationalLimitMotor().upperLimit;
					drawBox(bbMin, bbMax, trA, 0xffff00);
				}
			}
		}
		
		public function debugDrawWorld():void {
			if (m_debugMode & AWPDebugDraw.DBG_NoDebug) return;
			
			var dir:Vector3D = _view.camera.forwardVector.clone();
			dir.scaleBy(100);
			_segmentSet.position = _view.camera.position.add(dir);
			_segmentSet.removeAllSegments();
			
			var color:uint;
			for each (var obj:AWPCollisionObject in _physicsWorld.collisionObjects) {
				if (m_debugMode & AWPDebugDraw.DBG_DrawCollisionShapes)
				{
					switch(obj.activationState)
					{
						case  AWPCollisionObject.ACTIVE_TAG:
							color = 0xffffff; break;
						case AWPCollisionObject.ISLAND_SLEEPING:
							color = 0x00ff00; break;
						case AWPCollisionObject.WANTS_DEACTIVATION:
							color = 0x00ffff; break;
						case AWPCollisionObject.DISABLE_DEACTIVATION:
							color = 0xff0000; break;
						case AWPCollisionObject.DISABLE_SIMULATION:
							color = 0xffff00; break;
						default:
							color = 0xff0000;
					}
					debugDrawObject(obj.worldTransform, obj.shape, color);
				}
				if (m_debugMode & AWPDebugDraw.DBG_DrawRay)
				{
					for each (var ray:AWPRay in obj.rays) {
						drawLine(obj.worldTransform.transform.transformVector(ray.rayFrom), obj.worldTransform.transform.transformVector(ray.rayTo), 0xff0000);
					}
				}
			}
			
			if (m_debugMode & (AWPDebugDraw.DBG_DrawConstraints | AWPDebugDraw.DBG_DrawConstraintLimits))
			{
				for each(var constraint:AWPTypedConstraint in _physicsWorld.constraints) {
					debugDrawConstraint(constraint);
				}
			}
		}
	}
}