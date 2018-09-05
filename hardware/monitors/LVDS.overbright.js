let xrandrParse = require('xrandr-parse');

const { spawn } = require('child_process');
const xrandr = spawn('xrandr', ['--verbose']);

let output = "";

xrandr.stdout.on('data', (data) => {
  output += data;
  console.log(`stdout: ${data}`);
});

xrandr.stderr.on('data', (data) => {
  console.log(`stderr: ${data}`);
});

xrandr.on('close', (code) => {
  console.log(`child process exited with code ${code}`);

  outputDict = xrandrParse(output);
    console.log(outputDict);
});




// var exec = require('child_process').exec;

// exec('xrandr --verbose', function (err, stdout) {
//     var query = parse(stdout);
//     console.log(JSON.stringify(query, null, 2));
// });

