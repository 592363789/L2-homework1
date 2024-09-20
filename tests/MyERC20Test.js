const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyERC20", function () {
  let MyERC20, myERC20, owner, addr1, addr2;

  beforeEach(async function () {
    // 部署合约
    MyERC20 = await ethers.getContractFactory("MyERC20");
    [owner, addr1, addr2] = await ethers.getSigners();
    myERC20 = await MyERC20.deploy("My Token", "MTK");
    await myERC20.deployTransaction.wait(); // 使用 deployTransaction.wait()
  });

  describe("Deployment", function () {
    it("Should set the correct owner", async function () {
      expect(await myERC20.getOwner()).to.equal(await owner.getAddress());
    });

    it("Should have the correct name and symbol", async function () {
      expect(await myERC20.getName()).to.equal("My Token");
      expect(await myERC20.getSymbol()).to.equal("MTK");
    });
  });

  describe("Minting and Burning", function () {
    it("Owner can mint tokens", async function () {
      await myERC20.mint(await addr1.getAddress(), 1000);
      expect(await myERC20.getBalance(await addr1.getAddress())).to.equal(1000);
    });

    it("Non-owner cannot mint tokens", async function () {
      await expect(myERC20.connect(addr1).mint(await addr1.getAddress(), 1000)).to.be.revertedWith("onlyOwner!");
    });

    it("Owner can burn tokens", async function () {
      await myERC20.mint(await addr1.getAddress(), 1000);
      await myERC20.burn(await addr1.getAddress(), 500);
      expect(await myERC20.getBalance(await addr1.getAddress())).to.equal(500);
    });

    it("Cannot burn more than available balance", async function () {
      await myERC20.mint(await addr1.getAddress(), 1000);
      await expect(myERC20.burn(await addr1.getAddress(), 2000)).to.be.revertedWith("do not have enough balance");
    });
  });

  describe("Transfers", function () {
    it("Should transfer tokens between accounts", async function () {
      await myERC20.mint(await addr1.getAddress(), 1000);
      await myERC20.connect(addr1).transferTo(await addr2.getAddress(), 500);
      expect(await myERC20.getBalance(await addr1.getAddress())).to.equal(500);
      expect(await myERC20.getBalance(await addr2.getAddress())).to.equal(500);
    });

    it("Cannot transfer more than available balance", async function () {
      await myERC20.mint(await addr1.getAddress(), 1000);
      await expect(myERC20.connect(addr1).transferTo(await addr2.getAddress(), 2000)).to.be.revertedWith("do not have enough balance");
    });

    it("Should allow approved transfers by third-party", async function () {
      await myERC20.mint(await addr1.getAddress(), 1000);
      await myERC20.connect(addr1).approve(await addr2.getAddress(), 500);
      await myERC20.connect(addr2).transferFromTo(await addr1.getAddress(), await addr2.getAddress(), 500);
      expect(await myERC20.getBalance(await addr1.getAddress())).to.equal(500);
      expect(await myERC20.getBalance(await addr2.getAddress())).to.equal(500);
    });

    it("Cannot transfer more than approved allowance", async function () {
      await myERC20.mint(await addr1.getAddress(), 1000);
      await myERC20.connect(addr1).approve(await addr2.getAddress(), 500);
      await expect(myERC20.connect(addr2).transferFromTo(await addr1.getAddress(), await addr2.getAddress(), 1000)).to.be.revertedWith("not enough allowance");
    });
  });
});
