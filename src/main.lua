-------------------------------------------------------------------------------
-- globals
-------------------------------------------------------------------------------

-- constants
timer_grave = 20  -- timeout for grave
width=128   -- area width
height=64  -- area height
margin=2   -- left / right margin

-- states
state_game = "game"
state_dead = "dead"

-- vars
state=nil
frame=0    -- animation frame number
cam_x=0    -- camera y position
cam_y=0    -- camera x position
turn=1     -- turn number
sel=0      -- ui selection

-- sprites
sprites = {
    void=0,
    empty=1,
    grave=2,
    pet_cat=19,
    pet_dog=20,
}

-- enum, flags
flags={
    collision=0,
    --unused_one=1,
    --unused_two=2,
    --unused_three=3,
    --unused_four=4,
    --unused_five=5,
    --unused_six=6,
    entity=7,
}


-------------------------------------------------------------------------------
-- built-in functions
-------------------------------------------------------------------------------

-- built-in init function
function _init()
    -- set initial state
    state=state_game
    -- populate the world map with entities
    populate_map()
end

-- built-in update function
function _update()
    -- set animation frame
    frame = flr(t() * 2 % 2)
    -- update for the current state
    update[state]()
end

-- built-in draw function
function _draw()
    -- draw for the current state
    draw[state]()
end


-------------------------------------------------------------------------------
-- update
-------------------------------------------------------------------------------

update = {
    -- update for game state
    game = function()
        -- get input and perform turn
        if (input.game()) do_turn()
    end,
    -- game over state
    dead = function()
        input.dead()
    end,
}


-------------------------------------------------------------------------------
-- draw
-------------------------------------------------------------------------------

draw = {
    -- game state
    game = function()
        -- clear screen
        cls()
        -- draw map
        map(cam_x,cam_y)
        -- draw entities
        for e in all(entity.entities) do if (not e.collision) e:draw() end
        for e in all(entity.entities) do if (e.collision) e:draw() end
        ui:draw()
    end,
    -- game over state
    dead = function()
        draw.game()
        --for i=31,95 do line(i,70,i,70+rnd(8),8) end
        rectfill(32,40,94,70,0)
        line(32,39,94,39,6)
        line(32,71,94,71,6)
        line(31,40,31,70,6)
        line(95,40,95,70,6)
        s="- game over -"
        print(s,64-str_width(s)*0.5,43,8)
        print((sel==0 and ">" or " ") .. " restart",46,54,sel==0 and 6 or 5)
        print((sel==1 and ">" or " ") .. " quit",46,61,sel==1 and 6 or 5)
    end,
}


-------------------------------------------------------------------------------
-- ui
-------------------------------------------------------------------------------

ui = {
    -- flash the screen
    flash_n = 0,
    flash = function(self)
        self.flash_n = 2
    end,

    -- draw game ui
    draw = function(self)
        -- draw flash
        if (ui.flash_n > 0) then
            cls((player.hp < 5 and self.flash_n==1 and 8) or 7)
            self.flash_n-=1
        end
        -- bottom ui box
        rectfill(0,104,127,127,0)
        line(0,104,127,104,6)
        line(0,119,128,119,6)
        -- left
        print("pos:" .. player.x .. "-" .. player.y,margin,127-7*3,6)
        print("hp: " .. player.hp,margin,127-7*2,6)
        -- right
        ui_z="wait 🅾️"
        ui_x="menu ❎"
        print(ui_z,128-str_width(ui_z)-margin,127-7*3,6)
        print(ui_x,128-str_width(ui_x)-margin,127-7*2,6)
        -- bottom text
        print(log.entries[#log.entries],margin,127-6*1,6)
        -- frame
        line(0,0,127,0,6)     -- top
        line(127,0,127,127,6) -- right
        line(0,127,127,127,6) -- bottom
        line(0,0,0,127,6)     -- left
        pset(0,0,0)
        pset(127,0,0)
        pset(0,127,0)
        pset(127,127,0)
    end,
}


-------------------------------------------------------------------------------
-- input
-------------------------------------------------------------------------------
input = {
    -- game input
    game = function()
        valid = false
        if (btnp(⬆️)) valid = player:action_dir(player.x,player.y-1)
        if (btnp(➡️)) valid = player:action_dir(player.x+1,player.y)
        if (btnp(⬇️)) valid = player:action_dir(player.x,player.y+1)
        if (btnp(⬅️)) valid = player:action_dir(player.x-1,player.y)
        if (btnp(🅾️)) valid = player:action_wait()
        return valid
    end,
    -- game over input
    dead = function()
        valid = false
        if (btnp(⬆️)) sel=(sel-1)%tbl_len(selection[state])
        if (btnp(⬇️)) sel=(sel+1)%tbl_len(selection[state])
        if (btnp(🅾️) or btnp(❎)) selection[state][sel]()
        return valid
    end,
}


-------------------------------------------------------------------------------
-- selection
-------------------------------------------------------------------------------

selection = {
    dead = {
        [0] = function()
            run()
        end,
        [1] = function()
            stop()
        end,
    }
}


-------------------------------------------------------------------------------
-- log
-------------------------------------------------------------------------------

log={
    -- initialize log entries table
    entries={"welcome to game"},

    -- add message to log
    add = function(self, message)
        add(self.entries,turn .. ": " .. message)
    end,
}


-------------------------------------------------------------------------------
-- utils
-------------------------------------------------------------------------------

-- calculate distance between two points
function dist(a,b)
    return sqrt((b.x-a.x)^2 + (b.y-a.y)^2)
end

-- calculate distance between two points (simple)
function dist_simp(a,b)
    return max(abs(b.x-a.x),abs(b.y-a.y))
end

-- calculate distance between two points (simple)
function dist_simp_xy(x0,y0,x1,y1)
    return max(abs(x1-x0),abs(y1-y0))
end

-- calculate string width
function str_width(s)
    return print(s,0,-10)
end

-- merge table b into table a
function tbl_merge(a,b)
    for k,v in pairs(b) do
        a[k] = v
    end
end

-- check length of table
function tbl_len(t)
    num = 0
    for k,v in pairs(t) do num+=1 end
    return num
end


-------------------------------------------------------------------------------
-- game
-------------------------------------------------------------------------------

-- perform turn
function do_turn()
    -- update entities
    for e in all(entity.entities) do e:update() end
    -- update camera
    update_camera()
    -- increment turn counter
    turn+=1
end

-- update camera position
function update_camera()
    if (player.x - cam_x > 11 and cam_x < width-16) then
        cam_x = player.x - 11
    elseif (player.x - cam_x < 4 and cam_x > 0) then
        cam_x = player.x - 4
    elseif (player.y - cam_y > 8 and cam_y < height-16) then
        cam_y = player.y - 8
    elseif (player.y - cam_y < 4 and cam_y > 0) then
        cam_y = player.y - 4
    end
end


-------------------------------------------------------------------------------
-- world
-------------------------------------------------------------------------------

-- iterate through all map tiles and find entities
function populate_map()
    for x=0,127 do
        for y=0,63 do
            if (mget(x,y) == 0) mset(x,y,sprites.empty)
            if (fget(mget(x,y),flags.entity)) entity.spawn(mget(x,y),x,y)
        end
    end
end

-- check for collision
function collision(x,y)
    if (fget(mget(x,y),flags.collision)) return true
    e = entity.get(x,y)
    if (e ~= nil and e.collision) return true
    return false
end
