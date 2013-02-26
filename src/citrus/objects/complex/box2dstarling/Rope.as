package citrus.objects.complex.box2dstarling {
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DUtils;
	
	import org.osflash.signals.Signal;
	
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	public class Rope extends Box2DPhysicsObject {
		
		public var anchor:Box2DPhysicsObject;		
		public var ropeLength:uint = 200;
		public var numSegments:uint = 9;
		public var widthSegment:uint = 15;
		public var useTexture:Boolean = false;		
		public var segmentBitmapData:BitmapData;
		public var hero:Hero;
		
		
		private var ws:Number = 30;//worldscale
		private var heightSegment:uint;
		
		private var _vecBodyDefRope:Vector.<b2BodyDef>;
		private var _vecBodyRope:Vector.<b2Body>;
		private var _vecFixtureDefRope:Vector.<b2FixtureDef>;
		private var _vecRevoluteJointDef:Vector.<b2RevoluteJointDef>;
		private var _shapeRope:b2Shape;
		
		private var connectingJoint:b2Joint;
		private var targetJointIndex:int;
		
		private var displayReady:Boolean = false;
		private var ropeAdded:Boolean = false;		
		private var up:Boolean = true;
		private var timerUp:Timer;
		
		public var onHang:Signal;
		public var onHangEnd:Signal;
		private var _vecSprites:Vector.<CitrusSprite>;
		
		public function Rope(name:String, params:Object = null) {
			super(name, params);
			timerUp = new Timer(50, 0);
			timerUp.addEventListener(TimerEvent.TIMER, onUptimer);
			onHang = new Signal;
			onHangEnd = new Signal;
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			if (displayReady)
				updateSegmentDisplay();
		}
		
		override protected function defineBody():void {
			super.defineBody();
			
			heightSegment = ropeLength/numSegments
			if (useTexture)
			{
				initDisplay();
			}
			_vecBodyDefRope = new Vector.<b2BodyDef>();
			var bodyDefRope:b2BodyDef;
			for (var i:uint = 0; i < numSegments; ++i) 
			{
				bodyDefRope = new b2BodyDef();
				bodyDefRope.type = b2Body.b2_dynamicBody;
				bodyDefRope.position.Set(anchor.x/ws, anchor.y/ws + anchor.height/2/ws + i*heightSegment/ws);
				_vecBodyDefRope.push(bodyDefRope);
			}
		}
		
		override protected function createBody():void {
			super.createBody();
			_vecBodyRope = new Vector.<b2Body>();
			var bodyRope:b2Body;
			for each (var bodyDefRope:b2BodyDef in _vecBodyDefRope) 
			{
				bodyRope = _box2D.world.CreateBody(bodyDefRope);
				bodyRope.SetUserData(this);
				_vecBodyRope.push(bodyRope);
			}
		}
		
		override protected function createShape():void {
			super.createShape();
			_shapeRope = new b2PolygonShape();
			b2PolygonShape(_shapeRope).SetAsBox(widthSegment/ws, heightSegment/ws);
		}
		
		override protected function defineFixture():void {
			super.defineFixture();
			_vecFixtureDefRope = new Vector.<b2FixtureDef>();
			var fixtureDefRope:b2FixtureDef;
			for (var i:uint = 0; i < numSegments; ++i) 
			{
				fixtureDefRope = new b2FixtureDef();
				fixtureDefRope.shape = _shapeRope;
				fixtureDefRope.density = 35;
				fixtureDefRope.friction = 1;
				fixtureDefRope.restitution = 0;	
				fixtureDefRope.userData = {name:i};	
				_vecFixtureDefRope.push(fixtureDefRope);
			}
		}
		
		override protected function createFixture():void {
			super.createFixture();
			var i:uint = 0;
			for each (var fixtureDefRope:b2FixtureDef in _vecFixtureDefRope) {
				_vecBodyRope[i].CreateFixture(fixtureDefRope);
				++i;
			}
		}
		
		override protected function defineJoint():void {
			_vecRevoluteJointDef = new Vector.<b2RevoluteJointDef>();
			for (var i:uint = 0; i < numSegments; ++i) {
				
				if (i == 0)
					revoluteJoint(anchor.body, _vecBodyRope[i] ,new b2Vec2(0, anchor.height/2/ws), new b2Vec2(0, -heightSegment/ws));
				else
					revoluteJoint(_vecBodyRope[i - 1], _vecBodyRope[i],new b2Vec2(0, (heightSegment-2)/ws), new b2Vec2(0, -heightSegment/ws));
			}
			_body.SetActive(false);
		}
		
		private function revoluteJoint(bodyA:b2Body,bodyB:b2Body,anchorA:b2Vec2,anchorB:b2Vec2):void {
			var revoluteJointDef:b2RevoluteJointDef=new b2RevoluteJointDef();
			revoluteJointDef.localAnchorA.Set(anchorA.x,anchorA.y);
			revoluteJointDef.localAnchorB.Set(anchorB.x,anchorB.y);
			revoluteJointDef.bodyA=bodyA;
			revoluteJointDef.bodyB=bodyB;
			revoluteJointDef.motorSpeed = 0;
			revoluteJointDef.enableMotor = true;
			revoluteJointDef.maxMotorTorque = 0.1;
			revoluteJointDef.collideConnected = false;
			_vecRevoluteJointDef.push(revoluteJointDef);
		}
		
		override protected function createJoint():void {
			for each (var revoluteJointDef:b2RevoluteJointDef in _vecRevoluteJointDef) {
				_box2D.world.CreateJoint(revoluteJointDef);
			}
		}
		
		override public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			contact.SetEnabled(false);
			if (Box2DUtils.CollisionGetOther(this, contact) is Hero){
				if (!ropeAdded  && !hero.body.GetJointList()) 
				{
					targetJointIndex = int(((hero.getBody().GetPosition().y*ws - (hero.height)/2) - _vecBodyRope[0].GetPosition().y*ws)/(heightSegment*2-2));
					if (targetJointIndex < 1) targetJointIndex = 1;
					else if (targetJointIndex > _vecBodyRope.length-1) targetJointIndex = _vecBodyRope.length-1;
					
					revoluteJoint(_vecBodyRope[targetJointIndex], hero.body, new b2Vec2(0, heightSegment/ws),new b2Vec2(0, -((hero.height+75)/2/ws)));
					connectingJoint = _box2D.world.CreateJoint(_vecRevoluteJointDef[_vecRevoluteJointDef.length-1]);
					ropeAdded = true;
					(hero as HeroSnowman).isHanging = true;
					(hero as HeroSnowman).currentRope = this.name;
					hero.body.SetFixedRotation(false);
					hero.maxVelocity = 55;
					onHang.dispatch();
				}
			}
		}
		
		protected function onUptimer(event:TimerEvent=null):void
		{
			if (up && targetJointIndex >= 1) 
			{
				timerUp.delay = 150;
				_box2D.world.DestroyJoint(connectingJoint);
				_vecRevoluteJointDef[_vecRevoluteJointDef.length-1] = null;
				revoluteJoint(_vecBodyRope[targetJointIndex-1], hero.body, new b2Vec2(0, heightSegment/ws),new b2Vec2(0, -((hero.height+75)/2/ws)));
				connectingJoint = _box2D.world.CreateJoint(_vecRevoluteJointDef[_vecRevoluteJointDef.length-1]);
				targetJointIndex--;
			}
			else if (up && targetJointIndex == 0) {
				_box2D.world.DestroyJoint(connectingJoint);
				_vecRevoluteJointDef[_vecRevoluteJointDef.length-1] = null;
				revoluteJoint(anchor.body, hero.body,new b2Vec2(0, anchor.height/2/ws), new b2Vec2(0, -((hero.height+75)/2/ws)));
				connectingJoint = _box2D.world.CreateJoint(_vecRevoluteJointDef[_vecRevoluteJointDef.length-1]);
			}
			else if (!up && targetJointIndex < _vecBodyRope.length-1) 
			{
				timerUp.delay = 50;
				_box2D.world.DestroyJoint(connectingJoint);
				_vecRevoluteJointDef[_vecRevoluteJointDef.length-1] = null;
				revoluteJoint(_vecBodyRope[targetJointIndex+1], hero.body, new b2Vec2(0, heightSegment/ws),new b2Vec2(0, -((hero.height+75)/2/ws)));
				connectingJoint = _box2D.world.CreateJoint(_vecRevoluteJointDef[_vecRevoluteJointDef.length-1]);
				targetJointIndex++;
			}
		}
		
		public function startClimbing(u:Boolean):void
		{
			up = u;
			onUptimer();
			timerUp.start();
		}
		
		public function stopClimbing():void
		{
			timerUp.reset();
		}
		
		public function removeJoint():void
		{
			_box2D.world.DestroyJoint(connectingJoint);
			_vecRevoluteJointDef[_vecRevoluteJointDef.length-1] = null;
			connectingJoint = null;
			(hero as HeroSnowman).isHanging = false;
			onHangEnd.dispatch();
			hero.body.ApplyImpulse(new b2Vec2(0, -150), hero.body.GetWorldCenter());
			hero.body.SetAngle(deg2rad(0));
			hero.body.SetAngularVelocity(0);
			hero.body.SetFixedRotation(true);
			hero.maxVelocity = 7;
			setTimeout(function():void{ropeAdded = false;}, 1000);
		}
		
		private function initDisplay():void {
			displayReady = true;
			var texture:Texture;
			
			 	//If useTexture set to true but no bitmapData provided the segments will get a random color
			if (segmentBitmapData == null) texture = Texture.empty(heightSegment * 2, widthSegment * 2, 0xff000000 + Math.random() * 0xffffff);
				// Texture is sclaed to fit the width of the elements, so your image ratio should generally fit the segments
			else texture = Texture.fromBitmapData(segmentBitmapData, true, false, segmentBitmapData.width / ((heightSegment) * 2));
			_vecSprites = new Vector.<CitrusSprite>();
			
			for (var i:uint = 0; i < numSegments; ++i) {
				var image:CitrusSprite = new CitrusSprite(i.toString(), {group:2, width:heightSegment * 2, height:widthSegment * 2, view:new Image(texture), registration:"center"});
				_ce.state.add(image);
				_vecSprites.push(image);
			}
		}
		
		private function updateSegmentDisplay():void {
			var i:uint = 0;
			for each (var bodyRope:b2Body in _vecBodyRope) {
				_vecSprites[i].x = bodyRope.GetPosition().x * ws;
				_vecSprites[i].y = bodyRope.GetPosition().y * ws;
				_vecSprites[i].rotation = rad2deg(bodyRope.GetAngle())+90;
				++i;
			}
		}
	}
}
