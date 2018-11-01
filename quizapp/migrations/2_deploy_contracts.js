var Quizapp = artifacts.require("./Quizapp.sol");

module.exports = function(deployer) {
  deployer.deploy(Quizapp,4,5,7,10);
};
