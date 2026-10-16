--test
local s,id=GetID()
function s.initial_effect(c)
    -- Send itself at start of Duel
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetRange(LOCATION_DECK)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.startop)
    c:RegisterEffect(e1)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_DECK) then
		Duel.SendtoDeck(c,nil,-2,REASON_EFFECT+REASON_RULE)
		--replace draw
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetCountLimit(1)
		e2:SetCondition(s.igcon)
		e2:SetTarget(s.igtg)
        e2:SetOperation(s.ignop)
        Duel.RegisterEffect(e2,tp)
    end
end
function s.igcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.GetAttacker():IsControler(tp)
end
function s.igtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=Duel.GetAttacker()
end
function s.ignop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	local c=Duel.GetAttacker()
	local dam=c:GetAttack()/2
	Duel.NegateAttack()
end
