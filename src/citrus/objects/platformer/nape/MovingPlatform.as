package citrus.objects.platformer.nape
{
    import citrus.math.MathVector;
    import citrus.objects.NapePhysicsObject;
    import citrus.objects.common.Path;
    import citrus.physics.nape.NapeUtils;

    import nape.callbacks.InteractionCallback;
    import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyType;

    /**
     * A platform that moves between two points. The MovingPlatform has several properties that can customize it.
     *
     * <ul>Properties:
     * <li>speed - The speed at which the moving platform travels.</li>
     * <li>enabled - Whether or not the MovingPlatform can move, no matter the condition.</li>
     * <li>startX -  The initial starting X position of the MovingPlatform, and the place it returns to when it reaches the end destination.</li>
     * <li>startY -  The initial starting Y position of the MovingPlatform, and the place it returns to when it reaches the end destination.</li>
     * <li>endX -  The ending X position of the MovingPlatform, and the place it returns to when it reaches the start destination.</li>
     * <li>endY -  The ending Y position of the MovingPlatform, and the place it returns to when it reaches the start destination.</li>
     * <li>waitForPassenger - If set to true, MovingPlatform will not move unless there is a passenger. If set to false, it continually moves.</li></ul>
     */
    public class MovingPlatform extends Platform
    {
        /**
		 * The speed at which the moving platform travels. 
		 */
		[Inspectable(defaultValue="1")]
		public var speed:Number = 1;
		
		/**
		 * Whether or not the MovingPlatform can move, no matter the condition. 
		 */		
		[Inspectable(defaultValue="true")]
		public var enabled:Boolean = true;
		
		/**
		 * If set to true, the MovingPlatform will not move unless there is a passenger. 
		 */
		[Inspectable(defaultValue="false")]
		public var waitForPassenger:Boolean = false;
		
		protected var _start:MathVector = new MathVector();
		protected var _end:MathVector = new MathVector();
		protected var _forward:Boolean = true;
		protected var _passangers:Vector.<Body> = new Vector.<Body>();

        protected var _path:Path;
        protected var _pathIndex:int = 0;

        public function MovingPlatform(name:String, params:Object = null)
        {
            super(name, params);
        }

        public function get path():Path
        {
            return _path;
        }

        public function set path(value:Path):void
        {
            _path = value;
        }
		
		override public function set x(value:Number):void
		{
			super.x = value;
			
			_start.x = value;
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;
			
			_start.y = value;
		}

        /**
         * The initial starting X position of the MovingPlatform, and the place it returns to when it reaches
         * the end destination.
         */
        public function get startX():Number
        {
            return _start.x;
        }
		
		[Inspectable(defaultValue="0")]
        public function set startX(value:Number):void
        {
            _start.x = value;
        }

        /**
         * The initial starting Y position of the MovingPlatform, and the place it returns to when it reaches
         * the end destination.
         */
        public function get startY():Number
        {
            return _start.y;
        }
		
		[Inspectable(defaultValue="0")]
        public function set startY(value:Number):void
        {
            _start.y = value;
        }

        /**
         * The ending X position of the MovingPlatform.
         */
        public function get endX():Number
        {
            return _end.x;
        }
		
		[Inspectable(defaultValue="0")]
        public function set endX(value:Number):void
        {
            _end.x = value;
        }

        /**
         * The ending Y position of the MovingPlatform.
         */
        public function get endY():Number
        {
            return _end.y;
        }
		
		[Inspectable(defaultValue="0")]
        public function set endY(value:Number):void
        {
            _end.y = value;
        }

        override public function update(timeDelta:Number):void
        {
            super.update(timeDelta);

            var velocity:Vec2;

            if ((waitForPassenger && _passangers.length == 0) || !enabled)
            {
                // Platform should not move
                velocity = new Vec2();
            }
            else
            {
                // Move the platform according to its destination
                var destination:Vec2;

                if (_path)
                {
                    var dmv:MathVector = _path.getPointAt(_pathIndex);
                    destination = new Vec2(dmv.x, dmv.y);
                }
                else
                {
                    destination = _forward ? new Vec2(_end.x, _end.y) : new Vec2(_start.x, _start.y);
                }

                destination.subeq(body.position);
                velocity = destination;

                if (velocity.length >= 1)
                {
                    // Still has futher to go. Normalize the velocity to the speed
                    velocity.normalise();
                    velocity.muleq(speed);
                }
                else
                {
                    if (_path)
                    {
                        if (_path.isPolygon)
                        {
                            _pathIndex++;

                            if (_pathIndex == _path.length)
                            {
                                _pathIndex = 0;
                                _forward = true;
                            }
                        }
                        else
                        {
                            if (_forward)
                            {
                                _pathIndex++;
                                if (_pathIndex == _path.length)
                                {
                                    _forward = false;
                                    _pathIndex = _path.length - 2;
                                }
                            }
                            else
                            {
                                _pathIndex--;
                                if (_pathIndex == -1)
                                {
                                    _forward = true;
                                    _pathIndex = 1;
                                }
                            }
                        }
                    }
                    else
                    {
                        _forward = !_forward;
                    }
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
