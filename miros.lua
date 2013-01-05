
-- $Id: miros.lua 1167 2009-02-24 00:43:31Z tpschmit $

-- ==================================================================
--[[

Miros - A module that implements a Hierarchical State Machine (HSM)
class (i.e. one that implements behavioral inheritance). 

It is based on the excellent work of Miro Samek (hence the module name
"miros"). This implementation closely follows an older C/C++
implementation published in the 8/00 edition of "Embedded Systems"
magazine by Miro Samek and Paul Montgomery under the title "State
Oriented Programming". The article and code can be found here:
http://www.embedded.com/2000/0008.

A wealth of more current information can be found at Miro's well kept
site: http://www.state-machine.com/.
 
As far as I know this is the first implementation of Samek's work in
Lua. It was tested with Lua 5.1.4.

It is licensed under the same terms as Lua itself.

-----------------------------------------------------------
Change history.
Rev.    Date        Comments
-----------------------------------------------------------

1.0.0   10/25/08    Tom Schmit, First release.
1.1.2   11/22/08    Tom Schmit, Added caching of least common ancestor
                    (LCA).  Seems to to be working but also seems to
                    have little affect based on the simple profiling and
                    test case used thus far. Non-cached version remains
                    (commented out) just below cached version.
1.1.3    1/18/09    TS, Cleaned up variable def.'s and init..
1.1.4    2/23/09    TS, onStart() now takes argument top. Renamed sEvt to 
                    sType and tMsg to tEvt. This is consistent with
                    the Python version.

--]]
-- ==================================================================

-- ==============================================
-- Define a Hierarchical State Machine (HSM) class.

sRevision = "1.1.4, 2/23/09"

-- ====================================
-- Initialize table. A sub-table for each state will be added later.

Hsm = {
}

-- ====================================
-- Instantiates a new HSM.

function Hsm:new(o)
    -- create table if none is specified
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- ====================================
-- Adds a new state to the HSM. Specifies name, handler function, parent
-- state, and initializes an empty cache for toLca. These are added to Hsm
-- as a sub-table that is indexed by a reference to the associated handler
-- function. Note that toLca is computed when state transitions. It is the
-- number of levels between the source state and the least/lowest common
-- ancestor is shares with the target state.

function Hsm:addState(sName, fHandler, fSuper)
    self[fHandler] = { 
        name = sName, 
        handler = fHandler, 
        super = fSuper,
        toLcaCache = {},
    }
    -- print("addState:", sName, self[fHandler], fHandler, fSuper)
end

-- ====================================
-- Displays parent-child relationship of states.

function Hsm:dump()
    -- printf("\nSelf-%s\n", tostring(self))
    for k, v in pairs(self) do
        printf("State-%s\t%s,  Parent-%s, toLcaCache: %s\n", 
               v.name, tostring(v), tostring(self[v.super]), tostring(v.toLcaCache))
    end
end

-- 
-- ====================================
-- Starts HSM. Enters and starts top state.

function Hsm:onStart(top)
    self. tEvt = {        -- expandable table containing message parameters sent to HSM
        sType,             -- a string defining an event or signal sent to HSM
    }
    self.tEvt.sType = "entry"
    self.rCurr = self[top]
    self.rNext = 0
    -- handler for top sets initial state
    self.rCurr.handler(self)
    -- get path from initial state to top/root state
    while true do
        self.tEvt.sType = "init"
        self.rCurr.handler(self)
        if self.rNext == 0 then
            break
        end
        local entryPath = {}
        local s = self.rNext
        while s ~= self.rCurr do
           -- trace path to target
           entryPath[#entryPath + 1] = s.handler
           s = self[s.super]
        end
        -- follow path in reverse calling each handler
        self.tEvt.sType = "entry"
        for i = #entryPath, 1, -1 do
            -- retrace entry from source
            entryPath[i](self)
        end
        self.rCurr = self.rNext
        self.rNext = 0
    end
end

-- 
-- ====================================
-- Dispatches events.

function Hsm:onEvent(sType)
    self.tEvt.sType = sType
    local s = self.rCurr
    while true do
        -- level of outermost event handler
        self.rSource = s
        self.tEvt.Evt = s.handler(self)
        -- processed?
        if self.tEvt.Evt == 0 then
            -- state transition taken?
            if self.rNext ~= 0 then
                local entryPath = {}
                s = self.rNext
                while s ~= self.rCurr do
                   -- trace path to target
                   entryPath[#entryPath + 1] = s.handler
                   s = self[s.super]
                end
                -- follow path in reverse from LCA calling each handler
                self.tEvt.sType = "entry"
                for i = #entryPath, 1, -1 do
                    -- retrace entry from source
                    entryPath[i](self)
                end
                self.rCurr = self.rNext
                self.rNext = 0
                while true do
                    self.tEvt.sType = "init"
                    self.rCurr.handler(self)
                    if self.rNext == 0 then
                        break
                    end
                    local entryPath = {}
                    s = self.rNext
                    while s ~= self.rCurr do
                       -- record path to target
                       entryPath[#entryPath + 1] = s.handler
                       s = self[s.super]
                    end
                    -- follow path in reverse calling each handler
                    self.tEvt.sType = "entry"
                    for i = #entryPath, 1, -1 do
                        -- retrace the entry
                        entryPath[i](self)
                    end
                    self.rCurr = self.rNext
                    self.rNext = 0
                end
            end
            -- event processed
            break
        end
        s = self[s.super]
    end
    return(0)
end

-- 
-- ====================================
-- Exits current states and all super states up to LCA.

function Hsm:exit(toLca)
    local s = self.rCurr
    self.tEvt.sType = "exit"
    while s ~= self.rSource do
        s.handler(self)
        s = self[s.super]
    end
    while toLca ~= 0 do
        toLca = toLca - 1
        s.handler(self)
        s = self[s.super]
    end
    self.rCurr = s
end

-- ====================================
-- Finds number of levels to LCA (least common ancestor). 

function Hsm:toLCA(Target)
    local toLca = 0
    if self.rSource == Target then
        return(1)
    end
    local s = self.rSource
    while s ~= nil do
        local t = Target
        while t ~= nil do
            if s == t then
                return(toLca)
            end
            t = self[t.super]
        end
        toLca = toLca + 1
        s = self[s.super]
    end
    return(0)
end

-- ====================================
-- Transitions to new state.

-- ==========================
-- Cached version. Seems to to be working but has little affect.

function Hsm:stateTran(rTarget)
    -- printf("\nCurrent state: %s, Source state: %s\n", tostring(self.rCurr), tostring(self.rSource))
    if self.rCurr.toLcaCache[self.tEvt.sType] == nil then
        self.rCurr.toLcaCache[self.tEvt.sType] = self:toLCA(self[rTarget])
        -- printf("Cached State-%s, Event: %s, toLca: %d\n", 
        --         tostring(self.rCurr), self.tEvt.sType, self.rCurr.toLcaCache[self.tEvt.sType])
    end
    self:exit(self.rCurr.toLcaCache[self.tEvt.sType])
    self.rNext = self[rTarget]
end

-- -- ==========================
-- -- non-cached version
-- 
-- function Hsm:stateTran(rTarget)
--     local toLca = self:toLCA(self[rTarget])
--     self:exit(toLca)
--     self.rNext = self[rTarget]
-- end

-- ====================================
-- Sets initial state.

function Hsm:stateStart(Target)
    self.rNext = self[Target]
end

-- ====================================
-- Gets current state.

function Hsm:stateCurrent()
    return self.rCurr
end

-- ====================================
-- Gets HSM revision.

function Hsm:revision()
    return sRevision
end

return Hsm
