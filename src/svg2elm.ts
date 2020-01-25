const { Elm } = require("./Main.elm");
const fs = require("fs");
const path = require("path");

const app = Elm.Main.init({
    flags: { argv: process.argv, versionMessage: "0.1.0" }
});

app.ports.print.subscribe((message: string) => console.log(message));
app.ports.printAndExitFailure.subscribe((message: string) => {
    console.log(message);
    process.exit(1);
});

app.ports.printAndExitSuccess.subscribe((message: string) => {
    console.log(message);
    process.exit(0);
});

app.ports.readFiles.subscribe((paths: string[]) => {
    app.ports.filesRead.send(
        paths.map(p => [
            path.basename(p).split(".")[0],
            fs.readFileSync(p).toString()
        ])
    );
});
