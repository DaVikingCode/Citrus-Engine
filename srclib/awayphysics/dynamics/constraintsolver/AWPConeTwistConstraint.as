package awayphysics.dynamics.constraintsolver {
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.math.AWPMath;
	import awayphysics.math.AWPTransform;

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class AWPConeTwistConstraint extends AWPTypedConstraint {
		
		private var m_rbAFrame:AWPTransform;
		private var m_rbBFrame:AWPTransform;
		
		public function AWPConeTwistConstraint(rbA : AWPRigidBody, pivotInA : Vector3D, rotationInA : Vector3D, rbB : AWPRigidBody = null, pivotInB : Vector3D = null, rotationInB : Vector3D = null) {
			super(2);
			m_rbA = rbA;
			m_rbB = rbB;
			
			m_rbAFrame = new AWPTransform();
			m_rbAFrame.position = pivotInA;
			m_rbAFrame.rotation = AWPMath.degrees2radiansV3D(rotationInA);

			var posInA : Vector3D = pivotInA.clone();
			posInA.scaleBy(1 / _scaling);
			var rotA:Matrix3D = AWPMath.euler2matrix(m_rbAFrame.rotation);
			var rotArrInA : Vector.<Number> = rotA.rawData;
			if (rbB) {
				m_rbBFrame = new AWPTransform();
				m_rbBFrame.position = pivotInB;
				m_rbBFrame.rotation = AWPMath.degrees2radiansV3D(rotationInB);
				
				var posInB : Vector3D = pivotInB.clone();
				posInB.scaleBy(1 / _scaling);
				var rotB:Matrix3D = AWPMath.euler2matrix(m_rbBFrame.rotation);
				var rotArrInB : Vector.<Number> = rotB.rawData;
				pointer = bullet.createConeTwistConstraintMethod2(rbA.pointer, posInA, new Vector3D(rotArrInA[0], rotArrInA[4], rotArrInA[8]), new Vector3D(rotArrInA[1], rotArrInA[5], rotArrInA[9]), new Vector3D(rotArrInA[2], rotArrInA[6], rotArrInA[10]), rbB.pointer, posInB, new Vector3D(rotArrInB[0], rotArrInB[4], rotArrInB[8]), new Vector3D(rotArrInB[1], rotArrInB[5], rotArrInB[9]), new Vector3D(rotArrInB[2], rotArrInB[6], rotArrInB[10]));
			} else {
				m_rbBFrame = null;
				pointer = bullet.createConeTwistConstraintMethod1(rbA.pointer, posInA.x, posInA.y, posInA.z, rotArrInA[0], rotArrInA[4], rotArrInA[8], rotArrInA[1], rotArrInA[5], rotArrInA[9], rotArrInA[2], rotArrInA[6], rotArrInA[10]);
			}
		}
		
		public function get rbAFrame():AWPTransform {
			return m_rbAFrame;
		}
		
		public function get rbBFrame():AWPTransform {
			return m_rbBFrame;
		}

		public function setLimit(_swingSpan1 : Number, _swingSpan2 : Number, _twistSpan : Number, _softness : Number = 1, _biasFactor : Number = 0.3, _relaxationFactor : Number = 1) : void {
			swingSpan1 = _swingSpan1;
			swingSpan2 = _swingSpan2;
			twistSpan = _twistSpan;

			limitSoftness = _softness;
			biasFactor = _biasFactor;
			relaxationFactor = _relaxationFactor;
		}

		/*
		public function setMaxMotorImpulse(_maxMotorImpulse:Number):void {
		maxMotorImpulse = _maxMotorImpulse;
		bNormalizedMotorStrength = false;
		}
		
		public function setMaxMotorImpulseNormalized(_maxMotorImpulse:Number):void {
		maxMotorImpulse = _maxMotorImpulse;
		bNormalizedMotorStrength = true;
		}
		 */
		public function get limitSoftness() : Number {
			return memUser._mrf(pointer + 416);
		}

		public function set limitSoftness(v : Number) : void {
			memUser._mwf(pointer + 416, v);
		}

		public function get biasFactor() : Number {
			return memUser._mrf(pointer + 420);
		}

		public function set biasFactor(v : Number) : void {
			memUser._mwf(pointer + 420, v);
		}

		public function get relaxationFactor() : Number {
			return memUser._mrf(pointer + 424);
		}

		public function set relaxationFactor(v : Number) : void {
			memUser._mwf(pointer + 424, v);
		}

		public function get damping() : Number {
			return memUser._mrf(pointer + 428);
		}

		public function set damping(v : Number) : void {
			memUser._mwf(pointer + 428, v);
		}

		public function get swingSpan1() : Number {
			return memUser._mrf(pointer + 432);
		}

		public function set swingSpan1(v : Number) : void {
			memUser._mwf(pointer + 432, v);
		}

		public function get swingSpan2() : Number {
			return memUser._mrf(pointer + 436);
		}

		public function set swingSpan2(v : Number) : void {
			memUser._mwf(pointer + 436, v);
		}

		public function get twistSpan() : Number {
			return memUser._mrf(pointer + 440);
		}

		public function set twistSpan(v : Number) : void {
			memUser._mwf(pointer + 440, v);
		}

		public function get fixThresh() : Number {
			return memUser._mrf(pointer + 444);
		}

		public function set fixThresh(v : Number) : void {
			memUser._mwf(pointer + 444, v);
		}

		public function get twistAngle() : Number {
			return memUser._mrf(pointer + 500);
		}

		public function get angularOnly() : Boolean {
			return memUser._mru8(pointer + 512) == 1;
		}

		public function set angularOnly(v : Boolean) : void {
			memUser._mw8(pointer + 512, v ? 1 : 0);
		}
		/*public function get enableMotor():Boolean { return memUser._mru8(pointer + 540) == 1; }
		public function set enableMotor(v:Boolean):void { memUser._mw8(pointer + 540, v ? 1 : 0); }
		public function get bNormalizedMotorStrength():Boolean { return memUser._mru8(pointer + 541) == 1; }
		public function set bNormalizedMotorStrength(v:Boolean):void { memUser._mw8(pointer + 541, v ? 1 : 0); }
		public function get maxMotorImpulse():Number { return memUser._mrf(pointer + 560); }
		public function set maxMotorImpulse(v:Number):void { memUser._mwf(pointer + 560, v); }*/
	}
}