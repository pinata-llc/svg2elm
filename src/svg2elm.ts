import path from "path";
import fs from "fs";

const { Elm } = require("./Main.elm");

type Ok = { type: "Ok"; elm: string };
type Err = { type: "Err"; error: string };
type Result = Ok | Err;

/**
 * Generates an Elm function from an SVG.
 *
 * @param name - The name of the Elm function to generate. This name will be camelCased.
 * @param code - The source code of the SVG file
 */
export function generateSvgFunction(
    name: string,
    code: string
): Promise<string> {
    return new Promise((resolve, reject) => {
        const app = Elm.Main.init({ flags: { name, code } });

        app.ports.compiled.subscribe((result: Result) => {
            if (result.type === "Ok") {
                resolve(result.elm);
            } else {
                reject(result.error);
            }
        });
    });
}

/**
 * Given a module name, generates the module declaration and required imports.
 *
 * @param moduleName - The name of the Elm module to generate.
 */
export function generateModuleHeader(moduleName: string) {
    return `module ${moduleName} exposing (..)

import Svg
import VirtualDom exposing (Attribute, attribute)
`;
}

/**
 * Generates an Elm Module with a function per SVG file.
 *
 * @param moduleName - The name of the Elm module to generate.
 * @param filePaths - An array of file paths to SVG files
 */
export async function generateModule(
    moduleName: string,
    filePaths: string[]
): Promise<string> {
    const functions = await Promise.all(
        filePaths.map(async filePath => {
            const basename = path.basename(filePath, ".svg");
            const content = await fs.promises.readFile(filePath);

            return generateSvgFunction(basename, content.toString());
        })
    );

    const header = generateModuleHeader(moduleName);

    return `${header}\n\n${functions.join("\n\n")}`;
}
