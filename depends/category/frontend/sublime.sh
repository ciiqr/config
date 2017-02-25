#!/usr/bin/env bash

# TODO: Might want to move these functions to somewhere more common...
join_by()
{
	local d=$1
	shift
	echo -n "$1"
	shift
	printf "%s" "${@/#/$d}"
}

json_string_array()
{
	declare -a arr=("$@")
	if [ ${#arr[@]} -eq 0 ]; then
		echo '[]'
	else
		echo '["'`join_by '","' "${arr[@]}"`'"]'
	fi
}
escape_for_sed()
{
	sed -e 's@/@\\\/@g'
}

# TODO: Add windows support also... (whenever I need it next)
case "$HOST_OS" in
	osx)
		sublime_path="$destination/Library/Application Support/Sublime Text 3"
		;;
	linux)
		sublime_path="$destination/.config/sublime-text-3"
		;;
	*)
		echo $0: Unrecognized os $HOST_OS, we do not know where to look for sublime configs...
		exit 1
		;;
esac

# Make directories
$DEBUG mkdir -p "$sublime_path"/{Installed\ Packages,Packages/User}

# Download Package Control
$DEBUG wget -O "$sublime_path/Installed Packages/Package Control.sublime-package" http://packagecontrol.io/Package%20Control.sublime-package

# Create temp dir
sublime_temp_dir="$temp_dir/$category/sublime"
$DEBUG mkdir -p "$sublime_temp_dir"

declare -a packages
packages=(
	'Package Control'

	'Theme - SoDaReloaded'

	'MoveTab'
	'Case Conversion'
	'SortBy'
	'TrailingSpaces'
	'Normalize Indentation'

	'Delete Current File'
	'Quick File Move'
	'Terminal'
	'Superlime'

	'Fold Comments'

	'ApacheConf.tmLanguage'
	'Handlebars'
	'INI'
	'Smarty'
	'C++11'
	'Hjson'
	'HOCON Syntax Highlighting'
	'IDL-Syntax'
	'plist'
	'Sass'
	'SCSS'
	'Swift'
)

declare -a repositories
repositories=(
	# 'https://github.com/n1k0/SublimeHighlight/tree/python3'
)

# TODO: Go through packages I've previously had installed...
# CSS Colors
# FuzzyFileNav
# FuzzyFilePath
# PackageResourceViewer
# PHPIntel
# PHPUnit Completions
# RawLineEdit
# Statusbar Path
# SublimeTmpl
# WhoCalled Function Finder
# All Autocomplete
# BeautifyRuby
# Better CoffeeScript
# Bison
# BufferScroll
# C++ Snippets
# ClangAutoComplete
# CMakeEditor
# CMakeSnippets
# CoffeeComplete Plus (Autocompletion)
# Color Highlighter
# CSS Format
# Default File Type
# Dotfiles Syntax Highlighting
# Gist
# Gradle_Language
# HexViewer
# Highlight
# HTML-CSS-JS Prettify
# HTMLBeautify
# Javascript Beautify
# JavaScript Snippets
# Jinja2
# NimLime
# Number King
# Package Syncing
# PackageDev
# PKGBUILD
# Plist Binary
# Processing
# Project Port
# Python Breakpoints
# QMakeProject
# SASS Build
# SCSS Snippets
# SideBarEnhancements
# SublimeAStyleFormatter
# SublimeCodeIntel
# SublimeGDB
# SublimeHighlight

# SublimeOnSaveBuild
# SwiftKitten
# SyntaxFold
# Text Pastry
# URLEncode
# W3CValidators
# WordCount
# EJS
# ShowEncoding
# EncodingHelper
# JSX

# # Probably not...
# LiveStyle

# # Only if I end up needing
# SublimeLinter-coffee
# SublimeLinter-contrib-clang
# SublimeLinter-html-tidy
# SublimeLinter-jsl
# SublimeLinter-lua
# SublimeLinter-php
# SublimeLinter-pylint

# # These were disabled anyways, so we almost certainly don't need them
# ActionScript
# AppleScript
# ASP
# Batch File
# BeautifyRuby
# CTags
# HexViewer
# IDL-Syntax
# Javascript Beautify
# Number King
# Processing
# Project Port
# SublimeAStyleFormatter
# SublimeCodeIntel
# SublimeGDB
# SublimeOnSaveBuild

# Generate Package Control config
packages_json_string="`json_string_array "${packages[@]}" | escape_for_sed`"
repositories_json_string="`json_string_array "${repositories[@]}" | escape_for_sed`"

$DEBUG $file_transfer_command "$script_directory/depends/category/$category/sublime.gen/Package Control.sublime-settings" "$sublime_temp_dir/Package Control.sublime-settings"
$DEBUG sed -i 's/REPLACE_PACKAGES/'"$packages_json_string"'/;s/REPLACE_REPOSITORIES/'"$repositories_json_string"'/' "$sublime_temp_dir/Package Control.sublime-settings"

# Generate Preferences config
if contains_option hidpi "${categories[@]}"; then
	DPI_SCALE=2
else
	DPI_SCALE=1
fi

$DEBUG $file_transfer_command "$script_directory/depends/category/$category/sublime.gen/Preferences.sublime-settings" "$sublime_temp_dir/Preferences.sublime-settings"
$DEBUG sed -i 's/REPLACE_DPI_SCALE/'"$DPI_SCALE"'/' "$sublime_temp_dir/Preferences.sublime-settings"

# Transfer all configs
transfer "$sublime_temp_dir" "$sublime_path/Packages/User" "$backup"
transfer "$script_directory/depends/category/$category/sublime" "$sublime_path/Packages/User" "$backup"
