package citrus.ui.starling
{
	import starling.textures.Texture;
	import starling.display.Image;
	import citrus.ui.starling.UIGroup;

	/**
	 * @author Michelangelo Capraro (m&#64;mcapraro.com)
	 */
	public class UILives extends UIGroup
	{
		private var _textures:Array;
		private var _health:Number;
		private var _maxHealth:Number;
		private var _numLives:uint;
		private var _lives:Array;
		
		public function UILives(startHealth:Number, maxHealth:Number, lifeTextures:Array, numLives:uint = 5)
		{
			super(HORIZONTAL);

			_textures = lifeTextures;
			_padding = 2;

			if (startHealth > maxHealth)
				startHealth = maxHealth;
				
			_health = startHealth;
			_maxHealth = maxHealth;
			_numLives = numLives;
			_lives = new Array();
			
			if (lifeTextures.length < 2) {
				throw new ArgumentError(String(this) + "not enough textures.");
			}
			
			setupLives();
			refreshImages();
		}

		
		protected function setupLives():void
		{
			var i:uint = 0;
			var life:UIElement;
			for (; i < _numLives; i++)
			{
				life = add(new Image(_textures[0]));
				_lives.push(life);
			}
			refresh();
		}

		private function refreshImages():void
		{
			var oldWidth:Number = content.width;
			
			var texture:Texture;
			
			var healthPerHeart:Number = _maxHealth / _numLives;
			var texturesPerLife:uint = _textures.length;
			var currentHealth:Number = 0;
			var nextHealth:Number = 0;
			var currentHeartHealth:Number = 0;
			
			var totalStates:Number = texturesPerLife -1;
			var state:Number = totalStates;
			
			var life:UIElement;
			
			for (var i:int = 0; i < _numLives; i++)
			{		
				life = _lives[i];
				state = 0;
				
				currentHealth = i * healthPerHeart;
				nextHealth = (i + 1) * healthPerHeart;
				
				if (_health > nextHealth)
				{
					state = totalStates;
				}
				else if (_health >= currentHealth && _health <= nextHealth)
				{
					currentHeartHealth = _health - currentHealth;
					state = Math.round((currentHeartHealth / healthPerHeart)*(totalStates));
				}
				
				texture = _textures[state];
				(life.content as Image).texture = texture;
			}
			
			if (content.width != oldWidth) refresh();
		}
		
		public function set health(value:Number):void
		{
			if (value == _health)
				return;
			if (value > _maxHealth)
				value = _maxHealth;
			if (value <= 0)
				value = 0;
				
			_health = value;
			refreshImages();
		}
		
		public function get health():Number
		{
			return _health;
		}
		
		public function get maxHealth():Number
		{
			return _maxHealth;
		}	
	}
}
