-- LocalScript em StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =====================================================
-- ==================== CORES ==========================
-- =====================================================
local COR_FUNDO     = Color3.fromRGB(0, 0, 0)
local COR_BORDA     = Color3.fromRGB(255, 255, 255)
local COR_TEXTO     = Color3.fromRGB(255, 255, 255)
local COR_DESTAQUE  = Color3.fromRGB(255, 255, 255)
local COR_VERDE     = Color3.fromRGB(124, 252, 0)
local COR_VERMELHO  = Color3.fromRGB(255, 70, 70)
local COR_PET       = Color3.fromRGB(255, 215, 0)
local COR_CINZA     = Color3.fromRGB(150, 150, 150)

local TAMANHO_PAINEL     = UDim2.new(0, 520, 0, 420)
local TAMANHO_MINIMIZADO = UDim2.new(0, 520, 0, 55)

-- =====================================================
-- ================== ANTICHEAT ========================
-- =====================================================
local Anticheat = {}
Anticheat.__index = Anticheat

function Anticheat.new()
	local self = setmetatable({}, Anticheat)
	self.ativo = true
	self.ultimoToggle = 0
	self.tentativasSuspeitas = 0
	self.limiteTentativas = 5
	return self
end

function Anticheat:logar(motivo)
	self.tentativasSuspeitas += 1
	warn(("[ANTICHEAT] %s | %d/%d"):format(motivo, self.tentativasSuspeitas, self.limiteTentativas))
	if self.tentativasSuspeitas >= self.limiteTentativas then
		self:punir()
	end
end

function Anticheat:punir()
	self.ativo = false
	warn("[ANTICHEAT] Limite excedido. Fechando painel.")
	if _G.__PainelRoubeOvo and _G.__PainelRoubeOvo.fechar then
		pcall(_G.__PainelRoubeOvo.fechar)
	end
end

function Anticheat:verificarToggle()
	local agora = tick()
	if agora - self.ultimoToggle < 0.15 then
		self:logar("Toggle rápido (autoclicker?)")
	end
	self.ultimoToggle = agora
end

function Anticheat:verificarSpeed(valor)
	if type(valor) ~= "number" or valor < 100 or valor > 1000 or valor % 100 ~= 0 then
		self:logar("Speed inválido: " .. tostring(valor))
		return false
	end
	return true
end

function Anticheat:monitorarPainel(painel)
	task.spawn(function()
		while self.ativo and painel.Parent do
			task.wait(1)
			if painel.AbsolutePosition.X < -1000 or painel.AbsolutePosition.Y < -1000 then
				self:logar("Painel fora da tela")
				painel.Position = UDim2.new(0.5, 0, 0.5, 0)
			end
		end
	end)
end

local anticheat = Anticheat.new()

-- =====================================================
-- ================= GUI PRINCIPAL =====================
-- =====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PainelRoubeOvo"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- ===== BOTÃO REDONDO DE ABRIR =====
local botaoAbrir = Instance.new("TextButton")
botaoAbrir.Name = "BotaoAbrir"
botaoAbrir.Size = UDim2.new(0, 60, 0, 60)
botaoAbrir.Position = UDim2.new(0, 20, 0.5, -30)
botaoAbrir.BackgroundColor3 = COR_FUNDO
botaoAbrir.Text = "🎮"
botaoAbrir.TextColor3 = COR_TEXTO
botaoAbrir.TextScaled = true
botaoAbrir.Font = Enum.Font.GothamBold
botaoAbrir.BorderSizePixel = 0
botaoAbrir.Visible = false
botaoAbrir.Parent = screenGui

Instance.new("UICorner", botaoAbrir).CornerRadius = UDim.new(1, 0)
local sAbrir = Instance.new("UIStroke", botaoAbrir)
sAbrir.Color = COR_BORDA
sAbrir.Thickness = 3

-- ===== PAINEL =====
local painel = Instance.new("Frame")
painel.Name = "Painel"
painel.Size = TAMANHO_PAINEL
painel.Position = UDim2.new(0.5, 0, 0.5, 0)
painel.AnchorPoint = Vector2.new(0.5, 0.5)
painel.BackgroundColor3 = COR_FUNDO
painel.BorderSizePixel = 0
painel.Visible = true
painel.Active = true
painel.Parent = screenGui

Instance.new("UICorner", painel).CornerRadius = UDim.new(0, 14)
local sPainel = Instance.new("UIStroke", painel)
sPainel.Color = COR_BORDA
sPainel.Thickness = 3

-- ===== BOTÃO FECHAR =====
local botaoFechar = Instance.new("TextButton")
botaoFechar.Size = UDim2.new(0, 30, 0, 30)
botaoFechar.Position = UDim2.new(1, -40, 0, 10)
botaoFechar.BackgroundColor3 = COR_FUNDO
botaoFechar.Text = "✕"
botaoFechar.TextColor3 = COR_TEXTO
botaoFechar.TextScaled = true
botaoFechar.Font = Enum.Font.GothamBold
botaoFechar.BorderSizePixel = 0
botaoFechar.Parent = painel

Instance.new("UICorner", botaoFechar).CornerRadius = UDim.new(1, 0)
local sFechar = Instance.new("UIStroke", botaoFechar)
sFechar.Color = COR_BORDA
sFechar.Thickness = 2

-- ===== BOTÃO MINIMIZAR =====
local botaoMinimizar = Instance.new("TextButton")
botaoMinimizar.Size = UDim2.new(0, 30, 0, 30)
botaoMinimizar.Position = UDim2.new(1, -75, 0, 10)
botaoMinimizar.BackgroundColor3 = COR_FUNDO
botaoMinimizar.Text = "—"
botaoMinimizar.TextColor3 = COR_TEXTO
botaoMinimizar.TextScaled = true
botaoMinimizar.Font = Enum.Font.GothamBold
botaoMinimizar.BorderSizePixel = 0
botaoMinimizar.Parent = painel

Instance.new("UICorner", botaoMinimizar).CornerRadius = UDim.new(1, 0)
local sMin = Instance.new("UIStroke", botaoMinimizar)
sMin.Color = COR_BORDA
sMin.Thickness = 2

-- ===== TÍTULO =====
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -120, 0, 40)
titulo.Position = UDim2.new(0, 10, 0, 8)
titulo.BackgroundTransparency = 1
titulo.Text = "🎮 ROUBE UM OVO"
titulo.TextColor3 = COR_TEXTO
titulo.TextScaled = true
titulo.Font = Enum.Font.GothamBold
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = painel

-- =====================================================
-- ==================== ABAS ===========================
-- =====================================================
local abasFrame = Instance.new("Frame")
abasFrame.Size = UDim2.new(1, -20, 0, 45)
abasFrame.Position = UDim2.new(0, 10, 0, 55)
abasFrame.BackgroundTransparency = 1
abasFrame.Parent = painel

local layoutAbas = Instance.new("UIListLayout")
layoutAbas.FillDirection = Enum.FillDirection.Horizontal
layoutAbas.Padding = UDim.new(0, 10)
layoutAbas.Parent = abasFrame

local function criarAba(texto)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 150, 1, 0)
	btn.BackgroundColor3 = COR_FUNDO
	btn.TextColor3 = COR_TEXTO
	btn.Text = texto
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = abasFrame

	local s = Instance.new("UIStroke", btn)
	s.Color = COR_BORDA
	s.Thickness = 2

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	return btn
end

local abaSpeed = criarAba("💨 Speed")
local abaOvos  = criarAba("🥚 Ovos")

-- =====================================================
-- ================ CONTEÚDO: SPEED ====================
-- =====================================================
local conteudoSpeed = Instance.new("Frame")
conteudoSpeed.Size = UDim2.new(1, -20, 1, -115)
conteudoSpeed.Position = UDim2.new(0, 10, 0, 105)
conteudoSpeed.BackgroundTransparency = 1
conteudoSpeed.Visible = true
conteudoSpeed.Parent = painel

-- ===== TOGGLE PRINCIPAL DO SPEED (liga/desliga) =====
local btnToggleSpeed = Instance.new("TextButton")
btnToggleSpeed.Size = UDim2.new(1, 0, 0, 50)
btnToggleSpeed.Position = UDim2.new(0, 0, 0, 0)
btnToggleSpeed.BackgroundColor3 = COR_FUNDO
btnToggleSpeed.TextColor3 = COR_VERMELHO
btnToggleSpeed.Text = "🔴 SPEED: DESLIGADO"
btnToggleSpeed.TextScaled = true
btnToggleSpeed.Font = Enum.Font.GothamBold
btnToggleSpeed.BorderSizePixel = 0
btnToggleSpeed.Parent = conteudoSpeed

local sToggle = Instance.new("UIStroke", btnToggleSpeed)
sToggle.Color = COR_BORDA
sToggle.Thickness = 2

Instance.new("UICorner", btnToggleSpeed).CornerRadius = UDim.new(0, 10)

-- ===== BOTÃO "ESCOLHER VELOCIDADE" =====
local btnEscolherSpeed = Instance.new("TextButton")
btnEscolherSpeed.Size = UDim2.new(1, 0, 0, 40)
btnEscolherSpeed.Position = UDim2.new(0, 0, 0, 58)
btnEscolherSpeed.BackgroundColor3 = COR_FUNDO
btnEscolherSpeed.TextColor3 = COR_TEXTO
btnEscolherSpeed.Text = "🏃 Velocidade atual: 100"
btnEscolherSpeed.TextScaled = true
btnEscolherSpeed.Font = Enum.Font.GothamBold
btnEscolherSpeed.BorderSizePixel = 0
btnEscolherSpeed.Parent = conteudoSpeed

local sEscolher = Instance.new("UIStroke", btnEscolherSpeed)
sEscolher.Color = COR_BORDA
sEscolher.Thickness = 2

Instance.new("UICorner", btnEscolherSpeed).CornerRadius = UDim.new(0, 10)

-- ===== LISTA DE VELOCIDADES (abre/fecha) =====
local listaSpeedFrame = Instance.new("Frame")
listaSpeedFrame.Size = UDim2.new(1, 0, 0, 0)
listaSpeedFrame.Position = UDim2.new(0, 0, 0, 105)
listaSpeedFrame.BackgroundTransparency = 1
listaSpeedFrame.ClipsDescendants = true
listaSpeedFrame.Parent = conteudoSpeed

local gridSpeed = Instance.new("UIGridLayout")
gridSpeed.CellSize = UDim2.new(0, 100, 0, 40)
gridSpeed.CellPadding = UDim2.new(0, 8, 0, 8)
gridSpeed.Parent = listaSpeedFrame

local speedSelecionado = 100
local speedAtivo = false
local listaSpeedAberta = false
local botoesSpeed = {}

local function aplicarSpeed()
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if speedAtivo then
		humanoid.WalkSpeed = speedSelecionado
	else
		humanoid.WalkSpeed = 16
	end
end

for i = 100, 1000, 100 do
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = COR_FUNDO
	btn.TextColor3 = COR_TEXTO
	btn.Text = tostring(i)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = listaSpeedFrame

	local s = Instance.new("UIStroke", btn)
	s.Color = COR_BORDA
	s.Thickness = 2

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	botoesSpeed[i] = btn

	btn.MouseButton1Click:Connect(function()
		if not anticheat:verificarSpeed(i) then return end
		speedSelecionado = i
		for _, b in pairs(botoesSpeed) do
			b.BackgroundColor3 = COR_FUNDO
			b.TextColor3 = COR_TEXTO
		end
		btn.BackgroundColor3 = COR_DESTAQUE
		btn.TextColor3 = COR_FUNDO
		btnEscolherSpeed.Text = "🏃 Velocidade atual: " .. i
		aplicarSpeed()
	end)
end

-- ===== TOGGLE DO SPEED =====
btnToggleSpeed.MouseButton1Click:Connect(function()
	speedAtivo = not speedAtivo
	if speedAtivo then
		btnToggleSpeed.Text = "🟢 SPEED: LIGADO"
		btnToggleSpeed.TextColor3 = COR_VERDE
		sToggle.Color = COR_VERDE
	else
		btnToggleSpeed.Text = "🔴 SPEED: DESLIGADO"
		btnToggleSpeed.TextColor3 = COR_VERMELHO
		sToggle.Color = COR_BORDA
	end
	aplicarSpeed()
end)

-- ===== ABRIR/FECHAR LISTA DE VELOCIDADES =====
btnEscolherSpeed.MouseButton1Click:Connect(function()
	listaSpeedAberta = not listaSpeedAberta
	if listaSpeedAberta then
		listaSpeedFrame:TweenSize(
			UDim2.new(1, 0, 0, 150),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.2,
			true
		)
	else
		listaSpeedFrame:TweenSize(
			UDim2.new(1, 0, 0, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.2,
			true
		)
	end
end)

-- Aplicar speed automaticamente ao respawnar
player.CharacterAdded:Connect(function()
	task.wait(1)
	aplicarSpeed()
end)

-- =====================================================
-- ========== FILTRO DE RARIDADE =======================
-- =====================================================
local filtroFrame = Instance.new("Frame")
filtroFrame.Size = UDim2.new(1, -20, 0, 35)
filtroFrame.Position = UDim2.new(0, 10, 0, 108)
filtroFrame.BackgroundTransparency = 1
filtroFrame.Visible = false
filtroFrame.Parent = painel

local layoutFiltro = Instance.new("UIListLayout")
layoutFiltro.FillDirection = Enum.FillDirection.Horizontal
layoutFiltro.Padding = UDim.new(0, 5)
layoutFiltro.Parent = filtroFrame

local RARIDADES = {
	{texto = "Todas",   cor = Color3.fromRGB(255, 255, 255)},
	{texto = "Common",  cor = Color3.fromRGB(180, 180, 180)},
	{texto = "Rare",    cor = Color3.fromRGB(80, 160, 255)},
	{texto = "Epic",    cor = Color3.fromRGB(180, 100, 255)},
	{texto = "Mythic",  cor = Color3.fromRGB(255, 80, 80)},
	{texto = "Secret",  cor = Color3.fromRGB(255, 200, 0)},
	{texto = "Cosmic",  cor = Color3.fromRGB(100, 255, 200)},
	{texto = "Eternal", cor = Color3.fromRGB(200, 150, 255)},
	{texto = "Divine",  cor = Color3.fromRGB(255, 220, 100)},
}

local raridadeAtiva = "Todas"
local botoesRaridade = {}

for _, dados in ipairs(RARIDADES) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 55, 1, 0)
	btn.BackgroundColor3 = COR_FUNDO
	btn.TextColor3 = dados.cor
	btn.Text = dados.texto
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = filtroFrame

	local s = Instance.new("UIStroke", btn)
	s.Color = dados.cor
	s.Thickness = 1.5

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	botoesRaridade[dados.texto] = btn

	btn.MouseButton1Click:Connect(function()
		raridadeAtiva = dados.texto
		for _, b in pairs(botoesRaridade) do
			b.BackgroundColor3 = COR_FUNDO
		end
		btn.BackgroundColor3 = dados.cor
		btn.TextColor3 = COR_FUNDO
		if _G.__atualizarListaOvos then _G.__atualizarListaOvos() end
	end)
end

-- =====================================================
-- ============ CONTEÚDO: OVOS (DINÂMICO) ==============
-- =====================================================
local PASTA_OVOS = workspace:FindFirstChild("OvosSpawnados")

local conteudoOvos = Instance.new("ScrollingFrame")
conteudoOvos.Size = UDim2.new(1, -20, 1, -160)
conteudoOvos.Position = UDim2.new(0, 10, 0, 150)
conteudoOvos.BackgroundTransparency = 1
conteudoOvos.BorderSizePixel = 0
conteudoOvos.ScrollBarThickness = 5
conteudoOvos.CanvasSize = UDim2.new(0, 0, 0, 0)
conteudoOvos.AutomaticCanvasSize = Enum.AutomaticSize.Y
conteudoOvos.Visible = false
conteudoOvos.Parent = painel

local gridOvos = Instance.new("UIGridLayout")
gridOvos.CellSize = UDim2.new(0, 150, 0, 95)
gridOvos.CellPadding = UDim2.new(0, 8, 0, 8)
gridOvos.Parent = conteudoOvos

local function formatarNumero(n)
	if type(n) ~= "number" then return "?" end
	if n >= 1e9 then return string.format("%.1fB", n / 1e9) end
	if n >= 1e6 then return string.format("%.1fM", n / 1e6) end
	if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
	return tostring(n)
end

local function limparCards()
	for _, filho in ipairs(conteudoOvos:GetChildren()) do
		if filho:IsA("Frame") then filho:Destroy() end
	end
end

local function criarCardOvo(ovo)
	local nome     = ovo:GetAttribute("Nome") or ovo.Name
	local dinheiro = ovo:GetAttribute("Dinheiro") or 0
	local pet      = ovo:GetAttribute("Pet") or "?"
	local raridade = ovo:GetAttribute("Raridade") or "Common"
	local bioma    = ovo:GetAttribute("Bioma") or "?"

	if raridadeAtiva ~= "Todas" and raridade ~= raridadeAtiva then return end

	local card = Instance.new("TextButton")
	card.Name = "Card_" .. ovo.Name
	card.BackgroundColor3 = COR_FUNDO
	card.Text = ""
	card.BorderSizePixel = 0
	card.AutoButtonColor = false
	card.Parent = conteudoOvos

	local s = Instance.new("UIStroke", card)
	s.Color = COR_BORDA
	s.Thickness = 2

	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

	local nomeLabel = Instance.new("TextLabel")
	nomeLabel.Size = UDim2.new(1, -10, 0, 22)
	nomeLabel.Position = UDim2.new(0, 5, 0, 3)
	nomeLabel.BackgroundTransparency = 1
	nomeLabel.Text = "🥚 " .. nome
	nomeLabel.TextColor3 = COR_TEXTO
	nomeLabel.TextScaled = true
	nomeLabel.Font = Enum.Font.GothamBold
	nomeLabel.Parent = card

	local dinheiroLabel = Instance.new("TextLabel")
	dinheiroLabel.Size = UDim2.new(1, -10, 0, 20)
	dinheiroLabel.Position = UDim2.new(0, 5, 0, 28)
	dinheiroLabel.BackgroundTransparency = 1
	dinheiroLabel.Text = "💰 $" .. formatarNumero(dinheiro) .. "/s"
	dinheiroLabel.TextColor3 = COR_VERDE
	dinheiroLabel.TextScaled = true
	dinheiroLabel.Font = Enum.Font.GothamBold
	dinheiroLabel.TextXAlignment = Enum.TextXAlignment.Left
	dinheiroLabel.Parent = card

	local petLabel = Instance.new("TextLabel")
	petLabel.Size = UDim2.new(1, -10, 0, 20)
	petLabel.Position = UDim2.new(0, 5, 0, 50)
	petLabel.BackgroundTransparency = 1
	petLabel.Text = "🐾 " .. pet
	petLabel.TextColor3 = COR_PET
	petLabel.TextScaled = true
	petLabel.Font = Enum.Font.GothamBold
	petLabel.TextXAlignment = Enum.TextXAlignment.Left
	petLabel.Parent = card

	local rarLabel = Instance.new("TextLabel")
	rarLabel.Size = UDim2.new(0, 55, 0, 15)
	rarLabel.Position = UDim2.new(1, -60, 1, -18)
	rarLabel.BackgroundTransparency = 1
	rarLabel.Text = raridade
	rarLabel.TextColor3 = COR_TEXTO
	rarLabel.TextScaled = true
	rarLabel.Font = Enum.Font.GothamBold
	rarLabel.TextXAlignment = Enum.TextXAlignment.Right
	rarLabel.Parent = card

	local bioLabel = Instance.new("TextLabel")
	bioLabel.Size = UDim2.new(0, 55, 0, 12)
	bioLabel.Position = UDim2.new(0, 5, 1, -15)
	bioLabel.BackgroundTransparency = 1
	bioLabel.Text = bioma
	bioLabel.TextColor3 = COR_CINZA
	bioLabel.TextScaled = true
	bioLabel.Font = Enum.Font.Gotham
	bioLabel.TextXAlignment = Enum.TextXAlignment.Left
	bioLabel.Parent = card

	-- CLIQUE: mostra detalhes do ovo
	card.MouseButton1Click:Connect(function()
		warn("=========================================")
		warn("🥚 OVO: " .. nome)
		warn("💰 Valor: $" .. formatarNumero(dinheiro) .. "/s")
		warn("🐾 Pet: " .. pet)
		warn("⭐ Raridade: " .. raridade)
		warn("🌍 Bioma: " .. bioma)
		warn("📦 Objeto no mapa: " .. ovo:GetFullName())
		warn("=========================================")

		-- Feedback visual: destaca o card clicado
		s.Color = COR_PET
		s.Thickness = 3
		task.wait(0.3)
		s.Color = COR_BORDA
		s.Thickness = 2
	end)
end

local function atualizarListaOvos()
	limparCards()
	if not PASTA_OVOS then
		warn("[Painel] Pasta 'OvosSpawnados' não existe no Workspace.")
		return
	end
	for _, ovo in ipairs(PASTA_OVOS:GetChildren()) do
		if ovo:IsA("Model") or ovo:IsA("Part") or ovo:IsA("MeshPart") then
			criarCardOvo(ovo)
		end
	end
end

_G.__atualizarListaOvos = atualizarListaOvos

if PASTA_OVOS then
	PASTA_OVOS.ChildAdded:Connect(atualizarListaOvos)
	PASTA_OVOS.ChildRemoved:Connect(atualizarListaOvos)
	atualizarListaOvos()
else
	warn("[Painel] Pasta 'OvosSpawnados' não encontrada.")
end

-- =====================================================
-- ================== TROCA DE ABAS ====================
-- =====================================================
local function atualizarAbas(ativa)
	abaSpeed.BackgroundColor3 = COR_FUNDO
	abaSpeed.TextColor3 = COR_TEXTO
	abaOvos.BackgroundColor3 = COR_FUNDO
	abaOvos.TextColor3 = COR_TEXTO

	if ativa == "speed" then
		abaSpeed.BackgroundColor3 = COR_DESTAQUE
		abaSpeed.TextColor3 = COR_FUNDO
		conteudoSpeed.Visible = true
		conteudoOvos.Visible = false
		filtroFrame.Visible = false
	else
		abaOvos.BackgroundColor3 = COR_DESTAQUE
		abaOvos.TextColor3 = COR_FUNDO
		conteudoSpeed.Visible = false
		conteudoOvos.Visible = true
		filtroFrame.Visible = true
	end
end

abaSpeed.MouseButton1Click:Connect(function() atualizarAbas("speed") end)
abaOvos.MouseButton1Click:Connect(function() atualizarAbas("ovos") end)
atualizarAbas("speed")

-- =====================================================
-- ============ ARRASTAR PAINEL ========================
-- =====================================================
local arrastando = false
local inicioMouse, inicioPos

titulo.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		arrastando = true
		inicioMouse = input.Position
		inicioPos = painel.Position
	end
end)

titulo.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		arrastando = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if arrastando and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - inicioMouse
		painel.Position = UDim2.new(
			inicioPos.X.Scale, inicioPos.X.Offset + delta.X,
			inicioPos.Y.Scale, inicioPos.Y.Offset + delta.Y
		)
	end
end)

-- =====================================================
-- ============ MINIMIZAR / EXPANDIR ===================
-- ==
