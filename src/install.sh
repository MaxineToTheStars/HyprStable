#!/usr/bin/env bash

# File Docstring
# HyprStable || install.sh
# ------------------------
# Allows for the installation/update of Hyprland
#
# Last Updated On: 24/11/23
# Author: https://github.com/MaxineToTheStars
# ----------------------------------------------

# Constants

# Variables

# Main
function main() {
	# Configure the environment
	_configure_environment

	# Install base dependencies
	_installer_install_dependencies

	# Build cloned packages
	_installer_build_clone_packages

}

# Methods
function _configure_environment() {
	# Synchronies package list
	sudo apt-get update
	
	# Update the system
	sudo apt-get upgrade --assume-yes --verbose-versions --show-progress
}

function _installer_install_dependencies() {
	# Install dependencies from Debian package repository
	sudo apt-get install $(awk '{print $1}')

	# Git clone additional dependencies
	git clone https://gitlab.freedesktop.org/emersion/libdisplay-info.git
	git clone --recursive https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git
}

function _installer_build_clone_packages() {
	# Build libdisplay-info
	cd ./libdisplay-info
	
	# Setup build using meson
	meson setup build/
	# Build/Compile with ninja
	ninja -C build/

	# Go back one directory
	cd ..

	# Clean up
	rm --recursive --force ./libdisplay-info

	# Build libxcb-errors
	cd ./libxcb-errors

	# Build
	make

	# Go back one directory
	cd ..

	# Clean up
	rm --recursive --force ./libxcb-errors
}

# Executer
main