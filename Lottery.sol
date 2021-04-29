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
    mapping(uint => Lottery.Ticket) tickets;

    function _initialize(uint256 ownerKey, uint256 finishDate, uint128 ticketCost, uint8 percent) public{
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

    function buyTicket(address payable t_owner) public payable{
        uint tId = l_numTickets++;
        tickets[tId] = Ticket(t_owner);
    }

    function chooseWinner() public view returns (uint256 winnerAddress) {
        l_status = 1;
        uint randomNum = random();
        Ticket t_winner = tickets.fetch(randomNum);
        address payable dest = t_winner.t_owner;
        address payable m_owner = address(l_ownerKey);
        tvm.accept();
        uint256 prize = ((l_numTickets *  l_ticketCost) / 100) * l_percent;
        dest.transfer(uint128(prize) , true, 0);
        uint256 remainsMoney = (l_numTickets * l_ticketCost) - prize;
        m_owner.transfer(uint128(remainsMoney), true, 0);
    }

    function getNumOfSoldTickets() public view returns (uint256 numOfSoldTickets){
        numOfSoldTickets = l_numTickets;
    }

    function random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, now)));
    }

    function getTicket(uint64 tId) public view returns (Ticket ticket){
        Ticket tf = tickets.fetch(tId);
        ticket = tf;
    }
}
