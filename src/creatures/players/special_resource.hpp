/**
 * Canary - A free and open-source MMORPG server emulator
 * Copyright (©) 2019-2024 OpenTibiaBR <opentibiabr@outlook.com>
 * Repository: https://github.com/opentibiabr/canary
 * License: https://github.com/opentibiabr/canary/blob/main/LICENSE
 * Contributors: https://github.com/opentibiabr/canary/graphs/contributors
 * Website: https://docs.opentibiabr.com/
 */

#pragma once

#include <string>
#include <cstdint>
#include <functional>

enum class SpecialResourceState : uint8_t {
	NONE = 0, // Normal, sem penalidades
	MEDIUM = 1, // Penalidades leves
	HIGH = 2, // Penalidades severas
	CRITICAL = 3 // Bloqueio / colapso
};

enum class SpecialResourceMode : uint8_t {
	IDLE = 0,
	REGEN = 1,
	DRAIN = 2
};

enum class SpecialResourcePauseState : uint8_t {
	NONE = 0,
	REGEN = 1 << 0,
	DRAIN = 1 << 1,
	ALL = REGEN | DRAIN
};

inline SpecialResourcePauseState operator|(SpecialResourcePauseState lhs, SpecialResourcePauseState rhs) {
	return static_cast<SpecialResourcePauseState>(
		static_cast<uint8_t>(lhs) | static_cast<uint8_t>(rhs)
	);
}

inline SpecialResourcePauseState operator&(SpecialResourcePauseState lhs, SpecialResourcePauseState rhs) {
	return static_cast<SpecialResourcePauseState>(
		static_cast<uint8_t>(lhs) & static_cast<uint8_t>(rhs)
	);
}

inline SpecialResourcePauseState operator~(SpecialResourcePauseState flag) {
	return static_cast<SpecialResourcePauseState>(~static_cast<uint8_t>(flag));
}

class SpecialResource {
public:
	SpecialResource(
		const std::string &name,
		uint32_t maxValue,
		uint32_t regenPerSecond,
		uint32_t drainPerSecond,
		uint32_t thresholdMedium,
		uint32_t thresholdHigh,
		uint32_t thresholdCritical
	);

	// Atualizado pelo loop do servidor
	bool update(uint32_t elapsedMs);

	// Modificadores diretos
	void add(uint32_t amount);
	void remove(uint32_t amount);

	// Configuração dinâmica
	void setRegen(uint32_t regen);
	uint32_t getRegen() const;
	void setDrain(uint32_t drain);
	uint32_t getDrain() const;

	// Getters
	uint32_t getValue() const;
	uint32_t getMax() const;
	const std::string &getName() const;
	SpecialResourceState getState() const;

	// Controle
	void setMode(SpecialResourceMode newMode);
	SpecialResourceMode getMode() const;

	void setPaused(SpecialResourcePauseState flags);
	void removePaused(SpecialResourcePauseState flags);
	bool isPaused(SpecialResourcePauseState flag) const;

	// Persistence & Regen
	void setValue(uint32_t newValue);
	uint32_t applyOfflineRegen(uint32_t offlineSeconds, bool isPremium);

	using ChangeCallback = std::function<void(SpecialResource*)>;
	void setChangeCallback(ChangeCallback cb);

private:
	void recalcState();
	void notifyChange();

	std::string name;
	float value;
	uint32_t maxValue;
	uint32_t regenPerSecond;
	uint32_t drainPerSecond;
	uint32_t thresholdMedium;
	uint32_t thresholdHigh;
	uint32_t thresholdCritical;
	SpecialResourcePauseState pauseFlags;
	SpecialResourceState state;
	SpecialResourceMode mode;
	ChangeCallback changeCallback;
};
