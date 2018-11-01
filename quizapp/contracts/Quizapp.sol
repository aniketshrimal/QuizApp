pragma solidity ^0.4.24;

contract Quizapp{
    address public owner;
    uint joinTime;
    uint endTime;
    uint N; //max number of players
    uint currNoPlayers; //registered players <= N
    uint public pFee;
    uint num_questions;
    uint total;
    
    struct Player{
        string answer1;
        string answer2;
        string answer3;
        string answer4;
        address Account;
        uint pendingAmount;
        uint Timestamp;
    }
    struct Participant{
        address account;
    }

    /* For now any number of participants are allowed*/
    Participant[] public participants;

    mapping(uint => Question) questions;
    // mapping(address => Player) allPlayers;
    mapping(address => bool) public isValid;
    mapping(uint => address) PlayerList;
    mapping(address => uint) pendingReturns;
    mapping(address => string) answer1;
    mapping(address => string) answer2;
    mapping(address => string) answer3;
    mapping(address => string) answer4;

    event PaymentDetails(uint sender);
    
    struct Question{
        string ques;
        string ans;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner is allowed to call this method.");
        _;
    }
    constructor(uint _N, uint _startTime, uint _timeLimit, uint _pfee) public {
        require(_pfee >=0 && _N >0 && _timeLimit > 0, "invalid arguments!! please rectify" );
        
        N = _N;
        owner = msg.sender;
        joinTime = now + _startTime;
        endTime = joinTime + _timeLimit;
        pFee = _pfee;
        total=4;
        num_questions=1;
        currNoPlayers=0;
    }
    event print(string s);

    function getPlayerCount() public view returns(uint a){
        return currNoPlayers;
    }
    function getQuestion() public view returns(string a){
        return questions[num_questions-1].ques;
    }
    function getAnswer() public view returns(string a){
        return questions[num_questions-1].ans;
    }
    function getQuestionNumber() public view returns(uint a){
        return num_questions-1;
    }

    function getAnswer1() public view returns(string u)
    {
        return answer1[msg.sender];
    }
    function getAnswer2() public view returns(string u)
    {
        return answer2[msg.sender];
    }
    function getAnswer3() public view returns(string u)
    {
        return answer3[msg.sender];
    }
    function getAnswer4() public view returns(string u)
    {
        return answer4[msg.sender];
    }
    function getPayment() public view returns(uint a)
    {
        return pendingReturns[msg.sender];
    }
    function getParticipationFee() public view returns(uint a)
    {
        return pFee;
    }
    function getContractBalance() public view returns (uint a)
    {
        return address(this).balance;
    }
    function addQuestions(string _q1, string _a1) public
    onlyOwner() {
        require(now < joinTime,"you are late !!");
        require(num_questions<=total,"No more questions can be added");
        questions[num_questions].ques = _q1;
        questions[num_questions].ans = _a1;
        num_questions++;   
    }

    function registerPlayers() public payable {
        require(isValid[msg.sender] == false,"Already registered!!!");
        require(now < joinTime,"You are late!!");
        require(msg.sender != owner, "You already know the answers! ");
        require(currNoPlayers <N,"Limit exceeded");
        require(msg.value >= pFee, "please pay atleast the participation fee to proceed");        
        isValid[msg.sender] = true;
        participants.push(Participant({account:msg.sender}));
        pendingReturns[msg.sender] = msg.value - pFee; 
        PlayerList[currNoPlayers]=msg.sender; 
        currNoPlayers+=1;        
    }
    
    function startQuiz() public returns(string, string, string, string) {
        require(now>joinTime && now < endTime,"Time Out!");
        require(currNoPlayers>0,"Waiting for players to join");
        require(isValid[msg.sender] == true,"Please register to start quiz!!!");
        return(questions[1].ques,questions[2].ques,questions[3].ques,questions[4].ques);
    }
    function endQuiz(string _a1,string _a2,string _a3,string _a4) public returns(string) {
        require(now < endTime, "Times up!!!!!");
        require(now > joinTime, "Quiz hasnt started yet");
        require(isValid[msg.sender] == true, "You cant access Quiz!!!");
        answer1[msg.sender]=_a1;
        answer2[msg.sender]=_a2;
        answer3[msg.sender]=_a3;
        answer4[msg.sender]=_a4;
        return "Thanks for participating!";
    }
    function compareStrings (string a, string b) view returns (bool){
       return keccak256(a) == keccak256(b);
       }

    function declareWinner()
    public

    onlyOwner(){
        require(now>endTime,"Quiz has not ended!!");
        uint count1=0;
        uint count2=0;
        uint count3=0;
        uint count4=0;
        for(uint i=0; i<currNoPlayers;i++)
        {
            if(compareStrings(answer1[PlayerList[i]],questions[1].ans)== true)
            {
                count1++;
            }
            if(compareStrings(answer2[PlayerList[i]],questions[2].ans)==true)
            {
                count2++;
            }
            if(compareStrings(answer3[PlayerList[i]],questions[3].ans)==true)
            {
                count3++;
            }
            if(compareStrings(answer1[PlayerList[i]],questions[1].ans)==true)
            {
                count4++;
            }
        }
        uint prize1=0;
        uint prize2=0;
        uint prize3=0;
        uint prize4=0;
        
        if(count1>0)
            prize1 = (3*pFee*currNoPlayers)/(count1*16);
        if(count2>0)
            prize2 = (3*pFee*currNoPlayers)/(count2*16);
        if(count3>0)
            prize3 = (3*pFee*currNoPlayers)/(count3*16);
        if(count4>0)
            prize4 = (3*pFee*currNoPlayers)/(count4*16);
        

        for(i=0; i<currNoPlayers;i++)
        {
            if(compareStrings(answer1[PlayerList[i]],questions[1].ans)==true)
            {
                pendingReturns[PlayerList[i]]+=prize1;
            }
            if(compareStrings(answer2[PlayerList[i]],questions[2].ans)==true)
            {
                pendingReturns[PlayerList[i]]+=prize2;
            }
            if(compareStrings(answer3[PlayerList[i]],questions[3].ans)==true)
            {
                pendingReturns[PlayerList[i]]+=prize3;
            }
            if(compareStrings(answer4[PlayerList[i]],questions[4].ans)==true)
            {
                pendingReturns[PlayerList[i]]+=prize4;
            }
        }  
        for(i=0; i<currNoPlayers; i++)
        {
            uint Balance = pendingReturns[PlayerList[i]];
            emit PaymentDetails(Balance);
        }  

   }

   function withdraw() 
   public
   payable
   {
        require(now>endTime,"Quiz is not ended!!");
        require(pendingReturns[msg.sender]>0,"No pending returns");
        uint Balance = pendingReturns[msg.sender];       
        (msg.sender).transfer(Balance);
        pendingReturns[msg.sender]=0;
   
   }

    
}

