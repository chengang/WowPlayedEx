PlayedExDB = {}
local tmpDB = {}
local logintime = ""

local function now()
	return string.sub(date() .. time(), 1, 17)
end

local function timestamp(datetime)
	local m,d,y,h,i,s = string.match(datetime, "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)")

	local monthdays = 30
	if m == 1 then
		monthdays = 0
	elseif m == 3 then
		monthdays = 28
		if y == 12 then
			monthdays = 29
		end
	elseif m == 2 or m == 4 or m == 6 or m == 8 or m == 9 or m == 11 then
		monthdays = 31
	end

	local ts = (y * 365 * 24 * 60 * 60 + m * monthdays * 24 * 60 * 60 + d * 24 * 60 * 60 + h * 60 * 60 + i * 60 + s) / 60
	return ts
end

local function datediff(datetime1, datetime2)
	local ts1 = timestamp(datetime1)
	local ts2 = timestamp(datetime2)
	local dd = ts2 - ts1
	return dd
end

local function eventHandler()
	--print(event .. "PlayedEx Loaded")
	local t = now()
	print(t .. "\n")
	if event == "PLAYER_LOGIN" then
		DEFAULT_CHAT_FRAME:AddMessage("PlayedEx已经载入，它将帮助您记录此帐号的登入登出时间，并计算点卡消耗。", 1.0, 1.0, 0.0, 53, 9)
		print("请使用/pe或/playedex命令显示统计结果。")
		print("请使用/pec或/playedexclear命令重置统计数据。")
		tmpDB["s"] = t
		logintime = t
	elseif event == "PLAYER_LOGOUT" then
		tmpDB["e"] = t
		PlayedExDB[#PlayedExDB+1] = tmpDB
	end
end

local function cli_show()
	DEFAULT_CHAT_FRAME:AddMessage("您的登入登出详细情况如下：", 1.0, 1.0, 0.0, 53, 9)
	local nowlogtime = logintime
	local nowtime = now()
	local nowcost = datediff(nowlogtime, nowtime)

	local passcost = 0
	for i=1,#PlayedExDB do
		local daytime = PlayedExDB[i]
		DEFAULT_CHAT_FRAME:AddMessage("登入: " .. daytime["s"] .. "      " .. "登出: " .. daytime["e"], 0.0, 1.0, 1.0, 53, 9)
		passcost = passcost + datediff(daytime["s"], daytime["e"])
	end

	local totalcost = passcost + nowcost
	SendChatMessage("本帐号已经使用点卡 " .. math.ceil(totalcost) .. " 分钟，其中本次登入使用 " .. math.ceil(nowcost) .. " 分钟（PlayedEx插件统计）。", "yell")
end

local function cli_clear()
	PlayedExDB = {}
	DEFAULT_CHAT_FRAME:AddMessage("PlayedEx统计的数据已经重置，下次登陆将重新计算。", 1.0, 1.0, 0.0, 53, 9)
end

local frame = CreateFrame("FRAME", "PlayedExFrame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", eventHandler)

SLASH_PLAYEDEX1 = "/playedex"
SLASH_PLAYEDEX2 = "/pe"
SlashCmdList["PLAYEDEX"] = cli_show
SLASH_PLAYEDEXCLEAR1 = "/playedexclear"
SLASH_PLAYEDEXCLEAR2 = "/pec"
SlashCmdList["PLAYEDEXCLEAR"] = cli_clear
