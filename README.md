## IMPORTANT: This project can be compiled & run with Java 17 currently.

# About

This project contains sources to give code examples how to use Chemaxon [JChem Base](https://chemaxon.com/products/jchem-engines) to search and store molecules.

Find sources in the `src` folder. If you want to compile and test, just run `gradlew build`. For this you have to set `chemaxonUser` and `chemaxonPassword` in `gradle.properties`.

You can find the original HTML files in `html` folder. 

# Prerequisites

Copy all requested licenses (provided to you by your sales contact) to `cxn_home` folder in this project and name the file as `license.cxl`.

Or set up your license key as described [here](https://docs.chemaxon.com/display/docs/licensing_license-server-configuration.md).

The following licenses are needed to access all the examples:
* JChem Base
* Structure Search
* Geometry Plugin Group
* Protonation Plugin Group
* Partitioning Plugin Group

# Running an example

To try out the examples you must set your access in gradle properties as described above and must copy the corresponding license to `cxn_home˛` folder.

* On Linux, type `./gradlew <task_name>`
* On Windows, type `gradlew <task_name>`

The example tasks are the following: 
* runAsyncSearchExample
* runCalculatedColumnsSearchExample
* runChemicalTermsFilteringExample
* runDatabaseImportExample
* runDiverseSelectionExample
* runDuplicateSearchExample
* runHitColoringExample
* runMemorySearchExample
* runMultipleQueriesExample
* runPartialCleanExample
* runReactionSimilaritySearchExample
* runRetrievingDatabaseFieldsExample
* runRotateDatabaseHitsExample
* runRotateExample
* runSearchTypesExample
* runSearchWithFilterQueryExample
* runSimilaritySearchExample
* runSortedSearchExample
* runStandardizedMolSearchExample
