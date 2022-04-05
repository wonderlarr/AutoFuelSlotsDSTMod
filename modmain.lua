-- Quality of Lanters, a simple QOL mod for lanterns. It's pretty awesome
-- By Skylarr

TUNING = GLOBAL.TUNING

TUNING.AFS_SLOTSIZE = GetModConfigData("slotsize")
TUNING.AFS_SLOTBG = GetModConfigData("containerbg")

TUNING.AFS_LANTERN = GetModConfigData("lantern")
TUNING.AFS_MINERHAT = GetModConfigData("minerhat")
TUNING.AFS_ARMORSKELETON = GetModConfigData("armorskeleton")
TUNING.AFS_MOLEHAT = GetModConfigData("molehat")
TUNING.AFS_SHIELDOFTERROR = GetModConfigData("shieldofterror")
TUNING.AFS_YELLOWAMULET = GetModConfigData("yellowamulet")
TUNING.AFS_THURIBLE = GetModConfigData("thurible")
TUNING.AFS_EYEMASK = GetModConfigData("eyemaskhat")
TUNING.AFS_POCKETWATCH_WEAPON = GetModConfigData("pocketwatch_weapon")

-- Hack the inventory bar and some playerhud code to enable us to add slots for more things than just the hand slot. 
-- I wish Klei made this easier jeez
AddClassPostConstruct("screens/playerhud", function(self)
    -- Hook into playerhud:OpenContainer to get a head slot variant of a hand_inv container working correctly
    local _OpenContainer = self.OpenContainer
    local ContainerWidget = GLOBAL.require("widgets/containerwidget")


    self.OpenContainer = function(self, container, side)

        -- local OpenContainerWidget copy pasted from playerhud.lua, with one small change.
        local function OpenContainerWidget(self, container, side)
            local containerwidget = ContainerWidget(self.owner)
            local parent = side and self.controls.containerroot_side
            -- or (container.replica.container ~= nil and container.replica.container.type == "hand_inv") and self.controls.inv.hand_inv
            or (container.replica.container ~= nil and container.replica.container.type == "head_inv") and self.controls.inv.head_inv
            or (container.replica.container ~= nil and container.replica.container.type == "body_inv") and self.controls.inv.body_inv
            or (container.replica.container ~= nil and container.replica.container.type == "amulet_inv") and self.controls.inv.amulet_inv -- not in vanilla, added by other mods
            or self.controls.containerroot

            parent:AddChild(containerwidget)
        
            containerwidget:MoveToBack()
            containerwidget:Open(container, self.owner)
            self.controls.containers[container] = containerwidget
        end


        if container ~= nil and ((container.replica.container.type == "head_inv" and self.controls.inv.head_inv) or 
        (container.replica.container.type == "body_inv" and self.controls.inv.body_inv) or
        (container.replica.container.type == "amulet_inv" and self.controls.inv.amulet_inv)) then -- not in vanilla, added by other mods
            -- If we're using the head_inv slot, override the normal function so we're placed correctly.
            local ret = OpenContainerWidget(self, container, side)
            return ret
        else
            -- Otherwise, run the normal one.
            -- No need to check if container is nil, the original function does that for us.
            local ret = _OpenContainer(self, container, side)
            return ret
        end
    end
end)

AddClassPostConstruct("widgets/inventorybar", function(self)
    local Widget = GLOBAL.require "widgets/widget"

    local widgetscale = 1.5

    -- hand_inv added by the vanilla game
    self.hand_inv:SetScale(widgetscale, widgetscale)

    self.head_inv = self.root:AddChild(Widget("head_inv"))
    self.head_inv:SetScale(widgetscale, widgetscale)

    self.body_inv = self.root:AddChild(Widget("body_inv"))
    self.body_inv:SetScale(widgetscale, widgetscale)

    self.amulet_inv = self.root:AddChild(Widget("amulet_inv"))
    self.amulet_inv:SetScale(widgetscale, widgetscale)
    
    local _rebuild = self.Rebuild

    self.HeadInv = function(self)

        local function RebuildLayout(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
            local W = 68
            local SEP = 12
            local INTERSEP = 28

            local num_slots = inventory:GetNumSlots()
            local num_equip = #self.equipslotinfo
            local num_buttons = do_self_inspect and 1 or 0
            local num_slotintersep = math.ceil(num_slots / 5)
            local num_equipintersep = num_buttons > 0 and 1 or 0
            local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP
        
            local x = (W - total_w) * .5 + num_slots * W + (num_slots - num_slotintersep) * SEP + num_slotintersep * INTERSEP
            for k, v in ipairs(self.equipslotinfo) do

                if v.slot == GLOBAL.EQUIPSLOTS.HEAD then
                    self.head_inv:SetPosition(x, do_integrated_backpack and 80 or 40, 0)
                    self.head_inv:MoveToBack()
                end

                if v.slot == GLOBAL.EQUIPSLOTS.BODY then
                    self.body_inv:SetPosition(x, do_integrated_backpack and 80 or 40, 0)
                    self.body_inv:MoveToBack()
                end

                if GLOBAL.EQUIPSLOTS.NECK ~= nil and v.slot == GLOBAL.EQUIPSLOTS.NECK then -- added for compatiblity with equipslot mods. hopefully they call their slot this.
                    self.amulet_inv:SetPosition(x, do_integrated_backpack and 80 or 40, 0)
                    self.amulet_inv:MoveToBack()
                end
        
                x = x + W + SEP
            end
        end

        -- end layout rebuild

        if self.cursor ~= nil then
            self.cursor:Kill()
            self.cursor = nil
        end
    
        if self.toprow ~= nil then
            self.toprow:Kill()
            self.inspectcontrol = nil
        end
    
        if self.bottomrow ~= nil then
            self.bottomrow:Kill()
        end

    
        self.inv = {}
        self.equip = {}
        self.backpackinv = {}
    
        local controller_attached = GLOBAL.TheInput:ControllerAttached()
        self.controller_build = controller_attached
        self.integrated_backpack = controller_attached or GLOBAL.Profile:GetIntegratedBackpack()
    
        local inventory = self.owner.replica.inventory
    
        local overflow = inventory:GetOverflowContainer()
        overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil
    
        local do_integrated_backpack = overflow ~= nil and self.integrated_backpack
        local do_self_inspect = not (self.controller_build or GLOBAL.GetGameModeProperty("no_avatar_popup"))
    
        RebuildLayout(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
    
    
        self:SelectDefaultSlot()
        self.current_list = self.inv
        self:UpdateCursor()
    
        -- if self.cursor ~= nil then
        --     self.cursor:MoveToFront()
        -- end
    
        self.rebuild_pending = nil
        self.rebuild_snapping = nil
    end



    self.Rebuild = function(self)
        self.HeadInv(self)

        _rebuild(self)
    end
end)

-- Add slots to the actual items
-- lantern
if TUNING.AFS_LANTERN then
    AddPrefabPostInit("lantern", function(inst)
        local function OnTick(inst)
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner

                local fueltogive = inst.components.container:GetItemInSlot(1).components.fuel.fuelvalue
                local currentfuel = inst.components.fueled.currentfuel
                local maxfuel = inst.components.fueled.maxfuel

                if (maxfuel - currentfuel) > fueltogive then
                    local fuelitem = inst.components.container:GetItemInSlot(1).components.stackable:Get(1)
                    inst.components.fueled:TakeFuelItem(fuelitem, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        local containers = GLOBAL.require("containers")
        params = containers.params

        params.lantern_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = "hand_inv",
        }
        
        function params.lantern_inv.itemtestfn(container, item, slot)
            return item:HasTag("cavefuel") -- Tag added by this mod, not in vanilla.
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("lantern_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("lantern_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
    end)
end

-- minerhat
if TUNING.AFS_MINERHAT then
    AddPrefabPostInit("minerhat", function(inst)
        local function OnTick(inst)
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner

                local fueltogive = inst.components.container:GetItemInSlot(1).components.fuel.fuelvalue
                local currentfuel = inst.components.fueled.currentfuel
                local maxfuel = inst.components.fueled.maxfuel

                if (maxfuel - currentfuel) > fueltogive then
                    local fuelitem = inst.components.container:GetItemInSlot(1).components.stackable:Get(1)
                    inst.components.fueled:TakeFuelItem(fuelitem, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        local containers = GLOBAL.require("containers")
        params = containers.params

        params.minerhat_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = "head_inv",
        }
        
        function params.minerhat_inv.itemtestfn(container, item, slot)
            return item:HasTag("cavefuel") -- Tag added by this mod, not in vanilla.
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("minerhat_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("minerhat_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
    end)
end

-- armorskeleton / bone armor
if TUNING.AFS_ARMORSKELETON then
    AddPrefabPostInit("armorskeleton", function(inst)
        local function OnTick(inst)
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner

                local fueltogive = inst.components.container:GetItemInSlot(1).components.fuel.fuelvalue
                local currentfuel = inst.components.fueled.currentfuel
                local maxfuel = inst.components.fueled.maxfuel

                if (maxfuel - currentfuel) > fueltogive then
                    local fuelitem = inst.components.container:GetItemInSlot(1).components.stackable:Get(1)
                    inst.components.fueled:TakeFuelItem(fuelitem, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        local containers = GLOBAL.require("containers")
        params = containers.params

        params.armorskel_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = "body_inv",
        }
        
        function params.armorskel_inv.itemtestfn(container, item, slot)
            return item:HasTag("nightmarefuel") -- Tag added by this mod, not in vanilla.
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("armorskel_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("armorskel_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
    end)
end

-- molehat / moggles
if TUNING.AFS_MOLEHAT then
    AddPrefabPostInit("molehat", function(inst)
        local function OnTick(inst)
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner

                local fueltogive = inst.components.container:GetItemInSlot(1).components.fuel.fuelvalue
                local currentfuel = inst.components.fueled.currentfuel
                local maxfuel = inst.components.fueled.maxfuel

                if (maxfuel - currentfuel) > fueltogive then
                    local fuelitem = inst.components.container:GetItemInSlot(1).components.stackable:Get(1)
                    inst.components.fueled:TakeFuelItem(fuelitem, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        local containers = GLOBAL.require("containers")
        params = containers.params

        params.moggles_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = "head_inv",
        }
        
        function params.moggles_inv.itemtestfn(container, item, slot)
            return item:HasTag("wormfuel") -- Tag added by this mod, not in vanilla.
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("moggles_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("moggles_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
    end)
end

-- shieldofterror
if TUNING.AFS_SHIELDOFTERROR then
    AddPrefabPostInit("shieldofterror", function(inst)
        -- different ontick function for the shield, since it doesn't use the same system for durability as the other items covered in this mod
        local function OnTick(inst) 
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner
                local food = inst.components.container:GetItemInSlot(1)
                -- inst is shield

                if not food.components.edible then
                    return -- return if we aren't edible somehow
                end

                local armortogive = math.abs((food.components.edible.healthvalue * 4)) + math.abs((food.components.edible.hungervalue * 1.75))
                local currentarmor = inst.components.armor.condition
                local maxarmor = inst.components.armor.maxcondition

                if (maxarmor - currentarmor) > armortogive then
                    inst.components.eater:Eat(food, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        local containers = GLOBAL.require("containers")
        params = containers.params

        params.shieldofterror_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = "hand_inv",
        }
        
        function params.shieldofterror_inv.itemtestfn(container, item, slot)
            for k, v in pairs(GLOBAL.FOODTYPE) do
                if item:HasTag("edible_"..v) then
                    return true
                end
            end

            return false
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("shieldofterror_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("shieldofterror_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
        -- armordamaged added for improved visual feedback
        inst:ListenForEvent("armordamaged", OnTick)
    end)
end

-- yellowamulet / magilguminuibnaweiourhoaiweur
-- i hate typing out that word
if TUNING.AFS_YELLOWAMULET then
    AddPrefabPostInit("yellowamulet", function(inst)
        local function OnTick(inst)
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner

                local fueltogive = inst.components.container:GetItemInSlot(1).components.fuel.fuelvalue
                local currentfuel = inst.components.fueled.currentfuel
                local maxfuel = inst.components.fueled.maxfuel

                if (maxfuel - currentfuel) > fueltogive then
                    local fuelitem = inst.components.container:GetItemInSlot(1).components.stackable:Get(1)
                    inst.components.fueled:TakeFuelItem(fuelitem, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        -- if we have a mod installed that adds a neck slot, we'll need to use a different container so the body slot doesn't get overriden
        -- if the mod installed uses a different name though we're out of luck. 

        local invtype = "body_inv" -- vanilla inventory type
        
        if GLOBAL.EQUIPSLOTS.NECK ~= nil then 
            invtype = "amulet_inv" -- if we have extra equip slots or something similar, make it work with that
        end

        local containers = GLOBAL.require("containers")
        params = containers.params

        params.yellowamulet_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = invtype, -- set in a local above
        }
        
        function params.yellowamulet_inv.itemtestfn(container, item, slot)
            return item:HasTag("nightmarefuel") -- Tag added by this mod, not in vanilla.
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("yellowamulet_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("yellowamulet_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
    end)
end

-- shadow thurible
if TUNING.AFS_THURIBLE then
    AddPrefabPostInit("thurible", function(inst)
        local function OnTick(inst)
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner

                local fueltogive = inst.components.container:GetItemInSlot(1).components.fuel.fuelvalue
                local currentfuel = inst.components.fueled.currentfuel
                local maxfuel = inst.components.fueled.maxfuel

                if (maxfuel - currentfuel) > fueltogive then
                    local fuelitem = inst.components.container:GetItemInSlot(1).components.stackable:Get(1)
                    inst.components.fueled:TakeFuelItem(fuelitem, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        local containers = GLOBAL.require("containers")
        params = containers.params

        params.thurible_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = "hand_inv",
        }
        
        function params.thurible_inv.itemtestfn(container, item, slot)
            return item:HasTag("nightmarefuel") -- Tag added by this mod, not in vanilla.
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("thurible_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("thurible_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
    end)
end
-- eyemaskhat / eye mask
-- Thank you subscriber for reminding me this exists
if TUNING.AFS_EYEMASK then
    AddPrefabPostInit("eyemaskhat", function(inst)
        -- different ontick function for the eyemask, since it doesn't use the same system for durability as the other items covered in this mod
        local function OnTick(inst) 
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner
                local food = inst.components.container:GetItemInSlot(1)
                -- inst is eye mask

                if not food.components.edible then
                    return -- return if we aren't edible somehow
                end

                local armortogive = math.abs((food.components.edible.healthvalue * 4)) + math.abs((food.components.edible.hungervalue * 1.75))
                local currentarmor = inst.components.armor.condition
                local maxarmor = inst.components.armor.maxcondition

                if (maxarmor - currentarmor) > armortogive then
                    inst.components.eater:Eat(food, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        local containers = GLOBAL.require("containers")
        params = containers.params

        params.eyemaskhat_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = "head_inv",
        }
        
        function params.eyemaskhat_inv.itemtestfn(container, item, slot)
            for k, v in pairs(GLOBAL.FOODTYPE) do
                if item:HasTag("edible_"..v) then
                    return true
                end
            end

            return false
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("eyemaskhat_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("eyemaskhat_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
        -- armordamaged added for improved visual feedback
        inst:ListenForEvent("armordamaged", OnTick)
    end)
end

-- Alarming Clock / pocketwatch_weapon
if TUNING.AFS_POCKETWATCH_WEAPON then
    AddPrefabPostInit("pocketwatch_weapon", function(inst)
        local function OnTick(inst)
            if inst.components.container and inst.components.container:GetItemInSlot(1) then
                local owner = inst.components.inventoryitem.owner

                local fueltogive = inst.components.container:GetItemInSlot(1).components.fuel.fuelvalue
                local currentfuel = inst.components.fueled.currentfuel
                local maxfuel = inst.components.fueled.maxfuel

                if (maxfuel - currentfuel) > fueltogive then
                    local fuelitem = inst.components.container:GetItemInSlot(1).components.stackable:Get(1)
                    inst.components.fueled:TakeFuelItem(fuelitem, owner)
                end
            end
        end

        local function OnEquip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Open(owner)
            end
        end

        local function OnUnequip(inst, data)
            local owner = data.owner
            if inst.components.container ~= nil then
                inst.components.container:Close(owner)
            end
        end
        
        -- Start Container stuff ---------
        local containers = GLOBAL.require("containers")
        params = containers.params

        params.pocketwatch_weapon_inv =
        {
            widget =
            {
                slotpos =
                {
                    GLOBAL.Vector3(0,   32 + 4,  0),
                },
                animbank = "ui_cookpot_1x2",
                animbuild = "ui_cookpot_1x2",
                pos = GLOBAL.Vector3(0, 15, 0),
            },
            usespecificslotsforitems = true,
            type = "hand_inv",
        }
        
        function params.pocketwatch_weapon_inv.itemtestfn(container, item, slot)
            return item:HasTag("nightmarefuel") -- Tag added by this mod, not in vanilla.
        end
        -- End Container -------
        

        if not GLOBAL.TheWorld.ismastersim then
            inst.OnEntityReplicated = function(inst) 
                inst.replica.container:WidgetSetup("pocketwatch_weapon_inv") 
            end

            return
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("pocketwatch_weapon_inv")
        inst.components.container.canbeopened = false

        inst.tick = inst:DoPeriodicTask(1, OnTick)

        inst:ListenForEvent("equipped", OnEquip)
        inst:ListenForEvent("unequipped", OnUnequip)
        inst:ListenForEvent("itemget", OnTick)
    end)
end

-- Fuel PostInits
-- I would love to do this more elegantly but the `fuel` component isn't added on the client, so I have to do it for each prefab manually.
AddPrefabPostInit("lightbulb", function(inst)
    inst:AddTag("cavefuel")
end)

AddPrefabPostInit("slurtleslime", function(inst)
    inst:AddTag("cavefuel")
end)

AddPrefabPostInit("fireflies", function(inst)
    inst:AddTag("cavefuel")
end)

AddPrefabPostInit("nightmarefuel", function(inst)
    inst:AddTag("nightmarefuel")
end)

AddPrefabPostInit("wormlight", function(inst)
    inst:AddTag("wormfuel")
end)

AddPrefabPostInit("wormlight_lesser", function(inst)
    inst:AddTag("wormfuel")
end)