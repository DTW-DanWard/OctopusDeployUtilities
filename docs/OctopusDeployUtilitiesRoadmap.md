# Octopus Deploy Utilities Road Map

A Brief Road Map of Upcoming Enhancements


## Search Variable Utility

Add function to search across all variables (project and included library variable sets) matching partial variable name and/or value.  Also search across code files.


## Purge Duplicate Exports

Once you automate exports they can pile up.  If no changes exist between two exports the second export is unnecessary.  Add function to programmatically compare/delete identical exports.

## Add Custom Types to Objects and Provide Console Output Formatting

Add type names (ODU.<FolderName>, etc.) to export in oduobject processing.  Will allow for better filtering/processing and console output (PS1XML) formatting.


## Compare Releases

Function to export/compare two releases for a particular project to identify differences.


## Support for Multiple Server Configurations in Config System

Current config system only supports one server configuration.  Supporting multiple configurations allows you to exports from multiple servers and/or have different configurations for a single instance (export different sets of types - full export vs. partial export).


## Search Code Configuration Files Along with Octopus Deploy Configuration in oduvar

Search code configuration files (web.config, etc.) *along* with variables in Octopus Deploy configuration when using oduvar.


## Docker Container

Provide Octopus Deploy Utilities in Docker container for easier setup and use.
