// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2015 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.extensions.lighting
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.geom.Vector3D;

    import starling.rendering.MeshEffect;
    import starling.rendering.Program;
    import starling.rendering.VertexDataFormat;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;
    import starling.utils.Color;
    import starling.utils.RenderUtil;

    public class LightEffect extends MeshEffect
    {
        public static const VERTEX_FORMAT:VertexDataFormat =
            MeshEffect.VERTEX_FORMAT.extend("normalTexCoords:float2, xAxis:float2, yAxis:float2");

        private var _normalTexture:Texture;
        private var _lightPos:Vector3D;
        private var _diffuseColor:uint;
        private var _ambientColor:uint;

        private static const sVector:Vector.<Number> = new Vector.<Number>(4, true);

        public function LightEffect()
        {
            _lightPos = new Vector3D();
            _diffuseColor = 0xffffff;
            _ambientColor = 0x0;
        }

        override protected function createProgram():Program
        {
            if (_normalTexture == null) return super.createProgram();

            var vertexShader:String = [
                    "mov  v0, va0     ",     // pass vertex position to FB
                    "mov  v1, va1     ",     // pass texture coordinates to FP
                    "mul  v2, va2, vc4",     // pass vertex color * vertex alpha to FP
                    "mov  v3, va3     ",     // pass normal texture coordinates to FP
                    "mov  v4, va4     ",     // pass local x-axis to FP
                    "mov  v5, va5     ",     // pass local y-axis to FP
                    "m44  op, va0, vc0",     // transform vertex position into clip space

                    // --- this code produces errors on some Windows devices ------------------
                    // "mov  v6, va5     ",             // initialize v6 (with anything)
                    // "crs  v6.xyz, va4.xyz, va5.xyz", // calculate local z-axis, pass to FP

                    // --- so we make the cross product manually until that is fixed ----------
                    "mul vt0.xyzw, va4.yzxw, va5.zxyw",
                    "mul vt1.xyzw, va4.zxyw, va5.yzxw",
                    "sub v6, vt0, vt1"
            ].join("\n");

            // v0 - vertex position
            // v1 - vertex color * vertex alpha
            // v2 - texture coords
            // v3 - normal texture coords
            // v4 - x-axis
            // v5 - y-axis
            // v6 - z-axis

            var fragmentShader:String = [
                    RenderUtil.createAGALTexOperation("ft0", "v1", 0, texture),
                    RenderUtil.createAGALTexOperation("ft1", "v3", 1, normalTexture, false),

                    "mul ft1.xy, ft1.xy, fc4.xy", // normal.xy *= 2
                    "sub ft1.xy, ft1.xy, fc3.xy", // normal.xy -= 1
                    "m33 ft1.xyz, ft1, v4",       // bring NV into correct coordinate system
                    "nrm ft1.xyz, ft1.xyz",       // normalize normal vector

                    "sub ft2, v0, fc0",     // calculate light vector
                    "neg ft2.x, ft2.x",     // invert x-direction of light vector
                    "nrm ft2.xyz, ft2.xyz", // normalize light vector

                    "mul ft0, ft0, v2",     // surface color = texel * vertex color
                    "dp3 ft3, ft1, ft2",    // dotProd = normal vector (dot) light vector
                    "mul ft4, ft3, fc1",    // diffuse color = dotProd * diffuse color
                    "mov ft4.w, fc3.w",     // set alpha of diffuse color to '1.0'
                    "add ft5, ft4, fc2",    // final color = diffuse color + ambient color
                    "mul  oc, ft0, ft5"     // frag color = surface color * final color
            ].join("\n");

            return Program.fromSource(vertexShader, fragmentShader);
        }

        override protected function beforeDraw(context:Context3D):void
        {
            super.beforeDraw(context);

            // vc0-vc3 — MVP matrix
            // vc4 — alpha value (same value for all components)

            // fc0 - light position
            // fc1 - light color * brightness
            // fc2 - ambient color
            // fc3 - [1, 1, 1, 1]
            // fc4 - [2, 2, 2, 2]

            // va0 — vertex position (xy)
            // va1 — texture coordinates
            // va2 — vertex color (rgba), using premultiplied alpha
            // va3 - normal texture coordinates
            // va4 - x-axis vector (xy)
            // va5 - y-axis vector (xy)

            // fs0 — texture
            // fs1 - normal texture

            if (_normalTexture)
            {
                sVector[0] = _lightPos.x; sVector[1] = _lightPos.y; sVector[2] = _lightPos.z;
                context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, sVector);

                Color.toVector(_diffuseColor, sVector);
                context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, sVector);

                Color.toVector(_ambientColor, sVector);
                context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, sVector);

                sVector[0] = sVector[1] = sVector[2] = sVector[3] = 1.0;
                context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, sVector);

                sVector[0] = sVector[1] = sVector[2] = sVector[3] = 2.0;
                context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, sVector);

                RenderUtil.setSamplerStateAt(1, _normalTexture.mipMapping, TextureSmoothing.BILINEAR);
                context.setTextureAt(1, _normalTexture.base);
                vertexFormat.setVertexBufferAt(3, vertexBuffer, "normalTexCoords");
                vertexFormat.setVertexBufferAt(4, vertexBuffer, "xAxis");
                vertexFormat.setVertexBufferAt(5, vertexBuffer, "yAxis");
            }
        }

        override protected function afterDraw(context:Context3D):void
        {
            if (_normalTexture)
            {
                context.setTextureAt(1, null);
                context.setVertexBufferAt(3, null);
                context.setVertexBufferAt(4, null);
                context.setVertexBufferAt(5, null);
            }

            super.afterDraw(context);
        }

        override protected function get programVariantName():uint
        {
            var normalMapBits:uint = RenderUtil.getTextureVariantBits(_normalTexture);
            return super.programVariantName | (normalMapBits << 8);
        }

        override public function get vertexFormat():VertexDataFormat
        {
            return VERTEX_FORMAT;
        }

        public function get normalTexture():Texture { return _normalTexture; }
        public function set normalTexture(value:Texture):void { _normalTexture = value; }

        public function get lightPosition():Vector3D { return _lightPos; }
        public function set lightPosition(value:Vector3D):void { _lightPos.copyFrom(value); }

        public function get diffuseColor():uint { return _diffuseColor; }
        public function set diffuseColor(value:uint):void { _diffuseColor = value; }

        public function get ambientColor():uint { return _ambientColor; }
        public function set ambientColor(value:uint):void { _ambientColor = value; }
    }
}
