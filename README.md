# Bicep Docs Demo

## Create a readme for a single module

```pwsh
bicep docs generate ./demo-module/connection/main.bicep
```

## Create a readme for multiple modules

```pwsh
bicep docs generate --pattern ./demo-module/**/main.bicep
```

## Use a custom template file

```pwsh
bicep docs generate --pattern ./demo-module/**/main.bicep --template-file ./avm.scriban
```

## Supply the custom template values

```pwsh
./Generate-AvmDocs.ps1
```

## Use a custom inputs file

```pwsh
bicep docs generate --pattern ./demo-module/**/main.bicep --template-file ./avm.scriban --custom-template-value-file-path ./custom-inputs.json
```