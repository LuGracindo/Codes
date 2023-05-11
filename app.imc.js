function main() {
    const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
    });

    let peso = 0;
    let altura = 0;

    readline.question('Digite o peso:\n\n', function (userInput) {
        peso = userInput;
        
        readline.question('Digite o altura:\n\n', function (userInput) {
            altura = userInput;

            const imc = calcularImc(peso, altura);
            const label = labelImc(imc);
            console.log(`altura[${altura}], peso[${peso}] ... IMC: [${imc}/${label}]`);
            readline.close();
        });
    });    
}

// Este código se propõe a validar o comportamento central do app 
// em relacao aos cálculos e traduções
function sanityCheck() {
    console.log("================================");
    console.log("start running sanity check...");
    const scenarios = {
        "Magreza": {
            "altura": 1.70,
            "peso": 50.0,
            "imc": 17.30
        },
        "Normal": {
            "altura": 1.70,
            "peso": 70.0,
            "imc": 24.22
        },
        "Sobrepeso": {
            "altura": 1.70,
            "peso": 75.0,
            "imc": 25.95
        },
        "Obesidade": {
            "altura": 1.70,
            "peso": 90.0,
            "imc": 31.14
        }
    }

    Object.keys(scenarios).forEach(function (key) {
        const imc = calcularImc(scenarios[key]["peso"], scenarios[key]["altura"]);
        const label = labelImc(imc);

        if (imc === scenarios[key]["imc"]) console.log(key + " imc: ok");
        if (label === key) console.log(key + " label: ok");
    });

    console.log("finish running sanity check...");
    console.log("================================");
}

// Traduz um valor de IMC em texto conforme a regra abaixo:
// Magreza, quando o resultado é menor que 18, 5 kg / m2;
// Normal, quando o resultado está entre 18, 5 e 24, 9 kg / m2;
// Sobrepeso, quando o resultado está entre 24, 9 e 30 kg / m2;
// Obesidade, quando o resultado é maior que 30 kg / m2;
function labelImc(imc) {
    if (isNaN(imc)) return;
    if (imc < 18.5) return "Magreza";
    if (imc < 24.9) return "Normal";
    if (imc < 30.0) return "Sobrepeso";
    return "Obesidade";
}

// calcula o índice de massa corporal, conforme fórmula clássica
// Obs: cálculo sempre realizado truncando resultado em duas casa decimais
// IMC = Peso / Altura²
function calcularImc(peso, altura) {
    return Number((peso / altura ** 2).toFixed(2));
}

sanityCheck();
main();