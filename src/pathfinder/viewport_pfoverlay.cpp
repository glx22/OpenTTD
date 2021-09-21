/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

#include "../stdafx.h"
#include "viewport_pfoverlay.h"
#include "../zoom_func.h"
#include "../track_func.h"
#include "../debug.h"
#include <vector>

ViewportPfOverlay _viewport_pf_overlay; ///< Global shared PF overlay for viewports


static Point GetTileEdgeMiddle(const Viewport *vp, TileIndex t, DiagDirection dd)
{
	int x = TileX(t) * TILE_SIZE;
	int y = TileY(t) * TILE_SIZE;
	switch (dd) {
		case DIAGDIR_NW: y += TILE_SIZE / 2; break;
		case DIAGDIR_NE: x += TILE_SIZE / 2; break;
		case DIAGDIR_SW: y += TILE_SIZE / 2; x += TILE_SIZE; break;
		case DIAGDIR_SE: x += TILE_SIZE / 2; y += TILE_SIZE; break;
	}

	int z = GetSlopePixelZ(Clamp(x, 0, MapSizeX() * TILE_SIZE - 1), Clamp(y, 0, MapSizeY() * TILE_SIZE - 1));
	Point p = RemapCoords(x, y, z);

	p.x = UnScaleByZoom(p.x - vp->virtual_left, vp->zoom) + vp->left;
	p.y = UnScaleByZoom(p.y - vp->virtual_top, vp->zoom) + vp->top;
	return p;
}

static DiagDirection TrackdirToEntrydir(Trackdir td)
{
	return TrackdirToExitdir(ReverseTrackdir(td));
}


void ViewportPfOverlay::Draw(const DrawPixelInfo *dpi, const Viewport *vp)
{
	if (this->costs.empty()) return;

	std::vector<std::pair<Point, int>> numbers;

	for (auto tdc : this->costs) {
		TileIndex tile = tdc.first.first;
		Trackdir td = tdc.first.second;
		int cost = tdc.second;

		Point pta = GetTileEdgeMiddle(vp, tile, TrackdirToEntrydir(td));
		Point ptb = GetTileEdgeMiddle(vp, tile, TrackdirToExitdir(td));
		Point ptm = { (pta.x + ptb.x) / 2, (pta.y + ptb.y) / 2 };

		if ((pta.x < ptb.x) != (pta.y < ptb.y)) ptm.y += FONT_HEIGHT_SMALL;
		//numbers.emplace_back(std::make_pair(ptm, cost));

		const int colour = _colour_gradient[COLOUR_PINK][cost * 8 / this->maxcost];
		GfxDrawLine(pta.x, pta.y, ptb.x, ptb.y, colour, 5, 0);
	}

	for (auto nd : numbers) {
		Point pt = nd.first;
		std::string s = std::to_string(nd.second);
		DrawString(pt.x - 100, pt.x + 100, pt.y, s, TC_WHITE, SA_CENTER, false, FS_SMALL);
	}
}

void ViewportPfOverlay::Clear()
{
	if (!this->enable_tracking) return;
	this->costs.clear();
	this->maxcost = 1;
}

void ViewportPfOverlay::AddTile(TileIndex tile, Trackdir td, int cost)
{
	if (!this->enable_tracking) return;
	this->costs[std::make_pair(tile, td)] = cost;
	if (cost > this->maxcost) this->maxcost = cost;
}

void ViewportPfOverlay::SetTracking(bool enabled)
{
	this->enable_tracking = enabled;
}
