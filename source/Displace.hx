import flixel.system.FlxAssets.FlxShader;

class Displace extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float waves;
        uniform float uTime;
        uniform float intensity;
        uniform float limit;

        void main()
        {
            //Calculate the size of a pixel (normalized)
            vec2 pixel = vec2(1.0,1.0) / openfl_TextureSize;
			
            //Grab the current position (normalized)
            vec2 p = openfl_TextureCoordv;
            
            //Create the effect using sine waves
            if (p.y >= limit)
            {
                p.x += sin( p.y*waves+uTime*2.0 )*pixel.x*intensity;
                p.y += cos( p.x*waves+uTime*2.0 )*pixel.y*intensity;
            }
            
            //Apply
            vec4 source = flixel_texture2D(bitmap, p);
            gl_FragColor = source;

        }'
    )

    public function new(Waves:Float, Intensity:Float, Limit:Float)
    {
        super();
        this.waves.value = [Waves];
        this.intensity.value = [Intensity];
        this.limit.value = [Limit];
    }
}