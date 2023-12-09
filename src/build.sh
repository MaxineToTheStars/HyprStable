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
	
	# Build and install cloned packages
	_installer_build_and_install_cloned_packages
	
	# Download and install Hyprland
	_installer_download_and_install_hyprland
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
	
	# Git clone additional dependencies to ./build directory
	git clone https://gitlab.freedesktop.org/emersion/libdisplay-info.git ./build/libdisplay-info
	git clone --recursive https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git ./build/libxcb-errors
}

function _installer_build_and_install_cloned_packages() {
	# Switch to build directory
	cd ./build
	
	# <-- libdisplay-info -->
	# Switch to libdisplay-info directory
	cd ./libdisplay-info
	
	# Set-up build directory
	meson setup ./build
	
	# Build library
	ninja -C ./build
	
	# Install library
	sudo ninja -C ./build install
	
	# Go up a directory
	cd ..
	
	# Clean up
	rm --recursive --force ./libdisplay-info
	
	
	# <-- libxcb-errors -->
	# Switch to libxcb-errors directory
	cd ./libxcb-errors
	
	# Update build info
	autoupdate
	
	# Set-up build (Has to be ran twice because of black magic or something)
	autoreconf --install --verbose --force
	autoreconf --install --verbose --force
	
	# Configure the build
	./configure --disable-silent-rules
	
	# Build library
	make all
	
	# Install library
	sudo make install
	
	# Go up a directory
	cd ..
	
	# Clean up
	rm --recursive --force ./libxcb-errors
	
	# Leave build directory
	cd ..
}

function _installer_download_and_install_hyprland() {
	# Git clone the repository to ./build directory
	git clone --recursive https://github.com/hyprwm/Hyprland -b v0.33.1 ./build/Hyprland
	
	# Switch to the ./build/Hyprland directory
	cd ./build/Hyprland
	
	# Build Hyprland
	make all
	
	# Install Hyprland
	sudo make install
}

# Executer
main