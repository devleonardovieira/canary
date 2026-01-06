Sistema de Recurso Especial (Special Resource System)

Este documento descreve a implementação de um sistema genérico de recursos especiais para clãs/vocações, como:

Strain Ocular (Uchiha)

Byakugan Pressure (Hyuuga)

Vital Flow (Senju)

Seal Instability (Uzumaki)

O sistema é agnóstico ao clã, altamente performático e extensível.

🎯 Objetivo do Sistema

Criar um recurso oscilante (não treinável) que:

Possui valor mínimo e máximo

Regenera ou drena com o tempo

Possui estados (faixas)

Ativa penalidades ou buffs

Força gestão estratégica (risco x recompensa)

Pode ser exibido na UI (barra)

🧠 Princípios de Arquitetura
Camada	Responsabilidade
C++	Core, performance, sincronização, estado
Lua	Regras de gameplay, efeitos, jutsus
XML	Configuração por vocação
UI	Visualização (barra / alertas)

📌 Regra de ouro:

C++ nunca decide gameplay. Lua nunca controla estado crítico.

🧱 Conceito Central: Special Resource

Um Special Resource é um medidor com:

Valor atual

Valor máximo

Taxa de regeneração

Taxa de drenagem

Limiares de estado (thresholds)

🧩 Estados do Recurso
enum class SpecialResourceState : uint8_t {
    NONE = 0,      // Normal, sem penalidades
    MEDIUM = 1,    // Penalidades leves
    HIGH = 2,      // Penalidades severas
    CRITICAL = 3   // Bloqueio / colapso
};


📌 O jogador sempre pertence a apenas um estado por vez.

🧱 Classe Core: SpecialResource
📄 SpecialResource.hpp
#pragma once

#include <string>
#include <cstdint>

enum class SpecialResourceState : uint8_t;

class SpecialResource {
public:
    // Cria o recurso especial
    SpecialResource(
        const std::string& name,
        uint32_t maxValue,
        uint32_t regenPerSecond,
        uint32_t drainPerSecond,
        uint32_t thresholdMedium,
        uint32_t thresholdHigh,
        uint32_t thresholdCritical
    );

    // Atualizado pelo loop do servidor
    void update(uint32_t elapsedMs);

    // Modificadores diretos
    void add(uint32_t amount);
    void remove(uint32_t amount);

    // Getters
    uint32_t getValue() const;
    uint32_t getMax() const;
    const std::string& getName() const;
    SpecialResourceState getState() const;

    // Controle
    void setPaused(bool value);
    bool isPaused() const;

private:
    void recalcState();

private:
    std::string name;

    uint32_t value;
    uint32_t maxValue;

    uint32_t regenPerSecond;
    uint32_t drainPerSecond;

    uint32_t thresholdMedium;
    uint32_t thresholdHigh;
    uint32_t thresholdCritical;

    bool paused;
    SpecialResourceState state;
};

📄 SpecialResource.cpp
#include "SpecialResource.h"
#include <algorithm>

SpecialResource::SpecialResource(
    const std::string& name,
    uint32_t maxValue,
    uint32_t regenPerSecond,
    uint32_t drainPerSecond,
    uint32_t thresholdMedium,
    uint32_t thresholdHigh,
    uint32_t thresholdCritical
) :
    name(name),
    value(0),
    maxValue(maxValue),
    regenPerSecond(regenPerSecond),
    drainPerSecond(drainPerSecond),
    thresholdMedium(thresholdMedium),
    thresholdHigh(thresholdHigh),
    thresholdCritical(thresholdCritical),
    paused(false),
    state(SpecialResourceState::NONE)
{}

void SpecialResource::update(uint32_t elapsedMs) {
    if (paused) {
        return;
    }

    // Regeneração passiva
    uint32_t regen = (regenPerSecond * elapsedMs) / 1000;
    value = std::min(value + regen, maxValue);

    recalcState();
}

void SpecialResource::add(uint32_t amount) {
    value = std::min(value + amount, maxValue);
    recalcState();
}

void SpecialResource::remove(uint32_t amount) {
    value = (amount > value) ? 0 : value - amount;
    recalcState();
}

void SpecialResource::recalcState() {
    if (value >= thresholdCritical) {
        state = SpecialResourceState::CRITICAL;
    } else if (value >= thresholdHigh) {
        state = SpecialResourceState::HIGH;
    } else if (value >= thresholdMedium) {
        state = SpecialResourceState::MEDIUM;
    } else {
        state = SpecialResourceState::NONE;
    }
}

👤 Integração com Player
📄 Player.h
#include "SpecialResource.h"
#include <memory>

class Player {
public:
    void createSpecialResource(std::unique_ptr<SpecialResource> resource);
    SpecialResource* getSpecialResource();

private:
    std::unique_ptr<SpecialResource> specialResource;
};

📄 Player.cpp
void Player::createSpecialResource(std::unique_ptr<SpecialResource> resource) {
    specialResource = std::move(resource);
}

SpecialResource* Player::getSpecialResource() {
    return specialResource.get();
}

⏱️ Atualização Global (Game Loop)

No loop principal do servidor:

for (Player* player : game.getPlayers()) {
    if (auto resource = player->getSpecialResource()) {
        resource->update(elapsedMs);
    }
}

🧾 Configuração por Vocação (XML)
<vocation id="10" name="Uchiha">
    <specialresource
        name="Strain Ocular"
        max="100"
        regen="3"
        drain="2"
        medium="50"
        high="75"
        critical="90"
    />
</vocation>


📌 O parser cria a instância de SpecialResource ao logar.

🧠 Lua — Consumo do Sistema
Obter estado do recurso
local resource = player:getSpecialResource()

if resource:getState() == RESOURCE_HIGH then
    player:sendTextMessage(MESSAGE_STATUS_WARNING, "Seus olhos estão sobrecarregados.")
end

Jutsu que aumenta strain
player:addSpecialResource(15)

Penalidade baseada em estado
if state == RESOURCE_CRITICAL then
    player:setMovementBlocked(true)
end


⚖️ Regras de Balanceamento

Apenas um estado ativo

Penalidades não acumulam

Estados são reversíveis

Recuperação exige tempo real

Não depende de treino