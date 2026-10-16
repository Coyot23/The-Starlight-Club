--Battlefield of Hopes and Dreams
local s,id=GetID()
s.counter_place_list={COUNTER_SIGNAL}

--Shared condition: this player holds the "Quick" flag granted by effect 8
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end

--Registers an effect twice: as an Ignition Effect while the player has no flag,
--and as a Quick Effect while the player holds the flag granted by the opponent
function s.regboth(c,e)
	e:SetType(EFFECT_TYPE_IGNITION)
	e:SetCondition(aux.NOT(s.quickcon))
	c:RegisterEffect(e)
	local q=e:Clone()
	q:SetType(EFFECT_TYPE_QUICK_O)
	q:SetCode(EVENT_FREE_CHAIN)
	q:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	q:SetCondition(s.quickcon)
	c:RegisterEffect(q)
end

function s.initial_effect(c)
	--Special Summon procedure (preserved)
	c:AddMustBeSpecialSummoned()
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e1)

	--Set in Field Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.fztg)
	e2:SetOperation(s.fzop)
	c:RegisterEffect(e2)

	--Inflict damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetOperation(s.dmgop)
	s.regboth(c,e3)

	--Gain LP
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetOperation(s.lpop)
	s.regboth(c,e4)

	--Search any card
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	s.regboth(c,e5)

	--Discard any number of cards to place Signal Counters
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,5))
	e6:SetCategory(CATEGORY_COUNTER)
	e6:SetRange(LOCATION_FZONE)
	e6:SetOperation(s.cntop)
	s.regboth(c,e6)

	--Remove Signal Counters
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,6))
	e7:SetRange(LOCATION_FZONE)
	e7:SetOperation(s.remop)
	s.regboth(c,e7)

	--Grant the opponent Quick Effect speed for this turn
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,7))
	e8:SetRange(LOCATION_FZONE)
	e8:SetOperation(s.quickop)
	s.regboth(c,e8)

	--Win the Duel
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,8))
	e9:SetRange(LOCATION_FZONE)
	e9:SetOperation(s.winop)
	s.regboth(c,e9)

	--Lose the Duel
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,9))
	e10:SetRange(LOCATION_FZONE)
	e10:SetOperation(s.loseop)
	s.regboth(c,e10)
end

--Set itself
function s.fztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)<2
	end
end

function s.fzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end

--Declare amount in multiples of 100
local declare_amount_table={}
for i=1,100 do
	declare_amount_table[i]=i*100
end

function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.AnnounceNumber(tp,table.unpack(declare_amount_table))
	Duel.Damage(1-tp,ac,REASON_EFFECT)
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.AnnounceNumber(tp,table.unpack(declare_amount_table))
	Duel.Recover(tp,ac,REASON_EFFECT)
end

--Search any card
function s.thfilter(c)
	return c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Discard any number of cards and place that many Signal Counters
function s.cntop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)
	if #hg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=hg:Select(tp,1,#hg,nil)
	local n=Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	if n>0 and c:IsFaceup() and c:IsLocation(LOCATION_FZONE) then
		c:AddCounter(COUNTER_SIGNAL,n)
	end
end

--Remove a positive number of Signal Counters
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(COUNTER_SIGNAL)
	if ct<=0 then return end
	local num={}
	for i=1,ct do
		num[i]=i
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(num))
	c:RemoveCounter(tp,COUNTER_SIGNAL,ac,REASON_EFFECT)
end

--Give the opponent Quick Effect speed until the end of this turn
function s.quickop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
end

--Win the Duel
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,REASON_EFFECT)
end

--Lose the Duel
function s.loseop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(1-tp,REASON_EFFECT)
end