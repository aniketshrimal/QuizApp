pragma solidity ^0.4.24;


contract Quizapp{
	
	 /* this variable holds the address of the moderator which will organize online quiz */
    address public moderator;

    /* Time when contract is created */
    uint startTime;


    /* Time passed after initialisation of contract */
    function getcurrTime() public view returns(uint a){
        return now - startTime;
    }

    /* Till {startTime + participantDeadline} all people who want to take part in online quiz should be registered*/
    uint participantDeadline;
    
    /* to check the number of participant registering for the quiz */
    uint num_participant;

    /* to limit maximum number of participant registering for the quiz upto N people */
    uint max_participant;

    /* participation fee */
    uint participation_fee;


    /* This structure will represent each participant in the quiz */
    struct Participant{
        address account;
    }

    /* For now any number of participants are allowed*/
    Participant[] public participants;
    num_participant = 0;
    /* To check that only one participant can register from one address */
    mapping (address => uint) private is_participant;
    
    mapping(address => uint) pendingReturns;
    

    modifier onlyBefore(uint _time){
        require(now - startTime < _time, "Too Late"); _;
    }

    // ensures the call is made after certain time
    modifier onlyAfter(uint _time){
        require(now - startTime > _time, "Too early"); _;
    }

    // ensures only the moderator is calling the function
    modifier onlyModerator(){
        require(msg.sender == moderator, "Only Moderator is allowed to call this method"); _;
    }


    /* Takes max no of people participating in quiz , Time after which participant registeration will close (measured from startTime)*/
    constructor (uint _nopeople,uint _participantDeadline,uint _pfee ) public{
        participantDeadline = _participantDeadline;
        max_participant = _nopeople;
        participation_fee = _pfee;
        startTime = now;
        moderator = msg.sender;
    }


    /* A public function which will register the participant iff one has not registered before */
    function registerParticipant()
    public
    payable
    // allow registration of participants only before the participantDeadline
    onlyBefore(participantDeadline)
    {
        require(num_participant < max_participant , "Sorry, but the quiz is full" );
        require(is_participant[msg.sender] == 0, "Sorry, but you have already registered for this quiz as a participant");
        require(msg.value >= participation_fee, "Insufficient funds");
        is_participant[msg.sender] = 1;          // Add it to the map
        participants.push(Participant({account:msg.sender}));
        pendingReturns[msg.sender] = msg.value - participation_fee;  
        num_participant+=1;
    }

}