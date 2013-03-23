package citrus.objects.complex.box2dstarling {

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;

	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.physics.PhysicsCollisionCategories;

	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.extensions.filters.ThresholdFilter;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;

	/**
	 * Example Object for simulating liquid using thresholdfilter.
	 * Its a rotating box, just place it anywhere. You need to include ThresholdFilter.as
	 * #author Thomas Zenkner
	 */
	public class FluidBox extends Box2DPhysicsObject {

		public var bcWidth:Number = 550;
		public var bcHeight:Number = 240;
		public var bcThickness:Number = 40;
		public var ws:int = 30;
		public var numBalls:int = 15;
		
		private var ball:b2Body;
		private var ballFixtureDef:b2FixtureDef;
		private var ballFixture:b2Fixture;
		private var ballshape:b2CircleShape;
		private var ballBodyDef:b2BodyDef;
		private var _vecSprites:Vector.<CitrusSprite>;
		private var _vecBody:Vector.<b2Body>;
		private var texture:Texture;
		private var thresholdFilter:ThresholdFilter;
		private var renderTexture:RenderTexture;
		private var renderSprite:CitrusSprite;
		private var m:Matrix;
		private var ballRadius:uint = 10;
		private var offX:Number;
		private var offY:Number;
		private var anchor:Box2DPhysicsObject;
		private var circleShape:Shape;
		private var circleData:BitmapData;

		public function FluidBox(name:String, params:Object = null) {
			
			updateCallEnabled = true;
			
			super(name, params);
		}

		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			
			var i:uint = 0;
			if (_vecSprites[0]) {
				
				for each (var ball:b2Body in _vecBody) {
					
					_vecSprites[i].x = _vecBody[i].GetPosition().x * ws;
					_vecSprites[i].y = _vecBody[i].GetPosition().y * ws;
					_vecSprites[i].rotation = rad2deg(_vecBody[i].GetAngle());
					++i;
				}
				
				renderTexture.drawBundled(function():void {
					i = 0;
					for each (var image:CitrusSprite in _vecSprites) {
						m.identity();
						m.translate(image.x - offX, image.y - offY);
						renderTexture.draw(image.view, m);
						++i;
					}
				});
			}
		}

		override protected function defineBody():void {
			
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_dynamicBody;
			_bodyDef.position.Set(x / ws, y / ws);
			
			ballBodyDef = new b2BodyDef();
			ballBodyDef.type = b2Body.b2_dynamicBody;
		}

		override protected function createBody():void {
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
		}

		override protected function createShape():void {
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(bcWidth / 2 / ws, bcThickness / 2 / ws, new b2Vec2(), deg2rad(0));
			ballshape = new b2CircleShape(10 / ws);
		}

		override protected function defineFixture():void {
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.density = 1;
			_fixtureDef.friction = 0;
			_fixtureDef.restitution = 0.7;
		}

		override protected function createFixture():void {
			
			_fixture = _body.CreateFixture(_fixtureDef);
			ballFixtureDef = new b2FixtureDef();
			ballFixtureDef.density = 1;
			ballFixtureDef.friction = 0;
			ballFixtureDef.restitution = 0.7;
			
			_shape = new b2PolygonShape();
			b2PolygonShape(_shape).SetAsOrientedBox(bcWidth / 2 / ws, bcThickness / 2 / ws, new b2Vec2(0, -bcHeight / ws + bcThickness / ws));
			_fixtureDef.shape = _shape;
			_body.CreateFixture(_fixtureDef);
			b2PolygonShape(_shape).SetAsOrientedBox(bcThickness / 2 / ws, bcHeight / 2 / ws, new b2Vec2((bcWidth / 2 + bcThickness / 2) / ws, -(bcHeight / 2 / ws - bcThickness / 2 / ws)));
			_fixtureDef.shape = _shape;
			_body.CreateFixture(_fixtureDef);
			b2PolygonShape(_shape).SetAsOrientedBox(bcThickness / 2 / ws, bcHeight / 2 / ws, new b2Vec2((-bcWidth / 2 - bcThickness / 2) / ws, -(bcHeight / 2 / ws - bcThickness / 2 / ws)));
			_fixtureDef.shape = _shape;
			_body.CreateFixture(_fixtureDef);
			
			var blur:int = 35;
			circleShape = new Shape();
			circleShape.graphics.beginFill(0x0099ff, 0.8);
			circleShape.graphics.drawCircle(ballRadius * 2, ballRadius * 2, ballRadius * 2);
			circleShape.graphics.endFill();
			circleShape.filters = [new BlurFilter(blur, blur)];
			
			m = new Matrix();
			m.translate(blur, blur);
			circleData = new BitmapData(ballRadius * 4 + 2 * blur, ballRadius * 4 + 2 * blur, true, 0x00000000);
			circleData.draw(circleShape, m);
			texture = Texture.fromBitmapData(circleData, true, true, 1);
			
			_vecSprites = new Vector.<CitrusSprite>();
			_vecBody = new Vector.<b2Body>();
			thresholdFilter = new ThresholdFilter(0.7);
			renderTexture = new RenderTexture(bcWidth + 2 * bcThickness + 10, bcHeight * 4, false);
			
			var fi:Image = new Image(renderTexture);
			fi.filter = thresholdFilter;
			fi.blendMode = BlendMode.ADD;
			renderSprite = new CitrusSprite("render", {view:fi, x:x, y:y - bcHeight / 2 + bcThickness / 2, group:3, width:100, height:100, registration:"center"});
			_ce.state.add(renderSprite);
			
			anchor = new Box2DPhysicsObject("anchor", {x:renderSprite.x, y:renderSprite.y});
			anchor.body.SetType(b2Body.b2_staticBody);
			var filter:b2FilterData = new b2FilterData();
			filter.maskBits = PhysicsCollisionCategories.GetNone();
			anchor.body.GetFixtureList().SetFilterData(filter);
			_ce.state.add(anchor);
			
			offX = renderSprite.x - renderTexture.width / 2 + texture.width / 2;
			offY = renderSprite.y - renderTexture.height / 2 + texture.height / 2;
			m = new Matrix();
			
			for (var i:int = 0; i < 4; i++) {
				for (var j:int = 0; j < numBalls; j++) {
					ballBodyDef.position.Set(x / ws - bcWidth / 2 / ws + 25 / ws + j * 30 / ws, y / ws - 30 / ws - 30 / ws * i);
					ball = _box2D.world.CreateBody(ballBodyDef);
					ball.SetUserData(this);
					ballshape = new b2CircleShape(ballRadius / ws);
					ballFixtureDef.shape = ballshape;
					ball.CreateFixture(ballFixtureDef);
					var image:CitrusSprite = new CitrusSprite(i.toString(), {x:ball.GetPosition().x * ws, y:ball.GetPosition().y * ws, group:2, width:_width * 2, height:_height * 2, view:new Image(texture), registration:"center"});
					_vecSprites.push(image);
					_vecBody.push(ball);
				}
			}
		}

		override protected function defineJoint():void {
			revoluteJoint(anchor.body, _body, new b2Vec2(0, 0), new b2Vec2(0, -bcHeight / 2 / ws + bcThickness / 2 / ws));
		}

		private function revoluteJoint(bodyA:b2Body, bodyB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2):void {
			var revoluteJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			revoluteJointDef.localAnchorA.Set(anchorA.x, anchorA.y);
			revoluteJointDef.localAnchorB.Set(anchorB.x, anchorB.y);
			revoluteJointDef.bodyA = bodyA;
			revoluteJointDef.bodyB = bodyB;
			revoluteJointDef.motorSpeed = Math.PI / 16;
			revoluteJointDef.enableMotor = true;
			revoluteJointDef.maxMotorTorque = 10000;
			revoluteJointDef.collideConnected = false;
			_box2D.world.CreateJoint(revoluteJointDef);
		}
	}
}