# Options

The options dialog can be opened from the main screen by click the `Options` button. Internally the options are stored in a `vcs-options.json` file in the path of the exported source code. These options are loaded and used when exporting to source files, or when building a project from source.

## General

![](img/options-general.jpg)

 * **Export Folder** - I like to keep this relative to the project, but it can be customized here.
    * *[Blank]* - Use default name of `/[database.accdb].src`, i.e. `/Test.accdb.src`
    * *Relative Path* - Prefix folder name with a backslash. For example, to export source into a subfolder called `Source`, you would enter `\Source` in this box.
    * *Absolute Path* - You may also use a full path name to a folder. I.e. `W:\Git\Projects\Vehicles Database`
    * *Placeholder* - In combination with the above options, you may also use a `%dbName%` [placeholder](https://github.com/joyfullservice/msaccess-vcs-integration/issues/139) to use the database filename in a custom path. I.e. `\src\%dbName%.src\`

 * **Use Fast Save** - Major performance gain with small changes to large projects. This attempts to only export the objects that have changed since the last export. This especially helps to not have to export forms and reports if they have not changed.    
 * **Show Detailed Output** - Show more verbose messages while running.
 * **Strip out Publish Option** - Strips out some *Publish to Web* settings from source files that are irrelevant to most projects.
 * **Aggressive Sanitize** - Removes object GUIDs, name maps, and other data that changes from build to build. (These values are recreated automatically when importing source files.) From a development perspective, these are more like binary artifacts that just add noise to the version control commits, reducing clarity on actual code changes.
 * **Export Theme Files** - Microsoft Access theme files (*.thmx) are actually zip files containing XML and other files that define the specifics of a theme. If you are customizing a theme, you may wish to extract these files so your changes can be tracked in Version Control.
 * **Save Report Print Settings** - Saves a copy of the print configuration for reports and forms. This is especially useful when you are using specific printer settings. The output is stored in human-readable json. By default, page orientation and paper size are saved with each report, but additional options are also available.

<details>
   <summary>Show Advanced Printer Options...</summary>

![](img/options-printer-settings.jpg)

Note that these options only determine what is *Exported* and saved to the JSON file. Any settings defined in the JSON source file will be applied when the report object is Imported, regardless of the currently specified options.

</details>

 * **Save Query SQL** - In addition to the Access object, this option exports a copy of just the SQL code from queries. I find this much more readable than the source of the Access Object when reviewing what I actually changed on the SQL side. (The Access object includes other information relating to the layout of the query designer.)
 * **Save Table SQL** - In addition to the Access object, this creates a SQL statement like what you would use to create the table. Here again I find this easier to see at a glance what changed in the actual structure of the table between versions.
 
 * **Use git integration** - (Work in Progress, only part of dev at the moment).

 * **Show Legacy Prompts** - If you have the integrated VCS as part of your Access Project, the Addin will remind you those modules aren't needed.
   * *Checked* - Prompts are on.
   * *Cleared* - Prompts are off. 

* **Security** - Define the security level you would like to use for potentially sensitive information like file paths, user or domain name.
   * *None* - (Default) Just export everything like it is stored in the database.
   * *Encrypt* - Use a basic encryption to mask sensitive data.
   * *Remove* - Remove the sensitive data from the export files. (Note that you may not be able to successfully build from source if you choose this option.)
 * **Run Sub Before Export** - Run a VBA subroutine before exporting the source code. This can be used to clean up temporary data, mask sensitive information, or anything else you want to do. This will be called using  `Application.Run`.
 * **Run Sub After Export** - Similar to the option above, this allows you to specify a VBA subroutine to run *after* exporting the source code.

## Table Data

![](img/options-table-data.jpg)

The Table Data tab allows you to selectively include certain tables from which to include table ***data*** in version control. The *structure* of the tables is already being saved, but this gives you the additional option of saving the *data* itself.

An example of where you might use this would be a table that defines options or settings in your database application. You might want to track when these settings change. Another example would be a `USysRibbons` table that defines the layout of a custom application ribbon.

The concept here is that you are selecting the table from which you want to save data, choosing the format to use, and clicking Update to save the changes.

 * **Show Hidden** - List hidden tables in the current database.
  
 * **Show System** - List system tables in the current database.
  
 * **Show Other** - List table names that are saved in the options, but do not exist in the current database. You can also manually add table names to your `vcs-options.json` file. (Add a table through the interface first, and use the same syntax.)
  
 * **Selected Table** - This highlights which table you have selected to set the export format. To add a table that is not listed, click the [*Other...*]() link.
 * **Data to Export** - Select the format to use for the exported data.
   * *Tab Delimited* - Separate values with tab character. This is a good format to use when importing to Microsoft Excel, or reading the values in Version Control files.
   * *XML Format* - Select this option for the most complete and robust representation of the data. It is harder to read in source files, but should import back in to accurate recreate the original data.
   * *No Data* - Don't save data for this table.

 * **Update** - Save output specification changes for the selected table. You should see the Save Data column update in the list of tables when you click the Update button.

## Build

![](img/options-build.jpg)

One of the unique features of this add-in is the ability to build a fully functioning database completely from source files. This allows multi-user development in a more typical development workflow where source files are exported and combined to build the end product.

 * **Force import of original SQL for queries** - In some cases, such as when a query contains a subquery, _AND_ has been modified in the visual query designer, it may be imported incorrectly and unable to run. For these cases we have added an option to overwrite the .SQL property with the SQL that we saved separately during the export. See [issue #76](https://github.com/joyfullservice/msaccess-vcs-integration/issues/76) for further details.
 * **Run Sub After Build** - Run the specified subroutine after building the project from source files. This is a great way to extend the add-in to add any custom post-build functionality that you need after the build finishes. For example, you might use this to trigger an automated testing routine that verifies that the application is fully functional.


 * Save output specification changes for the selected table. You should see the Save Data column update in the list of tables when you click the Update button.

## Settings (Global)
These affect your system at large; not just the currently open Access Project.

![](img/options-settings.jpg)

 * **Save as Default** - Save the current options as default for new projects. Anytime you export source and a `vcs-options.json` file does not already exist, it will use the default options that you have specified.

 * **Restore Defaults** - In the current project (open database), restore all the options to their default values based on your saved system defaults.

 * **Clear Defaults** - Reset all the options to the default settings specified in the add-in source code. If you click this button, then the *Save as Default* button, it will reset any user customizations to the default options.

## Uninstalling
 * **Uninstall** - Uninstalls the add-in from your user profile, including all saved defaults and encryption keys.
