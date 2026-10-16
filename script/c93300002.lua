local s,id=GetID()

function s.initial_effect(c)
	-- Skill procedure
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop,EVENT_DESTROYED)
end

-- Skill activation condition
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=tp then return false end
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	if not re or not re:GetHandler() then return false end

	-- Check destroyed opponent monster by your card
	return eg:IsExists(s.cfilter,1,nil,tp,re)
end

function s.cfilter(c,tp,re)
	return c:IsReason(REASON_DESTROY)
		and c:IsPreviousControler(1-tp)
		and c:IsPreviousLocation(LOCATION_MZONE)
		and re:GetHandler():IsControler(tp)
		and c:IsCanBeSpecialSummoned(re,0,tp,false,false)
end

-- Skill operation
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)

	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=eg:Filter(s.cfilter,nil,tp,re)
	if #g==0 then return end

	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		s.give_effect(tc,tp)
	end
end

-- Grant effect to the summoned monster
function s.give_effect(c,tp)
	-- Tribute to destroy monsters with same Type or Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function s.desfilter(c,typ,att)
	return c:IsFaceup() and (c:IsType(typ) or c:IsAttribute(att))
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local typ=e:GetHandler():GetType()
	local att=e:GetHandler():GetAttribute()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,typ,att)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetHandler():GetType()
	local att=e:GetHandler():GetAttribute()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,typ,att)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end