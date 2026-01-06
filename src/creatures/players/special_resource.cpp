/**
 * Canary - A free and open-source MMORPG server emulator
 * Copyright (©) 2019-2024 OpenTibiaBR <opentibiabr@outlook.com>
 * Repository: https://github.com/opentibiabr/canary
 * License: https://github.com/opentibiabr/canary/blob/main/LICENSE
 * Contributors: https://github.com/opentibiabr/canary/graphs/contributors
 * Website: https://docs.opentibiabr.com/
 */

#include "creatures/players/special_resource.hpp"
#include <algorithm>

SpecialResource::SpecialResource(
	const std::string &name,
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
	pauseFlags(SpecialResourcePauseState::NONE),
	state(SpecialResourceState::NONE),
	mode(SpecialResourceMode::IDLE) { }

bool SpecialResource::update(uint32_t elapsedMs) {
	float seconds = elapsedMs / 1000.0f;
	float oldValue = value;

	switch (mode) {
		case SpecialResourceMode::REGEN:
			if ((pauseFlags & SpecialResourcePauseState::REGEN) == SpecialResourcePauseState::NONE) {
				value = std::min(value + (regenPerSecond * seconds), static_cast<float>(maxValue));
			}
			break;

		case SpecialResourceMode::DRAIN:
			if ((pauseFlags & SpecialResourcePauseState::DRAIN) == SpecialResourcePauseState::NONE) {
				value = std::max(value - (drainPerSecond * seconds), 0.0f);
			}
			break;

		case SpecialResourceMode::IDLE:
		default:
			break;
	}

	// Safety clamp
	value = std::clamp(value, 0.0f, static_cast<float>(maxValue));

	recalcState();

	// Check if integer value changed (to avoid spamming updates for tiny float changes if client only uses int)
	if (static_cast<uint32_t>(oldValue) != static_cast<uint32_t>(value)) {
		notifyChange();
		return true;
	}
	return false;
}

void SpecialResource::add(uint32_t amount) {
	float oldValue = value;
	value = std::min(value + amount, static_cast<float>(maxValue));
	recalcState();
	if (static_cast<uint32_t>(oldValue) != static_cast<uint32_t>(value)) {
		notifyChange();
	}
}

void SpecialResource::remove(uint32_t amount) {
	float oldValue = value;
	value = std::max(value - amount, 0.0f);
	recalcState();
	if (static_cast<uint32_t>(oldValue) != static_cast<uint32_t>(value)) {
		notifyChange();
	}
}

void SpecialResource::setRegen(uint32_t regen) {
	regenPerSecond = regen;
}

uint32_t SpecialResource::getRegen() const {
	return regenPerSecond;
}

void SpecialResource::setDrain(uint32_t drain) {
	drainPerSecond = drain;
}

uint32_t SpecialResource::getDrain() const {
	return drainPerSecond;
}

void SpecialResource::recalcState() {
	auto currentValue = static_cast<uint32_t>(value);
	if (currentValue >= thresholdCritical) {
		state = SpecialResourceState::CRITICAL;
	} else if (currentValue >= thresholdHigh) {
		state = SpecialResourceState::HIGH;
	} else if (currentValue >= thresholdMedium) {
		state = SpecialResourceState::MEDIUM;
	} else {
		state = SpecialResourceState::NONE;
	}
}

uint32_t SpecialResource::getValue() const {
	return static_cast<uint32_t>(value);
}

uint32_t SpecialResource::getMax() const {
	return maxValue;
}

const std::string &SpecialResource::getName() const {
	return name;
}

SpecialResourceState SpecialResource::getState() const {
	return state;
}

void SpecialResource::setMode(SpecialResourceMode newMode) {
	mode = newMode;
}

SpecialResourceMode SpecialResource::getMode() const {
	return mode;
}

void SpecialResource::setPaused(SpecialResourcePauseState flags) {
	pauseFlags = pauseFlags | flags;
}

void SpecialResource::removePaused(SpecialResourcePauseState flags) {
	pauseFlags = pauseFlags & ~flags;
}

bool SpecialResource::isPaused(SpecialResourcePauseState flag) const {
	return (pauseFlags & flag) != SpecialResourcePauseState::NONE;
}

void SpecialResource::setValue(uint32_t newValue) {
	float oldValue = value;
	value = std::clamp(static_cast<float>(newValue), 0.0f, static_cast<float>(maxValue));
	recalcState();
	if (static_cast<uint32_t>(oldValue) != static_cast<uint32_t>(value)) {
		notifyChange();
	}
}

uint32_t SpecialResource::applyOfflineRegen(uint32_t offlineSeconds, bool isPremium) {
	if (!isPremium) {
		return 0;
	}

	// Formula: min(maxValue * 0.30, offlineSeconds * regenPerSecond * 0.25)
	const float regenAmount = std::min(static_cast<float>(maxValue) * 0.30f, static_cast<float>(offlineSeconds) * static_cast<float>(regenPerSecond) * 0.25f);

	// Limit: threshold MEDIUM or 30% of max
	const float limit = std::min(static_cast<float>(thresholdMedium), static_cast<float>(maxValue) * 0.30f);

	if (value < limit) {
		const float before = value;
		value = std::min(limit, value + regenAmount);
		recalcState();
		if (static_cast<uint32_t>(before) != static_cast<uint32_t>(value)) {
			notifyChange();
		}
		return static_cast<uint32_t>(std::max(0.0f, value - before));
	}
	return 0;
}

void SpecialResource::setChangeCallback(ChangeCallback cb) {
	changeCallback = cb;
}

void SpecialResource::notifyChange() {
	if (changeCallback) {
		changeCallback(this);
	}
}
