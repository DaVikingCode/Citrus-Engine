package citrus.objects.platformer.box2d{
	
	import flash.display.BitmapData;
	
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	
	import citrus.core.CitrusEngine;
	import citrus.math.MathUtils;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.physics.PhysicsCollisionCategories;
	
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.utils.rad2deg;
	
	/**
	 * A Bridge consists of Box2dPhysicsObjects connected with RevoluteJoints and is build between two Objects (usually platforms).
	 * Sometimes you will not properly stand on the bridge because of rotating etc., to solve this modify your Heros's handleBeginContact() function
	 * <ul>Properties:
	 * <li>bridgeLength : If not set it's calculated automatically.</li>
	 * <li>useTexture : set false for debugging</li>
	 * <li>segmentBitmapData : BitmapData for creating the texture for Bridgeelements. It get's scaled with keeping 
	 * proportion between width and height</li></ul>
	 * 
	 */
	public class Bridge extends Box2DPhysicsObject {
		
		public var leftAnchor:Box2DPhysicsObject;
		public var rightAnchor:Box2DPhysicsObject;
		
		public var bridgeLength:uint;
		public var numSegments:uint = 9;
		public var heightSegment:uint = 15;
		public var useTexture:Boolean = false;		
		public var segmentBitmapData:BitmapData;
		public var density:Number = 1;
		public var friction:Number = 1;
		public var restitution:Number = 1;
		
		private var widthSegment:uint;
		private var ws:Number; //worldscale
		private var display:BridgeDisplay;
		
		private var _vecBodyDefChain:Vector.<b2BodyDef>;
		private var _vecBodyChain:Vector.<b2Body>;
		private var _vecFixtureDefChain:Vector.<b2FixtureDef>;
		private var _vecRevoluteJointDef:Vector.<b2RevoluteJointDef>;
		private var _shapeChain:b2Shape;
		
		public function Bridge(name:String, params:Object = null) {
			super(name, params);
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			if (display)
				display.updateSegmentDisplay(_vecBodyChain, ws);
		}
		
		override protected function defineBody():void {
			super.defineBody();
			ws = _box2D.scale
			if (!bridgeLength)
			{
				var distance:Number = MathUtils.DistanceBetweenTwoPoints(rightAnchor.x - int(rightAnchor.width/2), leftAnchor.x + int(leftAnchor.width/2), rightAnchor.y, leftAnchor.y)/2;
				bridgeLength = distance;
			}
			widthSegment = bridgeLength/numSegments
			if (useTexture)
			{
				display = new BridgeDisplay();
				(segmentBitmapData == null) ? display.init(numSegments, widthSegment, heightSegment) : display.init(numSegments, widthSegment, heightSegment, segmentBitmapData);
			}
			_vecBodyDefChain = new Vector.<b2BodyDef>();
			var bodyDefChain:b2BodyDef;
			for (var i:uint = 0; i < numSegments; ++i) 
			{
				bodyDefChain = new b2BodyDef();
				bodyDefChain.type = b2Body.b2_dynamicBody;
				bodyDefChain.position.Set(leftAnchor.x/ws + leftAnchor.width/2/ws + i*widthSegment/ws - 10/ws, leftAnchor.y/ws);
				_vecBodyDefChain.push(bodyDefChain);
			}
		}
		
		override protected function createBody():void {
			super.createBody();
			_vecBodyChain = new Vector.<b2Body>();
			var bodyChain:b2Body;
			for each (var bodyDefChain:b2BodyDef in _vecBodyDefChain) 
			{
				bodyChain = _box2D.world.CreateBody(bodyDefChain);
				bodyChain.SetUserData(this);
				_vecBodyChain.push(bodyChain);
			}
		}
		
		override protected function createShape():void {
			super.createShape();
			_shapeChain = new b2PolygonShape();
			b2PolygonShape(_shapeChain).SetAsBox(widthSegment/ws, heightSegment/ws);
		}
		
		override protected function defineFixture():void {
			super.defineFixture();
			_vecFixtureDefChain = new Vector.<b2FixtureDef>();
			var fixtureDefChain:b2FixtureDef;
			for (var i:uint = 0; i < numSegments; ++i) 
			{
				fixtureDefChain = new b2FixtureDef();
				fixtureDefChain.shape = _shapeChain;
				fixtureDefChain.density = density;
				fixtureDefChain.friction = friction;
				fixtureDefChain.restitution = restitution;	
				fixtureDefChain.filter.maskBits = PhysicsCollisionCategories.Get("GoodGuys");
				_vecFixtureDefChain.push(fixtureDefChain);
			}
		}
		
		override protected function createFixture():void {
			super.createFixture();
			var i:uint = 0;
			for each (var fixtureDefChain:b2FixtureDef in _vecFixtureDefChain) {
				_vecBodyChain[i].CreateFixture(fixtureDefChain);
				++i;
			}
		}
		
		override protected function defineJoint():void {
			_vecRevoluteJointDef = new Vector.<b2RevoluteJointDef>();
			for (var i:uint = 0; i < numSegments; ++i) {
				
				if (i == 0)
					revoluteJoint(leftAnchor.body, _vecBodyChain[i] ,new b2Vec2(leftAnchor.width/2/ws, (-leftAnchor.height/2 + heightSegment)/ws), new b2Vec2(-widthSegment/ws, 0));
				else
					revoluteJoint(_vecBodyChain[i - 1], _vecBodyChain[i],new b2Vec2(widthSegment/ws, 0), new b2Vec2(-widthSegment/ws, 0));
			}
			revoluteJoint(_vecBodyChain[numSegments-1], rightAnchor.body, new b2Vec2(widthSegment/ws, 0),new b2Vec2(-(rightAnchor.width/2/ws), (-rightAnchor.height/2 + heightSegment)/ws));
			_body.SetActive(false);
		}
		
		private function revoluteJoint(bodyA:b2Body,bodyB:b2Body,anchorA:b2Vec2,anchorB:b2Vec2):void {
			var revoluteJointDef:b2RevoluteJointDef=new b2RevoluteJointDef();
			revoluteJointDef.localAnchorA.Set(anchorA.x,anchorA.y);
			revoluteJointDef.localAnchorB.Set(anchorB.x,anchorB.y);
			revoluteJointDef.bodyA=bodyA;
			revoluteJointDef.bodyB=bodyB;
			revoluteJointDef.enableMotor = true;
			revoluteJointDef.motorSpeed = 0;
			revoluteJointDef.maxMotorTorque = 1.0;
			revoluteJointDef.collideConnected = false;
			_vecRevoluteJointDef.push(revoluteJointDef);
		}
		
		override protected function createJoint():void {
			for each (var revoluteJointDef:b2RevoluteJointDef in _vecRevoluteJointDef) {
				_box2D.world.CreateJoint(revoluteJointDef);
			}
		}
		
		public function initDisplay():void{
			var texture:Texture
			/**
			 * If useTexture set to true but no bitmapData provided the segments will get a random color
			 */
			if (segmentBitmapData == null) texture = Texture.empty(widthSegment*2, heightSegment*2, 0xff000000 + Math.random()*0xffffff);
			// Texture is sclaed to fit the width of the elements, so your image ratio should generally fit the segments
			else texture = Texture.fromBitmapData(segmentBitmapData, true, false, segmentBitmapData.width/((widthSegment)*2));
			_vecSprites = new Vector.<CitrusSprite>();
			
			for (var i:uint = 0; i < numSegments; ++i) {
				var image:CitrusSprite = new CitrusSprite(i.toString(), {group:2, width:_width*2, height:_height*2, view:new Image(texture), registration:"center"});
				_ce.state.add(image);
				_vecSprites.push(image);
			}
		}
		
		public function updateSegmentDisplay():void {
			var i:uint = 0;
			for each (var body:b2Body in _vecBodySegment) {
				_vecSprites[i].x = body.GetPosition().x * ws;
				_vecSprites[i].y = body.GetPosition().y * ws;
				_vecSprites[i].rotation = rad2deg(body.GetAngle());
				++i;
			}
		}
	}
}
