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
		case DIAGDIR_NW: x += TILE_SIZE / 2; break;
		case DIAGDIR_NE: y += TILE_SIZE / 2; break;
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

static std::pair<Point, Point> GetArrowPointEdge(Point pointy, Point shaft, ZoomLevel zoom)
{
	/* Make vector from pointy end to shaft handle end,
	 * rotate it by 20 degrees CCW, and finally shorten it to 24. */
	const int cos_shr8 = 243; // (int)round(cos(-M_PI/9)*256)
	const int sin_shr8 = -79; // (int)round(sin(-M_PI/9)*256)
	const int target_len = UnScaleByZoom(32, zoom);
	Point rev_vec{ shaft.x - pointy.x, shaft.y - pointy.y };
	Point rot_vec{ rev_vec.x * cos_shr8 / 256 - rev_vec.y * sin_shr8 / 256, rev_vec.x * sin_shr8 / 256 + rev_vec.y * cos_shr8 / 256 };
	int rot_vec_len = IntSqrt(rot_vec.x * rot_vec.x + rot_vec.y * rot_vec.y);
	return std::make_pair(
		/* Arrow edge */
		Point{ pointy.x + rot_vec.x * target_len / rot_vec_len, pointy.y + rot_vec.y * target_len / rot_vec_len },
		/* Back edge */
		Point{ pointy.x + rev_vec.x * target_len / rot_vec_len, pointy.y + rev_vec.y * target_len / rot_vec_len }
	);
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

		/* adjust arrows to not overlap in both directions */
		if (pta.x == ptb.x) {
			/* vertical */
			if (pta.y < ptb.y) { // downwards?
				pta.x -= 1; ptb.x -= 1;
			} else {
				pta.x += 1; ptb.x += 1;
			}
		} else if (pta.y == ptb.y) {
			/* horizontal */
			if (pta.x < ptb.x) { // rightwards?
				pta.y += 1; ptb.y += 1;
			} else {
				pta.y -= 1; ptb.y -= 1;
			}
		} else {
			/* diagonal */
			const int dir1 = (int)(pta.y > ptb.y) * 2 - 1;
			const int dir2 = (int)(pta.x < ptb.x) * 2 - 1;
			pta.x += dir1; ptb.x += dir1;
			pta.y += dir2; ptb.y += dir2;
		}

		std::pair<Point, Point> arrow = GetArrowPointEdge(ptb, pta, dpi->zoom);
		Point ptm = { (pta.x + ptb.x) / 2, (pta.y + ptb.y) / 2 };

		//if ((pta.x < ptb.x) != (pta.y < ptb.y)) ptm.y += FONT_HEIGHT_SMALL;
		//numbers.emplace_back(std::make_pair(ptm, cost));

		const int colour = 42 + cost * 8 / this->maxcost;
		const int width = (dpi->zoom < ZOOM_LVL_OUT_2X) ? 3 : 1;

		GfxDrawLine(pta.x, pta.y, ptb.x, ptb.y, colour, width, 0);
		GfxDrawLine(ptb.x, ptb.y, arrow.first.x, arrow.first.y, colour, width, 0);
		GfxDrawLine(arrow.first.x, arrow.first.y, arrow.second.x, arrow.second.y, colour, width, 0);
		//GfxFillPolygon({ ptb, arrow.first, arrow.second }, colour); // this is stupidly slow, don't use
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
