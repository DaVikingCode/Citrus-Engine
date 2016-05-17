package citrus.math {
import com.gskinner.utils.Rndm;

/* Perlin noise class.  ( by Tom Nuydens (tom@delphi3d.net) )
 * Converted to C# by Mattias Fagerlund, Mattias.Fagerlund@cortego.se
 * Converted from C# to AS3 by gsynuh for Citrus Engine
 
  ******************************************************************************
 
  I used the following references for my implementation:
    http://students.vassar.edu/mazucker/code/perlin-noise-math-faq.html
    Darwin Peachey's chapter in "Texturing & Modeling: A Procedural Approach"
  Another good resource is
    http://freespace.virgin.net/hugo.elias/models/m_perlin.htm
 
  ******************************************************************************
 
  This class generates 3D Perlin noise. The demo that comes with this is 2D, but
  uses the 3rd dimension to create animated noise. The noise does not tile,
  although it could be made to do so with a few small modifications to the
  algorithm.
 
  Perlin noise can be used as a starting point for all kinds of things,
  including terrain generation, cloud rendering, procedural textures, and more.
  Most of these techniques involve rendering multiple "octaves" of noise. This
  means you generate multiple noise values for every pixel (each with different
  X, Y and/or Z coordinates), and then sum them. There's an example of this in
  the accompanying demo.
*/

	public class PerlinNoise {
		
		private const GradientSizeTable:uint = 256;
        private  var _random:com.gskinner.utils.Rndm;
        private var _gradients = new Array(GradientSizeTable * 3);
        /* Borrowed from Darwyn Peachey (see references above).
           The gradient table is indexed with an XYZ triplet, which is first turned
           into a single random index using a lookup in this table. The table simply
           contains all numbers in [0..255] in random order. */
        private var _perm:Array = new Array(
              225,155,210,108,175,199,221,144,203,116, 70,213, 69,158, 33,252,
                5, 82,173,133,222,139,174, 27,  9, 71, 90,246, 75,130, 91,191,
              169,138,  2,151,194,235, 81,  7, 25,113,228,159,205,253,134,142,
              248, 65,224,217, 22,121,229, 63, 89,103, 96,104,156, 17,201,129,
               36,  8,165,110,237,117,231, 56,132,211,152, 20,181,111,239,218,
              170,163, 51,172,157, 47, 80,212,176,250, 87, 49, 99,242,136,189,
              162,115, 44, 43,124, 94,150, 16,141,247, 32, 10,198,223,255, 72,
               53,131, 84, 57,220,197, 58, 50,208, 11,241, 28,  3,192, 62,202,
               18,215,153, 24, 76, 41, 15,179, 39, 46, 55,  6,128,167, 23,188,
              106, 34,187,140,164, 73,112,182,244,195,227, 13, 35, 77,196,185,
               26,200,226,119, 31,123,168,125,249, 68,183,230,177,135,160,180,
               12,  1,243,148,102,166, 38,238,251, 37,240,126, 64, 74,161, 40,
              184,149,171,178,101, 66, 29, 59,146, 61,254,107, 42, 86,154,  4,
              236,232,120, 21,233,209, 45, 98,193,114, 78, 19,206, 14,118,127,
               48, 79,147, 85, 30,207,219, 54, 88,234,190,122, 95, 67,143,109,
              137,214,145, 93, 92,100,245,  0,216,186, 60, 83,105, 97,204, 52);
 
        public function PerlinNoise(seed:int)
        {
            _random = new Rndm(seed);
            InitGradients();
        }
 
        public function Noise(x:Number, y:Number, z:Number):Number
        {
            /* The main noise function. Looks up the pseudorandom gradients at the nearest
               lattice points, dots them with the input vector, and interpolates the
               results to produce a single output value in [0, 1] range. */
 
            var ix:int = int(Math.floor(x));
            var fx0:Number = x - ix;
            var fx1:Number = fx0 - 1;
            var wx:Number = Smooth(fx0);
 
            var iy:int = int(Math.floor(y));
            var fy0:Number = y - iy;
            var fy1:Number = fy0 - 1;
            var wy:Number = Smooth(fy0);
 
            var iz:int = int(Math.floor(z));
            var fz0:Number = z - iz;
            var fz1:Number = fz0 - 1;
            var wz:Number = Smooth(fz0);
 
            var vx0:Number = Lattice(ix, iy, iz, fx0, fy0, fz0);
            var vx1:Number = Lattice(ix + 1, iy, iz, fx1, fy0, fz0);
            var vy0:Number = Lerp(wx, vx0, vx1);
 
            vx0 = Lattice(ix, iy + 1, iz, fx0, fy1, fz0);
            vx1 = Lattice(ix + 1, iy + 1, iz, fx1, fy1, fz0);
            var vy1:Number = Lerp(wx, vx0, vx1);
 
            var vz0:Number = Lerp(wy, vy0, vy1);
 
            vx0 = Lattice(ix, iy, iz + 1, fx0, fy0, fz1);
            vx1 = Lattice(ix + 1, iy, iz + 1, fx1, fy0, fz1);
            vy0 = Lerp(wx, vx0, vx1);
 
            vx0 = Lattice(ix, iy + 1, iz + 1, fx0, fy1, fz1);
            vx1 = Lattice(ix + 1, iy + 1, iz + 1, fx1, fy1, fz1);
            vy1 = Lerp(wx, vx0, vx1);
 
            var vz1:Number = Lerp(wy, vy0, vy1);
            return Lerp(wz, vz0, vz1);
        }
 
        private function InitGradients():void
        {
            for (var i:int = 0; i < GradientSizeTable; i++)
            {
                var z:Number = 1.0 - 2.0 * _random.random();
                var r:Number = Math.sqrt(1.0 - z * z);
                var theta:Number = 2 * Math.PI * _random.random();
                _gradients[i * 3] = r * Math.cos(theta);
                _gradients[i * 3 + 1] = r * Math.sin(theta);
                _gradients[i * 3 + 2] = z;
            }
        }
 
        private function Permutate(x:int):int
        {
            const mask:int = GradientSizeTable - 1;
            return _perm[x & mask];
        }
 
        private function Index(ix:int, iy:int , iz:int ):int
        {
            // Turn an XYZ triplet into a single gradient table index.
            return Permutate(ix + Permutate(iy + Permutate(iz)));
        }
 
        private function Lattice(ix:int, iy:int, iz:int, fx:Number, fy:Number, fz:Number):Number
        {
            // Look up a random gradient at [ix,iy,iz] and dot it with the [fx,fy,fz] vector.
            var index:int = Index(ix, iy, iz);
            var g:int = index*3;
            return _gradients[g] * fx + _gradients[g + 1] * fy + _gradients[g + 2] * fz;
        }
 
        private function Lerp(t:Number, value0:Number, value1:Number):Number
        {
            // Simple linear interpolation.
            return value0 + t * (value1 - value0);
        }
 
        private function Smooth(x:Number):Number
        {
            /* Smoothing curve. This is used to calculate interpolants so that the noise
              doesn't look blocky when the frequency is low. */
            return x * x * (3 - 2 * x);
        }
    }
}
