pragma solidity ^0.4.23;

contract QuizApp {
    string question1;
    string answer1;
    string question2;
    string answer2;
    string question3;
    string answer3;
    string question4;
    string answer4;
    address public owner;
    uint joinTime;
    uint endTime;
    uint N; //max number of players
    uint currNoPlayers; //registered players <= N
    uint public pFee;
    struct Player{
        string answer1;
        string answer2;
        string answer3;
        string answer4;
        address Account;
        uint pendingAmount;
        uint Timestamp;
    }
    mapping(address => Player) allPlayers;
    mapping(address => bool) public isValid;
    mapping(uint => address) PlayerList;
    
    event PaymentDetails(uint sender);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner is allowed to call this method.");
        _;
    }
    constructor(uint _N, uint _startTime, uint _timeLimit, uint _pfee) public payable {
        require(_pfee >=0 && _N >0 && _timeLimit > 0, "invalid arguments!! please rectify" );
        
        N = _N;
        owner = msg.sender;
        joinTime = now + _startTime;
        endTime = joinTime + _timeLimit;
        pFee = _pfee;
        //prepare questions 
        // question1 = "What is the protocol used in Bitcoin?";
        // answer1 = "Longest chain protocol";
        // question2 = "What is P2P?";
        // answer2 = "Peer to Peer";
        // question3 = "Who created Bitcoin?";
        // answer3 = "Satoshi";
        // question4 = "What is the limit on number of Bitcoins?";
        // answer4 = "21 million";
    }
    event print(string s);
    function addQuestions(string _q1, string _q2, string _q3, string _q4, string _a1, string _a2, string _a3, string _a4) public
    onlyOwner() {
        question1 = _q1;
        question2 = _q2;
        question3 = _q3;
        question4 = _q4;
        answer1 = _a1;
        answer2 = _a2;
        answer3 = _a3;
        answer4 = _a4;
        
        emit print(question1);
        emit print(question2);
    }
    function registerPlayers() payable {
        require(isValid[msg.sender] == false,"Already registered!!!");
        require(now < joinTime,"You are late!!");
        require(msg.sender != owner, "You already know the answers! ");
        require(currNoPlayers <= N,"Limit exceeded");
        require(msg.value >= pFee, "please pay atleast the participation fee to proceed");
        currNoPlayers++;
        Player currPlayer;
        currPlayer.Account = msg.sender;
        currPlayer.pendingAmount = msg.value-pFee;
        allPlayers[msg.sender] = currPlayer;
        isValid[msg.sender] = true;
        PlayerList[currNoPlayers] = msg.sender;
    }
    
    function startQuiz() public returns(string, string, string, string) {
        require(now>joinTime && now < endTime,"Time Out!");
        require(currNoPlayers>0,"Waiting for players to join");
        require(isValid[msg.sender] == true,"Please register to start quiz!!!");
        return(question1,question2,question3,question4);
    }
    function endQuiz(string a1,string a2,string a3,string a4) public returns(string) {
        require(now < endTime, "Times up!!!!!");
        require(now > joinTime, "Quiz hasnt started yet");
        require(isValid[msg.sender] == true, "You cant access Quiz!!!");
        isValid[msg.sender] = false;
        allPlayers[msg.sender].Timestamp = now;
        allPlayers[msg.sender].answer1 = a1;
        allPlayers[msg.sender].answer2 = a2;
        allPlayers[msg.sender].answer3 = a3;
        allPlayers[msg.sender].answer4 = a4;
        return "Thanks for participating!";
    }
    
    function declareWinner() payable public {
        require(msg.sender == owner, "You are not allowed to declare Winner");
        address winner = owner;
        uint _winnerTime = endTime;
        uint prize = 0;
        for(uint i=1; i<=currNoPlayers; i++)
        {
            if(keccak256(allPlayers[PlayerList[i]].answer1) == keccak256(answer1) && _winnerTime > allPlayers[PlayerList[i]].Timestamp)
            {
                _winnerTime = allPlayers[PlayerList[i]].Timestamp;
                winner = PlayerList[i];
            }
        }
        if(winner != owner)
        {
            prize = (3*pFee*currNoPlayers)/16;
            allPlayers[winner].pendingAmount += prize;
        }
        winner = owner;
        _winnerTime = endTime;
        prize = 0;
        //question 2
        for(i=1; i<=currNoPlayers; i++)
        {
            if(keccak256(allPlayers[PlayerList[i]].answer2) == keccak256(answer2) && _winnerTime > allPlayers[PlayerList[i]].Timestamp)
            {
                _winnerTime = allPlayers[PlayerList[i]].Timestamp;
                winner = PlayerList[i];
            }
        }
        if(winner != owner)
        {
            prize = (3*pFee*currNoPlayers)/16;
            allPlayers[winner].pendingAmount += prize;
        }
        
        winner = owner;
        _winnerTime = endTime;
        prize = 0;
        for(i=1; i<=currNoPlayers; i++)
        {
            if(keccak256(allPlayers[PlayerList[i]].answer3) == keccak256(answer3) && _winnerTime > allPlayers[PlayerList[i]].Timestamp)
            {
                _winnerTime = allPlayers[PlayerList[i]].Timestamp;
                winner = PlayerList[i];
            }
        }
        if(winner != owner)
        {
            prize = (3*pFee*currNoPlayers)/16;
            allPlayers[winner].pendingAmount += prize;
        }
        
        winner = owner;
        _winnerTime = endTime;
        prize = 0;
        for(i=1; i<=currNoPlayers; i++)
        {
            if(keccak256(allPlayers[PlayerList[i]].answer4) == keccak256(answer4) && _winnerTime > allPlayers[PlayerList[i]].Timestamp)
            {
                _winnerTime = allPlayers[PlayerList[i]].Timestamp;
                winner = PlayerList[i];
            }
        }
        if(winner != owner)
        {
            prize = (3*pFee*currNoPlayers)/16;
            allPlayers[winner].pendingAmount += prize;
        }
        
        for(i=1; i<=currNoPlayers; i++)
        {
            uint Balance = allPlayers[PlayerList[i]].pendingAmount;
            emit PaymentDetails(Balance);
            if(Balance > 0)
            {
                allPlayers[PlayerList[i]].pendingAmount = 0;
                // allPlayers[PlayerList[i]].Account.transfer(Balance);
            }
        }
        // selfdestruct(owner);
    }
}

