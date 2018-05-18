#!/usr/bin/perl

use Storable qw(retrieve);
use YAML;

print Dump(retrieve @ARGV);
