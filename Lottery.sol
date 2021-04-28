pragma ton-solidity >= 0.35.0;
pragma experimental ABIEncoderV2;
pragma ignoreIntOverflow;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

contract Lottery {

    struct Ticket {
        address payable t_owner;
    }

    uint32 public timestamp;

    /*
        statuses
        -1 = not started
        0 = going
        1 = finished
    */


    uint256 m_ownerKey;
    uint256 finishDate;
    uint128 ticketCost;
    uint8 status;

    uint numTickets;
    mapping(uint => Ticket) tickets;

    constructor() public {
        // Check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and
        // message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        // The current smart contract agrees to buy some gas to finish the
        // current transaction. This actions required to process external
        // messages, which bring no value (henceno gas) with themselves.
        tvm.accept();
        timestamp = now;
    }

    function buyTicket(adress payable t_owner) public {
        uint tId = numTickets++;
        tickets[tId] = Ticket(t_owner);
    }

    function chooseWinner() public returns (uint256 winnerAddress) {
        uint num = 10;
        Ticket t_winner = tickets(num);
        address payable dest = t_winner.t_owner;
        address payable m_owner = adress(m_ownerKey);
        tvm.accept();
        dest.transfer((numTickets * ticketCost) / 50, true, 0);
        m_owner.transfer((numTickets * ticketCost) / 50, true, 0);
    }

}
