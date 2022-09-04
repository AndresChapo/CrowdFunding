
let CrowdFundingWithDeadline = artifacts.require
('./TestCrowdFundingWithDeadline')

contract('CrowdFundingWithDeadline', function(accounts){

    let contract;
    let contractCreator = accounts[0];
    let beneficiary = accounts[1];

    const ONE_ETH = 1000000000000000000;
    const ERROR_MSG = 'Returned error: VM Exception while processing transaction: revert';

    const ONGOING_STATE = '0';
    const FAILED_STATE = '1';
    const SUCCEEDED_STATE = '2';
    const PAID_OUT_STATE = '3';

    beforeEach(async function() {
        contract = await CrowdFundingWithDeadline.new(
            'funding',
            1,
            10,
            beneficiary,
            {
                from: contractCreator,
                gas: 2000000
            }
        );
    });

    it('contract is initialized', async function() {
        let campaignName = await contract.name.call();
        expect(campaignName).to.equal('funding');

        let targetAmount = await contract.targetAmount.call();
        expect(Number(targetAmount)).to.equal(ONE_ETH);

        let fundingDeadline = await contract.fundingDeadline.call();
        expect(Number(fundingDeadline)).to.equal(600);

        let actualBeneficiary = await contract.beneficiary.call();
        expect(actualBeneficiary).to.equal(beneficiary);

        let state = await contract.state.call();
        expect(String(state.words[0])).to.equal(ONGOING_STATE);
    });

    it('funds are contributed', async function() {
        await contract.contribute({
            value: ONE_ETH,
            from: contractCreator
        });

        let contributed = await contract.amounts
            .call(contractCreator);
            expect(Number(contributed)).to.equal(ONE_ETH);
        
        let totalCollected = await contract.totalCollected.call();
        console.log('PRINT');
        console.log(Number(totalCollected));
        console.log(ONE_ETH);
        console.log('----------');
        expect(Number(totalCollected)).to.equal(ONE_ETH);
    });

    it('funds are contributed', async function() {
        try {
            await contract.setCurrentTime(601);
            await contract.sendTransaction({
                value: ONE_ETH,
                from: contractCreator
            });
            expect.fail();
        } catch (error) {
            expect(error.message).to.equal(ERROR_MSG);
        }
    });

    it('crowdfunding succeded', async function() {
        await contract.contribute({
            value: ONE_ETH, 
            from: contractCreator
        });
        await contract.setCurrentTime(601);
        await contract.finishCrowdFunding();
        let state = await contract.state.call();

        expect(String(state.words[0])).to.equal(SUCCEEDED_STATE);
    });
    
    it('crowdfunding failed', async function() {
        await contract.setCurrentTime(601);
        await contract.finishCrowdFunding();
        let state = await contract.state.call();

        expect(String(state.words[0])).to.equal(FAILED_STATE);
    });

});