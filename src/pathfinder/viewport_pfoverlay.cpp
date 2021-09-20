/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

#include "../stdafx.h"
#include "viewport_pfoverlay.h"
#include "../zoom_func.h"
#include "../debug.h"

ViewportPfOverlay _viewport_pf_overlay; ///< Global shared PF overlay for viewports


Point GetTileMiddle(const Viewport *vp, TileIndex t)
{
	int x = TileX(t) * TILE_SIZE + TILE_SIZE / 2;
	int y = TileY(t) * TILE_SIZE + TILE_SIZE / 2;
	int z = GetSlopePixelZ(Clamp(x, 0, MapSizeX() * TILE_SIZE - 1), Clamp(y, 0, MapSizeY() * TILE_SIZE - 1));

	Point p = RemapCoords(x, y, z);
	p.x = UnScaleByZoom(p.x, vp->zoom);
	p.y = UnScaleByZoom(p.y, vp->zoom);
	return p;
}


void ViewportPfOverlay::Draw(const DrawPixelInfo *dpi, const Viewport *vp)
{
	if (this->arrows.empty()) return;
	int minx = INT_MAX, miny = INT_MAX;
	int maxx = INT_MIN, maxy = INT_MIN;
	for (auto tp : this->arrows) {
		int cost = this->costs[tp.second];
		Point pta = GetTileMiddle(vp, tp.second);
		Point ptb = GetTileMiddle(vp, tp.first);
		const int colour = _colour_gradient[COLOUR_PINK][cost * 8 / this->maxcost];
		GfxDrawLine(pta.x, pta.y, ptb.x, ptb.y, colour, 5, 0);
	}
	for (auto tc : this->costs) {
		Point pt = GetTileMiddle(vp, tc.first);
		std::string s = std::to_string(tc.second);
		DrawString(pt.x - 100, pt.x + 100, pt.y, s, TC_WHITE, SA_CENTER, false, FS_SMALL);
	}
	for (auto tc : this->visit_count) {
		Point pt = GetTileMiddle(vp, tc.first);
		std::string s = std::to_string(tc.second);
		DrawString(pt.x - 100, pt.x + 100, pt.y + FONT_HEIGHT_SMALL, s, TC_YELLOW, SA_CENTER, false, FS_SMALL);
	}
}

void ViewportPfOverlay::Clear()
{
	if (!this->enable_tracking) return;
	this->arrows.clear();
	this->costs.clear();
	this->visit_count.clear();
	this->maxcost = 1;
}

void ViewportPfOverlay::AddTile(TileIndex from, TileIndex to, int cost)
{
	if (!this->enable_tracking) return;
	this->arrows[to] = from;
	if (this->costs.count(to) == 0) {
		this->costs[to] = cost;
	} else {
		this->costs[to] = std::min(this->costs[to], cost);
	}
	this->visit_count[to] += 1;
	if (cost > this->maxcost) this->maxcost = cost;
}

void ViewportPfOverlay::SetTracking(bool enabled)
{
	this->enable_tracking = enabled;
}
