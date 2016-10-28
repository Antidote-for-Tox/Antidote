#!/bin/sh

bundle install

git submodule update --init
bundle exec pod install
