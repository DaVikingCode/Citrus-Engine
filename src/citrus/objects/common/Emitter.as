package citrus.objects.common
{

	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.view.blittingview.BlittingArt;
	import citrus.view.blittingview.BlittingView;
	
	/**
	 * An emitter creates particles at a specified rate with specified distribution properties. You can set the emitter's x and y
	 * location at any time as well as change the graphic of the particles that the emitter makes.
	 */
	public class Emitter extends CitrusObject
	{
		/**
		 * The X position where the particles will emit from.
		 */
		public var x:Number = 0;
		
		/**
		 * The Y position where the particles will emit from.
		 */
		public var y:Number = 0;
		
		/**
		 * In milliseconds, how often the emitter will release new particles.
		 */
		public var emitFrequency:Number = 300;
		
		/**
		 * The number of particles that the emitter will release during each emission.
		 */
		public var emitAmount:uint = 1;
		
		/**
		 * In milliseconds, how long the particles will last before being recycled.
		 */
		public var particleLifeSpan:Number = 3000;
		
		/**
		 * The X force applied to particle velocity, in pixels per frame.
		 */
		public var gravityX:Number = 0;
		
		/**
		 * The Y force applied to particle velocity, in pixels per frame.
		 */
		public var gravityY:Number = 0;
		
		/**
		 * A number between 0 and 1 to create air resistance. Lower numbers create slow floatiness like a feather.
		 */
		public var dampingX:Number = 1;
		
		/**
		 * A number between 0 and 1 to create air resistance. Lower numbers create slow floatiness like a feather.
		 */
		public var dampingY:Number = 1;
		
		/**
		 * The minimum initial impulse velocity that a particle can have via the randomly generated impulse on the X axis.
		 */
		public var minImpulseX:Number = -10;
		
		/**
		 * The maximum initial impulse velocity that a particle can have via the randomly generated impulse on the X axis.
		 */
		public var maxImpulseX:Number = 10;
		
		/**
		 * The minimum initial impulse velocity that a particle can have via the randomly generated impulse on the Y axis.
		 */
		public var minImpulseY:Number = -10;
		
		/**
		 * The maximum initial impulse velocity that a particle can have via the randomly generated impulse on the Y axis.
		 */
		public var maxImpulseY:Number = 10;
		
		/**
		 * In milliseconds, how long the emitter lasts before destroying itself. If the value is -1, it lasts forever.
		 */
		public var emitterLifeSpan:int = -1;
		
		/**
		 * The width deviation from the x position that a particle can be created via a randomly generated number.
		 */
		public var emitAreaWidth:Number = 0;
		
		/**
		 * The height deviation from the y position that a particle can be created via a randomly generated number.
		 */
		public var emitAreaHeight:Number = 0;
		
		private var _particles:Vector.<EmitterParticle> = new Vector.<EmitterParticle>();
		private var _recycle:Array = [];
		private var _graphic:*;
		private var _particlesCreated:uint = 0;
		private var _lastEmission:Number = 0;
		private var _birthTime:Number = -1;
		
		/**
		 * Makes a particle emitter. 
		 * @param	name The name of the emitter.
		 * @param	graphic The graphic class to use to create each particle.
		 * @param	x The X position where the particles will emit from.
		 * @param	y The Y position where the particles will emit from.
		 * @param	emitFrequency In milliseconds, how often the emitter will release new particles.
		 * @param	emitAmount The number of particles that the emitter will release during each emission.
		 * @param	particleLifeSpan In milliseconds, how long the particles will last before being recycled.
		 * @param	gravityX The X force applied to particle velocity, in pixels per frame.
		 * @param	gravityY The Y force applied to particle velocity, in pixels per frame.
		 * @param	dampingX A number between 0 and 1 to create air resistance. Lower numbers create slow floatiness like a feather.
		 * @param	dampingY A number between 0 and 1 to create air resistance. Lower numbers create slow floatiness like a feather.
		 * @param	minImpulseX The minimum initial impulse velocity that a particle can have via the randomly generated impulse on the X axis.
		 * @param	maxImpulseX The maximum initial impulse velocity that a particle can have via the randomly generated impulse on the X axis.
		 * @param	minImpulseY The minimum initial impulse velocity that a particle can have via the randomly generated impulse on the Y axis.
		 * @param	maxImpulseY The maximum initial impulse velocity that a particle can have via the randomly generated impulse on the Y axis.
		 * @param	emitterLifeSpan In milliseconds, how long the emitter lasts before destroying itself. If the value is -1, it lasts forever.
		 * @param	emitAreaWidth The width deviation from the x position that a particle can be created via a randomly generated number.
		 * @param	emitAreaHeight The height deviation from the y position that a particle can be created via a randomly generated number.
		 * @return An emitter.
		 */
		public static function Make(name:String,
									graphic:*,
									x:Number,
									y:Number,
									emitFrequency:Number,
									emitAmount:Number,
									particleLifeSpan:Number,
									gravityX:Number,
									gravityY:Number,
									dampingX:Number,
									dampingY:Number,
									minImpulseX:Number,
									maxImpulseX:Number,
									minImpulseY:Number,
									maxImpulseY:Number,
									emitterLifeSpan:Number = -1,
									emitAreaWidth:Number = 0,
									emitAreaHeight:Number = 0):Emitter
		{
			return new Emitter(name, { 	graphic: graphic, x: x, y: y, emitFrequency: emitFrequency, emitAmount: emitAmount, particleLifeSpan: particleLifeSpan,
										gravityX: gravityX, gravityY: gravityY, dampingX: dampingX, dampingY: dampingY, minImpulseX: minImpulseX,
										maxImpulseX: maxImpulseX, minImpulseY: minImpulseY, maxImpulseY: maxImpulseY, emitterLifeSpan: emitterLifeSpan,
										emitAreaWidth: emitAreaWidth, emitAreaHeight: emitAreaHeight} );
		}
		
		public function Emitter(name:String, params:Object = null) 
		{
			super(name, params);
			_ce = CitrusEngine.getInstance();
		}
		
		override public function destroy():void
		{
			for each (var particle:EmitterParticle in _particles)
				particle.kill = true;
			_particles.length = 0;
			
			for each (particle in _recycle)
				particle.kill = true;
			_recycle.length = 0;
			
			super.destroy();
		}
		
		/**
		 * The graphic that will be generated for each particle. This works just like the CitrusObject's view property.
		 * The value can be 1) The path to an external image, 2) A DisplayObject class (not an instance) in String notation
		 * (view: "com.graphics.myParticle") or 3) A DisplayObject class (not an instance) in Object notation
		 * (view: MyParticle). See the documentation for ISpriteView.view for more info.
		 */
		public function get graphic():*
		{
			return _graphic;
		}
		
		public function set graphic(value:*):void
		{
			_graphic = value;
			destroyRecycle(); //clear the reusable ones, they all have to be remade
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var now:Number = new Date().time;
			var particle:EmitterParticle;
			var emitterExpired:Boolean = (emitterLifeSpan != -1 && _birthTime != -1 && _birthTime + emitterLifeSpan <= now);
			
			//check to see if any particles should be destroyed
			for (var i:int = _particles.length - 1; i >= 0; i--)
			{
				particle = _particles[i];
				if (particle.birthTime + particleLifeSpan <= now)
				{
					if (particle.canRecycle)
					{
						particle.visible = false;
						_recycle.push(particle);
					}
					else
					{
						particle.kill = true;
					}
					_particles.splice(_particles.indexOf(particle), 1);
				}
			}
			
			//generate more particles if necessary
			if (!emitterExpired && now - _lastEmission >= emitFrequency)
			{
				_lastEmission = now;
				
				for (i = 0; i < emitAmount; i++ )
				{
					particle = getOrCreateParticle(now);
				}
				
				//Set the emitter's birth time if this is the first emission.
				if (_birthTime == -1)
					_birthTime = now;
			}
			
			//update positions on existing particles.
			for each (particle in _particles)
			{
				particle.velocityX += gravityX;
				particle.velocityY += gravityY;
				particle.velocityX *= dampingX;
				particle.velocityY *= dampingY;
				
				particle.x += (particle.velocityX * timeDelta);
				particle.y += (particle.velocityY * timeDelta);
			}
			
			//should we destroy the emitter?
			if (emitterExpired && _particles.length == 0)
				kill = true;
		}
		
		private function getOrCreateParticle(birthTime:Number):EmitterParticle
		{
			var particle:EmitterParticle = _recycle.pop();
			
			if (!particle)
			{
				if (_ce.state.view is BlittingView)
				{
					particle = new EmitterParticle(name + "_" + _particlesCreated++, {view: new BlittingArt(graphic)});
				}
				else
				{
					particle = new EmitterParticle(name + "_" + _particlesCreated++, { view: graphic } );
				}
				
				_ce.state.add(particle);
			}
			
			_particles.push(particle);
			particle.x = Math.random() * emitAreaWidth + (x - emitAreaWidth / 2);
			particle.y = Math.random() * emitAreaHeight + (y - emitAreaHeight / 2);
			particle.velocityX = Math.random() * (maxImpulseX - minImpulseX) + minImpulseX;
			particle.velocityY = Math.random() * (maxImpulseY - minImpulseY) + minImpulseY;
			particle.birthTime = birthTime;
			particle.visible = true;
			
			return particle;
		}
		
		private function destroyRecycle():void
		{
			for each (var particle:EmitterParticle in _recycle)
				particle.kill = true;
			_recycle.length = 0;
			
			for each (particle in _particles)
				particle.canRecycle = false;
		}
	}

}