# Bicep Docs Demo

This repository demonstrates the experimental `bicep docs generate` command. It reads a Bicep module and writes a `README.md` next to it that describes the module's resources, parameters, outputs and usage examples, so the documentation always matches the code.

The demos start with Bicep's built-in layout and then build up to your own templates, written in [Scriban](https://github.com/scriban/scriban), a text templating language. The final demo produces full [Azure Verified Modules](https://aka.ms/avm) (AVM) documentation for 20 real modules.

Run every command from the root of this repository, because Bicep looks up the template and inputs files relative to the folder you run the command in. The commands were tested with Bicep CLI 0.47.16. Because the command is experimental, Bicep prints a warning each time you run it. Generated `README.md` and `module.json` files are ignored by Git, so you can run the demos as often as you like.

## Create a readme for a single module

Generates documentation for the storage account module in [demo01/module](./demo01/module) using Bicep's built-in layout. No template is needed: Bicep lists the resource types, parameters (including allowed values, defaults and length limits), exported types and outputs. It also picks up the usage example in the module's `examples` folder automatically.

```pwsh
bicep docs generate `
    ./demo01/module/main.bicep
```

## Use a custom template file

Generates documentation for the same module, but the layout comes from your own template, [demo01.scriban](./demo01/demo01.scriban). The template chooses which information to show and how: here, a parameters table, an outputs table and the usage examples.

```pwsh
bicep docs generate `
    ./demo01/module/main.bicep `
    --template-file ./demo01/demo01.scriban
```

## Use a custom inputs file

Adds information that isn't in the Bicep code. The [demo02.scriban](./demo01/demo02.scriban) template shows values passed in two ways: `demo01` and `demo02` come from the command line and produce "Hello World!", while the owner, support link and version come from [demo-inputs.json](./demo01/demo-inputs.json). If the same value is supplied more than once, the last one on the command line wins.

```pwsh
bicep docs generate `
    ./demo01/module/main.bicep `
    --template-file ./demo01/demo02.scriban `
    --custom-template-value "demo01=Hello" `
    --custom-template-value "demo02=World" `
    --custom-template-value-file-path ./demo01/demo-inputs.json
```

## Use a custom template for a format other than markdown - JSON example

Templates aren't limited to markdown: Scriban writes whatever text the template contains. The [demo03.scriban](./demo01/demo03.scriban) template produces a JSON description of the same module, including the custom values from the previous demo. That makes the output easy to feed into other tools, such as a module catalogue or a website. Each value goes through Scriban's `object.to_json` function, which handles quotes, escaping and `null` so the result is always valid JSON. That function writes some characters as codes, for example `'` as `\u0027`; this is still valid JSON, and any JSON reader turns it back into `'`.

The output is saved as `module.json` with `--outfile`, because the default file name is `README.md`. `--outfile` only works with a single module, so this command passes the file directly instead of using `--pattern`.

```pwsh
bicep docs generate `
    ./demo01/module/main.bicep `
    --template-file ./demo01/demo03.scriban `
    --custom-template-value "demo01=Hello" `
    --custom-template-value "demo02=World" `
    --custom-template-value-file-path ./demo01/demo-inputs.json `
    --outfile ./demo01/module/module.json
```

To show that the output is real JSON, load it into PowerShell and list the parameters:

```pwsh
(Get-Content ./demo01/module/module.json -Raw | ConvertFrom-Json).parameters | Format-Table name, type, required, defaultValue
```

## Use a complex custom template file with multiple modules - AVM example

Generates AVM-style documentation for all 20 App Service modules in [demo02/avm](./demo02/avm) with a single command. The [avm.scriban](./demo02/avm.scriban) template works out everything a module's page needs from the module itself: the module's registry path (such as `br/public:avm/res/web/site:<version>`) comes from its folder, and its main resource type is picked from the resources it deploys. No inputs are needed. The nearby [bicepconfig.json](./demo02/bicepconfig.json) settings file holds AVM's standard rules for moving scope-specific usage examples from a parent module to its child modules.

```pwsh
bicep docs generate `
    --pattern ./demo02/avm/**/main.bicep `
    --template-file ./demo02/avm.scriban
```

## Clean up

Deletes every file the demos generate, so you can run them again from a clean state: the `README.md` and `module.json` written by the `demo01` demos, and the 20 `README.md` files written by the AVM demo. It doesn't touch this `README.md` or any source files, and it's safe to run even if some demos haven't been run.

```pwsh
Remove-Item ./demo01/module/README.md, ./demo01/module/module.json -ErrorAction SilentlyContinue
Get-ChildItem ./demo02/avm -Filter README.md -Recurse | Remove-Item
```