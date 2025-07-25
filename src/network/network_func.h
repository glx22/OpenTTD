/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

/** @file network_func.h Network functions used by other parts of OpenTTD. */

#ifndef NETWORK_FUNC_H
#define NETWORK_FUNC_H

/**
 * Uncomment the following define to enable command replaying.
 * See docs/desync.md for details.
 */
// #define DEBUG_DUMP_COMMANDS
// #define DEBUG_FAILED_DUMP_COMMANDS

#include "network_type.h"
#include "../core/convertible_through_base.hpp"
#include "../console_type.h"
#include "../gfx_type.h"
#include "../openttd.h"
#include "../company_type.h"
#include "../string_type.h"

extern ClientID _network_own_client_id;
extern ClientID _redirect_console_to_client;
extern uint8_t _network_reconnect;
extern StringList _network_bind_list;
extern StringList _network_host_list;
extern StringList _network_ban_list;

uint8_t NetworkSpectatorCount();
bool NetworkIsValidClientName(std::string_view client_name);
bool NetworkValidateOurClientName();
bool NetworkValidateClientName(std::string &client_name);
bool NetworkValidateServerName(std::string &server_name);
void NetworkUpdateClientName(const std::string &client_name);
void NetworkUpdateServerGameType();
bool NetworkCompanyHasClients(CompanyID company);
void NetworkReboot();
void NetworkDisconnect(bool close_admins = true);
void NetworkGameLoop();
void NetworkBackgroundLoop();
std::string_view ParseFullConnectionString(std::string_view connection_string, uint16_t &port, CompanyID *company_id = nullptr);
using NetworkCompanyStatsArray = TypedIndexContainer<std::array<NetworkCompanyStats, MAX_COMPANIES>, CompanyID>;
NetworkCompanyStatsArray NetworkGetCompanyStats();

void NetworkUpdateClientInfo(ClientID client_id);
void NetworkClientsToSpectators(CompanyID cid);
bool NetworkClientConnectGame(std::string_view connection_string, CompanyID default_company, const std::string &join_server_password = "");
void NetworkClientJoinGame();
void NetworkClientRequestMove(CompanyID company);
void NetworkClientSendRcon(std::string_view password, std::string_view command);
void NetworkClientSendChat(NetworkAction action, DestType type, int dest, std::string_view msg, int64_t data = 0);
bool NetworkClientPreferTeamChat(const NetworkClientInfo *cio);
uint NetworkMaxCompaniesAllowed();
bool NetworkMaxCompaniesReached();
void NetworkPrintClients();
std::string_view NetworkGetPublicKeyOfClient(ClientID client_id);
void NetworkHandlePauseChange(PauseModes prev_mode, PauseMode changed_mode);

void NetworkOnGameStart();

/*** Commands ran by the server ***/
void NetworkServerSendConfigUpdate();
void NetworkServerUpdateGameInfo();
void NetworkServerShowStatusToConsole();
bool NetworkServerStart();
void NetworkServerNewCompany(const Company *company, NetworkClientInfo *ci);
bool NetworkServerChangeClientName(ClientID client_id, const std::string &new_name);


bool NetworkCanJoinCompany(CompanyID company_id);
void NetworkServerDoMove(ClientID client_id, CompanyID company_id);
void NetworkServerSendRcon(ClientID client_id, TextColour colour_code, std::string_view string);
void NetworkServerSendChat(NetworkAction action, DestType type, int dest, std::string_view msg, ClientID from_id, int64_t data = 0, bool from_admin = false);
void NetworkServerSendExternalChat(std::string_view source, TextColour colour, std::string_view user, std::string_view msg);

void NetworkServerKickClient(ClientID client_id, std::string_view reason);
uint NetworkServerKickOrBanIP(ClientID client_id, bool ban, std::string_view reason);
uint NetworkServerKickOrBanIP(std::string_view ip, bool ban, std::string_view reason);

void NetworkInitChatMessage();
void NetworkReInitChatBoxSize();
void CDECL NetworkAddChatMessage(TextColour colour, uint duration, const std::string &message);
void NetworkUndrawChatMessage();

void NetworkAfterNewGRFScan();

#endif /* NETWORK_FUNC_H */
