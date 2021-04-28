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


    uint256 l_ownerKey;
    uint256 l_finishDate;
    uint128 l_ticketCost;
    uint8 l_status;
    uint8 l_percent;

    uint l_numTickets;
    mapping(uint => Ticket) tickets;

    function _initialize(uint256 ownerKey, uint256 finishDate, uint128 ticketCost, uint8 percent){
        l_ownerKey = ownerKey;
        l_finishDate = finishDate;
        l_ticketCost = ticketCost;
        l_status = 0;
        l_numTickets = 0;
        l_percent = percent;
        
    }

    constructor(uint256 ownerKey, uint256 finishDate, uint128 ticketCost, uint8 percent) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        timestamp = now;
        _initialize(ownerKey, finishDate, ticketCost, percent);
    }

    function buyTicket(adress payable t_owner) public {
        uint tId = l_numTickets++;
        tickets[tId] = Ticket(t_owner);
    }

    function chooseWinner() public returns (uint256 winnerAddress) {
        uint num = 10;
        Ticket t_winner = tickets.fetch(num);
        address payable dest = t_winner.t_owner;
        address payable m_owner = adress(l_ownerKey);
        tvm.accept();
        uint prize = ((l_numTickets *  l_ticketCost) / 100) * l_percent;
        dest.transfer(prize , true, 0);
        m_owner.transfer((l_numTickets * l_ticketCost) - prize, true, 0);
    }

    function getNumOfSoldTickets() public returns (uint256 numOfSoldTickets){
        numOfSoldTickets = l_numTickets;
    }

    function getTicket(uint64 tId) public view returns (Ticket ticket){
        (bool exists, Ticket tf) = tickets.fetch(tId);
        require(exists, 102);
        ticket = tf;
    }   

}
