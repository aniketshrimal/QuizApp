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
		await contractInstance.registerPlayers({from: accounts[2],value: web3.toWei(0.00000000000000001,'ether')});
		await contractInstance.registerPlayers({from: accounts[3],value: web3.toWei(0.00000000000000001,'ether')});
		await contractInstance.registerPlayers({from: accounts[4],value: web3.toWei(0.00000000000000001,'ether')});
		
		var newcnt = await contractInstance.getPlayerCount();
		console.log(newcnt.c[0]);
		assert.equal(prevcnt.c[0] + 4, newcnt.c[0], 'player is not registered');
	})

	it('Check if questions are added', async() =>{
		await contractInstance.addQuestions("What is the protocol used in Bitcoin?","Longest chain protocol",{from: accounts[0]});
		await contractInstance.addQuestions("What is P2P?","Peer to Peer",{from: accounts[0]});
		await contractInstance.addQuestions("Who created Bitcoin?","Satoshi",{from: accounts[0]});
		await contractInstance.addQuestions("What is the limit on number of Bitcoins?","21 million",{from: accounts[0]});
		
		var a = await contractInstance.getQuestion();
		var b = await contractInstance.getAnswer();
		console.log(a);
		console.log(b);
		assert.equal("a","a",'not equal');
		assert.equal("b","b",'not equal');
	})

	it('Check answer is submitted or not', async() =>{
		await contractInstance.startQuiz({from:accounts[1]});
		await contractInstance.endQuiz("b","b","b","b",{from:accounts[1]});
		var p = await contractInstance.getAnswer1({from:accounts[1]});
		await contractInstance.endQuiz("b","b","Satoshi","b",{from:accounts[2]});
		await contractInstance.endQuiz("b","b","Satoshi","b",{from:accounts[3]});


		console.log(p);
		assert.equal("b",p,"not equal");
	})

	it('Check winning amount',async() => {
		var p = await contractInstance.getPayment({from:accounts[2]});
		await contractInstance.declareWinner({from : accounts[0]});
		var q =  await contractInstance.getPayment({from:accounts[2]})
		console.log(p.c[0],q.c[0]);
		assert.equal(1,1,"");

	})
	

})