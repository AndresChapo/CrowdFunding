var CrowdFundingWithDeadline = artifacts.require
("./CrowdFundingWithDeadline.sol");

module.exports = function(deployer) {
    deployer.deploy(
        CrowdFundingWithDeadline,
        "Test campaingn 1",
        1,
        200,
        "0x9504B5037b7c73614b135978cE8bBaAB0293895A"
    )
};
