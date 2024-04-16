--hololive king yagoo
local s,id=GetID()
function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    c:EnableReviveLimit()
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)

    --Special Summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetValue(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

    --Inflict 1000 damage for each of your banished Fire monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) end)
	e2:SetTarget(s.damsettg)
	e2:SetOperation(s.damsetop)
	c:RegisterEffect(e2)

	--Immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end

s.listed_names={id}
function s.spcfilter(c,tp)
	return (c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE)) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and not c:IsCode(id)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0
		and sg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_FIRE)==2
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_DECK,0,c)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_DECK,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,2,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end

function s.damsettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*1000)
end

function s.damsetop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	Duel.Damage(1-tp,#g*1000,REASON_EFFECT)
    --if Duel.Damage(1-tp,#g*1000,REASON_EFFECT)>0
		--todo make another effect on summon
	--end
end

s.listed_series={0x500}

function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x500)
end