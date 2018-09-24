--[[
Post-processing tests
]]
do
	CEffect = middleclass("CEffect", lquick.Effect)

	function CEffect:initialize()
		self.uniforms = {
			time = 0
		}
	end

	function CEffect:update(dt)
		self.uniforms.time = self.uniforms.time + dt
	end

	CEffect.shader = love.graphics.newShader [[
		uniform float time;

		#define COORD_MULT 10
		#define NOISE_MULT 0.01

		float rand(vec2);
		float noise(vec2);

		vec4 effect(vec4 vcolor, sampler2D tex, vec2 coord, vec2 screenCoord) {
			vec2 realCoord = (coord * love_ScreenSize.xy) / love_ScreenSize.xy * COORD_MULT + vec2(time, -time);

			vec4 orig = Texel(tex, coord + vec2(noise(realCoord.xy), noise(realCoord.yx)) * NOISE_MULT);
			return orig * vcolor;
		}

		// From https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
		float rand(vec2 n) {
			return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
		}

		float noise(vec2 p){
			vec2 ip = floor(p);
			vec2 u = fract(p);
			u = u*u*(3.0-2.0*u);

			float res = mix(
				mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
				mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
			return res*res;
		}
	]]
end

do
	G_renderer = lquick.Renderer:new()
	G_image = love.graphics.newImage("tests/rendering/image.png")
end

function love.update(dt)
	G_renderer:update(dt)
end

function love.draw()
	G_renderer:draw(function(renderer)
		love.graphics.draw(G_image)
	end)
end
