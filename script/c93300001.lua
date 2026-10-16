-- The Gift of Color Visioin
local s,id=GetID()
function s.initial_effect(c)
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop,EVENT_PREDRAW)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
		and Duel.IsTurnPlayer(tp)
		and Duel.GetDrawCount(tp)==1
		and (Duel.IsDuelType(DUEL_1ST_TURN_DRAW) or Duel.GetTurnCount()>1)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if aux.CheckSkillNegation(e,tp) then return end
	-- THIS is how you cancel the draw in EDOPro
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
	-- custom draw replacement logic
	Duel.ConfirmDecktop(tp,1)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if not tc then return end
	Duel.SendtoDeck(tc,nil,-2,REASON_EFFECT+REASON_RULE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	local token=Duel.CreateToken(tp,ac)
	Duel.SendtoHand(token,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,token)
end
