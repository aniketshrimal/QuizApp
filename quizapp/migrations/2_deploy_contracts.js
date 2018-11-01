var Quizapp = artifacts.require("./Quizapp.sol");

module.exports = function(deployer) {
  deployer.deploy(Quizapp,5,10,20,5);
};
