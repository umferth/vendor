local AddonName, Addon = ...
local L = Addon:GetLocale();
local RulesPanel = {};
Addon.RulesPanels = Addon.RulesPanel or {};

local SCROLL_PADDING_X = 4;
local SCROLL_PADDING_Y = 17;
local SCROLL_BUTTON_PADDING = 4;

local function setLocalizedText(frame, control, keyname)
    if (target[control]) then
        local key = frame[keyname];
        if (type(key) == "string") then
            local text = L[key] or string.upper(key);
            frame[control]:SetText(text);
        end
    end
end

local UrlEditBox = {};
function UrlEditBox.OnLoad(self)
    Mixin(self, UrlEditBox);

    -- Set the text to the url key
    local key = self.UrlKey;
    if (type(key) == "string") then
        local text = L[key] or string.upper(key);
        self.text = text;
    else
        self.text = "";
    end

    self:SetText(self.text);
    self:SetBlinkSpeed(0);
    self:SetAutoFocus(false);
    self:SetScript("OnChar", self.RestoreText);
    self:SetScript("OnTextChanged", self.RestoreText);
    self:SetScript("OnEditFocusGained", self.OnFocus);
    self:SetScript("OnEditFocusLost", self.OnBlur);
end

function UrlEditBox.RestoreText(self)
    self:SetText(self.text or "");
end

function UrlEditBox.OnFocus(self)
    self:HighlightText();
end

function UrlEditBox.OnBlur(self)
    self:HighlightText(0,0);
end

Addon.Public.UrlEditBox = UrlEditBox;

local SFrame =
{
    OnLoad = function(self)
        ScrollFrame_OnLoad(self);
        local scrollbar = self.ScrollBar;
        local up = scrollbar.ScrollUpButton;
        local down = scrollbar.ScrollDownButton;
        local offsetY = self.ScrollBarOffsetY or 0
        local offsetX = self.ScrollBarOffsetX or 0;
        local spacing = self.ScrollAreaPadding or 12;
        
        -- Adjust the buttons
        up:SetPoint("BOTTOMLEFT", scrollbar, "TOPLEFT");
        up:SetPoint("BOTTOMRIGHT", scrollbar, "TOPRIGHT");
        down:SetPoint("TOPLEFT", scrollbar, "BOTTOMLEFT");
        down:SetPoint("TOPRIGHT", scrollbar, "BOTTOMRIGHT");

        -- Adjust the scrollbar
        scrollbar:ClearAllPoints()
        scrollbar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -up:GetHeight());
        scrollbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, down:GetHeight());

        -- If we have a background then move it.
        if (self.ScrollbarBg) then
            local bg = self.ScrollbarBg;
            bg:ClearAllPoints();
            bg:SetPoint("LEFT", up, "LEFT");
            bg:SetPoint("RIGHT", down, "RIGHT");
            bg:SetPoint("TOP", up, "CENTER");
            bg:SetPoint("BOTTOM", down, "CENTER");
            scrollbar.ScrollbarBg = bg;
        end
        

        -- Replace show so we can adjust our contents
        scrollbar.Show = function(self)
                local frame = self:GetParent();
                local spacing = frame.ScrollAreaPadding or 0;
                local width = (frame:GetWidth() - (self:GetWidth() + spacing));
                local child = frame:GetScrollChild();
                child:ClearAllPoints();
                child:SetPoint("TOPLEFT");
                child:SetPoint("RIGHT", scrollbar, "LEFT", -spacing, 0);

                if (self.ScrollbarBg) then
                    self.ScrollbarBg:Show();
                end
                
                getmetatable(self).__index.Show(self);
            end

        -- Replace hide so we can adjust our contents
        scrollbar.Hide = function(self)
                local frame = self:GetParent();
                local width = frame:GetWidth();
                local child = frame:GetScrollChild();

                child:SetWidth(width);
                if (self.ScrollbarBg) then
                    self.ScrollbarBg:Hide();
                end
                
                getmetatable(self).__index.Hide(self);
            end
            
        self.scrollBarHideable = 1;
        self.scrollbar = scrollbar;
        scrollbar:Hide();
    end,
}

local function invoke(frame, method, ...)
    local fn = frame[method];
    if (type(fn) == "function") then
        local result, msg = xpcall(fn, CallErrorHandler, frame, ...);
        if (not result) then
            Addon:Debug("rulesdialog", "Failed to invoke '%s': %s%s|r", method, RED_FONT_COLOR_CODE, msg);
        end
    end
end

-- Loads in initializes a new rules panel (called from the XML's onload)
function RulesPanel.onInit(self)
    -- Mixin the implementation of the panel.
    local subclass = self.Implementation;
    if ((type(subclass) == "string") and Addon.RulesPanels) then
        local obj = Addon.RulesPanels[subclass];
        if (type(Addon.RulesPanels[subclass]) == "table") then
            Mixin(self, obj);
        end
    else
        Addon:Debug("rulesdialog", "Expected an implementation for RulesPanel");
    end

    -- If a help text key was provied set the help text in the panel.
    if (self.HelpText) then
        local helpTextKey = self.HelpTextKey;
        if (type(helpTextKey) == "string") then
            local text = L[helpTextKey];
            if (type(text) == "string") then
                self.HelpText:SetText(text);
            end
        else
            self.HelpText:SetText("");
        end
    end

    -- Load the panel and attach an onevent in case the subclass registers.
    self:SetScript("OnEvent", function(...) invoke(self, "OnEvent", ...) end);
    self:SetScript("OnShow", function(...) invoke(self, "OnShow", ...) end);
    self:SetScript("OnHide", function(...) invoke(self, "OnHide", ...) end);
    invoke(self, "OnLoad");
end


--local VENDOR_URL = "https://bit.ly/3kcOKOT";
local VENDOR_URL = "https://www.curseforge.com/wow/addons/vendor";
local VENDOR_TUTORIAL = "https://youtu.be/j93Orw3vPKQ";

local WHATS_NEW = { 
    ["v3.1.4"] = "<p>What's new in this version</p>",
    ["v4.0.0"] = "<p>What's new in this other version</p><p>this is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still string</p>",
    ["v4.0.1"] = "<p>What's new in this other version</p><p>this is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still string</p>",
    ["v4.0.2"] = "<p>What's new in this other version</p><p>this is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still string</p>",
    ["v4.0.3"] = "<p>What's new in this other version</p><p>this is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still string</p>",
    ["v4.0.4"] = "<p>What's new in this other version</p><p>this is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still string</p>",
    ["v4.0.5"] = "<p>What's new in this other version</p><p>this is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still string</p>",
    ["v4.0.6"] = "<p>What's new in this other version</p><p>this is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still string</p>",
    ["v4.0.7"] = "<p>What's new in this other version</p><p>this is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still stringthis is a really long much longer, and longer still string</p>",
};

local HelpPanel = {};
function HelpPanel:OnLoad()
    if (self.ReleaseNotesText) then
        SFrame.OnLoad(self.ReleaseNotesText);
        self.ReleaseNotesText.content:SetText("<html><body><h1>Hello</h1><p>this is some text</p></body></html>");
    end

    self.ReleaseVersion.html = self.ReleaseNotesText:GetScrollChild();
    UIDropDownMenu_SetWidth(self.ReleaseVersion, self.Url:GetWidth() - 12);
    UIDropDownMenu_Initialize(self.ReleaseVersion, HelpPanel.CreateVersionList);
    UIDropDownMenu_JustifyText(self.ReleaseVersion, "LEFT");
end

function HelpPanel.CreateVersionList(frame, level)
    local info = UIDropDownMenu_CreateInfo();
    info.isNotRadio = true;	
    info.notCheckable = true;
    info.arg1 = frame;

    if (level == 1) then
        for index, notes in ipairs(Addon.ReleaseNotes) do
            local text = string.format("%s (%s)", notes.release, notes.on);
            info.text = text
            info.value = index;
            info.arg2 = notes.html;
            info.func = function(self, dropdown, html)
                UIDropDownMenu_SetText(dropdown, self:GetText());
                dropdown.html:SetText(html);
            end;			
            UIDropDownMenu_AddButton(info, 1);
        end
    end
end

function HelpPanel:OnShow()
    local notes = Addon.ReleaseNotes[1];
    UIDropDownMenu_SetText(self.ReleaseVersion, string.format("%s (%s)", notes.release, notes.on));
    self.ReleaseVersion.html:SetText(notes.html);
end

function HelpPanel:OnHide()
end

--[[ Lists Panel ]]

local ListType = Addon.ListType;
local ListsItem = {};

function ListsItem:OnCreated()
    self:SetScript("OnClick", self.OnClick);
end

function ListsItem:OnModelChanged(model)
    self.Name:SetText(model.name);
end

function ListsItem:OnUpdate()
    if (self:IsMouseOver()) then
        self.Hover:Show();
    else
        self.Hover:Hide();
    end
end

function ListsItem:OnSelected(selected)
    if (selected) then
        self.Selected:Show();
        self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
    else
        self.Selected:Hide();
        self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
    end
end

function ListsItem:OnClick()
    self:GetParent():Select(self:GetModel());
end

local SystemListId = 
{
    NEVER = "system:never-sell",
    ALWAYS = "system:always-sell",
    DESTROY = "system:always-destroy",
};

local SYSTEM_LISTS = 
{
    {
        id = SystemListId.NEVER,
        name  = L.NEVER_SELL_LIST_NAME,
        empty = L.RULES_DIALOG_EMPTY_KEEP_LIST,
    },
    {
        id = SystemListId.ALWAYS,
        name  = L.ALWAYS_SELL_LIST_NAME,
        empty = L.RULES_DIALOG_EMPTY_SELL_LIST,
    },
    {
        id = SystemListId.DESTROY,
        name  = L.ALWAYS_DESTROY_LIST_NAME,
        empty = L.RULES_DIALOG_EMPTY_DELETE_LIST,
    }
};

local ListsPanel = 
{
    OnLoad = function(self)
        self.Lists.ItemHeight = 20;
        self.Lists.ItemTemplate = "Vendor_ItemLists_ListItem";
        self.Lists.ItemClass = ListsItem;
        self.Items.isReadOnly = false;

        self.Lists.GetItems = function()
            return SYSTEM_LISTS;
        end

        self.Lists.OnSelection = function() 
            self:OnSelectionChanged();
        end

        self.Items.OnAddItem = function(list, item)
            self:OnAddItem(item);
        end

        self.Items.OnDeleteItem=  function(list, item)
            self:OnDeleteItem(item);
        end

        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
    end,

    OnShow = function(self)
        self.Lists:Update();
        Addon:GetProfileManager():RegisterCallback("OnProfileChanged", self.OnSelectionChanged, self);
        if (not self.Lists:GetSelected()) then
            self.Lists:Select(1);
        end
    end,

    OnHide = function(self)
        Addon:GetProfileManager():UnregisterCallback("OnProfileChanged", self.OnSelectionChanged, self);
    end,
};

function ListsPanel:OnDeleteItem(item)
    local list = assert(self:GetSelectedList());
    if (list) then
        list:Remove(Addon.ItemList.GetItemId(item));
    end
end

function ListsPanel:OnAddItem(item)
    local list = assert(self:GetSelectedList());
    if (list) then
        list:Add(Addon.ItemList.GetItemId(item));
    end
end

--[[===========================================================================
    | Retrieves the currently selected list, returns the list, or nil to 
    | indicate there was no selection. Also returns the empty text to show
    | for the specified list.
	========================================================================--]]
function ListsPanel:GetSelectedList()
    local selection = self.Lists:GetSelected();
    if (selection) then
        local id = selection.id;        
        if (id == SystemListId.NEVER) then
            return Addon:GetList(ListType.KEEP), selection.empty;
        elseif (id == SystemListId.ALWAYS) then
            return Addon:GetList(ListType.SELL), selection.empty;
        elseif (id == SystemListId.DESTROY) then
            return Addon:GetList(ListType.DESTROY), selection.empty;
        end
    end

    return nil;
end

--[[===========================================================================
    | Called to handle selction changed, this simply populates the contents of
    | the list with the items from the currently selected list.
	========================================================================--]]
function ListsPanel:OnSelectionChanged()
    local list, empty = self:GetSelectedList();
    self.Items:SetEmptyText(empty);

    if (not list) then
        -- List is empty
        self.Items:SetContents();
        self.ItemCount:Hide();
    else
        local contents = list:GetItems();
        local count = table.getn(contents);
        
        self.Items:SetContents(contents);
        if  (count ~= 0) then
            self.ItemCount:SetFormattedText("(%d)", count);
            self.ItemCount:Show();
        else
            self.ItemCount:Hide();
        end
    end
end

Addon.RulesPanels.HelpPanel = HelpPanel;
Addon.RulesPanels.ListsPanel = ListsPanel;
Addon.Public.RulesPanel = RulesPanel;