# Bicep Docs Demo

This repository demonstrates the experimental `bicep docs generate` command. It reads a Bicep module and writes a `README.md` next to it that describes the module's resources, parameters, outputs and usage examples, so the documentation always matches the code.

The demos start with Bicep's built-in layout and then build up to your own templates, written in [Scriban](https://github.com/scriban/scriban), a text templating language. The final demo produces full [Azure Verified Modules](https://aka.ms/avm) (AVM) documentation for 20 real modules.

Run every command from the root of this repository, because Bicep looks up the module and inputs files relative to the folder you run the command in. The template isn't passed on the command line. Instead, Bicep reads it from the `bicepconfig.json` settings file nearest to the module, and finds the template relative to the folder that file is in. Each demo has its own folder, with its own copy of the module, because the nearest `bicepconfig.json` decides which template a module uses. The commands were tested with Bicep CLI 0.47.16. Because the command is experimental, Bicep prints a warning each time you run it. Generated `README.md` and `module.json` files are ignored by Git, so you can run the demos as often as you like.

## Create a readme for a single module

Generates documentation for the storage account module in [demo01/module](./demo01/module) using Bicep's built-in layout, because `demo01` has no `bicepconfig.json`. No template is needed: Bicep lists the resource types, parameters (including allowed values, defaults and length limits), exported types and outputs. It also picks up the usage example in the module's `examples` folder automatically.

```pwsh
bicep docs generate `
    ./demo01/module/main.bicep
```

## Use a custom template file

Generates documentation for the same module, copied into [demo02/module](./demo02/module), but the layout comes from your own template, [demo02.scriban](./demo02/demo02.scriban). The template chooses which information to show and how: here, a parameters table, an outputs table and the usage examples. The [bicepconfig.json](./demo02/bicepconfig.json) file in `demo02` tells Bicep to use this template, so the command only needs the module path.

```pwsh
bicep docs generate `
    ./demo02/module/main.bicep
```

## Use a custom inputs file

Adds information that isn't in the Bicep code. The [demo03.scriban](./demo03/demo03.scriban) template, chosen by [bicepconfig.json](./demo03/bicepconfig.json), shows values passed in two ways: `demo01` and `demo02` come from the command line and produce "Hello World!", while the owner, support link and version come from [demo-inputs.json](./demo03/demo-inputs.json). Unlike the template, these values can't be set in `bicepconfig.json`, so they're always passed on the command line. If the same value is supplied more than once, the last one on the command line wins.

```pwsh
bicep docs generate `
    ./demo03/module/main.bicep `
    --custom-template-value "demo01=Hello" `
    --custom-template-value "demo02=World" `
    --custom-template-value-file-path ./demo03/demo-inputs.json
```

## Use a custom template for a format other than markdown - JSON example

Templates aren't limited to markdown: Scriban writes whatever text the template contains. The [demo04.scriban](./demo04/demo04.scriban) template, chosen by [bicepconfig.json](./demo04/bicepconfig.json), produces a JSON description of the same module, including the custom values from the previous demo. That makes the output easy to feed into other tools, such as a module catalogue or a website. Each value goes through Scriban's `object.to_json` function, which handles quotes, escaping and `null` so the result is always valid JSON. That function writes some characters as codes, for example `'` as `\u0027`; this is still valid JSON, and any JSON reader turns it back into `'`.

The inputs file is this demo's own copy of [demo-inputs.json](./demo04/demo-inputs.json), so the folder has everything it needs. The output is saved as `module.json` with `--outfile`, because the default file name is `README.md`. `--outfile` only works with a single module, so this command passes the file directly instead of using `--pattern`.

```pwsh
bicep docs generate `
    ./demo04/module/main.bicep `
    --custom-template-value "demo01=Hello" `
    --custom-template-value "demo02=World" `
    --custom-template-value-file-path ./demo04/demo-inputs.json `
    --outfile ./demo04/module/module.json
```

To show that the output is real JSON, load it into PowerShell and list the parameters:

```pwsh
(Get-Content ./demo04/module/module.json -Raw | ConvertFrom-Json).parameters | Format-Table name, type, required, defaultValue
```

## Use a complex custom template file with multiple modules - AVM example

Generates AVM-style documentation for all 20 App Service modules in [demo05/avm](./demo05/avm) with a single command. The [avm.scriban](./demo05/avm.scriban) template works out everything a module's page needs from the module itself: the module's registry path (such as `br/public:avm/res/web/site:<version>`) comes from its folder, and its main resource type is picked from the resources it deploys. No inputs are needed. The nearby [bicepconfig.json](./demo05/bicepconfig.json) settings file picks this template for all 20 modules, and also holds AVM's standard rules for moving scope-specific usage examples from a parent module to its child modules.

```pwsh
bicep docs generate `
    --pattern ./demo05/avm/**/main.bicep
```

## Clean up

Deletes every file the demos generate, so you can run them again from a clean state: the `README.md` files written by the `demo01`, `demo02` and `demo03` demos, the `module.json` written by the `demo04` demo, and the 20 `README.md` files written by the AVM demo in `demo05`. It doesn't touch this `README.md` or any source files, and it's safe to run even if some demos haven't been run.

```pwsh
Remove-Item ./demo01/module/README.md, ./demo02/module/README.md, ./demo03/module/README.md, ./demo04/module/module.json -ErrorAction SilentlyContinue
Get-ChildItem ./demo05/avm -Filter README.md -Recurse | Remove-Item
```
