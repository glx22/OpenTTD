set_property(GLOBAL PROPERTY source_list)
function(add_files)
    get_property(SOURCE_FILES2 GLOBAL PROPERTY source_list)
    foreach(FILE ${ARGV})
        if (NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
            list(APPEND SOURCE_FILES2 ${CMAKE_CURRENT_SOURCE_DIR}/${FILE})
        else()
            list(APPEND SOURCE_FILES2 ${tmp} ${CMAKE_SOURCE_DIR}/src/${FILE})
        endif()
    endforeach()
    set_property(GLOBAL PROPERTY source_list "${SOURCE_FILES2}")
endfunction(add_files)

function(CheckSourceEquality)
	get_property(SOURCE_FILES2 GLOBAL PROPERTY source_list)

    foreach(FILE ${SOURCE_FILES2})
        list(FIND SOURCE_FILES "${FILE}" FOUND)
        if(FOUND LESS 0)
            message(STATUS "${FILE} only in SOURCE_FILES2")
        endif(FOUND LESS 0)
    endforeach()

    foreach(FILE ${SOURCE_FILES})
        list(FIND SOURCE_FILES2 "${FILE}" FOUND)
        if(FOUND LESS 0)
            message(STATUS "${FILE} only in SOURCE_FILES")
        endif(FOUND LESS 0)
    endforeach()
endfunction(CheckSourceEquality)

set(OPTION_COCOA NO)
if (APPLE)
    set(OPTION_COCOA YES)
endif (APPLE)

# These OSes used to be supported by OpenTTD, but have no CMake code yet
set(OPTION_BEOS NO)
set(OPTION_DOS NO)
set(OPTION_MORPHOS NO)
set(OPTION_OS2 NO)

# Source Files
add_files(
    airport.cpp
    animated_tile.cpp
    articulated_vehicles.cpp
    autoreplace.cpp
    bmp.cpp
    cargoaction.cpp
    cargomonitor.cpp
    cargopacket.cpp
    cargotype.cpp
    cheat.cpp
    command.cpp
    console.cpp
    console_cmds.cpp
    cpu.cpp
    crashlog.cpp
    currency.cpp
    date.cpp
    debug.cpp
    dedicated.cpp
    depot.cpp
    disaster_vehicle.cpp
    driver.cpp
    economy.cpp
    effectvehicle.cpp
    elrail.cpp
    engine.cpp
    fileio.cpp
    fios.cpp
    fontcache.cpp
    fontdetection.cpp
    base_consist.cpp
    gamelog.cpp
    genworld.cpp
    gfx.cpp
    gfxinit.cpp
    gfx_layout.cpp
    goal.cpp
    ground_vehicle.cpp
    heightmap.cpp
    highscore.cpp
    hotkeys.cpp
    ini.cpp
    ini_load.cpp
    landscape.cpp
)
add_files(
    linkgraph/demands.cpp
    linkgraph/flowmapper.cpp
    linkgraph/linkgraph.cpp
    linkgraph/linkgraphjob.cpp
    linkgraph/linkgraphschedule.cpp
    linkgraph/mcf.cpp
    linkgraph/refresh.cpp
)
add_files(
    map.cpp
    misc.cpp
    mixer.cpp
    music.cpp
)
add_files(
    network/network.cpp
    network/network_admin.cpp
    network/network_client.cpp
    network/network_command.cpp
    network/network_content.cpp
    network/network_gamelist.cpp
    network/network_server.cpp
    network/network_udp.cpp
)
add_files(
    openttd.cpp
    order_backup.cpp
    pbs.cpp
    progress.cpp
    rail.cpp
    road.cpp
    roadstop.cpp
    screenshot.cpp
    settings.cpp
    signal.cpp
    signs.cpp
    sound.cpp
    sprite.cpp
    spritecache.cpp
    station.cpp
)
add_files(strgen/strgen_base.cpp)
add_files(
    string.cpp
    stringfilter.cpp
    strings.cpp
    story.cpp
    subsidy.cpp
    textbuf.cpp
    texteff.cpp
    tgp.cpp
    tile_map.cpp
    tilearea.cpp
    townname.cpp
)
if (NOT WIN32)
    if (OPTION_OS2)
        add_files(os/os2/os2.cpp)
        add_files(
            3rdparty/os2/getaddrinfo.c
            3rdparty/os2/getaddrinfo.h
            3rdparty/os2/getnameinfo.c
            3rdparty/os2/getnameinfo.h
        )
    else (OPTION_OS2)
        if (APPLE)
            add_files(os/macosx/crashlog_osx.cpp)
        else (APPLE)
            add_files(os/unix/crashlog_unix.cpp)
        endif (APPLE)
        add_files(os/unix/unix.cpp)
    endif (OPTION_OS2)
endif (NOT WIN32)
add_files(
    vehicle.cpp
    vehiclelist.cpp
    viewport.cpp
)
if (SSE_FOUND)
    add_files(viewport_sprite_sorter_sse4.cpp)
endif (SSE_FOUND)
add_files(
    waypoint.cpp
    widget.cpp
    window.cpp
)

# Header Files
if (ALLEGRO_FOUND)
    add_files(music/allegro_m.h)
    add_files(sound/allegro_s.h)
    add_files(video/allegro_v.h)
endif (ALLEGRO_FOUND)
add_files(
    aircraft.h
    airport.h
    animated_tile_func.h
    articulated_vehicles.h
    autoreplace_base.h
    autoreplace_func.h
    autoreplace_gui.h
    autoreplace_type.h
    autoslope.h
    base_media_base.h
    base_media_func.h
    base_station_base.h
    bitmap_type.h
    bmp.h
    bridge.h
    cargo_type.h
    cargoaction.h
    cargomonitor.h
    cargopacket.h
    cargotype.h
    cheat_func.h
    cheat_type.h
    clear_func.h
    cmd_helper.h
    command_func.h
    command_type.h
    company_base.h
    company_func.h
    company_gui.h
    company_manager_face.h
    company_type.h
    console_func.h
    console_gui.h
    console_internal.h
    console_type.h
    cpu.h
    crashlog.h
    currency.h
    date_func.h
    date_gui.h
    date_type.h
    debug.h
)
add_files(video/dedicated_v.h)
add_files(
    depot_base.h
    depot_func.h
    depot_map.h
    depot_type.h
    direction_func.h
    direction_type.h
    disaster_vehicle.h
)
add_files(music/dmusic.h)
add_files(
    driver.h
    economy_base.h
    economy_func.h
    economy_type.h
    effectvehicle_base.h
    effectvehicle_func.h
    elrail_func.h
    engine_base.h
    engine_func.h
    engine_gui.h
    engine_type.h
    error.h
    fileio_func.h
    fileio_type.h
    fios.h
    fontcache.h
    fontdetection.h
    framerate_type.h
    base_consist.h
    gamelog.h
    gamelog_internal.h
    genworld.h
    gfx_func.h
    gfx_layout.h
    gfx_type.h
    gfxinit.h
    goal_base.h
    goal_type.h
    graph_gui.h
    ground_vehicle.hpp
    group.h
    group_gui.h
    group_type.h
    gui.h
    guitimer_func.h
    heightmap.h
    highscore.h
    hotkeys.h
    house.h
    house_type.h
    industry.h
    industry_type.h
    industrytype.h
    ini_type.h
    landscape.h
    landscape_type.h
    language.h
)
add_files(
    linkgraph/demands.h
    linkgraph/flowmapper.h
    linkgraph/init.h
    linkgraph/linkgraph.h
    linkgraph/linkgraph_base.h
    linkgraph/linkgraph_gui.h
    linkgraph/linkgraph_type.h
    linkgraph/linkgraphjob.h
    linkgraph/linkgraphjob_base.h
    linkgraph/linkgraphschedule.h
    linkgraph/mcf.h
    linkgraph/refresh.h
)
add_files(
    livery.h
    map_func.h
    map_type.h
    mixer.h
)
add_files(
    network/network.h
    network/network_admin.h
    network/network_base.h
    network/network_client.h
    network/network_content.h
    network/network_content_gui.h
    network/network_func.h
    network/network_gamelist.h
    network/network_gui.h
    network/network_internal.h
    network/network_server.h
    network/network_type.h
    network/network_udp.h
)
add_files(
    newgrf.h
    newgrf_airport.h
    newgrf_airporttiles.h
    newgrf_animation_base.h
    newgrf_animation_type.h
    newgrf_callbacks.h
    newgrf_canal.h
    newgrf_cargo.h
    newgrf_class.h
    newgrf_class_func.h
    newgrf_commons.h
    newgrf_config.h
    newgrf_debug.h
    newgrf_engine.h
    newgrf_generic.h
    newgrf_house.h
    newgrf_industries.h
    newgrf_industrytiles.h
    newgrf_object.h
    newgrf_properties.h
    newgrf_railtype.h
    newgrf_sound.h
    newgrf_spritegroup.h
    newgrf_station.h
    newgrf_storage.h
    newgrf_text.h
    newgrf_town.h
    newgrf_townname.h
    news_func.h
    news_gui.h
    news_type.h
)
add_files(
    music/midi.h
    music/midifile.hpp
    music/null_m.h
)
add_files(sound/null_s.h)
add_files(video/null_v.h)
add_files(
    object.h
    object_base.h
    object_type.h
    openttd.h
    order_backup.h
    order_base.h
    order_func.h
    order_type.h
    pbs.h
    progress.h
    querystring_gui.h
    rail.h
    rail_gui.h
    rail_type.h
    rev.h
    road_cmd.h
    road_func.h
    road_gui.h
    road_internal.h
    road_type.h
    roadstop_base.h
    roadveh.h
    safeguards.h
    screenshot.h
)
add_files(sound/sdl_s.h)
add_files(video/sdl_v.h)
add_files(
    settings_func.h
    settings_gui.h
    settings_internal.h
    settings_type.h
    ship.h
    signal_func.h
    signal_type.h
    signs_base.h
    signs_func.h
    signs_type.h
    slope_func.h
    slope_type.h
    smallmap_gui.h
    sortlist_type.h
    sound_func.h
    sound_type.h
    sprite.h
    spritecache.h
    station_base.h
    station_func.h
    station_gui.h
    station_kdtree.h
    station_type.h
    statusbar_gui.h
    stdafx.h
    story_base.h
    story_type.h
)
add_files(strgen/strgen.h)
add_files(
    string_base.h
    string_func.h
    string_type.h
)
add_files(os/windows/string_uniscribe.h)
add_files(
    stringfilter_type.h
    strings_func.h
    strings_type.h
    subsidy_base.h
    subsidy_func.h
    subsidy_type.h
    tar_type.h
    terraform_gui.h
    textbuf_gui.h
    textbuf_type.h
    texteff.hpp
    textfile_gui.h
    textfile_type.h
    tgp.h
    tile_cmd.h
    tile_type.h
    tilearea_type.h
    tilehighlight_func.h
    tilehighlight_type.h
    tilematrix_type.hpp
    timetable.h
    toolbar_gui.h
    town.h
    town_type.h
    town_kdtree.h
    townname_func.h
    townname_type.h
    track_func.h
    track_type.h
    train.h
    transparency.h
    transparency_gui.h
    transport_type.h
    tunnelbridge.h
    vehicle_base.h
    vehicle_func.h
    vehicle_gui.h
    vehicle_gui_base.h
    vehicle_type.h
    vehiclelist.h
    viewport_func.h
    viewport_kdtree.h
    viewport_sprite_sorter.h
    viewport_type.h
    water.h
    waypoint_base.h
    waypoint_func.h
    widget_type.h
)
add_files(os/windows/win32.h)
add_files(music/win32_m.h)
add_files(sound/win32_s.h)
add_files(video/win32_v.h)
add_files(
    window_func.h
    window_gui.h
    window_type.h
)
add_files(sound/xaudio2_s.h)
add_files(
    zoom_func.h
    zoom_type.h
)
if (NOT WIN32)
    add_files(
        music/bemidi.h
        music/cocoa_m.h
        music/extmidi.h
        music/libtimidity.h
        music/fluidsynth.h
        music/os2_m.h
        music/qtmidi.h
    )
    add_files(
        os/macosx/macos.h
        os/macosx/osx_stdafx.h
        os/macosx/splash.h
        os/macosx/string_osx.h
    )
    add_files(sound/cocoa_s.h)
    add_files(
        video/cocoa/cocoa_keys.h
        video/cocoa/cocoa_v.h
    )
endif (NOT WIN32)

# Core Source Code
add_files(
    core/alloc_func.cpp
    core/alloc_func.hpp
    core/alloc_type.hpp
    core/backup_type.hpp
    core/bitmath_func.cpp
    core/bitmath_func.hpp
    core/endian_func.hpp
    core/endian_type.hpp
    core/enum_type.hpp
    core/geometry_func.cpp
    core/geometry_func.hpp
    core/geometry_type.hpp
    core/kdtree.hpp
    core/math_func.cpp
    core/math_func.hpp
    core/mem_func.hpp
    core/multimap.hpp
    core/overflowsafe_type.hpp
    core/pool_func.cpp
    core/pool_func.hpp
    core/pool_type.hpp
    core/random_func.cpp
    core/random_func.hpp
    core/smallmap_type.hpp
    core/smallmatrix_type.hpp
    core/smallstack_type.hpp
    core/smallvec_type.hpp
    core/sort_func.hpp
    core/string_compare_type.hpp
)

# GUI Source Code
add_files(
    aircraft_gui.cpp
    airport_gui.cpp
    autoreplace_gui.cpp
    bootstrap_gui.cpp
    bridge_gui.cpp
    build_vehicle_gui.cpp
    cheat_gui.cpp
    company_gui.cpp
    console_gui.cpp
    date_gui.cpp
    depot_gui.cpp
    dock_gui.cpp
    engine_gui.cpp
    error_gui.cpp
    fios_gui.cpp
    framerate_gui.cpp
    genworld_gui.cpp
    goal_gui.cpp
    graph_gui.cpp
    group_gui.cpp
    highscore_gui.cpp
    industry_gui.cpp
    intro_gui.cpp
)
add_files(linkgraph/linkgraph_gui.cpp)
add_files(
    main_gui.cpp
    misc_gui.cpp
    music_gui.cpp
)
add_files(
    network/network_chat_gui.cpp
    network/network_content_gui.cpp
    network/network_gui.cpp
)
add_files(
    newgrf_debug_gui.cpp
    newgrf_gui.cpp
    news_gui.cpp
    object_gui.cpp
    order_gui.cpp
    osk_gui.cpp
    rail_gui.cpp
    road_gui.cpp
    roadveh_gui.cpp
    settings_gui.cpp
    ship_gui.cpp
    signs_gui.cpp
    smallmap_gui.cpp
    station_gui.cpp
    statusbar_gui.cpp
    story_gui.cpp
    subsidy_gui.cpp
    terraform_gui.cpp
    textfile_gui.cpp
    timetable_gui.cpp
    toolbar_gui.cpp
    town_gui.cpp
    train_gui.cpp
    transparency_gui.cpp
    tree_gui.cpp
    vehicle_gui.cpp
    viewport_gui.cpp
    waypoint_gui.cpp
)

# Widgets
add_files(
    widgets/airport_widget.h
    widgets/ai_widget.h
    widgets/autoreplace_widget.h
    widgets/bootstrap_widget.h
    widgets/bridge_widget.h
    widgets/build_vehicle_widget.h
    widgets/cheat_widget.h
    widgets/company_widget.h
    widgets/console_widget.h
    widgets/date_widget.h
    widgets/depot_widget.h
    widgets/dock_widget.h
    widgets/dropdown.cpp
    widgets/dropdown_func.h
    widgets/dropdown_type.h
    widgets/dropdown_widget.h
    widgets/engine_widget.h
    widgets/error_widget.h
    widgets/fios_widget.h
    widgets/framerate_widget.h
    widgets/genworld_widget.h
    widgets/goal_widget.h
    widgets/graph_widget.h
    widgets/group_widget.h
    widgets/highscore_widget.h
    widgets/industry_widget.h
    widgets/intro_widget.h
    widgets/link_graph_legend_widget.h
    widgets/main_widget.h
    widgets/misc_widget.h
    widgets/music_widget.h
    widgets/network_chat_widget.h
    widgets/network_content_widget.h
    widgets/network_widget.h
    widgets/newgrf_debug_widget.h
    widgets/newgrf_widget.h
    widgets/news_widget.h
    widgets/object_widget.h
    widgets/order_widget.h
    widgets/osk_widget.h
    widgets/rail_widget.h
    widgets/road_widget.h
    widgets/settings_widget.h
    widgets/sign_widget.h
    widgets/smallmap_widget.h
    widgets/station_widget.h
    widgets/statusbar_widget.h
    widgets/story_widget.h
    widgets/subsidy_widget.h
    widgets/terraform_widget.h
    widgets/timetable_widget.h
    widgets/toolbar_widget.h
    widgets/town_widget.h
    widgets/transparency_widget.h
    widgets/tree_widget.h
    widgets/vehicle_widget.h
    widgets/viewport_widget.h
    widgets/waypoint_widget.h
)

# Command handlers
add_files(
    aircraft_cmd.cpp
    autoreplace_cmd.cpp
    clear_cmd.cpp
    company_cmd.cpp
    depot_cmd.cpp
    group_cmd.cpp
    industry_cmd.cpp
    misc_cmd.cpp
    object_cmd.cpp
    order_cmd.cpp
    rail_cmd.cpp
    road_cmd.cpp
    roadveh_cmd.cpp
    ship_cmd.cpp
    signs_cmd.cpp
    station_cmd.cpp
    terraform_cmd.cpp
    timetable_cmd.cpp
    town_cmd.cpp
    train_cmd.cpp
    tree_cmd.cpp
    tunnelbridge_cmd.cpp
    vehicle_cmd.cpp
    void_cmd.cpp
    water_cmd.cpp
    waypoint_cmd.cpp
)

# Save/Load handlers
add_files(
    saveload/afterload.cpp
    saveload/ai_sl.cpp
    saveload/airport_sl.cpp
    saveload/animated_tile_sl.cpp
    saveload/autoreplace_sl.cpp
    saveload/cargomonitor_sl.cpp
    saveload/cargopacket_sl.cpp
    saveload/cheat_sl.cpp
    saveload/company_sl.cpp
    saveload/depot_sl.cpp
    saveload/economy_sl.cpp
    saveload/engine_sl.cpp
    saveload/game_sl.cpp
    saveload/gamelog_sl.cpp
    saveload/goal_sl.cpp
    saveload/group_sl.cpp
    saveload/industry_sl.cpp
    saveload/labelmaps_sl.cpp
    saveload/linkgraph_sl.cpp
    saveload/map_sl.cpp
    saveload/misc_sl.cpp
    saveload/newgrf_sl.cpp
    saveload/newgrf_sl.h
    saveload/object_sl.cpp
    saveload/oldloader.cpp
    saveload/oldloader.h
    saveload/oldloader_sl.cpp
    saveload/order_sl.cpp
    saveload/saveload.cpp
    saveload/saveload.h
    saveload/saveload_filter.h
    saveload/saveload_internal.h
    saveload/signs_sl.cpp
    saveload/station_sl.cpp
    saveload/storage_sl.cpp
    saveload/strings_sl.cpp
    saveload/story_sl.cpp
    saveload/subsidy_sl.cpp
    saveload/town_sl.cpp
    saveload/vehicle_sl.cpp
    saveload/waypoint_sl.cpp
)

# Tables
add_files(
    table/airport_defaults.h
    table/airport_movement.h
    table/airporttile_ids.h
    table/airporttiles.h
    table/animcursors.h
    table/autorail.h
    table/bridge_land.h
    table/build_industry.h
    table/cargo_const.h
    table/clear_land.h
    table/control_codes.h
    table/elrail_data.h
    table/engines.h
    table/genland.h
    table/heightmap_colours.h
    table/industry_land.h
    table/landscape_sprite.h
    table/newgrf_debug_data.h
    table/object_land.h
    table/palette_convert.h
    table/palettes.h
    table/pricebase.h
    table/railtypes.h
    table/road_land.h
    table/roadveh_movement.h
    table/sprites.h
    table/station_land.h
    table/strgen_tables.h
    table/string_colours.h
    table/town_land.h
    table/townname.h
    table/track_land.h
    table/train_cmd.h
    table/tree_land.h
    table/unicode.h
    table/water_land.h
)

# MD5
add_files(
    3rdparty/md5/md5.cpp
    3rdparty/md5/md5.h
)

# Script
add_files(
    script/script_config.cpp
    script/script_config.hpp
    script/script_fatalerror.hpp
    script/script_info.cpp
    script/script_info.hpp
    script/script_info_dummy.cpp
    script/script_instance.cpp
    script/script_instance.hpp
    script/script_scanner.cpp
    script/script_scanner.hpp
    script/script_storage.hpp
    script/script_suspend.hpp
    script/squirrel.cpp
    script/squirrel.hpp
    script/squirrel_class.hpp
    script/squirrel_helper.hpp
    script/squirrel_helper_type.hpp
    script/squirrel_std.cpp
    script/squirrel_std.hpp
)

# Squirrel
add_files(
    3rdparty/squirrel/squirrel/sqapi.cpp
    3rdparty/squirrel/squirrel/sqbaselib.cpp
    3rdparty/squirrel/squirrel/sqclass.cpp
    3rdparty/squirrel/squirrel/sqcompiler.cpp
    3rdparty/squirrel/squirrel/sqdebug.cpp
    3rdparty/squirrel/squirrel/sqfuncstate.cpp
    3rdparty/squirrel/squirrel/sqlexer.cpp
    3rdparty/squirrel/squirrel/sqmem.cpp
    3rdparty/squirrel/squirrel/sqobject.cpp
    3rdparty/squirrel/squirrel/sqstate.cpp
    3rdparty/squirrel/sqstdlib/sqstdaux.cpp
    3rdparty/squirrel/sqstdlib/sqstdmath.cpp
    3rdparty/squirrel/squirrel/sqtable.cpp
    3rdparty/squirrel/squirrel/sqvm.cpp
)

# Squirrel headers
add_files(
    3rdparty/squirrel/squirrel/sqarray.h
    3rdparty/squirrel/squirrel/sqclass.h
    3rdparty/squirrel/squirrel/sqclosure.h
    3rdparty/squirrel/squirrel/sqcompiler.h
    3rdparty/squirrel/squirrel/sqfuncproto.h
    3rdparty/squirrel/squirrel/sqfuncstate.h
    3rdparty/squirrel/squirrel/sqlexer.h
    3rdparty/squirrel/squirrel/sqobject.h
    3rdparty/squirrel/squirrel/sqopcodes.h
    3rdparty/squirrel/squirrel/sqpcheader.h
    3rdparty/squirrel/squirrel/sqstate.h
)
add_files(
    3rdparty/squirrel/include/sqstdaux.h
    3rdparty/squirrel/include/sqstdmath.h
    3rdparty/squirrel/include/sqstdstring.h
)
add_files(
    3rdparty/squirrel/squirrel/sqstring.h
    3rdparty/squirrel/squirrel/sqtable.h
)
add_files(3rdparty/squirrel/include/squirrel.h)
add_files(
    3rdparty/squirrel/squirrel/squserdata.h
    3rdparty/squirrel/squirrel/squtils.h
    3rdparty/squirrel/squirrel/sqvm.h
)

# AI Core
add_files(
    ai/ai.hpp
    ai/ai_config.cpp
    ai/ai_config.hpp
    ai/ai_core.cpp
    ai/ai_gui.cpp
    ai/ai_gui.hpp
    ai/ai_info.cpp
    ai/ai_info.hpp
    ai/ai_instance.cpp
    ai/ai_instance.hpp
    ai/ai_scanner.cpp
    ai/ai_scanner.hpp
)

# AI API
add_files(script/api/ai_changelog.hpp)

# Game API
add_files(script/api/game_changelog.hpp)

# Game Core
add_files(
    game/game.hpp
    game/game_config.cpp
    game/game_config.hpp
    game/game_core.cpp
    game/game_info.cpp
    game/game_info.hpp
    game/game_instance.cpp
    game/game_instance.hpp
    game/game_scanner.cpp
    game/game_scanner.hpp
    game/game_text.cpp
    game/game_text.hpp
)

# Script API
add_files(
    script/api/script_accounting.hpp
    script/api/script_admin.hpp
    script/api/script_airport.hpp
    script/api/script_base.hpp
    script/api/script_basestation.hpp
    script/api/script_bridge.hpp
    script/api/script_bridgelist.hpp
    script/api/script_cargo.hpp
    script/api/script_cargolist.hpp
    script/api/script_cargomonitor.hpp
    script/api/script_client.hpp
    script/api/script_clientlist.hpp
    script/api/script_company.hpp
    script/api/script_companymode.hpp
    script/api/script_controller.hpp
    script/api/script_date.hpp
    script/api/script_depotlist.hpp
    script/api/script_engine.hpp
    script/api/script_enginelist.hpp
    script/api/script_error.hpp
    script/api/script_event.hpp
    script/api/script_event_types.hpp
    script/api/script_execmode.hpp
    script/api/script_game.hpp
    script/api/script_gamesettings.hpp
    script/api/script_goal.hpp
    script/api/script_group.hpp
    script/api/script_grouplist.hpp
    script/api/script_industry.hpp
    script/api/script_industrylist.hpp
    script/api/script_industrytype.hpp
    script/api/script_industrytypelist.hpp
    script/api/script_info_docs.hpp
    script/api/script_infrastructure.hpp
    script/api/script_list.hpp
    script/api/script_log.hpp
    script/api/script_map.hpp
    script/api/script_marine.hpp
    script/api/script_news.hpp
    script/api/script_object.hpp
    script/api/script_order.hpp
    script/api/script_rail.hpp
    script/api/script_railtypelist.hpp
    script/api/script_road.hpp
    script/api/script_sign.hpp
    script/api/script_signlist.hpp
    script/api/script_station.hpp
    script/api/script_stationlist.hpp
    script/api/script_story_page.hpp
    script/api/script_storypagelist.hpp
    script/api/script_storypageelementlist.hpp
    script/api/script_subsidy.hpp
    script/api/script_subsidylist.hpp
    script/api/script_testmode.hpp
    script/api/script_text.hpp
    script/api/script_tile.hpp
    script/api/script_tilelist.hpp
    script/api/script_town.hpp
    script/api/script_townlist.hpp
    script/api/script_tunnel.hpp
    script/api/script_types.hpp
    script/api/script_vehicle.hpp
    script/api/script_vehiclelist.hpp
    script/api/script_viewport.hpp
    script/api/script_waypoint.hpp
    script/api/script_waypointlist.hpp
    script/api/script_window.hpp
)

# Script API Implementation
add_files(
    script/api/script_accounting.cpp
    script/api/script_admin.cpp
    script/api/script_airport.cpp
    script/api/script_base.cpp
    script/api/script_basestation.cpp
    script/api/script_bridge.cpp
    script/api/script_bridgelist.cpp
    script/api/script_cargo.cpp
    script/api/script_cargolist.cpp
    script/api/script_cargomonitor.cpp
    script/api/script_client.cpp
    script/api/script_clientlist.cpp
    script/api/script_company.cpp
    script/api/script_companymode.cpp
    script/api/script_controller.cpp
    script/api/script_date.cpp
    script/api/script_depotlist.cpp
    script/api/script_engine.cpp
    script/api/script_enginelist.cpp
    script/api/script_error.cpp
    script/api/script_event.cpp
    script/api/script_event_types.cpp
    script/api/script_execmode.cpp
    script/api/script_game.cpp
    script/api/script_gamesettings.cpp
    script/api/script_goal.cpp
    script/api/script_group.cpp
    script/api/script_grouplist.cpp
    script/api/script_industry.cpp
    script/api/script_industrylist.cpp
    script/api/script_industrytype.cpp
    script/api/script_industrytypelist.cpp
    script/api/script_infrastructure.cpp
    script/api/script_list.cpp
    script/api/script_log.cpp
    script/api/script_map.cpp
    script/api/script_marine.cpp
    script/api/script_news.cpp
    script/api/script_object.cpp
    script/api/script_order.cpp
    script/api/script_rail.cpp
    script/api/script_railtypelist.cpp
    script/api/script_road.cpp
    script/api/script_sign.cpp
    script/api/script_signlist.cpp
    script/api/script_station.cpp
    script/api/script_stationlist.cpp
    script/api/script_story_page.cpp
    script/api/script_storypagelist.cpp
    script/api/script_storypageelementlist.cpp
    script/api/script_subsidy.cpp
    script/api/script_subsidylist.cpp
    script/api/script_testmode.cpp
    script/api/script_text.cpp
    script/api/script_tile.cpp
    script/api/script_tilelist.cpp
    script/api/script_town.cpp
    script/api/script_townlist.cpp
    script/api/script_tunnel.cpp
    script/api/script_vehicle.cpp
    script/api/script_vehiclelist.cpp
    script/api/script_viewport.cpp
    script/api/script_waypoint.cpp
    script/api/script_waypointlist.cpp
    script/api/script_window.cpp
)

# Blitters
if (NOT OPTION_DEDICATED)
    add_files(
        blitter/32bpp_anim.cpp
        blitter/32bpp_anim.hpp
    )
    if (SSE_FOUND)
        add_files(
            blitter/32bpp_anim_sse2.cpp
            blitter/32bpp_anim_sse2.hpp
            blitter/32bpp_anim_sse4.cpp
            blitter/32bpp_anim_sse4.hpp
        )
    endif(SSE_FOUND)
    add_files(
        blitter/32bpp_base.cpp
        blitter/32bpp_base.hpp
        blitter/32bpp_optimized.cpp
        blitter/32bpp_optimized.hpp
        blitter/32bpp_simple.cpp
        blitter/32bpp_simple.hpp
    )
    if (SSE_FOUND)
        add_files(
            blitter/32bpp_sse_func.hpp
            blitter/32bpp_sse_type.h
            blitter/32bpp_sse2.cpp
            blitter/32bpp_sse2.hpp
            blitter/32bpp_sse4.cpp
            blitter/32bpp_sse4.hpp
            blitter/32bpp_ssse3.cpp
            blitter/32bpp_ssse3.hpp
        )
    endif (SSE_FOUND)
    add_files(
        blitter/8bpp_base.cpp
        blitter/8bpp_base.hpp
        blitter/8bpp_optimized.cpp
        blitter/8bpp_optimized.hpp
        blitter/8bpp_simple.cpp
        blitter/8bpp_simple.hpp
    )
endif (NOT OPTION_DEDICATED)
add_files(
    blitter/base.hpp
    blitter/common.hpp
    blitter/factory.hpp
    blitter/null.cpp
    blitter/null.hpp
)

# Drivers
add_files(music/music_driver.hpp)
add_files(sound/sound_driver.hpp)
add_files(video/video_driver.hpp)

# Sprite loaders
add_files(
    spriteloader/grf.cpp
    spriteloader/grf.hpp
    spriteloader/spriteloader.hpp
)

# NewGRF
add_files(
    newgrf.cpp
    newgrf_airport.cpp
    newgrf_airporttiles.cpp
    newgrf_canal.cpp
    newgrf_cargo.cpp
    newgrf_commons.cpp
    newgrf_config.cpp
    newgrf_engine.cpp
    newgrf_generic.cpp
    newgrf_house.cpp
    newgrf_industries.cpp
    newgrf_industrytiles.cpp
    newgrf_object.cpp
    newgrf_railtype.cpp
    newgrf_sound.cpp
    newgrf_spritegroup.cpp
    newgrf_station.cpp
    newgrf_storage.cpp
    newgrf_text.cpp
    newgrf_town.cpp
    newgrf_townname.cpp
)

# Map Accessors
add_files(
    bridge_map.cpp
    bridge_map.h
    clear_map.h
    industry_map.h
    object_map.h
    rail_map.h
    road_map.cpp
    road_map.h
    station_map.h
    tile_map.h
    town_map.h
    tree_map.h
    tunnel_map.cpp
    tunnel_map.h
    tunnelbridge_map.h
    void_map.h
    water_map.h
)

# Misc
add_files(
    misc/array.hpp
    misc/binaryheap.hpp
    misc/blob.hpp
    misc/countedobj.cpp
    misc/countedptr.hpp
    misc/dbg_helpers.cpp
    misc/dbg_helpers.h
    misc/fixedsizearray.hpp
    misc/getoptdata.cpp
    misc/getoptdata.h
    misc/hashtable.hpp
    misc/str.hpp
)

# Network Core
add_files(
    network/core/address.cpp
    network/core/address.h
    network/core/config.h
    network/core/core.cpp
    network/core/core.h
    network/core/game.h
    network/core/host.cpp
    network/core/host.h
    network/core/os_abstraction.h
    network/core/packet.cpp
    network/core/packet.h
    network/core/tcp.cpp
    network/core/tcp.h
    network/core/tcp_admin.cpp
    network/core/tcp_admin.h
    network/core/tcp_connect.cpp
    network/core/tcp_content.cpp
    network/core/tcp_content.h
    network/core/tcp_game.cpp
    network/core/tcp_game.h
    network/core/tcp_http.cpp
    network/core/tcp_http.h
    network/core/tcp_listen.h
    network/core/udp.cpp
    network/core/udp.h
)

# Pathfinder
add_files(pathfinder/follow_track.hpp)
add_files(
    pathfinder/opf/opf_ship.cpp
    pathfinder/opf/opf_ship.h
)
add_files(
    pathfinder/pathfinder_func.h
    pathfinder/pathfinder_type.h
    pathfinder/pf_performance_timer.hpp
)

# NPF
add_files(
    pathfinder/npf/aystar.cpp
    pathfinder/npf/aystar.h
    pathfinder/npf/npf.cpp
    pathfinder/npf/npf_func.h
    pathfinder/npf/queue.cpp
    pathfinder/npf/queue.h
)

# YAPF
add_files(
    pathfinder/yapf/nodelist.hpp
    pathfinder/yapf/yapf.h
    pathfinder/yapf/yapf.hpp
    pathfinder/yapf/yapf_base.hpp
    pathfinder/yapf/yapf_cache.h
    pathfinder/yapf/yapf_common.hpp
    pathfinder/yapf/yapf_costbase.hpp
    pathfinder/yapf/yapf_costcache.hpp
    pathfinder/yapf/yapf_costrail.hpp
    pathfinder/yapf/yapf_destrail.hpp
    pathfinder/yapf/yapf_node.hpp
    pathfinder/yapf/yapf_node_rail.hpp
    pathfinder/yapf/yapf_node_road.hpp
    pathfinder/yapf/yapf_node_ship.hpp
    pathfinder/yapf/yapf_rail.cpp
    pathfinder/yapf/yapf_road.cpp
    pathfinder/yapf/yapf_ship.cpp
    pathfinder/yapf/yapf_type.hpp
)

# Video
add_files(
    video/dedicated_v.cpp
    video/null_v.cpp
)
if (NOT OPTION_DEDICATED)
    if (ALLEGRO_FOUND)
        add_files(video/allegro_v.cpp)
    endif (ALLEGRO_FOUND)
    if (SDL_FOUND)
        add_files(video/sdl_v.cpp)
    endif (SDL_FOUND)
    if (WIN32)
        add_files(video/win32_v.cpp)
    endif (WIN32)
endif (NOT OPTION_DEDICATED)

# Music
if (NOT OPTION_DEDICATED)
    if (ALLEGRO_FOUND)
        add_files(music/allegro_m.cpp)
    endif (ALLEGRO_FOUND)
    if (WIN32)
        add_files(music/dmusic.cpp)
    endif (WIN32)
endif (NOT OPTION_DEDICATED)
add_files(
    music/null_m.cpp
    music/midifile.cpp
)
if (NOT OPTION_DEDICATED)
    if (WIN32)
        add_files(music/win32_m.cpp)
    else (WIN32)
        if (NOT OPTION_DOS AND NOT OPTION_MORPHOS)
            add_files(music/extmidi.cpp)
        endif (NOT OPTION_DOS AND NOT OPTION_MORPHOS)
    endif (WIN32)
    if (OPTION_BEOS)
        add_files(music/bemidi.cpp)
    endif (OPTION_BEOS)
    if (OPTION_TIMIDITY)
        add_files(music/libtimidity.cpp)
    endif (OPTION_TIMIDITY)
    if (FLUIDSYNTH_FOUND)
        add_files(music/fluidsynth.cpp)
    endif (FLUIDSYNTH_FOUND)
endif (NOT OPTION_DEDICATED)

# Sound
add_files(sound/null_s.cpp)
if (NOT OPTION_DEDICATED)
    if (ALLEGRO_FOUND)
        add_files(sound/allegro_s.cpp)
    endif (ALLEGRO_FOUND)
    if (SDL_FOUND)
        add_files(sound/sdl_s.cpp)
    endif (SDL_FOUND)
    if (WIN32)
        add_files(sound/win32_s.cpp)
        if (XAUDIO_FOUND)
            add_files(sound/xaudio2_s.cpp)
        endif (XAUDIO_FOUND)
    endif (WIN32)
endif (NOT OPTION_DEDICATED)

if (APPLE)
# OSX Files
    add_files(os/macosx/macos.mm)

    if (NOT OPTION_DEDICATED)
        add_files(music/qtmidi.cpp)
    endif (NOT OPTION_DEDICATED)

    if (OPTION_COCOA)
        add_files(
            video/cocoa/cocoa_v.mm
            video/cocoa/event.mm
            video/cocoa/fullscreen.mm
            video/cocoa/wnd_quartz.mm
            video/cocoa/wnd_quickdraw.mm
        )
        add_files(music/cocoa_m.cpp)
        add_files(sound/cocoa_s.cpp)
        add_files(
            os/macosx/splash.cpp
            os/macosx/string_osx.cpp
        )
    endif (OPTION_COCOA)
endif (APPLE)

# Windows files
if (WIN32)
    add_files(
        os/windows/crashlog_win.cpp
        os/windows/string_uniscribe.cpp
        os/windows/win32.cpp
    )
endif (WIN32)

# Threading
add_files(thread/thread.h)
if (OPTION_USE_THREADS)
    if (WIN32)
        add_files(thread/thread_win32.cpp)
    else (WIN32)
        if (OPTION_OS2)
            add_files(thread/thread_os2.cpp)
        else (OPTION_OS2)
            if (OPTION_MORPHOS)
                add_files(thread/thread_morphos.cpp)
            else (OPTION_MORPHOS)
                add_files(thread/thread_pthread.cpp)
            endif (OPTION_MORPHOS)
        endif (OPTION_OS2)
    endif (WIN32)
else (OPTION_USE_THREADS)
    add_files(thread/thread_none.cpp)
endif (OPTION_USE_THREADS)
