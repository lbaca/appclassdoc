# AppClassDoc

**A package to create a Javadoc-like API documentation site for PeopleSoft Application Classes.**

## About

This Python package will use the [PeopleCode parser](https://github.com/lbaca/PeopleCodeParser) to analyze PeopleSoft Application Class source code and generate an HTML API documentation site similar to Java's Javadoc.

## Prerequisites

### Application Class Source Code

Each Application Class's source code must be exported to its own file. The files need not be organized in any particular way, but they must respect the following naming convention:

```
<ROOT_PACKAGE>[.<INNER_PACKAGE_1>[.<INNER_PACKAGE_2>]].<CLASS_NAME>.<EXTENSION>
```

For example, assume an Application Package named `ZZ_APP_PACKAGE`, with the following structure:

```
ZZ_APP_PACKAGE
├─ GUI
│  ├─ UIController
│  └─ SomeException
├─ SERVICE
│  ├─ SOAP
│  │  └─ RequestHandler
│  └─ REST
│     └─ RequestHandler
└─ Utilities
```

The five Application Classes shown in this package would need to be extracted to files named as follows (from top to bottom):

1. `ZZ_APP_PACKAGE.GUI.UIController.ppl`
1. `ZZ_APP_PACKAGE.GUI.SomeException.ppl`
1. `ZZ_APP_PACKAGE.SERVICE.SOAP.RequestHandler.ppl`
1. `ZZ_APP_PACKAGE.SERVICE.REST.RequestHandler.ppl`
1. `ZZ_APP_PACKAGE.Utilities.ppl`

In essence, the file names are fully-qualified Application Class names as would be used in a PeopleCode `import` statement, except that the colons ("`:`") are replaced by dots ("`.`"), and followed by an extension. These examples use `.ppl` as the file extension. The extension itself is not important, but one *must* be present.

The files can be all in the same directory, in separate directories, or in hierarchical subdirectories. Any disposition is acceptable as long as the file naming convention is respected.

The source code can be extracted from Application Designer project exports by means of the PSTools package (_**TODO**: Provide a link to it once it's on GitHub_).

### API Comments

Much like Javadoc, AppClassDoc parses the source code to build a model of Application Classes and present them in a navigable set of HTML pages. With no further annotation on the source code itself, this is enough to identify each constant, property, method, method argument, return type, getters, setters, and so on. However, this can be enriched by the developer by means of API comments, such as in the example below:

```java
/**
 * A model of a User Exit as configured for the current date.
 *
 * @version 1.0
 * @author Leandro Baca
 */
class UserExit
   /**
    * Initializes the user exit by loading its context and commands.
    *
    * @param &mFeature - the feature name
    * @param &mName - the name of the user exit
    * @exception MisconfigurationException - thrown if the provided feature and
    *            user exit names reference an inextant User Exit
    */
   method UserExit(&mFeature As string, &mName As string);

   /**
    * Executes the commands configured for this user exit in sequence. If a
    * CommandBreakException interrupts the sequence, the method terminates
    * gracefully and the IsBreak property is set to True.
    */
   method Execute();

   /** The feature name. */
   property string Feature readonly;

   /** The name of the user exit. */
   property string Name readonly;

   [...]
end-class; 
```

This is inspired of course from [Javadoc](https://www.oracle.com/technical-resources/articles/java/javadoc-tool.html), but also from the ["Commenting and Documenting Application Classes" section](https://docs.oracle.com/cd/F40609_01/pt859pbr1/eng/pt/tpcr/task_CommentingandDocumentingApplicationClasses-0716b8.html?pli=ul_d38e193_tpcr) in the PeopleSoft Online Help (itself, no doubt, also inspired from Javadoc).

Briefly:

* API comments start with `/**` and end with `*/`.
* They must immediately precede any of the following:
  * *In the class header:*
    * The `class` or `interface` declaration;
    * A `method`, `property`, `constant` or `instance` declaration.
  * *In the class body:*
    * A `method` definition;
    * A `get` or `set` definition.

If a method has a preceding API comment in both the header and body, the latter is used.

If a property declaration in the header includes the `get` and/or `set` keywords, and both the property declaration itself and the `get`/`set` definitions include API comments, the one in the header will be printed in the summary section, whereas the latter will be included in the respective getters/setters section.

Within an API comment:

* The initial `/**` (and all subsequent asterisks) are ignored, as well as the trailing `*/`.
* An initial `*` in every internal line is ignored.
* The first sentence (i.e., all text up to the first period followed by a space) is used as the summary.
* The entirety of the text is used as the detailed explanation.
* After all the text, optional tags preceded by "at" signs ("`@`") can be included to provide further annotation, to wit:

| Tag | Applicability | Description | Occurrence |
| :---: | :---: | :--- | :---: |
| `@version` | Class/Interface declaration | The class/interface version. | Single |
| `@author` | Class/Interface declaration | The author(s) of the class/interface. | Multiple |
| `@param` | Method declaration/definition, `set` definition | The name of the parameter and a description of its purpose. | Multiple for methods, single for setters |
| `@returns` or `@return` | Method declaration/definition, `property`/`instance`/`constant` declaration, `get` definition | A description of what is returned. | Single |
| `@exception` or `@throws` or `@throw` | Method declaration/definition, `get`/`set` definition | The type of exception and a description of the circumstances of it being thrown. | Multiple |

(If a tag does not specify that it can occur multiple times, only the last occurrence is used.)

## Installation

To install the package, run the following:

```bash
pip install appclassdoc
```

## Usage

### Command Line Interface

The package installs a console script called `appclassdoc` to serve as a CLI:

```bash
appclassdoc -h
```

The usage information is as follows:

```
usage: appclassdoc [-h] [-v] [-o OUTPUTDIR] [-p] [-n] file_or_dir [file_or_dir ...]

Generate API documentation for PeopleSoft Application Classes.

positional arguments:
  file_or_dir           one or more source files or directories to process recursively (wildcards accepted)

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbosity       increase output verbosity
  -o OUTPUTDIR, --outputdir OUTPUTDIR
                        the output directory for the generated documentation files (defaults to the current directory)
  -p, --private         include private class members in documentation
  -n, --nodelete        avoid deleting files already in the target directory
```

The `-v`/`--verbosity` switch can be specified up to three times, to increase the level of verbose logging.

If the `-p`/`--private` switch is not specified, private class members are not printed to the HTML.

When the API documentation site is first generated, a number of [resource files](https://github.com/lbaca/appclassdoc/resources) are copied into the output directory, such as CSS files and fonts. These can be customized, in which case subsequent executions of the script by means of the CLI will want to include the `-n`/`--nodelete` switch to maintain the existing versions instead of replacing them.

### Package Invocation

The package can also be invoked from a Python script, in which case the function to call will be `generate_appclassdoc`. Its arguments map to the CLI's switches and positional arguments, with the exception that only the first level of verbosity can be specified (subsequent levels can be enabled through the `logging` mechanism).

## Results

The documentation site will look like the following image:

![AppClassDoc frames](https://github.com/lbaca/appclassdoc/blob/main/docs/frames.png)

The top navigation header shows links to jump to the summary and detail sections for:

* The constructor;
* Constants;
* Properties;
* Getters;
* Setters; *and*
* Methods.

The image below shows an example of the "Property Summary" section:

![Property summary](https://github.com/lbaca/appclassdoc/blob/main/docs/summary.png)

Clicking on the links in the "Property and Description" column jumps to the respective details below on the page, as will the `get` and `set` links in the "Modifiers and Type" column. The type links in the left column (e.g., `ValueObject` and `ContextFactory` in the image) will open the page for that class.

The last image shows some of the detail sections:

![Details](https://github.com/lbaca/appclassdoc/blob/main/docs/details.png)

## Acknowledgements

AppClassDoc was intially written as part of the deliverables for my Master of Science dissertation at the University of Liverpool, titled "A Framework for Customizing ERP Systems to Increase Software Reuse and Reduce Rework When Challenged with Evolving Requirements." I mention this primarily in gratitude to my employer, who graciously waived their claim to intellectual property on my work as part of this academic pursuit.
