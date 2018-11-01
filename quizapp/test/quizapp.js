const Quizapp = artifacts.require('./Quizapp.sol');
const assert = require('assert');


let contractInstance


contract('Quizapp', (accounts)=>{

	beforeEach(async () => {
		contractInstance = await Quizapp.deployed()
	})

	it('Check if player is getting registered', async() => {     
		var prevcnt = await contractInstance.getPlayerCount();
		await contractInstance.registerPlayers({from: accounts[1],value: web3.toWei(0.00000000000000001,'ether')});
		
		var newcnt = await contractInstance.getPlayerCount();
		// console.log(newcnt.c[0]);
		assert.equal(prevcnt.c[0] + 1, newcnt.c[0], 'player is not registered');
	})
	it('Check for participation fee', async() => {     
		var prevcnt = await contractInstance.getPlayerCount();
		try{
			await contractInstance.registerPlayers({from: accounts[2],value: web3.toWei(0.000000000000000001,'ether')});
		}
		catch(err){
			console.log(err.message);
		}
		var newcnt = await contractInstance.getPlayerCount();
		// console.log(newcnt.c[0]);
		assert.equal(prevcnt.c[0], newcnt.c[0], 'player is getting registered by paying less');
	})

	it('Check if participation fee is transferred or not',async()=>{
		var prevamount = await contractInstance.getContractBalance();
		await contractInstance.registerPlayers({from: accounts[2],value: web3.toWei(0.00000000000000001,'ether')});
		
		var newamount = await contractInstance.getContractBalance();
		
		var par_fee = await contractInstance.getParticipationFee();
		// console.log(parseInt(prevamount.c[0])+parseInt(par_fee),parseInt(newamount.c[0]));
		assert.equal(parseInt(prevamount.c[0])+parseInt(par_fee),parseInt(newamount.c[0]),"Not getting transferred");

		
	})

	
	it('Check if already registered', async() => {     
		var prevcnt = await contractInstance.getPlayerCount();
		try{
		await contractInstance.registerPlayers({from: accounts[1],value: web3.toWei(0.00000000000000001,'ether')});
		}
		catch(err){
			console.log(err.message);
		}
		var newcnt = await contractInstance.getPlayerCount();
		// console.log(newcnt.c[0]);
		assert.equal(prevcnt.c[0], newcnt.c[0], 'player registered twice');
	})

	it('Check if owner is getting registered', async() => {     
		var prevcnt = await contractInstance.getPlayerCount();
		try{
		await contractInstance.registerPlayers({from: accounts[0],value: web3.toWei(0.00000000000000001,'ether')});
		}
		catch(err){
			console.log(err.message)
		}
		var newcnt = await contractInstance.getPlayerCount();
		// console.log(newcnt.c[0]);
		assert.equal(prevcnt.c[0], newcnt.c[0], 'moderator was able to register');
	})
	it('registering maximum players', async() => {     
		var prevcnt = await contractInstance.getPlayerCount();
		await contractInstance.registerPlayers({from: accounts[3],value: web3.toWei(0.00000000000000001,'ether')});
		await contractInstance.registerPlayers({from: accounts[4],value: web3.toWei(0.00000000000000001,'ether')});
		
		var newcnt = await contractInstance.getPlayerCount();
		// console.log(newcnt.c[0]);
		assert.equal(prevcnt.c[0] + 2, newcnt.c[0], 'players are not registered');
	})

	it('Check if total registered players exceeds maximum allowed players', async() => {     
		var prevcnt = await contractInstance.getPlayerCount();
		try{
		await contractInstance.registerPlayers({from: accounts[5],value: web3.toWei(0.00000000000000001,'ether')});
		}
		catch(err){
			console.log(err.message);
		}
		var newcnt = await contractInstance.getPlayerCount();
		// console.log(newcnt.c[0]);
		assert.equal(prevcnt.c[0], newcnt.c[0], 'Number of players exceeds maximum allowed players');
	})


	
	it('Check if questions are added', async() =>{
		await contractInstance.addQuestions("What is the protocol used in Bitcoin?","Longest chain protocol",{from: accounts[0]});
		var a = await contractInstance.getQuestion();
		var b = await contractInstance.getAnswer();
		assert.equal(a,"What is the protocol used in Bitcoin?","Not equal");
		assert.equal(b,"Longest chain protocol","Not equal");
		await contractInstance.addQuestions("What is P2P?","Peer to Peer",{from: accounts[0]});
		var a = await contractInstance.getQuestion();
		var b = await contractInstance.getAnswer();
		assert.equal(a,"What is P2P?","Not equal");
		assert.equal(b,"Peer to Peer","Not equal");

		await contractInstance.addQuestions("Who created Bitcoin?","Satoshi",{from: accounts[0]});
		var a = await contractInstance.getQuestion();
		var b = await contractInstance.getAnswer();
		assert.equal(a,"Who created Bitcoin?","Not equal");
		assert.equal(b,"Satoshi","Not equal");

		await contractInstance.addQuestions("What is the limit on number of Bitcoins?","21 million",{from: accounts[0]});
		
		var a = await contractInstance.getQuestion();
		var b = await contractInstance.getAnswer();
		assert.equal(a,"What is the limit on number of Bitcoins?","Not equal");
		assert.equal(b,"21 million","Not equal");

	})

	it('Check if more than 4 questions can be added', async() =>{
		var prevcnt = await contractInstance.getQuestionNumber();
		try{
			await contractInstance.addQuestions("What is the protocol used in Bitcoin?","Longest chain protocol",{from: accounts[0]});
		}
		catch(err){
			console.log(err.message);
		}
		var newcnt = await contractInstance.getQuestionNumber();
		assert.equal(prevcnt.c[0],newcnt.c[0],"Able to add more than 4 questions");		
		
	})


	it('registering player after deadline', async() => {     
		var prevcnt = await contractInstance.getPlayerCount();
		function timepass(){
			for(i=0;i<2000000000;i++);
			
		}
		await timepass();
		try{
			await contractInstance.registerPlayers({from: accounts[5],value: web3.toWei(0.00000000000000001,'ether')});
			var newcnt = await contractInstance.getPlayerCount();
			// console.log(newcnt.c[0]);
			assert.equal(prevcnt.c[0] , newcnt.c[0], 'player is getting registered after deadline');
		}
		catch(err){
			console.log(err.message);
		}

		
	})

	it('Check if questions can be added after deadline', async() =>{
		var prevcnt = await contractInstance.getQuestionNumber();
		try{
			await contractInstance.addQuestions("What is the protocol used in Bitcoin?","Longest chain protocol",{from: accounts[0]});
			var newcnt = await contractInstance.getQuestionNumber();
			assert.equal(prevcnt.c[0],newcnt.c[0],"Able to add  questions after deadline");		

		}
		catch(err){
			console.log(err.message);
		}
		
	})

	it('Check answer is submitted or not', async() =>{
		await contractInstance.startQuiz({from:accounts[1]});
		await contractInstance.endQuiz("Longest chain protocol","Peer to Peer","don't know","don't know",{from:accounts[1]});
		var p = await contractInstance.getAnswer1({from:accounts[1]});
		var q = await contractInstance.getAnswer2({from:accounts[1]});
		var r = await contractInstance.getAnswer3({from:accounts[1]});
		var s = await contractInstance.getAnswer4({from:accounts[1]});
		
		assert.equal("Longest chain protocol",p,"not equal");
		assert.equal("Peer to Peer",q,"not equal");
		assert.equal("don't know",r,"not equal");
		assert.equal("don't know",s,"not equal");
			
	})

	it('Check answer is submitted or not for other users', async() =>{
		await contractInstance.endQuiz("don't know","Peer to Peer","Satoshi","don't know",{from:accounts[2]});
		await contractInstance.endQuiz("don't know","don't know","don't know","21 million",{from:accounts[3]});
		await contractInstance.endQuiz("don't know","don't know","don't know","don't know",{from:accounts[4]});
		
		var p = await contractInstance.getAnswer1({from:accounts[4]});
		var q = await contractInstance.getAnswer2({from:accounts[4]});
		var r = await contractInstance.getAnswer3({from:accounts[4]});
		var s = await contractInstance.getAnswer4({from:accounts[4]});
		
		assert.equal("don't know",p,"not equal");
		assert.equal("don't know",q,"not equal");
		assert.equal("don't know",r,"not equal");
		assert.equal("don't know",s,"not equal");
	})

	it('Check if winning amount can be declared by other than owner',async() => {
		
		try{
			await contractInstance.declareWinner({from : accounts[1]});
			assert.equal(1,2,"user is able to declare winnings");
			
		}
		catch(err){
			console.log(err.message);
		}
		
	})

	it('Check if winning amount can be declared before quiz ends',async() => {
		
		try{
			await contractInstance.declareWinner({from : accounts[0]});
			assert.equal(1,2,"user is able to declare winnings before quiz ends");
			
		}
		catch(err){
			console.log(err.message);
		}
		
	})

	it('Check winning amount',async() => {
		function timepass(){
			for(i=0;i<3000000000;i++);
			
		}
		await timepass();
		
		var p = await contractInstance.getPayment({from:accounts[1]});
		var q = await contractInstance.getPayment({from:accounts[2]});
		var r = await contractInstance.getPayment({from:accounts[3]});
		var s = await contractInstance.getPayment({from:accounts[4]});
		
		await contractInstance.declareWinner({from : accounts[0]});
		var a = await contractInstance.getPayment({from:accounts[1]});
		var b = await contractInstance.getPayment({from:accounts[2]});
		var c = await contractInstance.getPayment({from:accounts[3]});
		var d = await contractInstance.getPayment({from:accounts[4]});
		
		console.log(p.c[0],a.c[0]);
		console.log(q.c[0],b.c[0]);
		console.log(r.c[0],c.c[0]);
		console.log(s.c[0],d.c[0]);
		
		assert.equal(10,a.c[0]-p.c[0],"payments are not correct");
		assert.equal(10,b.c[0]-q.c[0],"payments are not correct");
		assert.equal(7,c.c[0]-r.c[0],"payments are not correct");
		assert.equal(0,d.c[0]-s.c[0],"payments are not correct");

	})
	

})