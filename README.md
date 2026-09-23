# Bicep Docs Demo

This repository demonstrates the experimental `bicep docs generate` command. It reads a Bicep module and writes a `README.md` next to it that describes the module's resources, parameters, outputs and usage examples, so the documentation always matches the code.

The demos start with Bicep's built-in layout and then build up to your own templates, written in [Scriban](https://github.com/scriban/scriban), a text templating language. The final demo produces full [Azure Verified Modules](https://aka.ms/avm) (AVM) documentation for 20 real modules.

Run every command from the root of this repository, because Bicep looks up the template and inputs files relative to the folder you run the command in. The commands were tested with Bicep CLI 0.47.16. Because the command is experimental, Bicep prints a warning each time you run it. Generated `README.md` files are ignored by Git, so you can run the demos as often as you like.

## Create a readme for a single module

Generates documentation for the storage account module in [demo01/module](./demo01/module) using Bicep's built-in layout. No template is needed: Bicep lists the resource types, parameters (including allowed values, defaults and length limits), exported types and outputs. It also picks up the usage example in the module's `examples` folder automatically.

```pwsh
bicep docs generate ./demo01/module/main.bicep
```

## Use a custom template file

Generates documentation for the same module, but the layout comes from your own template, [demo01.scriban](./demo01/demo01.scriban). The template chooses which information to show and how: here, a parameters table, an outputs table and the usage examples.

```pwsh
bicep docs generate `
    --pattern ./demo01/module/main.bicep `
    --template-file ./demo01/demo01.scriban
```

## Use a custom inputs file

Adds information that isn't in the Bicep code. The [demo02.scriban](./demo01/demo02.scriban) template shows values passed in two ways: `demo01` and `demo02` come from the command line and produce "Hello World!", while the owner, support link and version come from [demo-inputs.json](./demo01/demo-inputs.json). If the same value is supplied more than once, the last one on the command line wins.

```pwsh
bicep docs generate `
    --pattern ./demo01/module/main.bicep `
    --template-file ./demo01/demo02.scriban `
    --custom-template-value "demo01=Hello" `
    --custom-template-value "demo02=World" `
    --custom-template-value-file-path ./demo01/demo-inputs.json
```

## Use a complex custom template file - AVM example

Generates AVM-style documentation for all 20 App Service modules in [demo02/avm](./demo02/avm) with a single command. The [avm.scriban](./demo02/avm.scriban) template works out everything a module's page needs from the module itself: the module's registry path (such as `br/public:avm/res/web/site:<version>`) comes from its folder, and its main resource type is picked from the resources it deploys. No inputs are needed. The nearby [bicepconfig.json](./demo02/bicepconfig.json) settings file holds AVM's standard rules for moving scope-specific usage examples from a parent module to its child modules.

```pwsh
bicep docs generate `
    --pattern ./demo02/avm/**/main.bicep `
    --template-file ./demo02/avm.scriban
```
