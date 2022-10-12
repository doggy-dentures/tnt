import openfl.shader.GPUParticleShader;
import glsl.GLSL.texture2D;
import VectorMath;

class ParticleShader extends GPUParticleShader
{
	override function fragment()
	{
        super.fragment();
		color.rgb = color.rgb * colorv.rgb;
		color.rgba *= colorv.a;
		this.gl_FragColor = color * lifeAlpha * gl_openfl_Alphav * stageSizeAlpha.z;
	}
}
