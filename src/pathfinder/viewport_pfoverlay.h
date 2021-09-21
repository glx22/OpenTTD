/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

 /** @file viewport_pfoverlay.h Overlay for viewports to debug pathfinding. */

#ifndef VIEWPORT_PFOVERLAY_H
#define VIEWPORT_PFOVERLAY_H

#include "../landscape.h"
#include "../viewport_type.h"
#include "../gfx_type.h"

#include <map>

class ViewportPfOverlay {
	std::map<std::pair<TileIndex, Trackdir>, int> costs;
	int maxcost = 1;
	bool enable_tracking = false;

public:
	void Draw(const DrawPixelInfo *dpi, const Viewport *vp);
	void Clear();
	void AddTile(TileIndex tile, Trackdir td, int cost);
	void SetTracking(bool enabled);
};

extern ViewportPfOverlay _viewport_pf_overlay;

#endif /* VIEWPORT_PFOVERLAY_H */
