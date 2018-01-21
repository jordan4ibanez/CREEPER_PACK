--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")


--###################
--################### CREEPER
--###################

--create a giant igloo
local function ground_reversal(pos,self)
	
	--index the radius
	local index_radius = self.explosion_radius * 3
	local index_table = {}
	
	for x=-index_radius, index_radius do
		index_table[x] = {}
	for y=-index_radius, index_radius do
		index_table[x][y] = {}
	for z=-index_radius, index_radius do
	
	  if x*x+y*y+z*z <= index_radius*index_radius + index_radius then
		
		index_table[x][y][z] = {}
		
		index_table[x][y][z].localpos = {x=x,y=y,z=z}
		
		index_table[x][y][z].node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z+z})
		
	  end
	end
	end
	end
	
	for _,x in pairs(index_table) do
		for _,y in pairs(x) do
			for _,z in pairs(y) do
				minetest.set_node({x=pos.x+z.localpos.x,y=pos.y-z.localpos.y,z=pos.z+z.localpos.z}, z.node)
			end
		end
	end
	
	--flip radius
		--[[
	for x=-index_radius, index_radius do
	for y=-index_radius, index_radius do
	for z=-index_radius, index_radius do
	
	  if x*x+y*y+z*z <= index_radius*index_radius + index_radius then
		--local index_pos = {x=pos.x+x,y=pos.y+y,z=pos.z+z}
		local index_table.x.y.z.localpos = {x=x,y=y,z=z}
		local index_table.x.y.z.node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z+z})
	  end
	end
	end
	end
	]]--
end


mobs:register_mob("reversal_creeper:reversal_creeper", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.69, 0.3},
	pathfinding = 1,
	visual = "mesh",
	mesh = "reversal_creeper.b3d",
	textures = {
		{"reversal_creeper.png"},
	},
	visual_size = {x=3, y=3},
	sounds = {
		attack = "tnt_ignite",
		death = "Creeperdeath", -- TODO: Replace
		damage = "Creeper4", -- TODO: Replce
		war_cry = "tnt_ignite",
		explode = "tnt_explode",
		distance = 16,
	},
	makes_footstep_sound = true,
	walk_velocity = 1.5,
	run_velocity = 3,
	attack_type = "explode",
	
	explosion_radius = 5,
	explosion_fire = false,

	-- Force-ignite creeper with flint and steel and explode after 1.5 seconds.
	-- TODO: Make creeper flash after doing this as well.
	-- TODO: Test and debug this code.
	on_rightclick = function(self, clicker)
		if self._forced_explosion_countdown_timer ~= nil then
			return
		end
		local item = clicker:get_wielded_item()
		if item:get_name() == mobs_mc.items.flint_and_steel then
			if not minetest.settings:get_bool("creative_mode") then
				-- Wear tool
				local wdef = item:get_definition()
				item:add_wear(1000)
				-- Tool break sound
				if item:get_count() == 0 and wdef.sound and wdef.sound.breaks then
					minetest.sound_play(wdef.sound.breaks, {pos = clicker:getpos(), gain = 0.5})
				end
				clicker:set_wielded_item(item)
			end
			self._forced_explosion_countdown_timer = 1.5
			minetest.sound_play(self.sounds.attack, {pos = self.object:getpos(), gain = 1, max_hear_distance = 16})
		end
	end,
	do_custom = function(self, dtime)
		
		--lightning explosion instead of boom
		if self.timer > self.explosion_timer - 0.5 then
			self.object:remove()
			ground_reversal(self.object:getpos(),self)
			--[[
			minetest.sound_play("tnt_explode", {
				pos = self.object:getpos(),
				max_hear_distance = 10,
				gain = 10.0,
			})
			lightning.strike(self.object:getpos())
			]]--
			return
		end
		
		if self._forced_explosion_countdown_timer ~= nil then
			self._forced_explosion_countdown_timer = self._forced_explosion_countdown_timer - dtime
			if self._forced_explosion_countdown_timer <= 0 then
				mobs:explosion(self.object:getpos(), self.explosion_radius, 0, 1, self.sounds.explode)
				self.object:remove()
			end
		end
	end,
	on_die = function(self, pos)
		-- Drop a random music disc
		-- TODO: Only do this if killed by skeleton
	end,
	maxdrops = 2,
	drops = {
		{name = mobs_mc.items.gunpowder,
		chance = 1,
		min = 0,
		max = 2,},

		-- Head
		-- TODO: Only drop if killed by charged creeper
		{name = mobs_mc.items.head_creeper,
		chance = 200, -- 0.5%
		min = 1,
		max = 1,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 110,
		hurt_end = 139,
		death_start = 140,
		death_end = 189,
		look_start = 50,
		look_end = 108,
	},
	floats = 1,
	fear_height = 4,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	view_range = 16,
	blood_amount = 0,
})


mobs:spawn_specific("reversal_creeper:reversal_creeper",mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 6000, 4, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- compatibility
--mobs:alias_mob("mobs:creeper", "mobs_mc:reversal_creeper")

-- spawn eggs
mobs:register_egg("reversal_creeper:reversal_creeper", S("Reversal Creeper"), "mobs_reversal_creeper_inv.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "Reversal Creeper loaded")
end
