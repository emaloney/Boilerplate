![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# Mockingbird Template Processor

The Mockingbird Template Processor is a command-line utility for Mac OS X that utilizes the expression engine provided by [the Mockingbird Data Environment](https://github.com/emaloney/MBDataEnvironment#mockingbird-data-environment) to perform string replacement and transformation on text documents.

## How it works

The Mockingbird Template Processor accepts an *input document* and an optional *external data set* as input.

The data set—if it is provided—is loaded into the Mockingbird Data Environment before the input document is processed. This allows the data to be referenced from within the input document using [Mockingbird expressions](https://github.com/emaloney/MBDataEnvironment#an-introduction-to-mockingbird-expressions).

The text document is then scanned for any expressions that it might contain. Each expression encountered in the document is then *evaluated*, yielding a *resulting value*.

The output of the Mockingbird Template Processor is the result of replacing the Mockingbird expressions contained in the input document with the results of evaluating those expressions.

## Usage

To invoke the Mockingbird Template Processor, use the Terminal application to execute the command:

```bash
mbtp
```

By default, `mbtp` accepts the input document from `stdin` and writes the output to `stdout`.

#### Invoking without external data

An external data set does not need to be provided to use `mbtp`. For example, you could execute the following command to print the current time:

```bash
printf "^currentTime()" | mbtp
```

This command would yield output similar to:

```
2015-06-26 15:01:51 +0000
```

#### Invoking with external data

The external data set, if it is provided, must be in the form of [an XML variant called MBML](https://github.com/emaloney/MBDataEnvironment#the-structure-of-an-mbml-file).

Assume the following MBML code exists in a file named "`shipping.xml`":

```xml
<MBML>
    <Var name="recipient" type="map">
        <Var name="name" type="map">
            <Var name="first" value="J."/>
            <Var name="middle" value="Herbington"/>
            <Var name="last" value="Wellis"/>
        </Var>
        <Var name="street" value="201 South 2nd Street"/>
        <Var name="city" value="Lewisburg"/>
        <Var name="state" value="PA"/>
        <Var name="zip" value="17837"/>
    </Var>
</MBML>
```

Typically, you specify external data by providing a file path to the `--data` (or `-d`) argument:

```bash
printf "\$recipient.name.first \$recipient.name.last\n\$recipient.street\n\$recipient.city \$recipient.state \$recipient.zip" | mbtp -d shipping.xml
```

This would yield the output:

```
J. Wellis
201 South 2nd Street
Lewisburg PA 17837
```

> **Note:** The `$` characters are escaped in the command above with a backslash (`\`) to ensure that they are passed as-is to the `mbtp` command; otherwise, the `$` would be intereted by the shell *before* being passed to `mbtp`. You will not need to escape the input document in this way if you are not specifying it directly in the shell.
