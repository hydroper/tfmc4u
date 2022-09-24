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
        while ari <= arl do
            if rId < ar[ari] then
                ar[]
                table.insert(ar, ari, rId)
                return rId
            end
            ari = ari + 1
            rId = ar[ari] + 1
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
                if arl == 1 then
                    allocatedIdsByTarget[target] = nil
                end
                return
            end
            i = i + 1
        end
    end

    function c4u.internals.playerLeft(name)
        allocatedIdsByTarget[name] = nil
    end

    c4u.component = {}

    function c4u.component.subtype()
        local r = {}
        function r:typeof()
            return self._typeof
        end
        function r:target()
            return self._target
        end
        function r:setTarget(v)
            self._target = v ~= nil and tostring(v) or nil
            return self
        end
        function r:parent()
            return self._parent
        end
        function r:children()
            return self._children and {table.unpack(self._children)} or {}
        end
        function r:addChild(c)
            self._children = self._children || {}
            table.insert(self._children, c)
            return self
        end
        function r:removeChild(c)
            if self._children == nil then
                return false
            end
            for i, v in ipairs(self._children) do
                if v == c then
                    table.remove(self._children, i)
                    c._parent = nil
                    return true
                end
            end
            return false
        end
        function r:x()
            return self._x
        end
        function r:setX(v)
            self._x = tonumber(v)
            return self
        end
        function r:y()
            return self._y
        end
        function r:setY(v)
            self._y = tonumber(v)
            return self
        end
        function r:globalX()
            local p = self._parent
            if p == nil then
                return self._x
            end
            return p:globalX() + self._x
        end
        function r:globalY()
            local p = self._parent
            if p == nil then
                return self._y
            end
            return p:globalY() + self._y
        end
        function r:render()
        end
        function r:unrender()
            self:unrenderChildren()
        end
        function r:unrenderChildren()
            if self._children == nil then
                return
            end
            for i, v in ipairs(self._children) do
                v:unrender()
            end
        end
        return setmetatable(r, {
            __call = function(_, ...)
                return r:new(...)
            end,
        })
    end

    function c4u.component.subtype_instance(type)
        return setmetatable({
            _typeof = type,
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
        r._text = '';
        r._width = 0;
        r._height = 0;
        r._backgroundColor = 0x324650;
        r._borderColor = 0;
        r._backgroundAlpha = 0;
        r._fixedPos = false;
        return r
    end
end
