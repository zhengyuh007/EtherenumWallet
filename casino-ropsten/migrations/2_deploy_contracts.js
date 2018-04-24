var Casino = artifacts.require("./Casino.sol");

module.exports = function(deployer) {
    deployer.deploy(Casino, {gas: 3000000});
}



