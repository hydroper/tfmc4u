_G.c4u = { internals = {} }

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
        if target == nil then
            target = '#'
        end
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
            if self:isRendered() then
                error('Illegal target reassignment on rendered component')
            end
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
            self._children = self._children or {}
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
        function r:isRendered()
            return false
        end
        function r:render()
            self:renderChildren()
        end
        function r:renderChildren()
            if self._children == nil then
                return
            end
            for i, v in ipairs(self._children) do
                v:render()
            end
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
        function r:inheritTarget()
            local parent = self._parent
            if parent ~= nil then
                return parent.inheritTarget()
            end
            return self._target
        end
        function r:inheritFixedPos()
            local parent = self._parent
            if parent ~= nil then
                return parent.inheritFixedPos()
            end
            return self._fixedPos
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
            _x = 0,
            _y = 0,
        }, {
            __index = type
        })
    end

    c4u.textarea = c4u.component.subtype()

    function c4u.textarea:new()
        local r = c4u.component.subtype_instance()
        r._renderedId = -1
        r._text = ''
        r._width = 0
        r._height = 0
        r._backgroundColor = 0x324650
        r._borderColor = 0
        r._backgroundAlpha = 0
        r._fixedPos = false
        return r
    end

    function c4u.textarea:isRendered()
        return self._renderedId ~= -1
    end
    
    function c4u.textarea:text()
        return self._text
    end

    function c4u.textarea:setText(v)
        self._text = tostring(v)
        return self
    end

    function c4u.textarea:width()
        return self._width
    end

    function c4u.textarea:setWidth(v)
        self._width = tonumber(v)
        return self
    end

    function c4u.textarea:height()
        return self._height
    end

    function c4u.textarea:setHeight(v)
        self._height = tonumber(v)
        return self
    end

    function c4u.textarea:backgroundColor()
        return self._backgroundColor
    end

    function c4u.textarea:setBackgroundColor(v)
        self._backgroundColor = tonumber(v)
        return self
    end

    function c4u.textarea:borderColor()
        return self._borderColor
    end

    function c4u.textarea:setBorderColor(v)
        self._borderColor = tonumber(v)
        return self
    end

    function c4u.textarea:backgroundAlpha()
        return self._backgroundAlpha
    end

    function c4u.textarea:setBackgroundAlpha(v)
        self._backgroundAlpha = tonumber(v)
        return self
    end 

    function c4u.textarea:fixedPos()
        return self._fixedPos
    end

    function c4u.textarea:setFixedPos(v)
        self._fixedPos = not not v
        return self
    end

    function c4u.textarea:updateRenderedText()
        if self:isRendered() then
            ui.updateTextArea(self._renderedId, self._text, self:inheritTarget())
        end
    end

    function c4u.textarea:render()
        if self:isRendered() then
            self:unrender()
        end
        local target = self:inheritTarget()
        self._renderedId = allocateId(target)
        local parent = self._parent
        ui.addTextArea(self._renderedId, self._text, target, self:globalX(), self:globalY(), self._width, self._height, self._backgroundColor, self._borderColor, self._backgroundAlpha, self:inheritFixedPos())
        self:renderChildren()
    end

    function c4u.textarea:unrender()
        if not self:isRendered() then
            return
        end
        local target = self:inheritTarget()
        ui.removeTextArea(self._renderedId, target)
        freeId(target, self._renderedId)
        self._renderedId = -1
        self:unrenderChildren()
    end

    c4u.image = c4u.component.subtype()

    function c4u.image:new()
        local r = c4u.component.subtype_instance()
        r._renderedId = -1
        r._source = ''
        r._fixedPos = false
        r._scaleX = 1
        r._scaleY = 1
        r._angle = 0
        r._alpha = 1
        r._anchorX = 0
        r._anchorY = 0
        return r
    end

    function c4u.image:isRendered()
        return self._renderedId ~= -1
    end
    
    function c4u.image:source()
        return self._source
    end

    function c4u.image:setSource(v)
        self._source = v
        return self
    end

    function c4u.image:fixedPos()
        return self._fixedPos
    end

    function c4u.image:setFixedPos(v)
        self._fixedPos = not not v
        return self
    end

    function c4u.image:scaleX()
        return self._scaleX
    end

    function c4u.image:setScaleX(v)
        self._scaleX = tonumber(v)
        return self
    end

    function c4u.image:scaleY()
        return self._scaleY
    end

    function c4u.image:setScaleY(v)
        self._scaleY = tonumber(v)
        return self
    end

    function c4u.image:angle()
        return self._angle
    end

    function c4u.image:setAngle(v)
        self._angle = tonumber(v)
        return self
    end

    function c4u.image:alpha()
        return self._alpha
    end

    function c4u.image:setAlpha(v)
        self._alpha = tonumber(v)
        return self
    end

    function c4u.image:anchorX()
        return self._anchorX
    end

    function c4u.image:setAnchorX(v)
        self._anchorX = tonumber(v)
        return self
    end

    function c4u.image:anchorY()
        return self._anchorY
    end

    function c4u.image:setAnchorY(v)
        self._anchorY = tonumber(v)
        return self
    end

    function c4u.image:render()
        if self:isRendered() then
            self:unrender()
        end
        local target = self:inheritTarget()
        local parent = self._parent
        local fixedPos = self:inheritFixedPos()
        self._renderedId = tfm.exec.addImage(self._source, (fixedPos and '&' or '!') .. tostring(1), self:globalX(), self:globalY(), target, self._scaleX, self._scaleY, self._angle, self._alpha, self._anchorX, self._anchorY)
        self:renderChildren()
    end

    function c4u.image:unrender()
        if not self:isRendered() then
            return
        end
        tfm.exec.removeImage(self._renderedId)
        self._renderedId = -1
        self:unrenderChildren()
    end
end
