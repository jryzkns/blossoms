local blossoms = {}

blossoms.numpetals = 150
blossoms.gravity = 150
blossoms.wind = 100
blossoms.xsitionperiod = 40 -- in frames
blossoms.xdim,blossoms.ydim = 0,0

--mat[row][col]; for ease of computation these are also cumulative
blossoms.transitionmat = {}
blossoms.transitionmat[1] = {0.4,0.9,1,0}
blossoms.transitionmat[2] = {0.1,0.2,0.6,1}
blossoms.transitionmat[3] = {0,0.3,0.4,1}
blossoms.transitionmat[4] = {0,0.3,0.9,1}

blossoms.vertices = {}
blossoms.vertices[1] = {3,3,     8,1,    14,2,   15,5,   14,8,   7,9} -- flat
blossoms.vertices[2] = {13,3,    18,9,   16,16,  7,19,   5,16,   9,7} -- tilting
blossoms.vertices[3] = {1,8,     4,3,    9,4,    14,2,   16,4,   12,8,   6,10} -- rolling1
blossoms.vertices[4] = {1,5,     5,1,    12,6,   18,5,   17,9,   12,10,  3,8} -- rolling2; should be a similar to rolling1

blossoms.petals = {}
function blossoms:init()
        for i=1,blossoms.numpetals do
                blossoms.petals[i] = {}
                blossoms.petals[i].x = 2*blossoms.xdim + math.random()*blossoms.xdim
                blossoms.petals[i].y = -2*math.random()*blossoms.ydim
                -- there will be 4 states; state vector looks like [F T 1 2]
                blossoms.petals[i].state = math.ceil(math.random()*4)
                blossoms.petals[i].xsition = math.floor(math.random()*(blossoms.xsitionperiod+1))
                blossoms.petals[i].xvel, blossoms.petals[i].yvel = math.random()*20, math.random()*20
        end
end

function blossoms:petal(state) love.graphics.polygon("line",blossoms.vertices[state]) end

function blossoms:update(frames,dt)
        for i=1,blossoms.numpetals do
                if      (blossoms.petals[i].x < -20) or 
                        (blossoms.petals[i].y > blossoms.ydim + 20) then
                        blossoms.petals[i].x = blossoms.xdim/3 + math.random()*blossoms.xdim
                        blossoms.petals[i].y = -math.random()*blossoms.ydim
                        blossoms.petals[i].yvel,blossoms.petals[i].xvel = 0, 0
                end
        
                dx = blossoms.petals[i].xvel*dt
                blossoms.petals[i].x = blossoms.petals[i].x - dx
                blossoms.petals[i].xvel = blossoms.petals[i].xvel + blossoms.wind*dt
        
                dy = blossoms.petals[i].yvel*dt
                blossoms.petals[i].y = blossoms.petals[i].y + dy
                blossoms.petals[i].yvel = blossoms.petals[i].yvel + blossoms.gravity*dt

                -- transition
                if blossoms.petals[i].xsition == 5 then
                        pick = math.random()*0.99 + 0.01 -- generations a number from 0.01 to 1
                        for j=1,4 do
                                local in_transition = (blossoms.transitionmat[blossoms.petals[i].state][j] ~= 0)
                                if (pick < blossoms.transitionmat[blossoms.petals[i].state][j]) and in_transition then
                                        blossoms.petals[i].state = j
                                        break
                                end
                        end

                end

                -- increments transition timer
                blossoms.petals[i].xsition = (blossoms.petals[i].xsition + 1) % blossoms.xsitionperiod
        end
end

function blossoms:draw()
        love.graphics.setColor(1,0.41,0.71,0.8) -- pink color for petals
        for i=1,blossoms.numpetals do
                love.graphics.push()
                        love.graphics.translate(blossoms.petals[i].x,blossoms.petals[i].y)
                        blossoms:petal(blossoms.petals[i].state)
                love.graphics.pop()
        end
        love.graphics.setColor(1,1,1,1)
end

return blossoms