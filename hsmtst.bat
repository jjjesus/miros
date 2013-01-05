
goto =bat_commands

-- ==================================================================
-- See the end of this file about running Lua in Win32 batch files.

-- $Id: hsmtst.bat 1167 2009-02-24 00:43:31Z tpschmit $

-- ==================================================================
--[[

Hsmtst - Interactive example using the Hierarchical State Machine (HSM)
class defined in the "miros" module  (i.e. one that implements
behavioral inheritance). It implements the UML state chart shown in the
accompanying image "hsmtst-chart.gif".  

It is based on the excellent work of Miro Samek (hence the module name
"miros"). This implementation closely follows an older C/C++
implementation published in the 8/2000 edition of "Embedded Systems"
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
1.0.1   1/17/09     Tom Schmit, Cosmetic changes.
1.0.2   1/18/09     TS, Cleaned up variable def.'s and init..
1.0.3   2/23/09     TS, onStart() now takes argument top. Renamed sEvt to 
                    sType and tMsg to tEvt. This is consistent with
                    the Python version.

--]]

-- ==================================================================

local Hsm = require("miros")

-- ==============================================
-- helpers

function printf(s, ...)
    return io.write(s:format(...))
end

-- 
-- ==============================================
-- Define event handlers for states. For clarity, the functions are named
-- for the states they handle (though this is not required). For details
-- see the UML state chart shown in the accompanying image
-- "hsmtst-chart.gif".


-- ====================================
-- Top/root state is state d.

function top(self)
    if self.tEvt.sType == "init" then
        -- display event
        printf("top-%s;", self.tEvt.sType)
        -- transition to state d2.
        self:stateStart(d2)
        -- returning a 0 indicates event was handled
        return(0)
    elseif self.tEvt.sType == "entry" then
        -- display event, do nothing 
        -- else except indicate it was handled
        printf("top-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "exit" then
        printf("top-%s;", self.tEvt.sType)
        self.tEvt.nFoo = 0
        return(0)
    elseif self.tEvt.sType == "e" then
        printf("top-%s;", self.tEvt.sType)
        self:stateTran(d11)
        return(0)
    end
    return(self.tEvt.sType)
end

-- ====================================                 

function d1(self)
    if self.tEvt.sType == "init" then
        printf("d1-%s;", self.tEvt.sType)
        self:stateStart(d11)
        return(0)
    elseif self.tEvt.sType == "entry" then
        printf("d1-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "exit" then
        printf("d1-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "a" then
        printf("d1-%s;", self.tEvt.sType)
        self:stateTran(d1)
        return(0)
    elseif self.tEvt.sType == "b" then
        printf("d1-%s;", self.tEvt.sType)
        self:stateTran(d11)
        return(0)
    elseif self.tEvt.sType == "c" then
        printf("d1-%s;", self.tEvt.sType)
        self:stateTran(d2)
        return(0)
    elseif self.tEvt.sType == "f" then
        printf("d1-%s;", self.tEvt.sType)
        self:stateTran(d211)
        return(0)
    end
    return(self.tEvt.sType)
end

-- 
-- ====================================

function d11(self)
    if self.tEvt.sType == "entry" then
        printf("d11-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "exit" then
        printf("d11-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "d" then
        printf("d11-%s;", self.tEvt.sType)
        self:stateTran(d1)
        self.tEvt.nFoo = 0
        return(0)
    elseif self.tEvt.sType == "g" then
        printf("d11-%s;", self.tEvt.sType)
        self:stateTran(d211)
        return(0)
    elseif self.tEvt.sType == "h" then
        printf("d11-%s;", self.tEvt.sType)
        self:stateTran(top)
        return(0)
    end
    return(self.tEvt.sType)
end

-- ====================================

function d2(self)
    if self.tEvt.sType == "init" then
        printf("d2-%s;", self.tEvt.sType)
        self:stateStart(d211)
        return(0)
    elseif self.tEvt.sType == "entry" then
        printf("d2-%s;", self.tEvt.sType)
        if self.tEvt.nFoo ~= 0 then
            self.tEvt.nFoo = 0
        end
        return(0)
    elseif self.tEvt.sType == "exit" then
        printf("d2-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "c" then
        printf("d2-%s;", self.tEvt.sType)
        self:stateTran(d1)
        return(0)
    elseif self.tEvt.sType == "f" then
        printf("d2-%s;", self.tEvt.sType)
        self:stateTran(d11)
        return(0)
    end
    return(self.tEvt.sType)
end

-- 
-- ====================================

function d21(self)
    if self.tEvt.sType == "init" then
        printf("d21-%s;", self.tEvt.sType)
        self:stateStart(d211)
        return(0)
    elseif self.tEvt.sType == "entry" then
        printf("d21-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "exit" then
        printf("d21-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "a" then
        printf("d21-%s;", self.tEvt.sType)
        self:stateTran(d21)
        return(0)
    elseif self.tEvt.sType == "b" then
        printf("d21-%s;", self.tEvt.sType)
        self:stateTran(d211)
        return(0)
    elseif self.tEvt.sType == "g" then
        printf("d21-%s;", self.tEvt.sType)
        self:stateTran(d1)
        return(0)
    end
    return(self.tEvt.sType)
end

-- ====================================

function d211(self)
    if self.tEvt.sType == "entry" then
        printf("d211-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "exit" then
        printf("d211-%s;", self.tEvt.sType)
        return(0)
    elseif self.tEvt.sType == "d" then
        printf("d211-%s;", self.tEvt.sType)
        self:stateTran(d21)
        return(0)
    elseif self.tEvt.sType == "h" then
        printf("d211-%s;", self.tEvt.sType)
        self:stateTran(top)
        return(0)
    end
    return(self.tEvt.sType)
end

-- 
-- ==============================================
-- create HSM instance and populate it with states

hsm = Hsm:new()

-- --------------------------------------------------------------------
--             name                               parent's
--              of              event             event
--             state            handler           handler
-- --------------------------------------------------------------------
hsm:addState ( "top",           top,               nil)
hsm:addState ( "d1",            d1,                top)
hsm:addState ( "d11",           d11,               d1)
hsm:addState ( "d2",            d2,                top)
hsm:addState ( "d21",           d21,               d2)
hsm:addState ( "d211",          d211,              d21)

-- ====================================
-- Interactive tester/explorer.

function test_interactive()
    -- hsm:dump()
    printf("\nInteractive Hierarchical State Machine Example\n")
    printf("Miros revision: %s\n", hsm:revision())
    printf("Enter 'quit' to end.\n\n")
    -- start/initialize HSM
    hsm:onStart(top)
    while true do
        printf("\nEvent&lt;-")
        -- get letter of event
        sType = io.read()
        if sType == "quit" then return end 
        if #sType ~= 1 or sType < "a" or sType > "h" then 
            printf("Event not defined.") 
        else
            -- dispatch event and display results
            hsm:onEvent(sType)
        end
    end
end

-- ====================================
-- Non-interactive test.

function test_non_interactive()
    -- hsm:dump()
    printf("\nNon-interactive Hierarchical State Machine Example\n")
    printf("Miros revision: %s\n", hsm:revision())
    printf("\nThe following pairs of lines should all match each other and\n")
    printf("the accompanying UML state chart 'hsmtst-chart.gif'.\n\n")
    -- start/initialize HSM
    hsm:onStart(top)
    printf("\ntop-entry;top-init;d2-entry;d2-init;d21-entry;d211-entry;\n\n")
    hsm:onEvent("a")
    printf("\nd21-a;d211-exit;d21-exit;d21-entry;d21-init;d211-entry;\n\n")
    hsm:onEvent("b")
    printf("\nd21-b;d211-exit;d211-entry;\n\n")
    hsm:onEvent("c")
    printf("\nd2-c;d211-exit;d21-exit;d2-exit;d1-entry;d1-init;d11-entry;\n\n")
    hsm:onEvent("d")
    printf("\nd11-d;d11-exit;d1-init;d11-entry;\n\n")
    hsm:onEvent("e")
    printf("\ntop-e;d11-exit;d1-exit;d1-entry;d11-entry;\n\n")
    hsm:onEvent("f")
    printf("\nd1-f;d11-exit;d1-exit;d2-entry;d21-entry;d211-entry;\n\n")
    hsm:onEvent("g")
    printf("\nd21-g;d211-exit;d21-exit;d2-exit;d1-entry;d1-init;d11-entry;\n\n")
    hsm:onEvent("h")
    printf("\nd11-h;d11-exit;d1-exit;top-init;d2-entry;d2-init;d21-entry;d211-entry;\n\n")
    hsm:onEvent("g")
    printf("\nd21-g;d211-exit;d21-exit;d2-exit;d1-entry;d1-init;d11-entry;\n\n")
    hsm:onEvent("f")
    printf("\nd1-f;d11-exit;d1-exit;d2-entry;d21-entry;d211-entry;\n\n")
    hsm:onEvent("e")
    printf("\ntop-e;d211-exit;d21-exit;d2-exit;d1-entry;d11-entry;\n\n")
    hsm:onEvent("d")
    printf("\nd11-d;d11-exit;d1-init;d11-entry;\n\n")
    hsm:onEvent("c")
    printf("\nd1-c;d11-exit;d1-exit;d2-entry;d2-init;d21-entry;d211-entry;\n\n")
    hsm:onEvent("b")
    printf("\nd21-b;d211-exit;d211-entry;\n\n")
    hsm:onEvent("a")
    printf("\nd21-a;d211-exit;d21-exit;d21-entry;d21-init;d211-entry;\n\n")
end

-- ====================================

-- test_interactive()
test_non_interactive()

-- ==================================================================
-- Win32 sees the first line of this file as part of a batch file and jumps
-- over the Lua code above. That same line is ignored by Lua. As a result
-- this file can also be run directly by Lua. Win32 sees the Lua comment
-- below as part of a batch file while Lua obviously ignores it. The
-- concept is based on a 9/16/06 "lua-l" mail list thread titled "Lua
-- scripts made into executable on win32 ..." (search
-- http://lua-users.org/lists/lua-l/). Thanks guys!

--[[
:=bat_commands
@echo off

: ===============================================
: Uses globally installed Lua

: =====================================
set LUA_PATH=%LUA_PATH%;.\lib\?.lua;.\lib\local\?.lua;;
set LUA_CPATH=%LUA_CPATH%;.\lib\?.dll;.\lib\local\?.dll;;

: =====================================
: lua.exe -ltrace-calls %0
lua.exe %0

: ===============================================
: Use the Lua located local to working directory

: =====================================
: set LUA_PATH=.\lib\?.lua;.\lib\local\?.lua;;
: set LUA_CPATH=.\lib\?.dll;.\lib\local\?.dll;;

: =====================================
: set LUA_PATH=%LUA_PATH%;.\lua\local\?.lua;;
: set LUA_CPATH=%LUA_CPATH%;.\clibs\local\?.dll;;

: =====================================
: .\lua.exe -ltrace-calls %0
: .\lua.exe -ltrace-globals %0
: .\bin\lua.exe %0

: ===============================================
: Uncomment to inspect results of non-interactive runs
pause

:]]

