package citrus.math {
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class MathUtils {
		public static function DistanceBetweenTwoPoints(x1 : Number, x2 : Number, y1 : Number, y2 : Number) : Number {
			var dx : Number = x1 - x2;
			var dy : Number = y1 - y2;

			return Math.sqrt(dx * dx + dy * dy);
		}

		public static function RotateAroundInternalPoint(object : DisplayObject, pointToRotateAround : Point, rotation : Number) : void {
			// Thanks : http://blog.open-design.be/2009/02/05/rotate-a-movieclipdisplayobject-around-a-point/

			var m : Matrix = object.transform.matrix;

			var point : Point = pointToRotateAround;
			point = m.transformPoint(point);

			RotateAroundExternalPoint(object, point, rotation);
		}

		public static function RotateAroundExternalPoint(object : DisplayObject, pointToRotateAround : Point, rotation : Number) : void {
			var m : Matrix = object.transform.matrix;

			m.translate(-pointToRotateAround.x, -pointToRotateAround.y);
			m.rotate(rotation * (Math.PI / 180));
			m.translate(pointToRotateAround.x, pointToRotateAround.y);

			object.transform.matrix = m;
		}

		/**
		 * Rotates x,y around Origin (like MathVector.rotate() )
		 * if resultPoint is define, will set resultPoint to new values, otherwise, it will return a new point.
		 * @param	p flash.geom.Point
		 * @param	a angle in radians
		 * @return	returns a new rotated point.
		 */
		public static function rotatePoint(x : Number, y : Number, a : Number, resultPoint : Point = null) : Point {
			var c : Number = Math.cos(a);
			var s : Number = Math.sin(a);
			if (resultPoint) {
				resultPoint.setTo(x * c + y * s, -x * s + y * c);
				return null;
			} else
				return new Point(x * c + y * s, -x * s + y * c);
		}

		/**
		 * Get the linear equation from two points.
		 * @return an object, m is the slope and b a constant term.
		 */
		public static function lineEquation(p0 : Point, p1 : Point) : Object {
			var a : Number = (p1.y - p0.y) / (p1.x - p0.x);
			var b : Number = p0.y - a * p0.x;

			return {m:a, b:b};
		}

		/**
		 * Linear interpolation function
		 * @param	a start value
		 * @param	b end value
		 * @param	ratio interpolation amount
		 * @return
		 */
		public static function lerp(a : Number, b : Number, ratio : Number) : Number {
			return a + (b - a) * ratio;
		}

		/**
		 * returns the lerp parameter ( between 0 and 1) that produces the interpolant 'value' within the [a,b] range
		 * accepts a>b or b<a but does not clamp value to [a,b] range.
		 */
		public static function InverseLerp(a : Number, b : Number, value : Number) : Number {
			if (a > b) {
				return (value - b) / (a - b) ;
			} else if (a < b) {
				return (value - a) / (b - a);
			} else {
				throw new ArgumentError("a argument must be different from b argument.");
			}
		}
		
		/**
		 * maps value from ranges A to B with 
		 * 
		 * - range A : [minA,maxA] 
		 * - range B : [minB,maxB]
		 * 
		 * if minB is 0 and maxB is 1, in other words if we want to map the value to the [0,1] range,
		 * map will act like the InverseLerp function 
		 * 
		 * warning : return value is clamped withing range B.
		 * 
		 * example : 
		 * 
		 * input value is assumed to be withing the [-10,10] range.
		 * required range is :[20,40].
		 * 
		 * map(-24,-10,10,20,40); // 20 (input value is out of range A, result is clamped)
		 * map(-10,-10,10,20,40); // 20 (input is the minimum value of range A, so output  will be the minimum value of range B)
		 * map(0,-10,10,20,40); // 30 (input is middle of range A, output is middle of range B)
		 * map(10,-10,10,20,40); // 40(input is max of range A, so output is max of range B)
		 * 
		 * @param value value within range A
		 * @param minA minimum value of range A
		 * @param maxA maximum value of range A
		 * @param minB minimum value of range B
		 * @param maxB maximum value of range B
		 */
		public static function map(value:Number,minA:Number,maxA:Number,minB:Number=0,maxB:Number=1):Number {
			var t:Number = clamp01(InverseLerp(minA, maxA, value));
			return t*(maxB - minB) + minB;
		}

		/**
		 * Creates the axis aligned bounding box for a rotated rectangle.
		 * @param w width of the rotated rectangle
		 * @param h height of the rotated rectangle
		 * @param a angle of rotation around the topLeft point in radian
		 * @return flash.geom.Rectangle
		 */
		public static function createAABB(x : Number, y : Number, w : Number, h : Number, a : Number = 0) : Rectangle {
			var aabb : Rectangle = new Rectangle(x, y, w, h);

			if (a == 0)
				return aabb;

			var c : Number = Math.cos(a);
			var s : Number = Math.sin(a);
			var cpos : Boolean;
			var spos : Boolean;

			if (s < 0) {
				s = -s;
				spos = false;
			} else {
				spos = true;
			}
			if (c < 0) {
				c = -c;
				cpos = false;
			} else {
				cpos = true;
			}

			aabb.width = h * s + w * c;
			aabb.height = h * c + w * s;

			if (cpos)
				if (spos)
					aabb.x -= h * s;
				else
					aabb.y -= w * s;
			else if (spos) {
				aabb.x -= w * c + h * s;
				aabb.y -= h * c;
			} else {
				aabb.x -= w * c;
				aabb.y -= w * s + h * c;
			}

			return aabb;
		}

		/**
		 * Creates the axis aligned bounding box for a rotated rectangle
		 * and offsetX , offsetY which is simply the x and y position of
		 * the aabb relative to the rotated rectangle. the rectangle and the offset values are returned through an object.
		 * such object can be re-used by passing it through the last argument.
		 * @param w width of the rotated rectangle
		 * @param h height of the rotated rectangle
		 * @param a angle of rotation around the topLeft point in radian
		 * @param aabbdata the object to store the results in.
		 * @return {rect:flash.geom.Rectangle,offsetX:Number,offsetY:Number}
		 */
		public static function createAABBData(x : Number, y : Number, w : Number, h : Number, a : Number = 0, aabbdata : Object = null) : Object {
			if (aabbdata == null) {
				aabbdata = {offsetX:0, offsetY:0, rect:new Rectangle()};
			}

			aabbdata.rect.setTo(x, y, w, h);
			var offX : Number = 0;
			var offY : Number = 0;

			if (a == 0) {
				aabbdata.offsetX = 0;
				aabbdata.offsetY = 0;
				return aabbdata;
			}

			var c : Number = Math.cos(a);
			var s : Number = Math.sin(a);
			var cpos : Boolean;
			var spos : Boolean;

			if (s < 0) {
				s = -s;
				spos = false;
			} else {
				spos = true;
			}
			if (c < 0) {
				c = -c;
				cpos = false;
			} else {
				cpos = true;
			}

			aabbdata.rect.width = h * s + w * c;
			aabbdata.rect.height = h * c + w * s;

			if (cpos)
				if (spos)
					offX -= h * s;
				else
					offY -= w * s;
			else if (spos) {
				offX -= w * c + h * s;
				offY -= h * c;
			} else {
				offX -= w * c;
				offY -= w * s + h * c;
			}

			aabbdata.rect.x += aabbdata.offsetX = offX;
			aabbdata.rect.y += aabbdata.offsetY = offY;

			return aabbdata;
		}

		/**
		 * check if angle is between angle a and b
		 * thanks to http://www.xarg.org/2010/06/is-an-angle-between-two-other-angles/
		 */
		public static function angleBetween(angle : Number, a : Number, b : Number) : Boolean {
			var mod : Number = Math.PI * 2;
			angle = (mod + (angle % mod)) % mod;
			a = (mod * 100 + a) % mod;
			b = (mod * 100 + b) % mod;
			if (a < b)
				return a <= angle && angle <= b;
			return a <= angle || angle <= b;
		}

		/**
		 * Checks for intersection of Segment if asSegments is true.
		 * Checks for intersection of Lines if asSegments is false.
		 * 
		 * http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
		 * 
		 * @param	x1 x of point 1 of segment 1
		 * @param	y1 y of point 1 of segment 1
		 * @param	x2 x of point 2 of segment 1
		 * @param	y2 y of point 2 of segment 1
		 * @param	x3 x of point 3 of segment 2
		 * @param	y3 y of point 3 of segment 2
		 * @param	x4 x of point 4 of segment 2
		 * @param	y4 y of point 4 of segment 2
		 * @param	asSegments
		 * @return the intersection point of segment 1 and 2 or null if they don't intersect.
		 */
		public static function linesIntersection(x1 : Number, y1 : Number, x2 : Number, y2 : Number, x3 : Number, y3 : Number, x4 : Number, y4 : Number, asSegments : Boolean = true) : Point {
			var ip : Point;
			var a1 : Number, a2 : Number, b1 : Number, b2 : Number, c1 : Number, c2 : Number;

			a1 = y2 - y1;
			b1 = x1 - x2;
			c1 = x2 * y1 - x1 * y2;
			a2 = y4 - y3;
			b2 = x3 - x4;
			c2 = x4 * y3 - x3 * y4;

			var denom : Number = a1 * b2 - a2 * b1;
			if (denom == 0)
				return null;

			ip = new Point();
			ip.x = (b1 * c2 - b2 * c1) / denom;
			ip.y = (a2 * c1 - a1 * c2) / denom;

			// ---------------------------------------------------
			// Do checks to see if intersection to endpoints
			// distance is longer than actual Segments.
			// Return null if it is with any.
			// ---------------------------------------------------
			if (asSegments) {
				if (pow2(ip.x - x2) + pow2(ip.y - y2) > pow2(x1 - x2) + pow2(y1 - y2))
					return null;
				if (pow2(ip.x - x1) + pow2(ip.y - y1) > pow2(x1 - x2) + pow2(y1 - y2))
					return null;
				if (pow2(ip.x - x4) + pow2(ip.y - y4) > pow2(x3 - x4) + pow2(y3 - y4))
					return null;
				if (pow2(ip.x - x3) + pow2(ip.y - y3) > pow2(x3 - x4) + pow2(y3 - y4))
					return null;
			}
			return ip;
		}

		public static function pow2(value : Number) : Number {
			return value * value;
		}

		public static function clamp01(value : Number) : Number {
			return value < 0 ? 0 : (value > 1 ? 1 : value);
		}

		public static function clamp(value : Number, min : Number, max : Number) : Number {
			return Math.max(min, Math.min(max, value));
		}
		
		protected static var _perlinNoise:PerlinNoise = new PerlinNoise(int(Math.random()*99999));
		
		public static function perlinNoise(x:Number,y:Number = 0,z:Number = 0):Number {
			return _perlinNoise.Noise(x, y, z);
		}
		
		/**
		 * returns random Number between min and max
		 */
		public static function random(min:Number = 0, max:Number = 1):Number {
			 return min + (max - min) * Math.random();
		}

		/**
		 * returns random int between min and max
		 */
		public static function randomInt(min : int, max : int) : int {
			return Math.floor(Math.random() * (1 + max - min)) + min;
		}

		/**
		 * best fits the rect Rectangle into the into Rectangle, and returns what scale factor applied to into was necessary to do so.
		 * @param	rect
		 * @param	into
		 * @return
		 */
		public static function getBestFitRatio(rect : Rectangle, into : Rectangle) : Number {
			if (into.height / into.width > rect.height / rect.width)
				return into.width / rect.width;
			else
				return into.height / rect.height;
		}

		/**
		 * use to get the ratio required for one rectangle to fill the other. 
		 * Either the width, the height, or both will fill the into rectangle.
		 * Useful to make a background take up all the screen space even though the background
		 * will be cropped if the aspect ratio is not the same.
		 * @param	rect
		 * @param	into
		 */
		public static function getFillRatio(rect : Rectangle, into : Rectangle) : Number {
			if (into.height / into.width > rect.height / rect.width)
				return into.height / rect.height;
			else
				return into.width / rect.width;
		}

		/**
		 * get a random item from an array with an almost uniform distribution of probabilities using randomInt.
		 * @param	arr
		 * @return 
		 */
		public static function getArrayRandomItem(arr : Array) : * {
			return arr[randomInt(0, arr.length - 1)];
		}

		/**
		 * gets the next element in an array based on the currentElement's position, cyclically.
		 * - so if currentElement is the last element, you'll get the first in the array.
		 * @param	currentElement
		 * @param	array
		 */
		public static function getNextInArray(currentElement : *, array : Array) : * {
			var currIndex : int = array.lastIndexOf(currentElement) + 1;
			if (currIndex >= array.length)
				currIndex = 0;
			return array[currIndex];
		}

		/**
		 * gets the previous element in an array based on the currentElement's position, cyclically.
		 * - so if currentElement is the first element, you'll get the last in the array.
		 * @param	currentElement
		 * @param	array
		 */
		public static function getPreviousInArray(currentElement : *, array : Array) : * {
			var currIndex : int = array.lastIndexOf(currentElement) - 1;
			if (currIndex < 0)
				currIndex = array.length - 1;
			return array[currIndex];
		}

		/**
		 * returns a random color in given range.
		 * 
		 * @param minLum minimum for the r, g and b values.
		 * @param maxLum maximum for the r, g and b values.
		 * @param b32 return color with alpha channel (ARGB)
		 * @param randAlpha if format is ARGB, shall we set a random alpha value?
		 * @return
		 */
		public static function getRandomColor(minLum : uint = 0, maxLum : uint = 0xFF, b32 : Boolean = false, randAlpha : Boolean = false) : uint {
			maxLum = maxLum > 0xFF ? 0xFF : maxLum;
			minLum = minLum > 0xFF ? 0xFF : minLum;

			var r : uint = MathUtils.randomInt(minLum, maxLum);
			var g : uint = MathUtils.randomInt(minLum, maxLum);
			var b : uint = MathUtils.randomInt(minLum, maxLum);

			if (!b32)
				return r << 16 | g << 8 | b;
			else {
				var a : uint = randAlpha ? MathUtils.randomInt(0, 255) : 255;
				return a << 24 | r << 16 | g << 8 | b;
			}
		}

		/**
		 * http://snipplr.com/view/12514/as3-interpolate-color/
		 * @param	fromColor
		 * @param	toColor
		 * @param	t a number from 0 to 1
		 * @return
		 */
		public static function colorLerp(fromColor : uint, toColor : uint, t : Number) : uint {
			var q : Number = 1 - t;
			var fromA : uint = (fromColor >> 24) & 0xFF;
			var fromR : uint = (fromColor >> 16) & 0xFF;
			var fromG : uint = (fromColor >> 8) & 0xFF;
			var fromB : uint = fromColor & 0xFF;
			var toA : uint = (toColor >> 24) & 0xFF;
			var toR : uint = (toColor >> 16) & 0xFF;
			var toG : uint = (toColor >> 8) & 0xFF;
			var toB : uint = toColor & 0xFF;
			var resultA : uint = fromA * q + toA * t;
			var resultR : uint = fromR * q + toR * t;
			var resultG : uint = fromG * q + toG * t;
			var resultB : uint = fromB * q + toB * t;
			var resultColor : uint = resultA << 24 | resultR << 16 | resultG << 8 | resultB;
			return resultColor;
		}

		public static function abs(num : Number) : Number {
			return num < 0 ? -num : num;
		}
		
		public static function sign(num:Number):Number {
			return num < 0 ? -1 : 1; 
		}

		// robert penner's formula for a log of variable base
		public static function logx(val : Number, base : Number = 10) : Number {
			return Math.log(val) / Math.log(base)
		}
		
		/**
		 * Evaluate quadratic curve ( f(x)=y ) for x = t
		 * a = start
		 * b = control
		 * c = end
		 */
		public static function evaluateQuadraticCurve(a:Number,b:Number,c:Number,t:Number = 0):Number {
			return (1 - t) * (1 - t) * a + 2 * (1 - t) * t * b + t * t * c;
		}
		
		/**
		 * Evaluate cubic curve ( f(x)=y ) for x = t
		 * a = start
		 * b = first control
		 * c = second control
		 * d = end
		 */
		public static function evaluateCubicCurve(a:Number,b:Number,c:Number,d:Number,t:Number = 0):Number {
			return a + (-a * 3 + t * (3 * a - a * t)) * t + (3 * b + t * (-6 * b + b * 3 * t)) * t + (c * 3 - c * 3 * t) * t * t + d * t * t * t;
		}

		/**
		 * http://www.robertpenner.com/easing/
		 * t current time
		 * b start value
		 * c change in value
		 * d duration
		 */
		public static function easeInQuad(t : Number, b : Number, c : Number, d : Number) : Number {
			return c * (t /= d) * t + b;
		}

		public static function easeOutQuad(t : Number, b : Number, c : Number, d : Number) : Number {
			return -c * (t /= d) * (t - 2) + b;
		}

		public static function easeInCubic(t : Number, b : Number, c : Number, d : Number) : Number {
			return c * (t /= d) * t * t + b;
		}

		public static function easeOutCubic(t : Number, b : Number, c : Number, d : Number) : Number {
			return c * ((t = t / d - 1) * t * t + 1) + b;
		}

		public static function easeInQuart(t : Number, b : Number, c : Number, d : Number) : Number {
			return c * (t /= d) * t * t * t + b;
		}

		public static function easeOutQuart(t : Number, b : Number, c : Number, d : Number) : Number {
			return -c * ((t = t / d - 1) * t * t * t - 1) + b;
		}
	}
}
