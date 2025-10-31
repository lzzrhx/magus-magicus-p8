-------------------------------------------------------------------------------
-- object
-------------------------------------------------------------------------------

object = {

    -- metatable setup
    inherit = function(self, table)
        table=table or {}
        setmetatable(table,{
            __index=self
        })
        return table
    end,

}



-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------

entity = object:inherit({
    
    -- static vars
    class="entity",
    entities={},
    num=0,

    -- vars
    name="unknown",
    x=0,
    y=0,
    sprite=0,
    collision=true,

    -- constructor
    new = function(self, table)
        local new_entity = self:inherit(table)
        entity.num=entity.num+1
        new_entity["id"] = entity.num
        new_entity["prev_x"] = new_entity.x
        new_entity["prev_y"] = new_entity.y
        add(self.entities, new_entity)
        return new_entity
    end,

    -- update entity
    update = function(self)
    end,

    -- check if entity is on screen
    in_frame = function(self)
        return (self.x >= cam_x and self.x < cam_x+16 and self.y >= cam_y and self.y < cam_y+16-ui_h)
    end,

    -- draw entity
    draw = function(self)
        if (self:in_frame()) then
            sprite = self.sprite
            spr(sprite,pos_to_screen(self).x,pos_to_screen(self).y)
        end
    end,

    -- get entity at coordinate
    get = function(x,y)
        for e in all(entity.entities) do
            if (e.x == x and e.y == y) return e
        end
        return nil
    end,

    -- spawn entity on map
    spawn = function(sprite,x,y)
        mset(x,y,sprites.empty)
        -- get entity data
        entity_data = data.entities[sprite]
        if (entity_data ~= nil) then
            -- set up player
            if (entity_data.class == player.class) then
                player.x=x
                player.y=y
                player.sprite=sprite
                -- spawn player pet
                pet_sprite = (rnd() > 0.5 and sprites.pet_cat) or (sprites.pet_dog)
                pet_table = {x=x-1,y=y,sprite=pet_sprite}
                tbl_merge(pet_table,data.entities[pet_sprite])
                pet:new(pet_table)
            else
                -- set up data table
                table = {x=x,y=y,sprite=sprite}
                -- add data to table
                tbl_merge(table,entity_data)
                -- create new entity of given class
                if (table.class == pet.class) then
                    pet:new(table)
                elseif (table.class == npc.class) then 
                    npc:new(table)
                elseif (table.class == enemy.class) then 
                    enemy:new(table)
                elseif (table.class == sign.class) then
                    for e in all(data.signs) do 
                        if (e.x==x and e.y==y) then 
                            table.message=e.message 
                            break
                        end
                    end
                    sign:new(table)
                elseif (table.class == door.class) then
                    door:new(table)
                elseif (table.class == item.class) then 
                    item:new(table)
                else
                    entity:new(table)
                end
            end
        end
    end,
})



-------------------------------------------------------------------------------
-- creature
-------------------------------------------------------------------------------

creature = entity:inherit({
    
    -- static vars
    class="creature",

    -- vars
    hostile=false,
    attacked=false,
    dead=false,
    dhp=0,
    dhp_turn=0,
    ap=2,
    max_hp=10,

    -- constructor
    new = function(self, table)
        local new_entity = entity.new(self, table)
        new_entity["hp"] = new_entity.max_hp
        return new_entity
    end,

    -- update creature
    update = function(self)
        if (turn > self.dhp_turn) then
            self.attacked = false
            if (self.dead and (turn-self.dhp_turn) > timer_grave) del(entity.entities, self)
        end
        return (not self.dead and self:in_frame())
    end,

    -- draw creature
    draw = function(self)
        if (self:in_frame()) then
            sprite = self.sprite+frame*16
            -- dead
            if (self.dead) then
                sprite = sprites.grave
                if (frame == 1 and (turn - self.dhp_turn) <= 1) sprite = sprites.void
            -- under attack
            elseif (self.attacked and frame == 1) then
                sprite = sprites.void
                print(self.dhp,pos_to_screen(self).x+4-str_width(self.dhp)*0.5,pos_to_screen(self).y+1,self.dhp<0 and 8 or 10)
            end
            -- render sprite and overlay
            spr(sprite,pos_to_screen(self).x,pos_to_screen(self).y)
        end
    end,

    -- kill creature
    kill = function(self)
        self.dead = true
        self.collision = false
        if (self == player) state = state_dead
    end,

    -- try to move the entity to a given map coordinate
    move = function (self,x,y)
        if not collision(x,y) and x >= 0 and x < width and y >= 0 and y < height and (x ~= 0 or y ~= 0) then
            self.prev_x = self.x
            self.prev_y = self.y
            self.x = x
            self.y = y
            return true
        end
        return false
    end,

    move_towards_and_attack = function(self, other)
        if (dist_simp(self,other) <= 1) then
            self:attack(other)
        else
            self:move_towards(other)
        end
    end,

    -- try to move an towards another entity
    move_towards = function(self, other)
        diff_x = other.x - self.x
        diff_y = other.y - self.y
        desire_x = (diff_x > 0 and 1) or (diff_x < 0 and -1) or 0
        desire_y = (diff_y > 0 and 1) or (diff_y < 0 and -1) or 0
        valid = ((abs(diff_x) < abs(diff_y)) and self:move(self.x,self.y+desire_y) or (self:move(self.x+desire_x,self.y) or self:move(self.x,self.y+desire_y)))
    end,

    -- follow another entity
    follow = function(self, other)
        if (dist_simp_xy(self.x,self.y,other.prev_x,other.prev_y) == 1) then
            self:move(other.prev_x,other.prev_y)
        else
            self:move_towards(other)
        end
    end,

    -- perform attack
    attack = function(self, other)
        if(self == player or other == player) log:add(self.name .. " attacked " .. other.name)
        if (other:take_dmg(flr(self.ap*(0.5+rnd())+0.5))) then
            log:add(self.name .. " killed " .. other.name)
            if (self == player) self.xp+=other.xp
        end
    end,

    -- take damage
    take_dmg = function(self,dmg)
        if(self == player) draw:flash()
        self.attacked = true
        self.dhp_turn=turn
        self.dhp=dmg*-1
        self.hp-=dmg
        if (self.hp <= 0) then
            self:kill()
            return true
        end
        return false
    end,
})



-------------------------------------------------------------------------------
-- player
-------------------------------------------------------------------------------

player = creature:new({

    -- static vars
    class="player",

    -- vars
    name="you",
    xp=0,

    -- move the player or attack if enemy in target tile
    action_dir = function(self, x,y)
        if (self:move(x,y)) then
            log:add("you moved")
            return true
        else
            for e in all(entity.entities) do 
                if (e.hostile and e.x==x and e.y==y) then
                    self:attack(e)
                    return true
                end
            end
        end
        return false
    end,

    -- wait one turn
    action_wait = function(self)
        log:add("you waited")
        return true
    end,
})



-------------------------------------------------------------------------------
-- pet
-------------------------------------------------------------------------------

pet = creature:inherit({

    -- static vars
    class="pet",
    collision=false,

    -- update function
    update = function(self)
        if creature.update(self) then
            self:follow(player)
        end
    end
})



-------------------------------------------------------------------------------
-- npc
-------------------------------------------------------------------------------

npc = creature:inherit({

    -- static vars
    class="npc",

    -- update function
    update = function(self)
        if creature.update(self) then
        end
    end
})



-------------------------------------------------------------------------------
-- enemy
-------------------------------------------------------------------------------

enemy = creature:inherit({

    -- static vars
    class="enemy",
    hostile = true,

    -- vars
    ap = 1,
    max_hp = 5,
    xp=1,

    -- update function
    update = function(self)
        if creature.update(self) then
            if (self.hostile) then
                self:move_towards_and_attack(player)
            end
        end
    end,
})



-------------------------------------------------------------------------------
-- sign
-------------------------------------------------------------------------------

sign = entity:inherit({

    -- static vars
    class="sign",

    --vars
    message="...",

    interact = function(self)
        change_state(state_read)
        sel.read.text=self.message
    end,

})


-------------------------------------------------------------------------------
-- door
-------------------------------------------------------------------------------

door = entity:inherit({

    -- static vars
    class="door",

    interact = function(self)
        self.collision = not self.collision
        self.sprite = self.collision and 82 or 81
    end,

})



-------------------------------------------------------------------------------
-- item
-------------------------------------------------------------------------------

item = entity:inherit({

    -- static vars
    class="item",
    collision=false,

})
