/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

/** @file script_storypageelementlist.hpp List all story page elements. */

#ifndef SCRIPT_STORYPAGEELEMENTLIST_HPP
#define SCRIPT_STORYPAGEELEMENTLIST_HPP

#include "script_list.hpp"
#include "script_company.hpp"
#include "script_story_page.hpp"

/**
 * Create a list of all story page elements.
 * @api game
 * @ingroup ScriptList
 */
class ScriptStoryPageElementList : public ScriptList {
public:
	/**
	 * @param story_page_id The page id of the story page of which all page elements should be included in the list.
	 */
	ScriptStoryPageElementList(StoryPageID story_page_id);
};

#endif /* SCRIPT_STORYPAGEELEMENTLIST_HPP */
