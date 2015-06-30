![Gilt Tech logo](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/gilt-tech-logo.png)

# Boilerplate template processor

Boilerplate is a command-line template processor for Mac OS X.

Boilerplate utilizes the expression engine provided by [the Mockingbird Data Environment](https://github.com/emaloney/MBDataEnvironment#mockingbird-data-environment) to perform string replacement and transformation on text documents.

## How it works

Boilerplate accepts a *template document* and an optional *data set* as input.

The data set—if it is provided—is loaded into the Mockingbird Data Environment before the template is processed. This allows the data to be referenced from within the template using [Mockingbird expressions](https://github.com/emaloney/MBDataEnvironment#an-introduction-to-mockingbird-expressions).

The template is then scanned for any Mockingbird expressions that it might contain. Each expression encountered in the template is then *evaluated*, yielding a *resulting value*.

Lastly, Boilerplate replaces each expression in the template with the value the expression yields, and outputs the final result, the *output document*.

## Usage

> **Note:** Boilerplate is invoked using the Terminal application. This documentation assumes some familiarity with the Terminal and the `bash` shell.

Assuming the binary is reachable from your shell’s `$PATH`, Boilerplate is invoked with the command:

```bash
boiler
```

By default, `boiler` accepts the template document from `stdin` and writes the output to `stdout`.

### Invoking without a data set

A data set does not need to be provided to use `boiler`. The Mockingbird Data Environment provides a number of [*functions*](https://github.com/emaloney/MBDataEnvironment/blob/master/README.md#mbml-functions) that you can invoke from within a template.

For example, you might just want to use `boiler` to embed a timestamp in a document. You could use [the `^currentTime()` function](https://rawgit.com/emaloney/MBDataEnvironment/master/Documentation/html/Classes/MBMLDateFunctions.html#//api/name/currentTime) for this.

To see what the output of `^currentTime()` would look like in your template document, you can get a preview from the command line:

```bash
echo "^currentTime()" | boiler
```

This command would yield output similar to:

```
2015-06-30 16:44:36 +0000
```

Because the Mockingbird Data Environment is built upon standard Cocoa types, the result of the `^currentTime()` expression is actually an `NSDate` under the hood.

When a native Cocoa object is the result of an expression in the template document, it is first converted into text—an `NSString` instance—by calling the `description` method.

Before the `NSDate` is converted into a string, we can pass it to a function that applies an `NSDateFormatterStyle` to return a locale-appropriate format.

The [`^formatLongDateTime()`](https://rawgit.com/emaloney/MBDataEnvironment/master/Documentation/html/Classes/MBMLDateFunctions.html#//api/name/formatLongDateTime:) function accepts an `NSDate` and returns a formatted string using the `NSDateFormatterLongStyle`:

```bash
echo "^formatLongDateTime(^currentTime())" | boiler
```

For someone in New York City, this command would yield output similar to:

```
June 30, 2015 at 12:44:36 PM EDT
```

And, of course, what would any date formatting tool be without the ability to specify custom formats? The `^formatDate()` function handles this:

```bash
echo "^formatDate(^currentTime()|yyyy-MM-dd)" | boiler
```

The command above would yield output like:

```
2015-06-30
```

That’s just the tip of the iceberg. The Mockingbird Data Environment provides over 170 functions usable on Mac OS X.

### Invoking with a data set

The data set, if it is provided, must be in the form of [an XML variant called MBML](https://github.com/emaloney/MBDataEnvironment#the-structure-of-an-mbml-file).

Assume the following MBML code exists in a file named “`shipping.xml`”:

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
echo "\$recipient.name.first \$recipient.name.last\n\$recipient.street\n\$recipient.city \$recipient.state \$recipient.zip" | boiler -d shipping.xml
```

This would yield the output:

```
J. Wellis
201 South 2nd Street
Lewisburg PA 17837
```

> **Note:** The `$` characters are escaped in the command above with a backslash (`\`) to ensure that they are passed as-is to the `boiler` command; otherwise, the `$` would be intereted by the shell *before* being passed to `boiler`. You will not need to escape the input document in this way if you are not specifying it directly in the shell.

#### Specifying a template file

The template document can be stored in a file, which makes it easier to perform repeated operations and lets you avoid needing to escape certain characters as you would in the shell.

A template file is simply a text document contains Mockingbird expressions embedded within it. By convention, template filenames adopt the `.boilerplate` extension. Further, if the output of the `boiler` command is a file, it is customary to name the template file the same as the output file, but with `.boilerplate` added to the end.

For example, let’s say we’ve got a template file called `address.txt.boilerplate` that looks like:

```text
$recipient.name.first $recipient.name.last
$recipient.street
$recipient.city $recipient.state $recipient.zip
```

Running the following command:

```bash
boiler -d shipping.xml -t address.txt.boilerplate
```

yields the result:

```
J. Wellis
201 South 2nd Street
Lewisburg PA 17837
```

#### Specifying an output file

Instead of writing output to `stdout`, you can also direct output to a file:

```bash
boiler -d shipping.xml -t address.txt.boilerplate -o address.txt
```

This would create a file called `address.txt` containing:

```
J. Wellis
201 South 2nd Street
Lewisburg PA 17837
```
