-- glitch effect
function glitch1()
    o1 = flr(rnd(0x1F00)) + 0x6040
    o2 = o1 + flr(rnd(0x4)-0x2)
    len = flr(rnd(0x40))
    memcpy(o1,o2,len)
end

-- glitch effect
function glitch2(lines)
    local lines=lines or 64
    for i=1,lines do
        row=flr(rnd(128))
        row2=flr(rnd(127))
        if (row2>=row) row2+=1
        memcpy(0x4300, 0x6000+64*row, 64)
        memcpy(0x6000+64*row, 0x6000+64*row2, 64)
        memcpy(0x6000+64*row2, 0x4300,64)
    end
end

-- quartic polynomial smoothstep
function smoothstep(x)
  return x*x*(2-x*x)
end

-- calculate distance between two points
function dist(a,b)
  return sqrt((b.x-a.x)^2 + (b.y-a.y)^2)
end

      --[[
      self.anim_frame=(self.anim_frame+1)%30
      --y_offset=self.frame*0.25
      --if(self.frame%2==0) self.rnd1,self.rnd2 = rnd(1),rnd(1)
      --y=y_orig-y_offset
      --x+=sin(t())*8
      --x+=self.frame
      --rectfill(x+1,y+5,x+5,y+20,10)
      for i=x+1,x+5 do
        --n=max(x+5-i,i-(x+1))*0.3
        --line(i,y_orig+self.rnd1+n-1,i,y_orig+10,9)
        --if(blink)line(i,y_orig+self.rnd2+n-1,i,y_orig+10,7)
        --if(blink)line(i,y+2+self.rnd2-1,i,y_orig+10,7)
      if(draw_lid) then
        line(x+1,y+1,x+5,y+1,4)
        rectfill(x,y+2,x+6,y+4,4)
        pset(x,y+2,4)
        pset(x,y+3,2)
        line(x,y+4,x+6,y+4,2)
        line(x+1,y+1,x+5,y+1,6)
        line(x+1,y+2,x+5,y+2,7)
        line(x+1,y+3,x+5,y+3,6)
        pset(x+1,y+4,13)
        pset(x+5,y+4,13)
        pset(x+6,y+4,4)
        rectfill(x+2,y+1,x+4,y+3,4)
      end
      end]]--