#!/usr/bin/env bash

# File Docstring
# HyprStable || build.sh
# ------------------------
# Allows for the building/updating of Hyprland
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

	# Create build directory
	mkdir ./build
}

function _installer_install_dependencies() {
	# Install dependencies from Debian package repository
	sudo apt-get install $(awk '{print $1}' ./resources/dependencies.txt) --assume-yes --verbose-versions --show-progress

	# Git clone additional dependencies
	git clone https://gitlab.freedesktop.org/emersion/libdisplay-info.git ./build/libdisplay-info
	git clone --recursive https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git ./build/libxcb-errors
}

function _installer_build_clone_packages() {
	# Switch to build directory
	cd ./build

	# Switch to libdisplay-info directory
	cd ./libdisplay-info
	
	# Set-up build
	meson setup build/
	# Build
	ninja -C build/ install

	# Go up a directory
	cd ..

	# Clean up
	rm --recursive --force ./libdisplay-info

	# Switch to libxcb-errors directory
	cd ./libxcb-errors

	# Update build info
	autoupdate
	# Set-up build (Has to be ran twice because of black magic or something)
	autoreconf --install --verbose --force
	autoreconf --install --verbose --force
	# Configure the build
	./configure --disable-silent-rules
	# Build
	make install
	# Sanity check
	make check

	# Go up a directory
	cd ..

	# Clean up
	rm --recursive --force ./libxcb-errors

	# Leave build directory
	cd ..
}

# Executer
main