/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

/** @file network_stun.cpp STUN sending/receiving part of the network protocol. */

#include "../stdafx.h"

#include "../debug.h"
#include "network_coordinator.h"
#include "network_stun.h"

#include "../safeguards.h"

/** Connect to the STUN server. */
class NetworkStunConnecter : public TCPConnecter {
private:
	ClientNetworkStunSocketHandler *stun_handler;
	std::string token;
	uint8_t family;

public:
	/**
	 * Initiate the connecting.
	 * @param stun_handler The handler for this request.
	 * @param connection_string The address of the server.
	 */
	NetworkStunConnecter(ClientNetworkStunSocketHandler *stun_handler, std::string_view connection_string, std::string_view token, uint8_t family) :
		TCPConnecter(connection_string, NETWORK_STUN_SERVER_PORT, NetworkAddress(), family),
		stun_handler(stun_handler),
		token(token),
		family(family)
	{
	}

	void OnFailure() override
	{
		Debug(net, 9, "Stun::OnFailure(): family={}", this->family);

		this->stun_handler->connecter = nullptr;

		/* Connection to STUN server failed. For example, the client doesn't
		 * support IPv6, which means it will fail that attempt. */

		_network_coordinator_client.StunResult(this->token, this->family, false);
	}

	void OnConnect(SOCKET s) override
	{
		Debug(net, 9, "Stun::OnConnect(): family={}", this->family);

		this->stun_handler->connecter = nullptr;

		assert(this->stun_handler->sock == INVALID_SOCKET);
		this->stun_handler->sock = s;

		/* Store the local address; later connects will reuse it again.
		 * This is what makes STUN work for most NATs. */
		this->stun_handler->local_addr = NetworkAddress::GetSockAddress(s);

		/* We leave the connection open till the real connection is setup later. */
	}
};

/**
 * Connect to the STUN server over either IPv4 or IPv6.
 * @param token The token as received from the Game Coordinator.
 * @param family What IP family to use.
 */
void ClientNetworkStunSocketHandler::Connect(std::string_view token, uint8_t family)
{
	this->token = token;
	this->family = family;

	Debug(net, 9, "Stun::Connect(): family={}", this->family);

	this->connecter = TCPConnecter::Create<NetworkStunConnecter>(this, NetworkStunConnectionString(), token, family);
}

/**
 * Send a STUN packet to the STUN server.
 * @param token The token as received from the Game Coordinator.
 * @param family What IP family this STUN request is for.
 * @return The handler for this STUN request.
 */
std::unique_ptr<ClientNetworkStunSocketHandler> ClientNetworkStunSocketHandler::Stun(std::string_view token, uint8_t family)
{
	auto stun_handler = std::make_unique<ClientNetworkStunSocketHandler>();

	stun_handler->Connect(token, family);

	auto p = std::make_unique<Packet>(stun_handler.get(), PACKET_STUN_SERCLI_STUN);
	p->Send_uint8(NETWORK_COORDINATOR_VERSION);
	p->Send_string(token);
	p->Send_uint8(family);

	stun_handler->SendPacket(std::move(p));

	return stun_handler;
}

NetworkRecvStatus ClientNetworkStunSocketHandler::CloseConnection(bool error)
{
	NetworkStunSocketHandler::CloseConnection(error);

	/* Also make sure any pending connecter is killed ASAP. */
	if (this->connecter != nullptr) {
		this->connecter->Kill();
		this->connecter = nullptr;
	}

	return NETWORK_RECV_STATUS_OKAY;
}

ClientNetworkStunSocketHandler::~ClientNetworkStunSocketHandler()
{
	if (this->connecter != nullptr) {
		this->connecter->Kill();
		this->connecter = nullptr;
	}
}

/**
 * Check whether we received/can send some data from/to the STUN server and
 * when that's the case handle it appropriately.
 */
void ClientNetworkStunSocketHandler::SendReceive()
{
	if (this->sock == INVALID_SOCKET) return;

	/* We never attempt to receive anything on a STUN socket. After
	 * connecting a STUN connection, the local address will be reused to
	 * to establish the connection with the real server. If we would be to
	 * read this socket, some OSes get confused and deliver us packets meant
	 * for the real connection. It appears most OSes play best when we simply
	 * never attempt to read it to start with (and the packets will remain
	 * available on the other socket).
	 * Protocol-wise, the STUN server will never send any packet back anyway. */

	this->CanSendReceive();
	if (this->SendPackets() == SPS_ALL_SENT && !this->sent_result) {
		/* We delay giving the GC the result this long, as to make sure we
		 * have sent the STUN packet first. This means the GC is more likely
		 * to have the result ready by the time our StunResult() packet
		 * arrives. */
		this->sent_result = true;
		_network_coordinator_client.StunResult(this->token, this->family, true);
	}
}
