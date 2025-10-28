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
    entities={},
    name="unknown",
    x=0,
    y=0,
    sprite=0,
    collision=true,
    attacked=false,
    attacked_no=0,
    hp=10,
    ap=2,
    hostile=false,

    -- constructor
    new = function(self, table)
        local new_entity = self:inherit(table)
        add(self.entities, new_entity)
        return new_entity
    end,

    -- set hit
    hit = function(self)
        self.attacked = true
        self.attacked_no=no
    end,

    -- update entity
    update = function(self)
        if (no > self.attacked_no) self.attacked = false
    end,

    -- draw entity
    draw = function(self)
        if (self.x >= cam_x and self.x < cam_x+16 and self.y >= cam_y and self.y < cam_y+16) then
            sprite = (self.attacked and frame == 0 and self.sprite) or (self.attacked and frame == 1 and empty) or self.sprite+frame*16
            spr(sprite,8*(self.x-cam_x),8*(self.y-cam_y))
        end
    end,

    -- get entity at coordinate
    get = function(x,y)
        for e in all(entity.entities) do
            if (e.x == x and e.y == y) return e
        end
        return nil
    end,

    -- try to move the entity to a given map coordinate
    move = function (self,x,y)
        if not collision(x,y) and x >= 0 and x < width and y >= 0 and y < height and (x ~= 0 or y ~= 0) then
            self.x = x
            self.y = y
            return true
        end
        return false
    end,

    -- perform attack
    attack = function(self, other)
        if(self == player or other == player) log:add(self.name .. " attacked " .. other.name)
        other.hp-=flr(self.ap*(0.5+rnd())+0.5)
        other:hit()
        if (other.hp <= 0) then 
            if(self == player) then
                log:add(self.name .. " killed " .. other.name)
                self.xp+=other.xp
            end
            del(entity.entities, other)
        end
    end,

    -- spawn entity on map
    spawn = function(sprite,x,y)
        mset(x,y,empty)
        table = {x=x,y=y,sprite=sprite}
        
        -- player
        if (sprite == 16) then
            table.name="you"
            table.xp=0
            player = entity:new(table)

        -- green guy
        elseif (sprite == 17) then
            table.name="green guy"
            npc:new(table)
        
        -- dino
        elseif (sprite == 18) then
            table.name="dino"
            npc:new(table)

        -- cat
        elseif (sprite == 19) then
            table.name="cat"
            npc:new(table)

        -- dog
        elseif (sprite == 20) then
            table.name="dog"
            npc:new(table)

        -- man
        elseif (sprite == 21) then
            table.name="man"
            npc:new(table)

        -- blob
        elseif (sprite == 22) then
            table.name="blob"
            npc:new(table)

        -- goblin
        elseif (sprite == 23) then
            table.name="goblin"
            npc:new(table)

        -- skully
        elseif (sprite == 24) then
            table.name="skully"
            enemy:new(table)

        -- ghoul
        elseif (sprite == 25) then
            table.name="ghoul"
            npc:new(table)

        -- bat
        elseif (sprite == 26) then
            table.name="bat"
            npc:new(table)

        -- vampire
        elseif (sprite == 27) then
            table.name="vampire"
            npc:new(table)
        
        else
            entity:new(table)
        end
    end,
})


-------------------------------------------------------------------------------
-- npc
-------------------------------------------------------------------------------

npc = entity:inherit({
})


-------------------------------------------------------------------------------
-- enemy
-------------------------------------------------------------------------------

enemy = entity:inherit({
    hostile = true,
    ap = 1,
    hp = 5,
    xp=1,

    -- update function
    update = function(self)
        entity.update(self)
        if (self.hostile) then
            if (dist(self,player) <= 1) then
                self:attack(player)
            else
                self:move_towards(player)
            end
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
})

