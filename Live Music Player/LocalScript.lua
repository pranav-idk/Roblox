local songs = {
	{ Name = "Raining Tacos", Id = "rbxassetid://158666489" },
	{ Name = "Exit the Earth's Atmosphere", Id = "rbxassetid://1571702965" },
	{ Name = "Bad Apple (Bad Psy!! Remix)", Id = "rbxassetid://4565796080" },
}

local icons = {
	Pause = "rbxassetid://6813750293",
	Play = "rbxassetid://6813750207",
	Mute = "rbxassetid://6813750387",
	Volume = "rbxassetid://6813750121",
}

local ORIGINAL_VOLUME = 0.35

local Player = {
	CurrentIndex = 1,
	Songs = { table.unpack(songs) },
	Paused = false,
	Volume = ORIGINAL_VOLUME,
	PlayNext = Instance.new("BindableEvent"),
}

local function changeIndex(i)
	i = tonumber(i) or 1
	local ni = Player.CurrentIndex + i
	local sl = #Player.Songs
	
	if ni > sl then
		ni -= sl
	elseif ni < 1 then
		ni += sl
	end
	
	Player.CurrentIndex = ni
end

local function fireNext()
	Player.PlayNext:Fire()
end

local song = script:FindFirstChild("Sound") or script:WaitForChild("Sound")

local gui = script.Parent
local container = gui.Frame.Container
local buttons = container.Buttons

song.Ended:Connect(fireNext)
song.Stopped:Connect(fireNext)

buttons.Mute.MouseButton1Click:Connect(function()
	Player.Volume = Player.Volume == 0 and ORIGINAL_VOLUME or 0
	buttons.Mute.Icon.Image = Player.Volume == 0 and icons.Volume or icons.Mute
end)

buttons.Pause.MouseButton1Click:Connect(function()
	Player.Paused = not Player.Paused
	buttons.Pause.Icon.Image = Player.Paused and icons.Play or icons.Pause
end)

buttons.Previous.MouseButton1Click:Connect(function()
	Player.CurrentIndex -= 2
	song:Stop()
end)

buttons.Next.MouseButton1Click:Connect(function()
	song:Stop()
end)

game:GetService("RunService").Heartbeat:Connect(function()
	container.Bar.Indicator.Size = UDim2.new(
		math.clamp(song.TimePosition / song.TimeLength, 0, 1),
		0, 1, 0
	)
	container.Duration.Text = string.format("%i:%02i - %i:%02i",
		math.floor(song.TimePosition / 60), song.TimePosition % 60,
		math.floor(song.TimeLength / 60), song.TimeLength % 60
	)

	song.Playing = not Player.Paused
	song.Volume = Player.Volume
end)

while true do
	local currentSong = Player.Songs[Player.CurrentIndex]
	song.SoundId = currentSong.Id
	container.SongName.Text = currentSong.Name

	song:Play()
	Player.PlayNext.Event:Wait()
	
	changeIndex(1)
end
