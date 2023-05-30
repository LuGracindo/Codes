
console.log('Olá, seja bem-vindo!');

function main() {
const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
});

new Promise(function(resolve){
      readline.question('Digite seu peso: ', function(peso){
        readline.question('Digite sua altura em centímetros: ', function(altura){
            altura = (altura/100);                            
            imc = peso/(altura * altura);
            if (imc < 18.5){
                console.log('Abaixo do Peso Normal, seu IMC é :' + imc);
            } else if (imc >= 18.5 && imc <= 24.9) {
                console.log('Normal, seu IMC é :' + imc);
            } else if (imc >= 24.9 && imc <= 30){
                console.log('Sobrepeso, seu imc é :' + imc);
            } else {
                console.log('Obesidade,  seu imc é :' + imc);
            }           
           readline.close();   
        });
      });
    });    
}
main();