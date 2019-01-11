## - ![#f03c15](IMPORTANT): This project can only be compiled & run in Java 8 currently.

# About

This project contains sources to give code examples how to use ChemAxon [JChem Base](https://chemaxon.com/products/jchem-engines) to search and store molecules.

Find sources in the `src` folder. If you want to compile and test, just run `gradlew build`. For this you have to set `chemaxonUser` and `chemaxonPassword` in `gradle.properties`.

You can find the original HTML files in `html` folder. 

# Prerequisites

Copy all requested license (provided to you by your sales contact) to `cxn_home` folder in this project and name the file as `license.cxl`.  

# Running an example

To try out the examples you must set your access in gradle properties as described above and must copy the corresponding license to `cxn_home˛` folder.

* On linux type `./gradlew <task_name>`
* On windows type `gradlew <task_name>`

the exmaple tasks are the followings: 
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
