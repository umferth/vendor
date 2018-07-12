
-- Evaluating items for selling.
Vendor = Vendor or {}

function Vendor:GetRuleConfig()
	if (not Vendor_RulesConfig) then
		Vendor_RulesConfig = Vendor:DeepTableCopy(self.db.defaults.rule)
	end	
	return Vendor_RulesConfig
end

-- Called when our rule configuration has changed
function Vendor:OnRuleConfigUpdated()
	if (self.ruleManager) then
		self.ruleManager:UpdateConfig(self:GetRuleConfig())
	end
end

-- Rules for determining if an item should be sold.
-- TODO: Make this a dynamic system with default rules and allow user-supplied rules.
function Vendor:EvaluateItemForSelling(item)

    -- Check some cases where we know we should never ever sell the item
    if not item then
        return false
    end

    -- If have not yet initialized, or the config has changed we need to build our list of "keep" rules
    -- we always add the check against the neversell list no matter what the options says
    if (not self.ruleManager) then
        self.ruleManager = Vendor.RuleManager:Create(Vendor.RuleFunctions);
        self:OnRuleConfigUpdated()
    end
    
    -- Determine if we should keep this item or not
    local result, fromRule, _, ruleName = self.ruleManager:Run(item)
    if (result == Vendor.RULE_ACTION_SELL) then    
        Vendor:DebugRules("Selling '%s' due to rule '%s'", item.Name, fromRule)
    	return true, fromRule, ruleName
    elseif (result == Vendor.RULE_ACTION_KEEP) then
        Vendor:DebugRules("Keeping '%s' due to rule '%s'", item.Name, fromRule)
    	return false, fromRule, ruleName
    elseif (result == Vendor.RULE_ACTION_PROMPT) then
    	assert(false, "Not Yet Implemented")
    end

    -- Doesn't fit one of our above sell criteria so we keep it.
    return false, nil, nil
end


