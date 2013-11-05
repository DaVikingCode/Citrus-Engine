package citrus.ui.starling.basic 
{
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author gsynuh
	 */
	public class BasicUIHearts extends BasicUIElement
	{
		
		protected var _life:Number = 0;
		protected var _maxlife:Number = 0;
		protected var _numHearts:uint = 0;
		protected var _textures:Array = [];
		protected var _hearts:Array = [];
		protected var _padding:Number = 10;
		
		public function BasicUIHearts(startLife:Number,maxLife:Number,textures:Array,numHearts:uint = 5, padding:Number = 10) 
		{	
			if (startLife > maxLife)
				startLife = maxLife;
				
			_life = startLife;
			_maxlife = maxLife;
			_textures = textures;
			_numHearts = numHearts;
			_padding = padding;
			
			super(new Sprite());
			
			if (textures.length < 2)
				throw new ArgumentError(String(this) + "not enough textures.");
			
			setupHearts();
			refreshLife();
		}
		
		protected function setupHearts():void
		{
			var i:uint = 0;
			var heart:Image;
			for (; i < _numHearts; i++)
			{
				heart = new Image(_textures[0]);
				heart.x = heart.y = 0;
				(_content as DisplayObjectContainer).addChild(heart);
				heart.x = i * (heart.width + _padding);
				_hearts[i] = heart;
			}
			resetContentPosition();
		}
		
		protected function refreshLife():void
		{
			var i:uint = 0;
			var heart:Image;
			var texture:Texture;
			
			var lifePerHeart:Number = _maxlife / _numHearts;
			var texturesPerHeart:uint = _textures.length;
			var currentLife:Number = 0;
			var nextLife:Number = 0;
			var currentHeartLife:Number = 0;
			
			var totalstates:Number = texturesPerHeart -1;
			var state:Number = totalstates;
			
			for (; i < _numHearts; i++)
			{		
				heart = _hearts[i];
				state = 0;
				
				currentLife = i * lifePerHeart;
				nextLife = (i + 1) * lifePerHeart;
				
				if (_life > nextLife)
				{
					state = totalstates;
				}
				else if (_life >= currentLife && _life <= nextLife)
				{
					currentHeartLife = _life - currentLife;
					state = Math.round((currentHeartLife / lifePerHeart)*(totalstates));
				}
				
				texture = _textures[state];
				heart.texture = texture;
			}
		}
		
		override public function destroy():void
		{
			_hearts.length = 0;
			_textures.length = 0;
			super.destroy();
		}
		
		public function set life(value:Number):void
		{
			if (value == _life)
				return;
			if (value > _maxlife)
				value = _maxlife;
			if (value <= 0)
				value = 0;
				
			_life = value;
			refreshLife();
		}
		
		public function get life():Number
		{
			return _life;
		}
		
		public function get maxLife():Number
		{
			return _maxlife;
		}
		
	}

}