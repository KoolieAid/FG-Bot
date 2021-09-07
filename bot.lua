discordia = require('discordia')
client = discordia.Client()
local clock = discordia.Clock()
commands = require ("commands")
discordia.extensions()
require("util")

local tokenFile = io.open("token", "r")
io.input(tokenFile)
local token = io.read()
io.close(tokenFile)

math.randomseed(os.time())

client:on('ready', function()
	commands.help.update()
	commands.lua.extra.client = client
	print("Bot is now online!")
end)

client:on('voiceChannelJoin', function(member, channel)

	-- Concert Mode
	if commands.concertMode.on then
		if commands.concertMode.channel == channel and member.user.id ~= commands.concertMode.userid then
			member:mute()
		end

		if member.muted and commands.concertMode.channel ~= channel then
			member:unmute()
		end
	end

	-- Lock Channel
	if commands.lockChannel.state then
		-- Kicks strangers
		if not existsInArray(commands.lockChannel.lockedMembers, member) and channel == commands.lockChannel.voiceChannel then
			member:setVoiceChannel()
		-- On the lockdown list, bring member back
		elseif existsInArray(commands.lockChannel.lockedMembers, member) and channel ~= commands.lockChannel.voiceChannel then
			member:setVoiceChannel(commands.lockChannel.voiceChannel)
		end
	end

end)

client:on('voiceChannelLeave', function(member, channel)
-- empty
end)

client:on('voiceUpdate', function(member)
	--temp fix lmao
	if commands.concertMode.on and member.voiceChannel == commands.concertMode.channel and member.user.id ~= commands.concertMode.userid then
		member:mute()
	end

	if commands.lua.extra.protectMe then
		if member.user == client.owner and member.muted then
			member:unmute()
		end
	end

end)

client:on('messageCreate', function(message)

	if not message.guild then return end
	if message.author.bot then return end


	if string.find(message.content, "wanna die") then message:reply("same") end

	if Split(message.content, " ")[1] == "!p" then
		message:reply("ulol tangina mo anong play play ka diyan")
	end

	local status, error;

	local function exec(cmd, message)
		commands[cmd].exec(message, message.content)
	end

	local args = Split(message.content, " ")

	if not string.find(args[1], commands.prefix.currentPrefix) then return end
	local cmd
    cmd = string.sub(args[1], #commands.prefix.currentPrefix + 1)

	if commands[cmd] == nil then return end

	status, error = pcall(commands[cmd].exec, message, message.content)
	if status == false then message:reply("```"..error.."```") end

end)

client:run("Bot "..token)