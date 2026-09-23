# Bicep Docs Demo

## Create a readme for a single module

```pwsh
bicep docs generate ./demo/main.bicep
```

## Use a custom template file

```pwsh
bicep docs generate `
    --pattern ./demo/module/main.bicep `
    --template-file ./demo/demo01.scriban
```

## Use a custom inputs file

```pwsh
bicep docs generate `
    --pattern ./demo/module/main.bicep `
    --template-file ./demo/demo02.scriban `
    --custom-template-value "demo01=Hello" `
    --custom-template-value "demo02=World" `
    --custom-template-value-file-path ./demo/demo-inputs.json
```

## Use a complex custom template file - AVM example

```pwsh
bicep docs generate `
    --pattern ./avm/**/main.bicep `
    --template-file ./avm.scriban
```
