local c4u = { internals = {} }

do
    local allocatedIdsByTarget = {}
    local function allocateId(target)
        if target == nil then
            target = '#'
        end
        local ar = allocatedIdsByTarget[target]
        if ar == nil then
            ar = {}
            allocatedIdsByTarget[target] = ar
        end
        local rId, ari, arl = 1, 1, #ar
        while i <= arl do
            if rId < ar[i] then
                ar[]
                table.insert(ar, i, rId)
                return rId
            end
            ari = ari + 1
            rId = ar[i] + 1
        end
        ar[arl + 1] = rId
        return rId
    end
    
    local function freeId(target, id)
        local ar = allocatedIdsByTarget[target]
        if ar == nil then
            return
        end
        local i, arl = 1, #ar
        while i <= arl do
            if ar[i] == id then
                table.remove(ar, i)
                return
            end
            i = i + 1
        end
    end

    function c4u.internals.playerLeft(name)
        if allocatedIdsByTarget[name] ~= nil then
            allocatedIdsByTarget[name] = nil
        end
    end

    c4u.component = {}

    function c4u.component.subtype()
        local r = {}
        function r:target()
            return self._target
        end
        function r:setTarget(v)
            self._target = v ~= nil and tostring(v) or nil
        end
        function r:parent()
            return self._parent
        end
        function r:children()
            return self._children and {table.unpack(self._children)} or {}
        end
        function r:x()
            return self._x
        end
        function r:setX(v)
            self._x = tonumber(v)
        end
        function r:y()
            return self._y
        end
        function r:setY(v)
            self._y = tonumber(v)
        end
        function r:render()
        end
        return setmetatable(r, {
            __call = function(_, ...)
                return r:new(...)
            end,
        })
    end

    function c4u.component.subtype_instance(type)
        return setmetatable({
            _children = nil,
            _target = nil,
            _x =  0,
            _y = 0,
        }, {
            __index = type
        })
    end

    c4u.textarea = c4u.component.subtype()

    function c4u.textarea:new()
        local r = c4u.component.subtype_instance()
        return r
    end
end
