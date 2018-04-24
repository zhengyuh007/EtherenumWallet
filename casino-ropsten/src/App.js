import React from 'react'
import ReactDOM from 'react-dom'
import Web3 from 'web3'
import './main.css'

class App extends React.Component {
   constructor(props){
       super(props)
       this.state = {
           lastWinner: 0,
           numberOfBets: 0,
           minimumBet: 0,
           totalBet: 0,
           maxAmountOfBets: 0
        }
        console.log(typeof Web3)
        console.log(typeof web3)
        if(typeof web3 !== 'undefined'){
            console.log("Using web3 detected from external source like Metamask")
            this.web3 = new Web3(web3.currentProvider)
        }
        else{
            console.log("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
            this.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))
        }
        // add ABI and contract address
        const MyContract = web3.eth.contract([{"constant":false,"inputs":[{"name":"numberSelected","type":"uint256"}],"name":"bet","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"_newVal","type":"uint256"}],"name":"changeMaxAmountOfBets","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_minimumBet","type":"uint256"}],"name":"changeMinimumBet","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"newRunTime","type":"uint256"},{"name":"newHashNum","type":"uint256"}],"name":"changeRNG","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"winNumber","type":"uint256"}],"name":"distributePrizes","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"generateNumberWinner","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"constant":true,"inputs":[{"name":"player","type":"address"}],"name":"checkPlayerExists","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"lastWinNumber","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"LIMIT_AMOUNT_BETS","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"maxAmountOfBets","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"minimumBet","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"name":"numberBetPlayers","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"numberOfBets","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"playerBetsMoney","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"playerBetsNumber","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"players","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"showCasinoBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"totalBet","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}])
        this.state.ContractInstance = MyContract.at("0xeb4d9d65a6ebc02d59c8274252d05f6b5cf74b19");
        window.a = this.state;
   }
   
   componentDidMount(){
       this.updateState()
       this.setupListeners()
       
       setInterval(this.updateState.bind(this), 7e3)
    }

    // update state shown on the website
    updateState(){
        this.state.ContractInstance.lastWinNumber((err, result) => {
            if(result != null){
               this.setState({
                  lastWinner: parseInt(result)
               })
            }
         })
        this.state.ContractInstance.minimumBet((err, result) => {
           if(result != null){
              this.setState({
                 minimumBet: parseFloat(web3.fromWei(result, 'ether'))
              })
           }
        })
        this.state.ContractInstance.totalBet((err, result) => {
           if(result != null){
              this.setState({
                 totalBet: parseFloat(web3.fromWei(result, 'ether'))
              })
           }
        })
        this.state.ContractInstance.numberOfBets((err, result) => {
           if(result != null){
              this.setState({
                 numberOfBets: parseInt(result)
              })
           }
        })
        this.state.ContractInstance.maxAmountOfBets((err, result) => {
           if(result != null){
              this.setState({
                 maxAmountOfBets: parseInt(result)
              })
           }
        })
    }

    // Listen for events and executes the voteNumber method
    setupListeners(){
        let liNodes = this.refs.numbers.querySelectorAll('li')
        liNodes.forEach(number => {
            number.addEventListener('click', event => {
                event.target.className = 'number-selected'
                this.voteNumber(parseInt(event.target.innerHTML), done => {
                    // Remove the other number selected
                    for(let i = 0; i < liNodes.length; i++){
                        liNodes[i].className = ''
                    }
                })
            })
        })
    }

   
   voteNumber(number, cb){
       console.log(number)
       let bet = this.refs['ether-bet'].value
       if(!bet) bet = 0.1
       if(parseFloat(bet) < this.state.minimumBet) {
           alert('You must bet more than minimum!')
           cb()
       }
       else {
           this.state.ContractInstance.bet(number, {
               gas: 300000,
               from: web3.eth.accounts[0],
               value: web3.toWei(bet, 'ether')
           }, (err, result) => {
               cb()
           })
       }
    }
    
    render(){
        return ( 
        <div className="main-container">
            <h1>Bet for your best number and win/lose huge amounts of Ether</h1>

            <div className="block">
               <b>Number of bets:</b> &nbsp;
               <span> {this.state.numberOfBets}</span>
            </div>
            
            <div className="block">
                <b>Last number winner:</b> &nbsp;
                <span>{this.state.lastWinner}</span>
            </div>

            <div className="block">
                <b>Total ether bet:</b> &nbsp;
                <span>{this.state.totalBet} ether</span>
            </div>

            <div className="block">
                <b>Minimum bet:</b> &nbsp;
                <span>{this.state.minimumBet} ether</span>
            </div>

            <div className="block">
                <b>Minimum Number Player:</b> &nbsp;
                <span>{this.state.maxAmountOfBets} </span>
            </div>

            <hr/>
            
            <h2>Vote for the next number</h2>

            <label>
                <b>How much Ether do you want to bet? <input className="bet-input" ref="ether-bet" type="number" placeholder={this.state.minimumBet}/></b> ether
                <br/>
            </label>

            <ul ref="numbers">
               <li>1</li>
               <li>2</li>
               <li>3</li>
               <li>4</li>
               <li>5</li>
               <li>6</li>
               <li>7</li>
               <li>8</li>
               <li>9</li>
               <li>10</li>
            </ul>

            <hr/>

            <div><i>Only working with the Ropsten Test Network</i></div>
            <div><i>You can only vote once per account</i></div>
            <div><i>Your vote will be reflected when the next block is mined</i></div>
            <div>Copy Right: Harry He </div>

        </div>
      )
   }
}

ReactDOM.render(
   <App />,
   document.querySelector('#root')
)

/*
import React from "react";
import ReactDOM from "react-dom";

const App = () => {
  return (
    <div>
        <h1> U will make it one day! </h1>
        <p>React here!</p>
        <h2> And that day will not be far away </h2>
    </div>
  );
};
export default App;
ReactDOM.render(<App />, document.getElementById("app"));
*/