package citrus.objects.platformer.nape
{
    import citrus.math.MathVector;
    import citrus.objects.NapePhysicsObject;
    import citrus.physics.nape.NapeUtils;
    
    import nape.callbacks.InteractionCallback;
    import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyType;

    public class MovingPlatform extends Platform
    {
        private var _speed:Number = 1;

        private var _enabled:Boolean = true;

        private var _waitForPassangers:Boolean = false;

        private var _passangers:Vector.<Body> = new Vector.<Body>;

        private var _forward:Boolean = true;

        private var _start:MathVector = new MathVector();

        private var _end:MathVector = new MathVector();

        public function MovingPlatform(name:String, params:Object = null)
        {
            super(name, params);
        }

        public function get speed():Number
        {
            return _speed;
        }

        public function set speed(value:Number):void
        {
            _speed = value;
        }

        public function get enabled():Boolean
        {
            return _enabled;
        }

        public function set enabled(value:Boolean):void
        {
            _enabled = value;
        }

        public function get waitForPassangers():Boolean
        {
            return _waitForPassangers;
        }

        public function set waitForPassangers(value:Boolean):void
        {
            _waitForPassangers = value;
        }

        public function get startX():Number
        {
            return _start.x;
        }

        public function set startX(value:Number):void
        {
            _start.x = value;
        }

        public function get startY():Number
        {
            return _start.y;
        }

        public function set startY(value:Number):void
        {
            _start.y = value;
        }

        public function get endX():Number
        {
            return _end.x;
        }

        public function set endX(value:Number):void
        {
            _end.x = value;
        }

        public function get endY():Number
        {
            return _end.y;
        }

        public function set endY(value:Number):void
        {
            _end.y = value;
        }

        override public function update(timeDelta:Number):void
        {
            super.update(timeDelta);

            var velocity:Vec2;

            if ((waitForPassangers && _passangers.length == 0) || !enabled)
            {
                // Platform should not move
                velocity = new Vec2();
            }
            else
            {
                // Move the platform according to its destination
                var destination:Vec2 = _forward ? new Vec2(_end.x, _end.y) : new Vec2(_start.x, _start.y);
                destination.subeq(body.position);

                velocity = destination;

                if (velocity.length > _speed)
                {
                    // Still has futher to go. Normalize the velocity to the speed
                    velocity.normalise();
                    velocity.muleq(_speed);
                }
                else
                {
                    // Destination is very close. Switch travelling direction 
                    _forward = !_forward;
                }
            }

            _body.velocity.set(velocity);
        }

        override protected function defineBody():void
        {
            super.defineBody();
            _bodyType = BodyType.KINEMATIC;
        }

        override public function handleBeginContact(callback:InteractionCallback):void
        {
            var other:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
            _passangers.push(other.body);
        }

        override public function handleEndContact(callback:InteractionCallback):void
        {
            var other:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
            _passangers.splice(_passangers.indexOf(other.body), 1);
        }
    }
}