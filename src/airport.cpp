/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

/** @file airport.cpp Functions related to airports. */

#include "stdafx.h"
#include "station_base.h"

#include "table/strings.h"
#include "table/airport_movement.h"
#include "table/airporttile_ids.h"

#include "safeguards.h"


/**
 * Define a generic airport.
 * @param name Suffix of the names of the airport data.
 * @param terminals The terminals.
 * @param num_helipads Number of heli pads.
 * @param flags Information about the class of FTA.
 * @param delta_z Height of the airport above the land.
 */
#define AIRPORT_GENERIC(name, terminals, num_helipads, flags, delta_z) \
	static const AirportFTAClass _airportfta_ ## name(_airport_moving_data_ ## name, terminals, \
			num_helipads, _airport_entries_ ## name, flags, _airport_fta_ ## name, delta_z);

/**
 * Define an airport.
 * @param name Suffix of the names of the airport data.
 * @param num_helipads Number of heli pads.
 * @param short_strip Airport has a short land/take-off strip.
 */
#define AIRPORT(name, num_helipads, short_strip) \
	AIRPORT_GENERIC(name, _airport_terminal_ ## name, num_helipads, AirportFTAClass::Flags({AirportFTAClass::Flag::Airplanes, AirportFTAClass::Flag::Helicopters}) | (short_strip ? AirportFTAClass::Flags{AirportFTAClass::Flag::ShortStrip} : AirportFTAClass::Flags{}), 0)

/**
 * Define a heliport.
 * @param name Suffix of the names of the helipad data.
 * @param num_helipads Number of heli pads.
 * @param delta_z Height of the airport above the land.
 */
#define HELIPORT(name, num_helipads, delta_z) \
	AIRPORT_GENERIC(name, nullptr, num_helipads, AirportFTAClass::Flag::Helicopters, delta_z)

AIRPORT(country, 0, true)
AIRPORT(city, 0, false)
HELIPORT(heliport, 1, 60)
AIRPORT(metropolitan, 0, false)
AIRPORT(international, 2, false)
AIRPORT(commuter, 2, true)
HELIPORT(helidepot, 1, 0)
AIRPORT(intercontinental, 2, false)
HELIPORT(helistation, 3, 0)
HELIPORT(oilrig, 1, 54)
AIRPORT_GENERIC(dummy, nullptr, 0, AirportFTAClass::Flags({AirportFTAClass::Flag::Airplanes, AirportFTAClass::Flag::Helicopters}), 0)

#undef HELIPORT
#undef AIRPORT
#undef AIRPORT_GENERIC

#include "table/airport_defaults.h"


static uint16_t AirportGetNofElements(const AirportFTAbuildup *apFA);
static void AirportBuildAutomata(std::vector<AirportFTA> &layout, uint8_t nofelements, const AirportFTAbuildup *apFA);


/**
 * Rotate the airport moving data to another rotation.
 * @param orig Pointer to the moving data to rotate.
 * @param rotation How to rotate the moving data.
 * @param num_tiles_x Number of tiles in x direction.
 * @param num_tiles_y Number of tiles in y direction.
 * @return The rotated moving data.
 */
AirportMovingData RotateAirportMovingData(const AirportMovingData *orig, Direction rotation, uint num_tiles_x, uint num_tiles_y)
{
	AirportMovingData amd;
	amd.flags = orig->flags;
	amd.direction = ChangeDir(orig->direction, (DirDiff)rotation);
	switch (rotation) {
		case DIR_N:
			amd.x = orig->x;
			amd.y = orig->y;
			break;

		case DIR_E:
			amd.x = orig->y;
			amd.y = num_tiles_y * TILE_SIZE - orig->x - 1;
			break;

		case DIR_S:
			amd.x = num_tiles_x * TILE_SIZE - orig->x - 1;
			amd.y = num_tiles_y * TILE_SIZE - orig->y - 1;
			break;

		case DIR_W:
			amd.x = num_tiles_x * TILE_SIZE - orig->y - 1;
			amd.y = orig->x;
			break;

		default: NOT_REACHED();
	}
	return amd;
}

AirportFTAClass::AirportFTAClass(
	const AirportMovingData *moving_data_,
	const uint8_t *terminals_,
	const uint8_t num_helipads_,
	const uint8_t *entry_points_,
	Flags flags_,
	const AirportFTAbuildup *apFA,
	uint8_t delta_z_
) :
	moving_data(moving_data_),
	terminals(terminals_),
	num_helipads(num_helipads_),
	flags(flags_),
	nofelements(AirportGetNofElements(apFA)),
	entry_points(entry_points_),
	delta_z(delta_z_)
{
	/* Build the state machine itself */
	AirportBuildAutomata(this->layout, this->nofelements, apFA);
}

/**
 * Get the number of elements of a source Airport state automata
 * Since it is actually just a big array of AirportFTA types, we only
 * know one element from the other by differing 'position' identifiers
 */
static uint16_t AirportGetNofElements(const AirportFTAbuildup *apFA)
{
	uint16_t nofelements = 0;
	int temp = apFA[0].position;

	for (uint i = 0; i < MAX_ELEMENTS; i++) {
		if (temp != apFA[i].position) {
			nofelements++;
			temp = apFA[i].position;
		}
		if (apFA[i].position == MAX_ELEMENTS) break;
	}
	return nofelements;
}

AirportFTA::AirportFTA(const AirportFTAbuildup &buildup) : blocks(buildup.blocks), position(buildup.position), next_position(buildup.next), heading(buildup.heading)
{
}

/**
 * Construct the FTA given a description.
 * @param layout The vector to write the automata to.
 * @param nofelements The number of elements in the FTA.
 * @param apFA The description of the FTA.
 */
static void AirportBuildAutomata(std::vector<AirportFTA> &layout, uint8_t nofelements, const AirportFTAbuildup *apFA)
{
	uint16_t internalcounter = 0;

	layout.reserve(nofelements);
	for (uint i = 0; i < nofelements; i++) {
		AirportFTA *current = &layout.emplace_back(apFA[internalcounter]);

		/* outgoing nodes from the same position, create linked list */
		while (current->position == apFA[internalcounter + 1].position) {
			current->next = std::make_unique<AirportFTA>(apFA[internalcounter + 1]);
			current = current->next.get();
			internalcounter++;
		}
		internalcounter++;
	}
}

/**
 * Get the finite state machine of an airport type.
 * @param airport_type %Airport type to query FTA from. @see AirportTypes
 * @return Finite state machine of the airport.
 */
const AirportFTAClass *GetAirport(const uint8_t airport_type)
{
	if (airport_type == AT_DUMMY) return &_airportfta_dummy;
	return AirportSpec::Get(airport_type)->fsm;
}

/**
 * Get the vehicle position when an aircraft is build at the given tile
 * @param hangar_tile The tile on which the vehicle is build
 * @return The position (index in airport node array) where the aircraft ends up
 */
uint8_t GetVehiclePosOnBuild(TileIndex hangar_tile)
{
	const Station *st = Station::GetByTile(hangar_tile);
	const AirportFTAClass *apc = st->airport.GetFTA();
	/* When we click on hangar we know the tile it is on. By that we know
	 * its position in the array of depots the airport has.....we can search
	 * layout for #th position of depot. Since layout must start with a listing
	 * of all depots, it is simple */
	for (uint i = 0;; i++) {
		if (st->airport.GetHangarTile(i) == hangar_tile) {
			assert(apc->layout[i].heading == HANGAR);
			return apc->layout[i].position;
		}
	}
	NOT_REACHED();
}
